//
// Created by Mark Meeus on 29/06/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//


#import <Foundation/Foundation.h>

/**
* Settings used to intialize an AuthatureClient
*/
@interface AuthatureClientSettings : NSObject

/**
* The OAuth2 clientId
*/
@property (strong, nonatomic) NSString *clientId;

/**
* Your OAuth2 callback url.
*/
@property (strong, nonatomic) NSString *callbackUrl;

- (instancetype)initWithClientId:(NSString *)clientId
                     callbackUrl:(NSString *)callbackUrl;

@end