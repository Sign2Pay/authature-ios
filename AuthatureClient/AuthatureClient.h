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

/**
* Authature Scope names
*/
FOUNDATION_EXPORT NSString *const AUTHATURE_SCOPE_PRE_APPROVAL;
FOUNDATION_EXPORT NSString *const AUTHATURE_SCOPE_AUTHENTICATE;
FOUNDATION_EXPORT NSString *const AUTHATURE_SCOPE_SIGNATURE_CAPTURE;

/**
* AuthatureClient facilitates the interaction with the Authature OAuth2 flow and API's
*/
@interface AuthatureClient : NSObject
/**
* The clients current settings
* See AuthatureClientSettings.h
*/
@property (strong, nonatomic) AuthatureClientSettings *settings;
/**
* The current user parameters
* See AuthatureUserParams.h
*/
@property (strong, nonatomic) AuthatureUserParams *userParams;

/**
* The current deviceUid.
* This property is set by the AuthatureClient but can be changed after initialization
*/
@property (strong, nonatomic) NSString *deviceUid;

/**
* The current delegate
*/
@property (strong, nonatomic) NSObject<AuthatureDelegate> *delegate;

/**
* Whether the client should automaticall store the received Tokens per ClientId and Scopes.
* Default is NO
*/
@property (nonatomic) BOOL automaticTokenStorageEnabled;

- (instancetype)initWithSettings:(AuthatureClientSettings *)settings
                   userParams:(AuthatureUserParams *) userParams
                  andDelegate:(NSObject<AuthatureDelegate>*) delegate;

/**
* Starts the Authature Flow to get a token for the preapproval scope
*/
- (void)startAuthatureFlowForPreapprovalWithSuccess:(void(^)(NSDictionary *))successCallback
                                         andFailure:(void(^)(NSString *, NSString *))errorCallback;

/**
* Starts the Authature Flow to get a token for the authenticate scope
*/
- (void)startAuthatureFlowForAuthenticationWithSuccess:(void(^)(NSDictionary *))successCallback
                                            andFailure:(void(^)(NSString *, NSString *))errorCallback;

/**
* Starts the Authature Flow to get a token for the capture scope
*/
- (void)startAuthatureFlowForSignatureCaptureWithSuccess:(void(^)(NSDictionary *))successCallback
                                              andFailure:(void(^)(NSString *, NSString *))errorCallback;

/**
* Starts the Authature Flow to get a token for a custom scopes
*/
- (void)startAuthatureFlowForScope:(NSString *)scope withSuccess:(void(^)(NSDictionary *))successCallback
                        andFailure:(void(^)(NSString *, NSString *))errorCallback;;

/**
* If automaticTokenStorageEnabled == YES, getStoredTokenForScope: can be used to retreive the token a a later point.
*/
- (NSDictionary *)getStoredTokenForScope:(NSString *)scope;

/**
* If automaticTokenStorageEnabled == YES, destroyStoredTokenForScope: can be used to destroy the token.
*/
- (void)destroyStoredTokenForScope:(NSString *)scope;

/**
* If automaticTokenStorageEnabled == YES,
* verifyStoredTokenValidityforScope:callBack:errorCalback can be used to verify if the token is still valid
* The callback contains a BOOL which indicates the tokens validity.
* If NO, the second parameter contains a dictionary with error/error_description info
*/
- (void)verifyStoredTokenValidityforScope:(NSString *)scope
                                 callBack:(void (^)(BOOL, NSDictionary *))callback
                            errorCallBack:(void (^)(NSError *)) errorCallback;

/**
* Can be used to verify if a token is still valid
* The callback contains a BOOL which indicates the tokens validity.
* If NO, the second parameter contains a dictionary with error/error_description info
*/
- (void)verifyTokenValidity:(NSDictionary *)token
                  forScope:(NSString *)scope
                   callBack:(void (^)(BOOL, NSDictionary *))callback
              errorCallBack:(void (^)(NSError *)) errorCallback;
@end
