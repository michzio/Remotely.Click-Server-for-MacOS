//
//  NSDProxyObjC.m
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 12/06/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDProxyObjC.h"

// global pointer to NSDProxyObjC instance
static NSDProxyObjC *sharedNSDProxyObj = nil;

void nsd_register_callback(const char *name,
                           const char *regtype,
                           const char *domain,
                           nsd_flags_t flags,
                           void *context) {
    
    
    if(sharedNSDProxyObj != nil && sharedNSDProxyObj.registerCallbackBlock != nil)
        // call nsd register callback block
        sharedNSDProxyObj.registerCallbackBlock([NSString stringWithUTF8String:name],
                                                [NSString stringWithUTF8String:regtype],
                                                [NSString stringWithUTF8String:domain],
                                                flags );
    
}

void nsd_browse_callback(uint32_t interface_idx,
                         const char *service_name,
                         const char *regtype,
                         const char *domain,
                         nsd_flags_t flags,
                         void *context) {
    
    if(sharedNSDProxyObj != nil && sharedNSDProxyObj.browseCallbackBlock != nil)
        // call nsd browse callback block
        sharedNSDProxyObj.browseCallbackBlock(interface_idx,
                                              [NSString stringWithUTF8String:service_name],
                                              [NSString stringWithUTF8String: regtype],
                                              [NSString stringWithUTF8String: domain],
                                              flags);
    
    /*
    if(flags & ADDED) {
        printf("NSD ADDED: %d | %s | %s | %s\n", interface_idx, service_name, regtype, domain);
    } else if(flags & REMOVED) {
        printf("NSD REMOVED:  %d | %s | %s | %s\n", interface_idx, service_name, regtype, domain);
    }
    
    if( !(flags & MORE) )
        fflush(stdout);
    */
}

void nsd_resolve_callback(uint32_t interface_idx,
                          const char *fullname,
                          const char *hosttarget,
                          uint16_t port,
                          nsd_flags_t flags,
                          void *context) {
    
    if(sharedNSDProxyObj != nil && sharedNSDProxyObj.resolveCallbackBlock != nil)
        // call nsd resolve callback block
        sharedNSDProxyObj.resolveCallbackBlock(interface_idx,
                                               [NSString stringWithUTF8String: fullname],
                                               [NSString stringWithUTF8String: hosttarget],
                                               port,
                                               flags);
}

@implementation NSDProxyObjC

@synthesize registerCallbackBlock;
@synthesize browseCallbackBlock;
@synthesize resolveCallbackBlock;


+ (id)sharedNSD {

    @synchronized(self) {
        if (sharedNSDProxyObj == nil)
            sharedNSDProxyObj = [[self alloc] init];
    }
    return sharedNSDProxyObj;

}

- (id) init
{
    self = [super init];
    if(self) {
        // init some fields
    }
    return self; 
}

- (void) simpleRegisterServiceOfType: (NSString *) regtype atPort: (UInt16) port withCallback: (NSDRegisterCallbackBlock) callbackBlock {
    
    registerCallbackBlock = callbackBlock;
    
    nsd_simple_register(regtype.UTF8String, port, nsd_register_callback);
    
}

- (void) simpleRegisterServiceInBackgroundOfType: (NSString *) regtype atPort: (UInt16) port withCallback: (NSDRegisterCallbackBlock) callbackBlock {
    
   registerCallbackBlock = callbackBlock;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        nsd_simple_register(regtype.UTF8String, port, nsd_register_callback);
    });
}

- (void) registerServiceNamed: (NSString *) name ofType: (NSString *) regtype inDomain: (NSString *) domain withHost: (NSString *) host andPort: (UInt16) port usingCallback: (NSDRegisterCallbackBlock) callbackBlock {
    
    registerCallbackBlock = callbackBlock;
    
    nsd_register(name.UTF8String, regtype.UTF8String, domain.UTF8String, host.UTF8String, port, nsd_register_callback);
}

- (void) registerServiceInBackgroundNamed: (NSString *) name ofType: (NSString *) regtype inDomain: (NSString *) domain withHost: (NSString *) host andPort: (UInt16) port usingCallback: (NSDRegisterCallbackBlock) callbackBlock {
    
    registerCallbackBlock = callbackBlock;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        nsd_register(name.UTF8String, regtype.UTF8String, domain.UTF8String, host.UTF8String, port, nsd_register_callback);
    });
}

- (void) browseServicesOfType: (NSString *) regtype inDomain: (NSString *)domain withCallback: (NSDBrowseCallbackBlock) callbackBlock {
    
    browseCallbackBlock = callbackBlock;
    
    nsd_browse(regtype.UTF8String, domain.UTF8String, nsd_browse_callback);
}

- (void) browseServicesInBackgroundOfType: (NSString *) regtype inDomain: (NSString *)domain withCallback: (NSDBrowseCallbackBlock) callbackBlock {
    
    browseCallbackBlock = callbackBlock;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        nsd_browse(regtype.UTF8String, domain.UTF8String, nsd_browse_callback);
    });
}

- (void) resolveServiceNamed: (NSString *) name ofType: (NSString *) regtype inDomain: (NSString *)domain withInterfaceIdx: (const UInt32) interfaceIdx usingCallback: (NSDResolveCallbackBlock) callbackBlock {
    
    resolveCallbackBlock = callbackBlock;
    
    nsd_resolve(name.UTF8String, regtype.UTF8String, domain.UTF8String, interfaceIdx,nsd_resolve_callback);
}

- (void) resolveServiceInBackgroundNamed: (NSString *) name ofType: (NSString *) regtype inDomain: (NSString *)domain withInterfaceIdx: (const UInt32) interfaceIdx usingCallback: (NSDResolveCallbackBlock) callbackBlock {
    
    resolveCallbackBlock = callbackBlock;
    
     dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
         nsd_resolve(name.UTF8String, regtype.UTF8String, domain.UTF8String, interfaceIdx,nsd_resolve_callback);
     });
}

@end
