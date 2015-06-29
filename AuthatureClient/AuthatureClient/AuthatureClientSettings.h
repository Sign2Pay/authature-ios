//
// Created by Mark Meeus on 29/06/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthatureClientSettings : NSObject

@property (strong, nonatomic) NSString * ClientId;
@property (strong, nonatomic) NSString * ClientSecret;
@property (strong, nonatomic) NSString * CallbackUrl;

- (instancetype)initWithClientId:(NSString *)clientId
                    clientSecret:(NSString *)clientSecret
                     callbackUrl:(NSString *)callbackUrl;

@end