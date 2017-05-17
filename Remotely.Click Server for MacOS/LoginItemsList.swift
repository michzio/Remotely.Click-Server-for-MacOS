//
//  LoginItems.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 17/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Foundation
import Cocoa

class LoginItemsList : NSObject {

    let loginItemsList : LSSharedFileList = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue();
    
    
    
    func addLoginItem(_ path: CFURL) -> Bool {
        
        if(getLoginItem(path) != nil) {
            print("Login Item has already been added to the list."); 
            return true;
        }
        
        var path : CFURL = CFURLCreateWithString(nil, "file:///Applications/Safari.app" as CFString, nil);
        print("Path adding to Login Item list is: ", path);
        
        // add new Login Item at the end of Login Items list
        if let loginItem = LSSharedFileListInsertItemURL(loginItemsList,
                                                          getLastLoginItemInList(),
                                                          nil, nil,
                                                          path,
                                                          nil, nil) {
            print("Added login item is: ", loginItem);
            return true;
        }
        
        return false;
    }
    
    
    func removeLoginItem(_ path: CFURL) -> Bool {
        
        // remove Login Item from the Login Items list 
        if let oldLoginItem = getLoginItem(path) {
            print("Old login item is: ", oldLoginItem);
            if(LSSharedFileListItemRemove(loginItemsList, oldLoginItem) == noErr) {
                return true;
            }
            return false;
        }
        print("Login Item for given path not found in the list."); 
        return true;
    }
    
    
    func getLoginItem(_ path : CFURL) -> LSSharedFileListItem! {
        
        var path : CFURL = CFURLCreateWithString(nil, "file:///Applications/Safari.app" as CFString, nil);

        
        // Copy all login items in the list
        let loginItems : NSArray = LSSharedFileListCopySnapshot(loginItemsList, nil).takeRetainedValue();
        
        var foundLoginItem : LSSharedFileListItem?;
        var nextItemUrl : Unmanaged<CFURL>?;
        
        // Iterate through login items to find one for given path
        print("App URL: ", path);
        for var i in (0..<loginItems.count)  // CFArrayGetCount(loginItems)
        {
            
            var nextLoginItem : LSSharedFileListItem = loginItems.object(at: i) as! LSSharedFileListItem; // CFArrayGetValueAtIndex(loginItems, i).;
            
            
            if(LSSharedFileListItemResolve(nextLoginItem, 0, &nextItemUrl, nil) == noErr) {
                
                
                
                print("Next login item URL: ", nextItemUrl!.takeUnretainedValue());
                // compare searched item URL passed in argument with next item URL
                if(nextItemUrl!.takeRetainedValue() == path) {
                    foundLoginItem = nextLoginItem;
                }
            }
        }
        
        return foundLoginItem;
    }
    
    func getLastLoginItemInList() -> LSSharedFileListItem! {
        
        // Copy all login items in the list
        let loginItems : NSArray = LSSharedFileListCopySnapshot(loginItemsList, nil).takeRetainedValue() as NSArray;
        if(loginItems.count > 0) {
            let lastLoginItem = loginItems.lastObject as! LSSharedFileListItem;
            
            print("Last login item is: ", lastLoginItem);
            return lastLoginItem
        }
        
        return kLSSharedFileListItemBeforeFirst.takeRetainedValue();
    }
    
    func isLoginItemInList(_ path : CFURL) -> Bool {
     
        if(getLoginItem(path) != nil) {
            return true;
        }
        
        return false;
    }
    
    static func appPath() -> CFURL {

        return NSURL.fileURL(withPath: Bundle.main.bundlePath) as CFURL;
    }
    
    
    // Returns a list of references to login items for the current user.
    func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItem?, lastReference: LSSharedFileListItem?) {
        var itemUrl: UnsafeMutablePointer<Unmanaged<CFURL>?> = UnsafeMutablePointer<Unmanaged<CFURL>?>.allocate(capacity:1)
        if let appUrl: NSURL = NSURL.fileURL(withPath: Bundle.main.bundlePath) as NSURL? {
                       let loginItemsRef = LSSharedFileListCreate(
                                nil,
                                kLSSharedFileListSessionLoginItems.takeRetainedValue(),
                                nil
                                ).takeRetainedValue() as LSSharedFileList?
                        if loginItemsRef != nil {
                                let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
                                if(loginItems.count > 0)
                                {
                                    let lastItemRef: LSSharedFileListItem = loginItems.lastObject as! LSSharedFileListItem
                                    for var i in  (0..<loginItems.count) {
                                        let currentItemRef: LSSharedFileListItem = loginItems.object(at:i) as! LSSharedFileListItem
                                        let currentItemUrl = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, nil).takeRetainedValue()
                                        if appUrl.isEqual(currentItemUrl) {
                                            return (currentItemRef, lastItemRef)
                                        }
                                    }
                                    // The application was not found in the startup list.
                                    return (nil, lastItemRef)
                                }
                              else
                          {
                          let addatstart: LSSharedFileListItem = kLSSharedFileListItemBeforeFirst.takeRetainedValue()
                    
                                 return(nil,addatstart)
                       }
                }
                }
        return (nil, nil)
    }
    
    // Toggles whether or not this program is launched at startup.
    func toggleLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems()
        let shouldBeToggled = (itemReferences.existingReference == nil)
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
            ).takeRetainedValue() as LSSharedFileList?
        if loginItemsRef != nil {
           if shouldBeToggled {
               if let appUrl: CFURL = NSURL.fileURL(withPath: Bundle.main.bundlePath) as NSURL? {
                print("Adding Login Item");
                    LSSharedFileListInsertItemURL(
                        loginItemsRef,
                        itemReferences.lastReference,
                        "Display Name" as CFString,
                        nil,
                        appUrl,
                        nil,
                        nil
                                        )
                             }
                      } else {
                if let itemRef = itemReferences.existingReference {
                    LSSharedFileListItemRemove(loginItemsRef,itemRef);
                    }
                }
            }
    }
    
    func applicationIsInStartUpItems() -> Bool {
            return (itemReferencesInLoginItems().existingReference != nil)
    }
    
}
