//
//  ServerProxyObjC.m
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 17/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <comparer.h>
#include <linked_list/linked_list.h>
#include <common/fifo_queue.h>
#include <bitwise.h>
#include <test/assertion.h>
#include <common/endianness.h>
#include "networking/stream_server.h"
#include "server.h"
#include "networking/passive_socket.h"

#import "ServerProxyObjC.h"

void on_server_start(const sock_fd_t ps_fd, const int server_port, const char *server_ip, void *callback_arg) {

    // cast callback argument to ServerProxy object in Obj-C
    ServerProxyObjC *serverProxy = (__bridge ServerProxyObjC *)callback_arg;
    // forward event handling to delegate method on ServerProxy's delegate object
    if( serverProxy.delegate != nil && [serverProxy.delegate respondsToSelector:
                                        @selector(serverStartWithPasvSock:boundToPort:onHostAddress:)]) {
        [serverProxy.delegate serverStartWithPasvSock:ps_fd
                              boundToPort:server_port
                              onHostAddress:[NSString stringWithUTF8String:server_ip] ];
    }
}

void on_server_end(const sock_fd_t ps_fd, void *callback_arg) {
    
    // cast callback argument to ServerProxy object in Obj-C
    ServerProxyObjC *serverProxy = (__bridge ServerProxyObjC *)callback_arg;
    // forward event handling to delegate method on ServerProxy's delegate object
    if( serverProxy.delegate != nil && [serverProxy.delegate respondsToSelector:
                                        @selector(serverEnd)]) {
        [serverProxy.delegate serverEnd];
    }
}

void on_server_error(const sock_fd_t ps_fd, const int error_code, const char *error_msg, void *callback_arg) {
 
    // cast callback argument to ServerProxy object in Obj-C
    ServerProxyObjC *serverProxy = (__bridge ServerProxyObjC *)callback_arg;
    // forward event handling to delegate method on ServerProxy's delegate object
    if( serverProxy.delegate != nil && [serverProxy.delegate respondsToSelector:
                                        @selector(serverErrorOnPasvSock:withErrorCode:andErrorMessage:)]) {
        [serverProxy.delegate serverErrorOnPasvSock:ps_fd
                              withErrorCode:error_code
                              andErrorMessage:[NSString stringWithUTF8String:error_msg]];
    }
}

void on_client_connected(const sock_fd_t cs_fd, const int client_port, const char *client_ip, void *callback_arg) {
    
    // cast callback argument to ServerProxy object in Obj-C
    ServerProxyObjC *serverProxy = (__bridge ServerProxyObjC *)callback_arg;
    // forward event handling to delegate method on ServerProxy's delegate object
    if( serverProxy.delegate != nil && [serverProxy.delegate respondsToSelector:
                                        @selector(clientConnectedToConnSock:withPort:andPeerAddress:)]) {
        [serverProxy.delegate clientConnectedToConnSock:cs_fd
                              withPort:client_port
                              andPeerAddress:[NSString stringWithUTF8String:client_ip]];
    }
}

void on_client_authenticated(const sock_fd_t cs_fd, const int client_port, const char *client_ip, const char *client_name, const char *client_os,void *callback_arg) {
    
    // cast callback argument to ServerProxy object in Obj-C
    ServerProxyObjC *serverProxy = (__bridge ServerProxyObjC *)callback_arg;
    // forward event handling to delegate method on ServerProxy's delegate object
    if( serverProxy.delegate != nil && [serverProxy.delegate respondsToSelector:
                                        @selector(clientAuthenticatedOnConnSock:withPort:andPeerAddress:andPeerName:andOS:)]) {
        
        [serverProxy.delegate clientAuthenticatedOnConnSock:cs_fd
                              withPort:client_port
                              andPeerAddress:[NSString stringWithUTF8String:client_ip]
                              andPeerName:[NSString stringWithUTF8String:client_name]
                              andOS: [NSString stringWithUTF8String:client_os]];
    }
}

void on_client_disconnecting(const sock_fd_t cs_fd, const int client_port, const char *client_ip, void *callback_arg) {
    
    // cast callback argument to ServerProxy object in Obj-C
    ServerProxyObjC *serverProxy = (__bridge ServerProxyObjC *)callback_arg;
    // forward event handling to delegate method on ServerProxy's delegate object
    if( serverProxy.delegate != nil && [serverProxy.delegate respondsToSelector:
                                        @selector(clientDisconnectingOnConnSock:withPort:andPeerAddress:)]) {
        [serverProxy.delegate clientDisconnectingOnConnSock:cs_fd
                              withPort:client_port
                              andPeerAddress:[NSString stringWithUTF8String:client_ip]];
    }
}

void on_connection_error(const sock_fd_t cs_fd, const int error_code, const char *error_msg, void *callback_arg) {
    
    // cast callback argument to ServerProxy object in Obj-C
    ServerProxyObjC *serverProxy = (__bridge ServerProxyObjC *)callback_arg;
    // forward event handling to delegate method on ServerProxy's delegate object
    if( serverProxy.delegate != nil && [serverProxy.delegate respondsToSelector:
                                        @selector(connectionErrorOnConnSock:withErrorCode:andErrorMessage:)]) {
        [serverProxy.delegate connectionErrorOnConnSock:cs_fd
                              withErrorCode:error_code
                              andErrorMessage:[NSString stringWithUTF8String:error_msg]];
    }
}

void on_datagram_error(const sock_fd_t ps_fd, const int error_code, const char *error_msg, void *callback_arg) {
    
    // cast callback argument to ServerProxy object in Obj-C
    ServerProxyObjC *serverProxy = (__bridge ServerProxyObjC *)callback_arg;
    // forward event handling to delegate method on ServerProxy's delegate object
    if( serverProxy.delegate != nil && [serverProxy.delegate respondsToSelector:
                                        @selector(datagramErrorOnPasvSock:withErrorCode:andErrorMessage:)] ) {
        
        [serverProxy.delegate datagramErrorOnPasvSock: ps_fd
                              withErrorCode: error_code
                              andErrorMessage: [NSString stringWithUTF8String: error_msg]];
    }
}

@implementation ServerProxyObjC : NSObject

@synthesize delegate; 

server_info_t *serverInfo;

- (id) init {
 
    self = [super init];
    if(self) {
        server_info_init(&serverInfo);
        server_info_set_port(serverInfo, "0");
        server_info_set_server_start_callback_arg(serverInfo, (__bridge void *)(self));
        server_info_set_server_start_callback(serverInfo, on_server_start);
        server_info_set_server_end_callback_arg(serverInfo, (__bridge_retained void *)(self));
        server_info_set_server_end_callback(serverInfo, on_server_end);
        server_info_set_server_error_callback_arg(serverInfo, (__bridge void *)(self));
        server_info_set_server_error_callback(serverInfo, on_server_error);
        server_info_set_client_connected_callback_arg(serverInfo, (__bridge void *)(self));
        server_info_set_client_connected_callback(serverInfo, on_client_connected);
        server_info_set_client_authenticated_callback_arg(serverInfo, (__bridge void *)(self));
        server_info_set_client_authenticated_callback(serverInfo, on_client_authenticated);
        server_info_set_client_disconnecting_callback_arg(serverInfo, (__bridge void *)(self));
        server_info_set_client_disconnecting_callback(serverInfo, on_client_disconnecting);
        server_info_set_connection_error_callback_arg(serverInfo, (__bridge void *)(self));
        server_info_set_connection_error_callback(serverInfo, on_connection_error);
        server_info_set_datagram_error_callback_arg(serverInfo, (__bridge void *)(self));
        server_info_set_datagram_error_callback(serverInfo, on_datagram_error);
    }
    return self;
}

- (id) initWithSecurityPassword: (NSString *) password {
 
    self = [self init];
    if(self) {
        [self setSecurityPassword:password];
    }
    return self;
}

- (void) setSecurityPassword: (NSString *) password {
    
    server_info_set_security_password(serverInfo, password.UTF8String);
}
- (NSString *) getSecurityPassword {
    
    return [NSString stringWithUTF8String: server_info_security_password(serverInfo)];
}

- (void) setCustomPortNumber: (int) port {
    
    char *portCstr = int_to_str(port, NULL);
    server_info_set_port(serverInfo, portCstr);
}

- (int) getCutomPortNumber {
    return atoi(server_info_port(serverInfo));
}

- (NSString *) getIpAddress {
    return [NSString stringWithUTF8String:server_info_ip(serverInfo)];
}

- (void) startServer: (server_t) serverFunc {
    
    start_server(serverFunc, serverInfo);

}

- (void) startServerInBackground: (server_t) serverFunc {
    
    dispatch_queue_t server_dispatch_queue = dispatch_queue_create("click.remotely.Server", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(server_dispatch_queue, ^(void){
        
        start_server(serverFunc, serverInfo);
        
        /***
         *   dispatch_async(dispatch_get_main_queue(), ^(void){
         *   //Run UI Updates
         *   });
         */
    });
}

- (void) startServerOfType: (ServerType) serverType {
 
    switch(serverType) {
        case ECHO_SERVER:
            [self startServer:echo_stream_server];
            break;
        case RPC_SERVER:
            [self startServer:rpc_stream_server];
            break;
        case EVENT_SERVER:
            [self startServer:event_stream_server];
            break;
        default:
            break;
    }
}

- (void) startServerInBackgroundOfType: (ServerType) serverType {
    
    switch(serverType) {
        case ECHO_SERVER:
            [self startServerInBackground:echo_stream_server];
            break;
        case RPC_SERVER:
            [self startServerInBackground:rpc_stream_server];
            break;
        case EVENT_SERVER:
            [self startServerInBackground:event_stream_server];
            break;
        default:
            break;
    }
}

- (void) endServer {

    end_server(serverInfo);
}

- (void) shutdownServer {
    
    shutdown_server(serverInfo);
}

@end
