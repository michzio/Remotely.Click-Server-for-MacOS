//
//  PreferencesTabViewController.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 16/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

class PreferencesTabViewController: NSTabViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        
        print("Selected tab: ", tabViewItem?.label);
    }

}
