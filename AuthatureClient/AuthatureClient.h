//
//  AuthatureClient.h
//  AuthatureClient
//
//  Created by Mark Meeus on 29/06/15.
//  Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthatureDelegate.h"
#import "AuthatureClientSettings.h"
#import "AuthatureUserParams.h"
#import <UIKit/UIKit.h>


FOUNDATION_EXPORT NSString *const AUTHATURE_SCOPE_PRE_APPROVAL;
FOUNDATION_EXPORT NSString *const AUTHATURE_SCOPE_AUTHENTICATE;
FOUNDATION_EXPORT NSString *const AUTHATURE_SCOPE_SIGNATURE_CAPTURE;


@interface AuthatureClient : NSObject

@property (strong, nonatomic) AuthatureClientSettings *settings;
@property (strong, nonatomic) AuthatureUserParams *userParams;
@property (strong, nonatomic) NSString *deviceUid;
@property (strong, nonatomic) NSObject<AuthatureDelegate> *delegate;
@property (nonatomic) BOOL automaticTokenStorageEnabled;

- (instancetype)initWithSettings:(AuthatureClientSettings *)settings
                   userParams:(AuthatureUserParams *) userParams
                  andDelegate:(NSObject<AuthatureDelegate>*) delegate;

- (void)startAuthatureFlowForPreapprovalWithSuccess:(void(^)(NSDictionary *))successCallback
                                         andFailure:(void(^)(NSString *, NSString *))errorCallback;

- (void)startAuthatureFlowForAuthenticationWithSuccess:(void(^)(NSDictionary *))successCallback
                                            andFailure:(void(^)(NSString *, NSString *))errorCallback;;

- (void)startAuthatureFlowForSignatureCaptureWithSuccess:(void(^)(NSDictionary *))successCallback
                                              andFailure:(void(^)(NSString *, NSString *))errorCallback;;

- (void)startAuthatureFlowForScope:(NSString *)scope withSuccess:(void(^)(NSDictionary *))successCallback
                        andFailure:(void(^)(NSString *, NSString *))errorCallback;;

- (NSDictionary *)getStoredTokenForScope:(NSString *)scope;

- (void)destroyStoredTokenForScope:(NSString *)scope;

- (void)verifyStoredTokenValidityforScope:(NSString *)scope
                                 callBack:(void (^)(BOOL, NSDictionary *))callback
                            errorCallBack:(void (^)(NSError *)) errorCallback;

- (void)verifyTokenValidity:(NSDictionary *)token
                  forScope:(NSString *)scope
                   callBack:(void (^)(BOOL, NSDictionary *))callback
              errorCallBack:(void (^)(NSError *)) errorCallback;
@end
