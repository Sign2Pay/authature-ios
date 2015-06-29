//
//  AuthatureClient.h
//  AuthatureClient
//
//  Created by Mark Meeus on 29/06/15.
//  Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthatureDelegate.h"
#import "AuthatureUser.h"
#import <UIKit/UIKit.h>

@class AuthatureClientSettings;

@interface AuthatureClient : NSObject

@property (strong, nonatomic) AuthatureClientSettings *settings;
@property (strong, nonatomic) AuthatureUser *user;
@property (strong, nonatomic) NSString *deviceUid;
@property (strong, nonatomic) NSObject<AuthatureDelegate> *delegate;

- (instancetype)initWithSettings:(AuthatureClientSettings *)settings
                            user:(AuthatureUser *) user
                        delegate:(NSObject<AuthatureDelegate>*) delegate;

- (void)startPreApproval;
@end
