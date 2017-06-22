//
//  ConnectedDevicesViewController.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 20/06/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

class ConnectedDevicesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    let serverManager = ServerManager.sharedInstance;
    
    @IBOutlet weak var connectedDevicesTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        connectedDevicesTableView.delegate = self;
        connectedDevicesTableView.dataSource = self;
        
        NotificationCenter.default.addObserver(self, selector: #selector(serverManagerClientConnected(notification:)), name: ServerManager.ClientConnectedNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(serverManagerClientLost(notification:)), name: ServerManager.ClientLostNotification, object: nil);
    }
    
    deinit {
     
        NotificationCenter.default.removeObserver(self, name: ServerManager.ClientConnectedNotification, object: nil);
        NotificationCenter.default.removeObserver(self, name: ServerManager.ClientLostNotification, object: nil);
    }
    
    func serverManagerClientConnected(notification: NSNotification) {
     
            connectedDevicesTableView.reloadData();
    }
    
    func serverManagerClientLost(notification: NSNotification) {
     
        connectedDevicesTableView.reloadData();
    }
    
    
    // MARK: NSTableViewDataSource delegate methods
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return serverManager.connectedDevices.count;
    }
    
    // MARK: NSTableViewDelegate delegate methods 
    fileprivate enum CellIdentifiers {
        static let DeviceIdentityCell = "DeviceIdentityCellID";
        static let DeviceOSCell = "DeviceOSCellID";
        static let ConnSockCell = "ConnSockCellID";
        static let IPAddressCell = "IPAddressCellID";
        static let PortNumberCell = "PortNumberCellID";
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var image : NSImage?;
        var text : String  = "";
        var cellIdentifier : String = "";
        
        let connectedDevice : ServerManager.ClientInfo = serverManager.connectedDevices[row].value;
        
        if( tableColumn == connectedDevicesTableView.tableColumns[0] )
        {
            cellIdentifier = CellIdentifiers.DeviceIdentityCell;
            text = connectedDevice.deviceIdentity;
            
        } else if(tableColumn == connectedDevicesTableView.tableColumns[1]) {
         
            cellIdentifier = CellIdentifiers.DeviceOSCell;
            text = connectedDevice.deviceOS;
            if(connectedDevice.deviceOS == "Android") {
                image = #imageLiteral(resourceName: "AndroidIcon");
            } else if(connectedDevice.deviceOS == "iOS") {
                image = #imageLiteral(resourceName: "iOSIcon");
            }
            image?.size = NSSize(width: 20, height: 20);
            
        } else if(tableColumn == connectedDevicesTableView.tableColumns[2]) {
         
            cellIdentifier = CellIdentifiers.ConnSockCell;
            
            text = String(Int(connectedDevice.connSock));
            
        } else if(tableColumn == connectedDevicesTableView.tableColumns[3]) {
         
            cellIdentifier = CellIdentifiers.IPAddressCell;
            
            text = connectedDevice.connIpAddress;
            
        } else if(tableColumn == connectedDevicesTableView.tableColumns[4]) {
         
            cellIdentifier = CellIdentifiers.PortNumberCell;
            
            text = String(connectedDevice.connPortNumber);
        }
        
        if let cell = connectedDevicesTableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
         
            cell.textField?.stringValue = text;
            cell.imageView?.image = image ?? nil;
            
            return cell;
        }
        
        return nil;
    }
}

extension Dictionary {
    subscript(i:Int) -> (key:Key,value:Value) {
        get {
            return self[index(startIndex, offsetBy: i)];
        }
    }
}
