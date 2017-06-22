//
//  NSDManager.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 14/06/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Foundation

@objc
protocol NSDManagerDelegate : class {
    @objc optional func serviceRegistered(_ service: NetService);
    @objc optional func serviceUnregistered(_ service: NetService);
    @objc optional func serviceAdded(_ service: NetService, moreComing more: Bool);
    @objc optional func serviceRemoved(_ service: NetService, moreComing more: Bool);
    @objc optional func serviceResolved(_ service: NetService, withAddress address: String, andPort port: Int);
}

class NSDManager : NSObject, NetServiceDelegate, NetServiceBrowserDelegate {
    
    weak var delegate:NSDManagerDelegate?
    
    var netService : NetService?;
    var netServiceBrowser : NetServiceBrowser?;

    // MARK: NetService registration/unregistration
    func registerService(domain: String, type: String, name: String, port: Int32) -> Void {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.netService = NetService(domain: domain, type: type, name: name, port: port);
            self.netService?.delegate = self;
            self.netService?.startMonitoring();
            self.netService?.publish();
            
            RunLoop.current.run();
        }
    }
    
    func unregisterService() {
        netService?.stop();
        self.delegate?.serviceUnregistered?(netService!);
    }
    
    // MARK: NetService Browsing 
    func browseServicesOfType(_ type: String, inDomain domain: String) -> Void {
    
        DispatchQueue.global(qos: .userInitiated).async {
        
            self.netServiceBrowser = NetServiceBrowser();
            self.netServiceBrowser?.delegate = self;
            self.netServiceBrowser?.searchForServices(ofType: type, inDomain: domain);
            
            RunLoop.current.run();
        }
    }
    
    // MARK: NetService Resolving
    func resolveServiceNamed(_ name: String, ofType type: String, inDomain domain:String, withTimeout timeout: TimeInterval) -> Void {
     
        DispatchQueue.global(qos: .userInitiated).async {
            
            let service = NetService(domain: domain, type: type, name: name);
            service.delegate = self;
            service.resolve(withTimeout: timeout);
            
            RunLoop.current.run();
        }
    }
    
    // MARK: NetService Delegate
    func netServiceWillPublish(_ service: NetService) {
        // not supported
    }
    
    func netServiceDidPublish(_ service: NetService) {
        DispatchQueue.main.async {
            print("NSD Manager did publish service: ", service.name, ", ", service.type, ", ", service.domain, ", ", service.port);
            self.delegate?.serviceRegistered?(service);
        }
    }
    
    func netService(_ service: NetService, didNotPublish errorDict: [String : NSNumber]) {
       // not supported
    }
    
    // MARK: NetServiceBrowser Delegate
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        // not supported
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        DispatchQueue.main.async {
            print("Network Service Discovery: ADD | ", service.name, " | ", service.type, " | ", service.domain);
            self.delegate?.serviceAdded?(service, moreComing: moreComing);
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        DispatchQueue.main.async {
            print("Network Service Discovery: REMOVE | ", service.name, " | ", service.type, " | ", service.domain);
            self.delegate?.serviceRemoved?(service, moreComing: moreComing);
        }
    }
    
    // MARK: NetService Resolving 
    func netServiceWillResolve(_ service: NetService) {
        print("Resolving service ", service.name);
    }
    
    func netServiceDidResolveAddress(_ service: NetService) {
        DispatchQueue.main.async {
            print("Did resolve: ", service.name, " | ", service.type, " | ", service.domain);
            
            // may get more than one address 
            let addresses : [Data]? = service.addresses;
            addresses?.forEach { addressData in
                
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST));
                do {
                try addressData.withUnsafeBytes { ( pointer : UnsafePointer<sockaddr>) -> Void in
                    guard getnameinfo(pointer, socklen_t(addressData.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                        throw NSError(domain: "NSDManager",
                                      code: 0,
                                      userInfo: ["error":"unable to read ip address from resolved data"]);
                        }
                    }
                } catch {
                    print(error);
                    return;
                }
                
                let address = String(cString:hostname);
                print("Network service: ", service.name, " discovery RESOLVED ip address: ", address);
                self.delegate?.serviceResolved?(service, withAddress: address, andPort: service.port);
            }
        }
    }
    
    func netService(_ service: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("Not resolved service ", service.name, ", error ", errorDict)
    }
}
