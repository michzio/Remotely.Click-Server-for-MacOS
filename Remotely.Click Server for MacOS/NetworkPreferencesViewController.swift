//
//  NetworkPreferencesViewController.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 16/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

protocol NetworkPreferencesDelegate: class {
    
    func shouldStartServiceDiscovery(withName discoverableName : String);
    func shouldStopServiceDiscovery();
    func shouldServerStatusChange(from fromStatus : ServerStatus, to toStatus : ServerStatus);
}

class NetworkPreferencesViewController: NSViewController, NSTextFieldDelegate {
    
    weak var delegate : NetworkPreferencesDelegate? = nil;
    
    
    @IBOutlet weak var shouldAutoDiscoverDevices: NSButton!
    @IBOutlet weak var discoverableName: NSTextField! {
     
        didSet {
            discoverableName.delegate = self;
        }
    }
    @IBOutlet weak var ipAddress: NSTextField!
    @IBOutlet weak var portNumber: NSTextField! {
     
        didSet {
            portNumber.delegate = self;
        }
    }
    @IBOutlet weak var shouldUseCustomPort: NSButton!
    @IBOutlet weak var serverStatus: NSImageView!
    @IBOutlet weak var listenButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shouldAutoDiscoverDevices.state = UserDefaults.standard.bool(forKey: "shouldAutoDiscoverDevices") ? 1 : 0;
        discoverableName.stringValue = UserDefaults.standard.string(forKey: "discoverableName") ?? "";
        ipAddress.stringValue = UserDefaults.standard.string(forKey: "serverIPAddress") ?? "0.0.0.0";
        portNumber.stringValue = UserDefaults.standard.string(forKey: "serverPortNumber") ?? "0";
        shouldUseCustomPort.state = UserDefaults.standard.bool(forKey: "shouldUseCustomPort") ? 1 : 0;
        if(shouldUseCustomPort.state == 1) {
            portNumber.isEnabled = true;
        } else {
            portNumber.isEnabled = false;
        }
        
        loadServerStatusInfo();
        
    }
    
    private func loadServerStatusInfo() {
        
        let status = UserDefaults.standard.string(forKey: "serverStatus") ?? "Down";
        switch status {
            case "Down":
                listenButton.title = "Start listening";
                serverStatus.image = #imageLiteral(resourceName: "RedStatusIcon");
            case "Starting":
                listenButton.title = "Restart";
                serverStatus.image = #imageLiteral(resourceName: "OrangeStatusIcon");
            case "Running":
                listenButton.title = "Stop listening";
                serverStatus.image = #imageLiteral(resourceName: "GreenStatusIcon");
            default:
                print("Incorrect server status!");
        }
    }
    
    @IBAction func autoDiscoverDevicesCheckboxClick(_ checkboxButton: NSButton) {
        
        UserDefaults.standard
            .set(Bool(checkboxButton.state as NSNumber), forKey: "shouldAutoDiscoverDevices");
        
        if(isServerRunning()) {
            if(checkboxButton.state == 1) {
                print("Should start Bonjour service discovery");
                delegate?.shouldStartServiceDiscovery(withName: discoverableName.stringValue);
            } else {
                print("Should stop Bonjuor service discovery");
                delegate?.shouldStopServiceDiscovery();
            }
        }
    }
    
    @IBAction func useCustomPortCheckboxClick(_ checkboxButton: NSButton) {
        
        if(checkboxButton.state == 1) {
            portNumber.isEnabled = true;
        } else {
            portNumber.isEnabled = false;
            portNumber.stringValue =  "0";
        }
        
        // save new checbox state in UserDefaults 
        UserDefaults.standard
            .set(Bool(checkboxButton.state as NSNumber), forKey: "shouldUseCustomPort");
        
        if(checkboxButton.state == 0 && isServerActive()) {
            // ask to restart server
            askToRestartServer();
        }
    }

    @IBAction func listenButtonClick(_ button: NSButton) {
        
        print("Listen button clicked with label: ", button.title);
        
        let status = UserDefaults.standard.string(forKey: "serverStatus") ?? "Down";
        
        switch ServerStatus(rawValue: status) {
            case .Running?:
                button.title = "Start Listening";
                serverStatus.image = #imageLiteral(resourceName: "RedStatusIcon");
                delegate?.shouldServerStatusChange(from: .Running, to: .Down);
                break;
            case .Starting?:
                // keep starting again
                delegate?.shouldServerStatusChange(from: .Starting, to: .Starting);
                break;
            case .Down?:
                button.title = "Restart"
                serverStatus.image = #imageLiteral(resourceName: "OrangeStatusIcon");
                delegate?.shouldServerStatusChange(from: .Down, to: .Starting);
                break;
            default:
                print("Incorrect server status!");
                break;
        }
    }
    
    private func isServerActive() -> Bool {
        let status = UserDefaults.standard.string(forKey: "serverStatus");
        if(status == "Running" || status == "Starting") {
            return true;
        }
        return false;
    }
    
    private func isServerRunning() -> Bool {
        let status = UserDefaults.standard.string(forKey: "serverStatus");
        if(status == "Running") {
            return true;
        }
        return false;
    }
    
    private func isDevicesAutoDiscoveryActive() -> Bool {
        return UserDefaults.standard.bool(forKey: "isDevicesAutoDiscoverActive");
    }
    
    private func askToRestartServer() {
        let alert: NSAlert = NSAlert();
        alert.messageText = "Server is running...";
        alert.informativeText = "Should be restarted to apply changes?";
        alert.alertStyle = NSAlertStyle.warning;
        alert.addButton(withTitle:"Restart");
        alert.addButton(withTitle:"Cancel");
        if( alert.runModal() == NSAlertFirstButtonReturn) {
            print("Should restart server with new configuration.");
            listenButton.title = "Restart"
            serverStatus.image = #imageLiteral(resourceName: "OrangeStatusIcon");
            delegate?.shouldServerStatusChange(from: .Running, to: .Starting);
        }
    }
    
    
    // Delegate methods
    
    // on TextField end of edition
    func control(_ control: NSControl,
                          textShouldEndEditing fieldEditor: NSText) -> Bool{
    
        if(control == discoverableName) {
            print("Entered discoverable name: ", discoverableName.stringValue);
        
            UserDefaults.standard
                .set(discoverableName.stringValue, forKey: "discoverableName");
        
            if(isDevicesAutoDiscoveryActive()) {
                print("Should restart Bonjour service discovery with new name");
                delegate?.shouldStopServiceDiscovery();
                delegate?.shouldStartServiceDiscovery(withName: discoverableName.stringValue);
            }
        }
        
        if(control == portNumber) {
            print("Entered port number: ", portNumber.stringValue);
            
            UserDefaults.standard
                .set(portNumber.stringValue, forKey: "serverPortNumber");
            
            if(isServerActive()) {
                // ask to restart server
                askToRestartServer();
            }
        }
        
        return true;
    }

}
