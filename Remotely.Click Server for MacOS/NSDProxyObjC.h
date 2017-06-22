//
//  NSDProxyObjC.h
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 12/06/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

#ifndef NSDProxyObjC_h
#define NSDProxyObjC_h

#include <network_service_discovery.h>

typedef void (^NSDRegisterCallbackBlock)(NSString *name, NSString *regtype, NSString *domain, nsd_flags_t flags);
typedef void (^NSDBrowseCallbackBlock)(UInt32 interface_idx, NSString *service_name, NSString *regtype, NSString *domain, nsd_flags_t flags);
typedef void (^NSDResolveCallbackBlock)(UInt32 interface_idx, NSString *fullname, NSString *hosttarget, UInt16 port, nsd_flags_t flags);

@interface NSDProxyObjC : NSObject

@property (nonatomic, copy, readonly) NSDRegisterCallbackBlock registerCallbackBlock;
@property (nonatomic, copy, readonly) NSDBrowseCallbackBlock browseCallbackBlock;
@property (nonatomic, copy, readonly) NSDResolveCallbackBlock resolveCallbackBlock;

+ (id)sharedNSD;

- (void) simpleRegisterServiceOfType: (NSString *) type atPort: (UInt16) port withCallback: (NSDRegisterCallbackBlock) callbackBlock;
- (void) simpleRegisterServiceInBackgroundOfType: (NSString *) type atPort: (UInt16) port withCallback: (NSDRegisterCallbackBlock) callbackBlock;
- (void) registerServiceNamed: (NSString *) name ofType: (NSString *) regtype inDomain: (NSString *) domain withHost: (NSString *) host andPort: (UInt16) port usingCallback: (NSDRegisterCallbackBlock) callbackBlock;
- (void) registerServiceInBackgroundNamed: (NSString *) name ofType: (NSString *) regtype inDomain: (NSString *) domain withHost: (NSString *) host andPort: (UInt16) port usingCallback: (NSDRegisterCallbackBlock) callbackBlock;
- (void) browseServicesOfType: (NSString *) regtype inDomain: (NSString *)domain withCallback: (NSDBrowseCallbackBlock) callbackBlock;
- (void) browseServicesInBackgroundOfType: (NSString *) regtype inDomain: (NSString *)domain withCallback: (NSDBrowseCallbackBlock) callbackBlock;
- (void) resolveServiceNamed: (NSString *) name ofType: (NSString *) regtype inDomain: (NSString *)domain withInterfaceIdx: (const UInt32) interfaceIdx usingCallback: (NSDResolveCallbackBlock) callbackBlock;
- (void) resolveServiceInBackgroundNamed: (NSString *) name ofType: (NSString *) regtype inDomain: (NSString *)domain withInterfaceIdx: (const UInt32) interfaceIdx usingCallback: (NSDResolveCallbackBlock) callbackBlock;

@end

#endif /* NSDProxyObjC_h */
