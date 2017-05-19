//
//  SecurityPreferencesViewController.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 16/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Cocoa

protocol SecurityPreferencesDelegate: class {
 
    func shouldUseSecurityPassword(_ should : Bool, value password: String);
}

class SecurityPreferencesViewController: NSViewController {
    
    weak var delegate : SecurityPreferencesDelegate? = nil;

    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var confirmPasswordTextField: NSSecureTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        var currentPassword = UserDefaults.standard.string(forKey:"securityPassword") ?? "";
        passwordTextField.stringValue = currentPassword;
        confirmPasswordTextField.stringValue = currentPassword;
    }
    
    @IBAction func applyPasswordClick(_ sender: NSButton) {
        
        if(passwordTextField.stringValue
            != confirmPasswordTextField.stringValue) {
            let alert: NSAlert = NSAlert();
            alert.messageText = "Password doesn't match";
            alert.informativeText = "Both password field and confirm password filed should contain the same value.";
            alert.alertStyle = NSAlertStyle.warning;
            alert.addButton(withTitle:"OK");
            alert.runModal();
            return;
        }
        
        if(passwordTextField.stringValue == "") {
            let alert: NSAlert = NSAlert();
            alert.messageText = "Password empty";
            alert.informativeText = "Password fields left empty. Please enter correct password value.";
            alert.alertStyle = NSAlertStyle.warning;
            alert.addButton(withTitle:"OK");
            alert.runModal(); 
            return;
        }
        
        // if password & confirm password matches then applay it
        UserDefaults.standard.set(passwordTextField.stringValue, forKey:"securityPassword");
        UserDefaults.standard.set(true, forKey:"shouldUseSecurityPassword");
        
        delegate?.shouldUseSecurityPassword(true, value: passwordTextField.stringValue);
        
        print("Applied password: ", passwordTextField.stringValue);
    }
    
    
    @IBAction func clearPasswordClick(_ sender: NSButton) {
        
        UserDefaults.standard.set("", forKey: "securityPassword");
        UserDefaults.standard.set(false, forKey: "shouldUseSecurityPassword");
        
        delegate?.shouldUseSecurityPassword(false, value: "");
        
        // clear form controls 
        passwordTextField.stringValue = "";
        confirmPasswordTextField.stringValue = "";
        
        print("Password cleared");
    }
}
