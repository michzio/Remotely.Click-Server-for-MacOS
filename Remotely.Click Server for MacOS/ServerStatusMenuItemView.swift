//
//  ServerStatusMenuItemView.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 18/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

protocol ServerStatusMenuItemViewDelegate: class {
    
    func shouldServerStatusChange(from fromStatus: ServerStatus, to toStatus: ServerStatus);
}

@IBDesignable
class ServerStatusMenuItemView: NSView {
    
    weak var delegate: ServerStatusMenuItemViewDelegate? = nil;
    
    var _serverStatus : ServerStatus = .Down {
     
        didSet {
            
            switch serverStatus  {
                case .Down:
                    self.statusImage = #imageLiteral(resourceName: "RedStatusIcon");
                    self.statusText = "Server down";
                    self.buttonTitle = "Start";
                    break;
                case .Running:
                    self.statusImage = #imageLiteral(resourceName: "GreenStatusIcon");
                    self.statusText = "Server running"
                    self.buttonTitle = "Stop";
                    break;
                case .Starting:
                    self.statusImage = #imageLiteral(resourceName: "OrangeStatusIcon");
                    self.statusText = "Server starting...";
                    self.buttonTitle = "Restart";
                    break;
            }
        }
    }
    
    @IBOutlet weak var statusImageView: NSImageView!
    
    @IBOutlet weak var statusLabel: NSTextField!
    
    @IBOutlet weak var button: NSButton!
    
    // custom view from the XIB file
    var view : NSView!
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect);
    
        self.customViewInit();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        
        self.customViewInit();
    }
    
    func customViewInit() {
     
        view = loadViewFromNib();
        view.frame = bounds;
        view.autoresizingMask = [NSAutoresizingMaskOptions.viewWidthSizable, NSAutoresizingMaskOptions.viewHeightSizable];
        
        addSubview(view);
    }
    
    func loadViewFromNib() -> NSView! {
        
        let bundle = Bundle(for: type(of: self));
        let nib = NSNib(nibNamed: "ServerStatusMenuItemView", bundle: bundle);
        var views : NSArray = NSArray();
        nib?.instantiate(withOwner: self, topLevelObjects: &views);
        
        
        
        if let view = views[0] as? NSView {
            return view;
        }
        
        if let view = views[1] as? NSView {
            return view;
        }
        
        return nil;
    }
    
    
    @IBInspectable var statusImage: NSImage? {
        get {
            return statusImageView.image
        }
        set(image) {
            statusImageView.image = image
        }
    }
    
    @IBInspectable var statusText : String? {
        
        get {
            return statusLabel.stringValue;
        }
        set(text) {
            statusLabel.stringValue = text!;
        }
    }
    
    @IBInspectable var buttonTitle : String? {
        
        get {
            return button.title;
        }
        set(title) {
            button.title = title!;
        }
    }
    
    @IBInspectable var serverStatus : ServerStatus {
     
        get {
            return _serverStatus;
        }
        
        set(status) {
            _serverStatus = status;
        }
    }
    
    @IBAction func buttonClick(_ sender: NSButton) {
        
        
        
        switch serverStatus {
            case .Down: // Start
                serverStatus = .Starting;
                delegate?.shouldServerStatusChange(from: .Down, to: .Starting);
                break;
            case .Running: // Stop
                serverStatus = .Down
                delegate?.shouldServerStatusChange(from: .Running, to: .Down);
                break;
            case .Starting: // Restart
                serverStatus = .Starting;
                delegate?.shouldServerStatusChange(from: .Starting, to: .Starting);
                break;
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
