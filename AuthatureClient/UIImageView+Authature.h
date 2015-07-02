//
// Created by Mark Meeus on 01/07/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"

/**
* Category on UIButton
* Adds Bank Logo functionality
*/
@interface UIImageView (Authature)

/**
* Sets the default Bank Logo's for the current IP as the background of the button.
*/
-(void) useAsAuthatureBankLogos;

/**
* Sets the Bank Logo's for a specific country as the background of the button.
*/
-(void) useAsAuthatureBankLogosForCountryCode:(NSString *)countryCode;

/**
* Sets the Bank Logo for a given access token as the background of the button.
*/
-(void) useAsAuthatureBankLogosWithToken:(NSDictionary *)accessToken;

@end