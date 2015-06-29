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

@property (strong, nonatomic) AuthatureClientSettings * Settings;
@property (strong, nonatomic) AuthatureUser* User;
@property (strong, nonatomic) NSObject<AuthatureDelegate>* Delegate;

- (instancetype)initWithSettings:(AuthatureClientSettings *)settings
                            user:(AuthatureUser *) user
                        delegate:(NSObject<AuthatureDelegate>*) delegate;

- (void)startPreApproval;
@end
