//
//  ServerProxyObjC.h
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 17/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

#ifndef ServerProxyObjC_h
#define ServerProxyObjC_h

#import <Foundation/Foundation.h>
#include "networking/generic_server.h"

typedef enum { ECHO_SERVER, RPC_SERVER, EVENT_SERVER } ServerType;

@protocol ServerProxyDelegate;

@interface ServerProxyObjC : NSObject

@property (weak) id<ServerProxyDelegate> delegate;

- (id) initWithSecurityPassword: (NSString *) password;
- (void) setSecurityPassword: (NSString *) password;
- (NSString *) getSecurityPassword;
- (void) setCustomPortNumber: (int) port;
- (int) getCutomPortNumber;
- (NSString *) getIpAddress; 
- (void) startServer: (server_t) serverFunc;
- (void) startServerInBackground: (server_t) serverFunc;
- (void) startServerOfType: (ServerType) serverType;
- (void) startServerInBackgroundOfType: (ServerType) serverType;
- (void) endServer;
- (void) shutdownServer;

@end

@protocol ServerProxyDelegate <NSObject>

@optional
// notify delegate about server start event
- (void) serverStartWithPasvSock: (int) fd boundToPort: (int) port onHostAddress: (NSString *) ipAddress;
- (void) serverEnd;
- (void) serverErrorOnPasvSock: (int) fd withErrorCode: (int) errCode andErrorMessage: (NSString *) errMessage;
- (void) clientConnectedToConnSock: (int) fd withPort: (int) port andPeerAddress: (NSString *) ipAddress;
- (void) clientAuthenticatedOnConnSock: (int) fd withPort: (int) port andPeerAddress: (NSString *) ipAddress andPeerName: (NSString *) name andOS: (NSString *) nameOfOS;
- (void) clientDisconnectingOnConnSock: (int) fd withPort: (int) port andPeerAddress: (NSString *) ipAddress;
- (void) connectionErrorOnConnSock: (int) fd withErrorCode: (int) errCode andErrorMessage: (NSString *) errMessage;
- (void) datagramErrorOnPasvSock: (int) fd withErrorCode: (int) errCode andErrorMessage: (NSString *) errMessage;

@end

#endif /* ServerProxyObjC_h */
