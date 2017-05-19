//
//  PreferencesHeaderView.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 18/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

class PreferencesHeaderView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        NSColor.clear.setFill();
        NSRectFill(dirtyRect); 
        
    }
    
}
