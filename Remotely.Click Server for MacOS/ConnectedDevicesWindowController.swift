//
//  ConnectedDevicesWindowController.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 20/06/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

class ConnectedDevicesWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        NSApp.activate(ignoringOtherApps: true)
        self.window?.makeKeyAndOrderFront(nil);
        
        window?.titlebarAppearsTransparent = true;
        window?.titleVisibility = .hidden;
        
        // disable opacity
        window?.isOpaque = false;
        window?.backgroundColor = NSColor.clear;
    }
    
}
