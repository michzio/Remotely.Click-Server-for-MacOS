//
//  NetworkPreferencesViewController.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 16/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

class NetworkPreferencesViewController: NSViewController {
    
    @IBOutlet weak var shouldAutoDiscoverButton: NSButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func listenButtonClick(_ button: NSButton) {
        
        print("Listen button clicked with label: ", button.title);
    }
    
}
