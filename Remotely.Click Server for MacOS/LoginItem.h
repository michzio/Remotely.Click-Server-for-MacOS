//
//  LoginItem.h
//  Remotely.Click Server for MacOS
//
//  Created by Michal Ziobro on 17/05/2017.
//  Copyright © 2017 Michal Ziobro. All rights reserved.
//

#ifndef LoginItem_h
#define LoginItem_h

#import <Foundation/Foundation.h>

@interface LoginItem : NSObject

@property (strong, nonatomic) id someProperty;

- (void) someMethod;
- (void)enableLoginItemWithURL:(NSURL *)itemURL; 

@end


#endif /* LoginItem_h */
