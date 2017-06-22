//
//  NetworkPreferencesViewController.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 16/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

class NetworkPreferencesViewController: NSViewController, NSTextFieldDelegate {
    
    let serverManager = ServerManager.sharedInstance;
    
    @IBOutlet weak var shouldAutoDiscoverDevices: NSButton!
    @IBOutlet weak var discoverableName: NSTextField! {
     
        didSet {
            discoverableName.delegate = self;
        }
    }
    @IBOutlet weak var ipAddress: NSTextField!
    @IBOutlet weak var portNumber: NSTextField! {
     
        didSet {
            portNumber.delegate = self;
        }
    }
    @IBOutlet weak var shouldUseCustomPort: NSButton!
    @IBOutlet weak var serverStatusImageView: NSImageView!
    @IBOutlet weak var listenButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shouldAutoDiscoverDevices.state = UserDefaults.standard.bool(forKey: "shouldAutoDiscoverDevices") ? 1 : 0;
        discoverableName.stringValue = UserDefaults.standard.string(forKey: "discoverableName") ?? "";
        shouldUseCustomPort.state = UserDefaults.standard.bool(forKey: "shouldUseCustomPort") ? 1 : 0;
        if(shouldUseCustomPort.state == 1) {
            portNumber.isEnabled = true;
            portNumber.stringValue = UserDefaults.standard.string(forKey: "serverPortNumber") ?? "0";
        } else {
            portNumber.isEnabled = false;
            portNumber.stringValue = String(serverManager.serverPortNumber ?? 0);
        }
        ipAddress.stringValue = serverManager.serverIpAddress ?? "0.0.0.0"; 
        
        loadServerStatusInfo(serverStatus: serverManager.serverStatus);
        
        NotificationCenter.default.addObserver(self, selector: #selector(serverManagerServerStatusChanged(notification:)), name: ServerManager.ServerStatusChangedNotification, object: nil);

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    func serverManagerServerStatusChanged(notification : NSNotification) {
        
        let userInfo = notification.userInfo as! [String : AnyObject];
        let serverStatus = userInfo[ServerManager.ServerStatusNotificationKey] as! ServerStatus;
        let serverPortNumber = userInfo[ServerManager.ServerPortNumberNotificationKey] as! Int;
        let serverIpAddress = userInfo[ServerManager.ServerIpAddressNotificationKey] as! String;
        
        print("Network Preferences View Controller recived Server Status Changed Notification: ", serverStatus.rawValue);
        
        loadServerStatusInfo(serverStatus: serverStatus);
        ipAddress.stringValue = serverIpAddress;
        portNumber.stringValue = String(serverPortNumber);
        
    }
    
    private func loadServerStatusInfo(serverStatus : ServerStatus) {
        
        switch (serverStatus) {
            case .Down:
                listenButton.title = "Start listening";
                serverStatusImageView.image = #imageLiteral(resourceName: "RedStatusIcon");
            case .Starting:
                listenButton.title = "Restart";
                serverStatusImageView.image = #imageLiteral(resourceName: "OrangeStatusIcon");
            case .Running:
                listenButton.title = "Stop listening";
                serverStatusImageView.image = #imageLiteral(resourceName: "GreenStatusIcon");
        }
    }
    
    @IBAction func autoDiscoverDevicesCheckboxClick(_ checkboxButton: NSButton) {
        
        UserDefaults.standard
            .set(Bool(checkboxButton.state as NSNumber), forKey: "shouldAutoDiscoverDevices");
        
        if(checkboxButton.state == 1) {
            print("Should start Bonjour service discovery");
            if(serverManager.serverStatus == .Running) {
                serverManager.startServiceDiscovery(withName: discoverableName.stringValue);
            }
        } else {
            print("Should stop Bonjuor service discovery");
            if(serverManager.serverStatus == .Running) {
                serverManager.stopServiceDiscovery();
            }
        }
    }
    
    @IBAction func useCustomPortCheckboxClick(_ checkboxButton: NSButton) {
        
        // save new checkbox state in UserDefaults
        UserDefaults.standard
            .set(Bool(checkboxButton.state as NSNumber), forKey: "shouldUseCustomPort");
        
        if(checkboxButton.state == 1) {
            portNumber.isEnabled = true;
        } else {
            portNumber.isEnabled = false;
            
            let serverPort = String(serverManager.serverPortNumber ?? 0);
            if(serverPort != portNumber.stringValue) {
                portNumber.stringValue =  serverPort;
                
                // ask to restart server
                if(isServerActive()) { askToRestartServer(); } 
            }
        }
    }

    @IBAction func listenButtonClick(_ button: NSButton) {
        
        print("Listen button clicked with label: ", button.title);
        
        switch serverManager.serverStatus {
            case .Running:
                button.title = "Start Listening";
                serverStatusImageView.image = #imageLiteral(resourceName: "RedStatusIcon");
                serverManager.securityPassword = nil;
                serverManager.customPortNumber = nil;
                serverManager.serverStatus = .Down;
                break;
            case .Starting:
                // keep starting again
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
                serverManager.serverStatus = .Starting;
                break;
            case .Down:
                button.title = "Restart"
                serverStatusImageView.image = #imageLiteral(resourceName: "OrangeStatusIcon");
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
                serverManager.serverStatus = .Starting;
                break;
        }
    }
    
    private func isServerActive() -> Bool {
    
        if(serverManager.serverStatus == .Running
                || serverManager.serverStatus == .Starting) {
            return true;
        }
        return false;
    }
    
    private func askToRestartServer() {
        let alert: NSAlert = NSAlert();
        alert.messageText = "Server is running...";
        alert.informativeText = "Should be restarted to apply changes?";
        alert.alertStyle = NSAlertStyle.warning;
        alert.addButton(withTitle:"Restart");
        alert.addButton(withTitle:"Cancel");
        if( alert.runModal() == NSAlertFirstButtonReturn) {
            print("Should restart server with new configuration.");
            listenButton.title = "Restart"
            serverStatusImageView.image = #imageLiteral(resourceName: "OrangeStatusIcon");
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
            serverManager.serverStatus = .Starting;
        }
    }
    
    // NSTextField Delegate Methods
    
    // on TextField end of edition
    func control(_ control: NSControl,
                          textShouldEndEditing fieldEditor: NSText) -> Bool{
    
        if(control == discoverableName) {
            print("Entered discoverable name: ", discoverableName.stringValue);
        
            UserDefaults.standard
                .set(discoverableName.stringValue, forKey: "discoverableName");
        
            print("Should restart Bonjour service discovery with new name");
            serverManager.restartServiceDiscovery(withName: discoverableName.stringValue);
        }
        
        if(control == portNumber) {
            print("Entered port number: ", portNumber.stringValue);
            
            UserDefaults.standard
                .set(portNumber.stringValue, forKey: "serverPortNumber");
            
            if(isServerActive()) {
                // ask to restart server
                askToRestartServer();
            }
        }
        
        return true;
    }

}
