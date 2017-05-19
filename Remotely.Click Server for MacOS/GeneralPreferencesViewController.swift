//
//  PreferencesViewController.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 16/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa
import ServiceManagement

class GeneralPreferencesViewController: NSViewController {

    @IBOutlet weak var shouldBeLoginItem: NSButton!
    
    @IBOutlet weak var shouldAutoLaunchServer: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shouldBeLoginItem.state = UserDefaults.standard.bool(forKey: "shouldBeLoginItem") ? 1 : 0;
        
        shouldAutoLaunchServer.state = UserDefaults.standard.bool(forKey:"shouldAutoLaunchServer") ? 1 : 0;
    }
    
    
    @IBAction func loginItemCheckboxClick(_ checkboxButton: NSButton) {
        
        print("Add app as Login Item? ", Bool(checkboxButton.state as NSNumber) );
        
        UserDefaults.standard
            .set(Bool(checkboxButton.state as NSNumber), forKey: "shouldBeLoginItem");
        
       if(!SMLoginItemSetEnabled("click.remotely.Remotely-Click-Server-Launcher" as CFString, Bool(checkboxButton.state as NSNumber) ) ) {
            let alert: NSAlert = NSAlert()
            alert.messageText = "Remotely.Click Server - Error";
            alert.informativeText = "Application couldn't be added as Login Item to macOS System Preferences > Users & Groups.";
            alert.alertStyle = NSAlertStyle.warning;
            alert.addButton(withTitle:"OK");
            alert.runModal();
       } else {
            // 
        }
        
      /*
        // Deprecated approach that inserts new Login Item into
        // System Preferences > Users & Groups > Login Items 
        // in order to work it needs to disable App Sandbox 
        // by toggle from YES -> NO in Remotely.Click Server for MacOS.entitlements 
        // watch more: https://www.youtube.com/watch?v=UvDkby0t_WI
 
        let loginItemsList = LoginItemsList();
        
        if( checkboxButton.state == 0) {
            if(!loginItemsList.removeLoginItem(LoginItemsList.appPath())) {
                print("Error while removing Login Item from the list.");
            }
        } else {
            if(!loginItemsList.addLoginItem(LoginItemsList.appPath())) {
                print("Error while adding Login Item to the list.");
            }
        }
       */
    }
    
    @IBAction func autoLaunchServerCheckboxClick(_ checkboxButton: NSButton) {
        
        UserDefaults.standard
            .set(Bool(checkboxButton.state as NSNumber), forKey: "shouldAutoLaunchServer");
    
        // Test invocation of Objective-C method. 
        // let object: CustomObjectInObjC = CustomObjectInObjC()
        // object.someMethod();
    }
}
