//
// Created by Mark Meeus on 30/06/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
* AuthatureAccessTokenStorage is a static convenience class that can be used to store Authature access tokens.
* Tokens are organized per ClientId and a key.
* Tokens are stored in the users Library/Authature folder and are stored with the option NSDataWritingFileProtectionComplete
*/
@interface AuthatureAccessTokenStorage : NSObject

/**
* Returns an access token that was previously stored using the saveAccessToken:ForClientId:WithKey: method.
* Returns nil if the token cannot be found
*/
+ (NSDictionary *) getAccessTokenForClientId:(NSString *) clientId andKey:(NSString *)key;

/**
* Saves an access token for a given clientId and Key
*/
+ (void) saveAccessToken:(NSDictionary*) accessToken forClientId:(NSString *) clientId withKey:(NSString *)key;

/**
* Returns all access tokens for a given ClientId
*/
+ (NSArray *) allAccessTokensForClientId:(NSString *)clientId;

/**
* Destroys the token that has been previously saved with the saveAccessToken:ForClientId:WithKey: method.
*/
+ (void) destroyAccessTokenForClientId:(NSString *)clientId andKey:(NSString *)key;
@end