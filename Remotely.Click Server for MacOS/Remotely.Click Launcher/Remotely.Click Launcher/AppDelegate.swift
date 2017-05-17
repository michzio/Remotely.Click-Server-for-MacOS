//
//  AppDelegate.swift
//  Remotely.Click Launcher
//
//  Created by Michal Ziobro on 16/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let path : String = Bundle.main.bundleURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent().absoluteString;
        
        print(path);
    
        NSWorkspace.shared().launchApplication(path);
        NSApp.terminate(nil);
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

