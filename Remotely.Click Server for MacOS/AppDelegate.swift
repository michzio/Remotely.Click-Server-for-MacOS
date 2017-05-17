//
//  AppDelegate.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 16/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
       
        // Insert code here to initialize your application
        //firstAppLaunchPreferences();
        print("App started...");

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private func firstAppLaunchPreferences() {
        
        print("Firt App Launch Default Preferences"); 
        
        let preferencesKeys = UserDefaults.standard.dictionaryRepresentation().keys;
        
        if(!preferencesKeys.contains("shouldBeLoginItem")) {
            // add initial preference for "shouldBeLoginItem" default to true
            UserDefaults.standard.set(true, forKey: "shouldBeLoginItem");
            if(!SMLoginItemSetEnabled("click.remote.Remotely-Click-Launcher" as CFString, true )) {
                print("Couldn't enable Login Item by default");
            }
        }
        
        if(!preferencesKeys.contains("shouldAutoLaunchServer")) {
            // add initial preference for "shouldAutoLaunchServer" default to true
            UserDefaults.standard.set(true, forKey: "shouldAutoLaunchServer");
            
        }
    }
}

