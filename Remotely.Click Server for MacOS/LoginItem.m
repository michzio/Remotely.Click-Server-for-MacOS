//
//  LoginItem.m
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 17/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "LoginItem.h"

@implementation LoginItem

- (void) someMethod {
    NSLog(@"SomeMethod Ran");
}

- (void)enableLoginItemWithURL:(NSURL *)itemURL
{
    LSSharedFileListRef loginListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginListRef) {
        // Insert the item at the bottom of Login Items list.
        LSSharedFileListItemRef loginItemRef = LSSharedFileListInsertItemURL(loginListRef,
                                                                             kLSSharedFileListItemLast,
                                                                             NULL,
                                                                             NULL,
                                                                             (__bridge CFURLRef) itemURL,
                                                                             NULL,
                                                                             NULL);
        if (loginItemRef) {
            CFRelease(loginItemRef);
        }
        CFRelease(loginListRef);
    }
}

@end
