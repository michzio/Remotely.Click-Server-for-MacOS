//
//  StatusBarMenuController.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 16/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

class StatusBarMenuController: NSObject, ServerStatusMenuItemViewDelegate {
    
    let serverManager = ServerManager.sharedInstance;

    @IBOutlet weak var menu: NSMenu!;
    @IBOutlet weak var serverStatusMenuItem: NSMenuItem!
    @IBOutlet weak var connectingDevicesMenuItem: NSMenuItem!
    @IBOutlet weak var extraSeparator: NSMenuItem!
    
    private var connectedDeviceMenuItems = [SockFD : NSMenuItem]();
    private var connectedDevicesWindowController : NSWindowController!;
    
    override func awakeFromNib() {
        
        print("Menu created!");
        
        // assign out custom view to server status menu item in status bar menu
        let serverStatusMenuItemView
            = ServerStatusMenuItemView(frame: NSMakeRect(0, 0, 275, 50));
        serverStatusMenuItemView.serverStatus = .Down;
        serverStatusMenuItemView.delegate = self;
        serverStatusMenuItem.view = serverStatusMenuItemView;
        
        NotificationCenter.default.addObserver(self, selector: #selector(serverManagerServerStatusChanged(notification:)), name: ServerManager.ServerStatusChangedNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(serverManagerClientConnected(notification:)), name: ServerManager.ClientConnectedNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(serverManagerClientLost(notification:)), name: ServerManager.ClientLostNotification, object: nil); 
    }
    
    deinit {
        //NotificationCenter.default.removeObserver(self);
        NotificationCenter.default.removeObserver(self, name: ServerManager.ServerStatusChangedNotification, object: nil);
        NotificationCenter.default.removeObserver(self, name: ServerManager.ClientConnectedNotification, object: nil);
        NotificationCenter.default.removeObserver(self, name: ServerManager.ClientLostNotification, object: nil);
    }
    
    func serverManagerServerStatusChanged(notification : NSNotification) {
        
        let userInfo = notification.userInfo as! [String : AnyObject];
        let serverStatus = userInfo[ServerManager.ServerStatusNotificationKey] as! ServerStatus;
        
        let serverStatusMenuItemView = serverStatusMenuItem.view as! ServerStatusMenuItemView;
        serverStatusMenuItemView.serverStatus = serverStatus;
        
        if(serverStatus == .Running) {
            connectingDevicesMenuItem.isHidden = false;
            extraSeparator.isHidden = false;
        } else {
            connectingDevicesMenuItem.isHidden = true;
            extraSeparator.isHidden = true; 
        }
    }
    
    func serverManagerClientConnected(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! [String : AnyObject];
        let clientConnSock = userInfo[ServerManager.ClientConnSockNotificationKey] as! SockFD;
        let clientDeviceIdentity = userInfo[ServerManager.ClientDeviceIdentityNotificationKey] as! String;
        let clientDeviceOS = userInfo[ServerManager.ClientDeviceOSNotificationKey] as! String;
        
        print("Client device: ", clientDeviceIdentity, " running system: ", clientDeviceOS, " connected and authenticated on socket: ", clientConnSock);
        
        let connectedDeviceMenuItem : NSMenuItem = NSMenuItem(title: clientDeviceIdentity, action: nil, keyEquivalent: "");
        connectedDeviceMenuItem.isEnabled = true;
        connectedDeviceMenuItem.isHidden = false;
        if(clientDeviceOS == "Android") {
            let androidImage : NSImage = #imageLiteral(resourceName: "AndroidIcon");
            androidImage.size = NSSize(width: 20, height: 20);
            connectedDeviceMenuItem.image = androidImage;
        } else if(clientDeviceOS == "iOS") {
            let iOSImage : NSImage = #imageLiteral(resourceName: "iOSIcon");
            iOSImage.size = NSSize(width: 20, height: 20);
            connectedDeviceMenuItem.image = iOSImage;
        }
        
        connectedDeviceMenuItem.tag = Int(clientConnSock);
        connectedDeviceMenuItem.target = self;
        connectedDeviceMenuItem.action = #selector(connectedDeviceMenuItemSelected(_:));
        
        connectedDeviceMenuItems[clientConnSock] = connectedDeviceMenuItem;
        
        let indexOfConnectingDevicesMenuItem = menu.index(of: connectingDevicesMenuItem);
        menu.insertItem(connectedDeviceMenuItem, at: indexOfConnectingDevicesMenuItem+1);
        
        connectingDevicesMenuItem.isHidden = true;
    }
    
    func serverManagerClientLost(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! [String : AnyObject];
        let clientConnSock = userInfo[ServerManager.ClientConnSockNotificationKey] as! SockFD;
        
        let connectedDeviceMenuItem : NSMenuItem = connectedDeviceMenuItems[clientConnSock]!;
        
        menu.removeItem(connectedDeviceMenuItem);
        
        connectedDeviceMenuItems.removeValue(forKey: clientConnSock);
        
        if(connectedDeviceMenuItems.count == 0) {
            connectingDevicesMenuItem.isHidden = false;
        }
    }
    
    func connectedDeviceMenuItemSelected(_ menuItem : NSMenuItem) {
        
        print("Selected menu item of device with sock: ", menuItem.tag);
        
        if(connectedDevicesWindowController == nil) {
            let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main);
            connectedDevicesWindowController = storyboard.instantiateController(withIdentifier: "Connected Devices Window") as! NSWindowController;
        }
    
        connectedDevicesWindowController.showWindow(menuItem);
        
    }
    
    // MARK: ServerStatusMenuItemView delegate methods
    func shouldServerStatusChange(from fromStatus: ServerStatus, to toStatus: ServerStatus) {
        
        switch toStatus {
        case .Down:
            serverManager.securityPassword = nil;
            serverManager.customPortNumber = nil;
            break;
        case .Starting:
            if(UserDefaults.standard.bool(forKey: "shouldUseSecurityPassword")) {
                serverManager.securityPassword = UserDefaults.standard.string(forKey: "securityPassword");
            } else {
                serverManager.securityPassword = nil;
            }
            if(UserDefaults.standard.bool(forKey: "shouldUseCustomPort")) {
                serverManager.customPortNumber = Int( (UserDefaults.standard.string(forKey: "serverPortNumber") ?? "0") );
            } else {
                serverManager.customPortNumber = nil;
            }
            if(UserDefaults.standard.bool(forKey: "shouldAutoDiscoverDevices")) {
                serverManager.discoverableName = UserDefaults.standard.string(forKey: "discoverableName") ?? "";
            } else {
                serverManager.discoverableName = nil;
            }
            break;
        default:
            break;
        }
        serverManager.serverStatus = toStatus;
    }
}
