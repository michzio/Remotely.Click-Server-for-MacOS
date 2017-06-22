//
//  ServerManager.swift
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 16/06/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

import Foundation

enum ServerStatus : String {
    case Down
    case Running
    case Starting
}

// dictionary of server's connected devices
typealias SockFD = Int32;

class ServerManager : NSObject, ServerProxyDelegate, NSDManagerDelegate {
    
    public static let ServerStatusChangedNotification = Notification.Name("SMServerStatusChangedNotification");
    public static let ServerStatusNotificationKey = "SMServerStatusNotificationKey";
    public static let ServerPortNumberNotificationKey = "SMServerPortNumberNotificationKey";
    public static let ServerIpAddressNotificationKey = "SMServerIpAddressNotificationKey";
    public static let ClientConnectedNotification = Notification.Name("SMClientConnectedNotification");
    public static let ClientLostNotification = Notification.Name("SMClientLostNotification");
    public static let ClientConnSockNotificationKey = "SMClientConnSockNotificationKey";
    public static let ClientDeviceIdentityNotificationKey = "SMClientDeviceIdentityNotificationKey";
    public static let ClientDeviceOSNotificationKey = "SMClientDeviceOSNotificationKey";
    
    private static let NSD_SERVICE_TYPE = "_remotely_click._tcp.";
    
    static let sharedInstance = ServerManager()
    
    // info about current server state
    private var _serverStatus : ServerStatus = .Down {
     
        didSet {
            print("Server Status changed to ", _serverStatus.rawValue);
            
            NotificationCenter
                .default
                .post(name: ServerManager.ServerStatusChangedNotification,
                 object:self,
                 userInfo: [ServerManager.ServerStatusNotificationKey : _serverStatus,
                            ServerManager.ServerPortNumberNotificationKey : serverPortNumber ?? 0,
                            ServerManager.ServerIpAddressNotificationKey : serverIpAddress ?? "0.0.0.0"]);
        }
    }
    var serverStatus : ServerStatus {
        get {
            return _serverStatus;
        }
        set {
            let oldValue = _serverStatus;
            _serverStatus = newValue;
            
            if(newValue == .Down) {
                endServer();
            } else if (newValue == .Starting && oldValue == .Down) {
                startServer();
            } else if(newValue == .Starting) {
                restartServer();
            }
        }
    }
    private(set) var serverPortNumber : Int!;   // port number currently used by server
    private(set) var serverIpAddress : String!; // ip address currently used by server
    
    struct ClientInfo {
     
        var connSock : SockFD!;
        var deviceIdentity : String!;
        var deviceOS : String!;
        var connPortNumber : Int!;
        var connIpAddress : String!;
        
    }
    
    private(set) var connectedDevices = [SockFD: ClientInfo]();
    
    // custom server configuration
    var securityPassword : String!;
    var customPortNumber : Int!;    // custom port number to bind server at start
    var discoverableName : String!; 
    
    // flags
    private var shouldRestart : Bool = false;
    private var isRegisteredForNetworkDiscovery = false;
    
    // helper objects
    private var serverProxy: ServerProxyObjC! // enables access to Remotely.Click Server C API
    private var nsdManager : NSDManager!      // abstract Cocoa NetService API for Bonjour

    private override init() {
        super.init();
        nsdManager = NSDManager();
        nsdManager.delegate = self;
    }
    
    func startServer() -> Void {
        // set private field without side effects to avoid recurring server restarting
        // _serverStatus = .Starting;
        
        serverProxy = ServerProxyObjC();
        serverProxy.delegate = self;
        if(customPortNumber != nil) { serverProxy.setCustomPortNumber(Int32(customPortNumber)); }
        if(securityPassword != nil) { serverProxy.setSecurityPassword(securityPassword); }
        serverProxy.startServer(inBackgroundOf: ECHO_SERVER);
    }
    
    func endServer() -> Void {
        
        serverProxy.endServer();

        /***
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                // your code here
            };
        ***/
    }
    
    func restartServer() {
        print("Restarting server...");
        shouldRestart = true;
        endServer();
    }
    
    func startServiceDiscovery(withName name : String) -> Void {
        
        if(!isRegisteredForNetworkDiscovery) {
            // start network service discovery
            nsdManager.registerService(domain: "",                      // if empty use "local."
                         type: ServerManager.NSD_SERVICE_TYPE,          // _remotely_click._tcp.
                                       name: name,                      // if empty use computer name
                                       port: Int32(serverPortNumber));  // use running server port
        }
    }
    
    func stopServiceDiscovery() -> Void {
        
        if(isRegisteredForNetworkDiscovery) {
            // stop network service discovery
            nsdManager.unregisterService(); 
        }
    }
    
    func restartServiceDiscovery(withName name : String) -> Void {
     
        if(isRegisteredForNetworkDiscovery) {
            // then restart network service discovery
            stopServiceDiscovery();
            startServiceDiscovery(withName: name); 
        }
        
    }
    
    // MARK: Server Proxy Delegate Methods
    func serverStart(withPasvSock fd: Int32, boundToPort port: Int32, onHostAddress ipAddress: String!) {
        
        DispatchQueue.main.async {
            
            print("Server started with  pasv sock: ", fd, " (port: ", port, ", ip: ", ipAddress, ")");
        
            self.serverPortNumber = Int(port);
            self.serverIpAddress = ipAddress;
            self.serverStatus = .Running;
        
            if(self.discoverableName != nil) {
                self.startServiceDiscovery(withName: self.discoverableName);
            }
            
        }
    }
    
    func serverEnd() {
       DispatchQueue.main.async {
        
            self.stopServiceDiscovery();
            self.serverPortNumber = nil;
            self.serverIpAddress = nil;
            self.discoverableName = nil;
            self.serverStatus = .Down;
            self.serverProxy = nil;
            print("Server ended.");
        
            if(self.shouldRestart) {
                self.shouldRestart = false;
                self.startServer();
            }
        }
    }
    
    func serverError(onPasvSock fd: Int32, withErrorCode errCode: Int32, andErrorMessage errMessage: String!) {
        
        print("Server error occurred ", fd);
    }
    
    func clientConnected(toConnSock fd: Int32, withPort port: Int32, andPeerAddress ipAddress: String!)
    {
        
        print("Client connected ", fd);
        serverIpAddress = serverProxy.getIpAddress(); // renew current server IP address
    }
    
    func clientAuthenticated(onConnSock fd: Int32, withPort port: Int32, andPeerAddress ipAddress: String!, andPeerName name: String!, andOS nameOfOS: String!) {
        
        DispatchQueue.main.async {
        
            print("Client authenticated ", fd);
        
            // add client device connected and authenticated
            // to dictionary of all connected to the server client devices
            let clientInfo = ClientInfo(connSock: fd,
                                        deviceIdentity: name,
                                        deviceOS: nameOfOS,
                                        connPortNumber: Int(port),
                                        connIpAddress: ipAddress);
            
            self.connectedDevices[fd] = clientInfo;
            
            NotificationCenter.default
                    .post(name: ServerManager.ClientConnectedNotification,
                     object:self,
                     userInfo: [ServerManager.ClientConnSockNotificationKey : fd,
                                ServerManager.ClientDeviceIdentityNotificationKey : name,
                                ServerManager.ClientDeviceOSNotificationKey : nameOfOS]);
            
        }
    }

    func clientDisconnecting(onConnSock fd: Int32, withPort port: Int32, andPeerAddress ipAddress: String!) {

        DispatchQueue.main.async {
        
            print("Client disconnecting ", fd);
            
            // remove client device that is disconnecting
            // from dictionary of all connected to the server client devices
            self.connectedDevices.removeValue(forKey: fd);
            
            NotificationCenter.default
                     .post(name: ServerManager.ClientLostNotification,
                      object:self,
                      userInfo: [ServerManager.ClientConnSockNotificationKey : fd]);

        }
    }
    
    func connectionError(onConnSock fd: Int32, withErrorCode errCode: Int32, andErrorMessage errMessage: String!) {
        
        DispatchQueue.main.async {
            
            print("Connection error occurred ", fd);
            
            // remove client device if error happens
            // on connection to this client device
            self.connectedDevices.removeValue(forKey: fd);
            
            NotificationCenter.default
                .post(name: ServerManager.ClientLostNotification,
                      object:self,
                      userInfo: [ServerManager.ClientConnSockNotificationKey : fd]);
        }
    }
    
    // MARK: NSDManager Delegate Methods
    func serviceRegistered(_ service: NetService) {
        DispatchQueue.main.async {
            print("Service registered: ", service);
            self.isRegisteredForNetworkDiscovery = true;
        }
    }
    
    func serviceUnregistered(_ service: NetService) {
     
        DispatchQueue.main.async {
            print("Service unregistered: ", service);
            self.isRegisteredForNetworkDiscovery = false;
        }
    }
    
    func serviceAdded(_ service: NetService, moreComing more: Bool) {
        
        print("Service added: ", service);
        
        self.nsdManager.resolveServiceNamed(service.name, ofType: service.type, inDomain: service.domain, withTimeout: 3.0);
    }
    
    func serviceRemoved(_ service: NetService, moreComing more: Bool) {
        
        print("Service removed: ", service);
    }
    
    func serviceResolved(_ service: NetService, withAddress address: String, andPort port: Int) {
        
        print("Service resolved with address: ", address, ", port: ", port);
    }
}
