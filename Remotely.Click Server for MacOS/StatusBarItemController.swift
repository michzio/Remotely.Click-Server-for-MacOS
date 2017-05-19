//
//  StatusBarItemController.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 16/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

class StatusBarItemController: NSObject {

    
    @IBOutlet weak var statusBarMenuController: StatusBarMenuController!
    
    var statusBarItem : NSStatusItem = NSStatusItem();
    var statusBar : NSStatusBar = NSStatusBar.system();
    
    override func awakeFromNib() {
        
        print("Status bar app created!");
        
        statusBarItem  = statusBar.statusItem(withLength: NSVariableStatusItemLength);
        statusBarItem.menu = statusBarMenuController.menu;
        statusBarItem.image = #imageLiteral(resourceName: "SatatusBarIcon");
        statusBarItem.highlightMode = true;
        statusBarItem.toolTip = "Remotely.Click Server";
        
    }
}
