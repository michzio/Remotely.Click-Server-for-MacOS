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

    
    func testNSDProxy() {
        
        // Test invocation of NSDProxyObjC methods.
         let nsdProxy : NSDProxyObjC = NSDProxyObjC.sharedNSD() as! NSDProxyObjC;
         nsdProxy.simpleRegisterService(inBackgroundOfType: "_remotely_click._tcp", atPort: CFSwapInt16(59600), withCallback: {
         (name : String!, regtype : String!, domain : String!, flags : nsd_flags_t) -> Void in
         
         print("REGISTERED: ", name, " | ", regtype, " | ", domain);
         
         });
         
         nsdProxy.browseServices(inBackgroundOfType: "_remotely_click._tcp", inDomain: "local") { (interfaceIdx : UInt32, serviceName: String!, regtype: String!, domain : String!, flags : nsd_flags_t) in
         
         if( (flags.rawValue & ADDED.rawValue) > 0) {
         print("NSD ADDED: ", interfaceIdx, " | ", serviceName, " | ", regtype, " | ", domain);
         
         nsdProxy.resolveService(inBackgroundNamed: serviceName, ofType: regtype, inDomain: domain, withInterfaceIdx: interfaceIdx, usingCallback:
         { (interfaceIdx : UInt32, fullname: String!, hosttarget: String!, port: UInt16, flags: nsd_flags_t) in
         
         print("RESOLVED: ", interfaceIdx, " | ", fullname, " | ", hosttarget, " | ", port);
         
         if( (flags.rawValue & MORE.rawValue) == 0 ) {
         fflush(stdout);
         }
         });
         
         } else if( (flags.rawValue & REMOVED.rawValue) > 0) {
         print("NSD REMOVED: ", interfaceIdx, " | ", serviceName, " | ", regtype, " | ", domain);
         }
         
         if( (flags.rawValue & MORE.rawValue) == 0) {
         fflush(stdout);
         }
         }
 
    }
    
    
    // MARK: App Delegate - main code
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        ensureSingleInstanceOfThisApp();
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
       
        // Insert code here to initialize your application
        firstAppLaunchPreferences();
        print("App started...");
        
        if(UserDefaults.standard.bool(forKey: "shouldAutoLaunchServer")) {
            if(UserDefaults.standard.bool(forKey: "shouldUseSecurityPassword")) {
                ServerManager.sharedInstance.securityPassword = UserDefaults.standard.string(forKey: "securityPassword");
            } else {
                ServerManager.sharedInstance.securityPassword = nil;
            }
            if(UserDefaults.standard.bool(forKey: "shouldUseCustomPort")) {
                ServerManager.sharedInstance.customPortNumber = Int( (UserDefaults.standard.string(forKey: "serverPortNumber") ?? "0") );
            } else {
                ServerManager.sharedInstance.customPortNumber = nil;
            }
            if(UserDefaults.standard.bool(forKey: "shouldAutoDiscoverDevices")) {
                ServerManager.sharedInstance.discoverableName = UserDefaults.standard.string(forKey: "discoverableName") ?? "";
            } else {
                ServerManager.sharedInstance.discoverableName = nil; 
            }
            ServerManager.sharedInstance.startServer();
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
         UserDefaults.standard.set("Down", forKey: "serverStatus");
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
        
        if(!preferencesKeys.contains("shouldAutoDiscoverDevices")) {
            // add initial preference for "shouldAutoDiscoverDevices" default to true 
            UserDefaults.standard.set(true, forKey: "shouldAutoDiscoverDevices"); 
        }
    }
    
    /*
     * Before launching application check whether there isn't another
     * instance of application with the same Bundle Identifier already running
     */
    func ensureSingleInstanceOfThisApp() {
        
        let runningApps : [NSRunningApplication] = NSWorkspace.shared().runningApplications
        
        var countInstances = 0;
        for app in runningApps {
            if (app.bundleIdentifier == Bundle.main.bundleIdentifier) {
                countInstances = countInstances + 1;
            }
        }
        
        if(countInstances > 1) {
            NSApp.terminate(nil);
        }
    }
}
