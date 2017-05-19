//
//  StatusBarMenuController.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 16/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

class StatusBarMenuController: NSObject, ServerStatusMenuItemViewDelegate {

    @IBOutlet weak var menu: NSMenu!;
    @IBOutlet weak var serverStatusMenuItem: NSMenuItem!
    
    override func awakeFromNib() {
        
        print("Menu created!");
        
        // assign out custom view to server status menu item in status bar menu
        let serverStatusMenuItemView
            = ServerStatusMenuItemView(frame: NSMakeRect(0, 0, 275, 50));
        serverStatusMenuItemView.serverStatus = .Down;
        serverStatusMenuItemView.delegate = self;
        serverStatusMenuItem.view = serverStatusMenuItemView;
    }
    
    func serverStatusChanged(from fromStatus: ServerStatus, to toStatus: ServerStatus) {
        print("StatusBarMenuController: server status changed in menu item from ",
              fromStatus, " to ", toStatus);
    }
    
}
