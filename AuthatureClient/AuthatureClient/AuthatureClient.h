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
#import "AuthatureClientSettings.h"
#import <UIKit/UIKit.h>


FOUNDATION_EXPORT NSString *const AUTHATURE_SCOPE_PRE_APPROVAL;
FOUNDATION_EXPORT NSString *const AUTHATURE_SCOPE_AUTHENTICATE;
FOUNDATION_EXPORT NSString *const AUTHATURE_SCOPE_SIGNATURE_CAPTURE;


@interface AuthatureClient : NSObject

@property (strong, nonatomic) AuthatureClientSettings *settings;
@property (strong, nonatomic) AuthatureUser *user;
@property (strong, nonatomic) NSString *deviceUid;
@property (strong, nonatomic) NSObject<AuthatureDelegate> *delegate;
@property (nonatomic) BOOL automaticTokenStorageEnabled;

- (instancetype)initWithSettings:(AuthatureClientSettings *)settings
                            user:(AuthatureUser *) user
                        delegate:(NSObject<AuthatureDelegate>*) delegate;

- (void)startGetTokenForPreApproval;

- (void)startGetTokenForAuthentication;

- (void)startGetTokenForSignatureCapture;

- (void)startGetTokenForScope:(NSString *)scope;

@end
