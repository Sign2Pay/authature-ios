//
// Created by Mark Meeus on 30/06/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AuthatureAccessTokenStorage : NSObject

+ (NSDictionary *) getAccessTokenForClientId:(NSString *) clientId andKey:(NSString *)key;

+ (void) saveAccessToken:(NSDictionary*) accessToken forClientId:(NSString *) clientId withKey:(NSString *)key;

+ (NSArray *) allAccessTokensForClientId:(NSString *)clientId;

+ (void) destroyAccessTokenForClientId:(NSString *)clientId andKey:(NSString *)key;
@end