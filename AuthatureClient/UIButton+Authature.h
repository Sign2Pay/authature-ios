//
// Created by Mark Meeus on 02/07/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIButton.h>

/**
* Category on UIButton
* Adds Bank Logo functionality
*/
@interface UIButton (Authature)

/**
* Sets the default Bank Logo's for the current IP as the background of the button.
*/
-(void) useAuthatureBankLogos;

/**
* Sets the Bank Logo's for a specific country as the background of the button.
*/
-(void) useAsAuthatureBankLogosForCountryCode:(NSString *)countryCode;

/**
* Sets the Bank Logo for a given access token as the background of the button.
*/
-(void) useAuthatureBankLogosWithToken:(NSDictionary *)accessToken;

@end