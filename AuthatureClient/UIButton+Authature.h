//
// Created by Mark Meeus on 02/07/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIButton.h>

@interface UIButton (Authature)

-(void) useAuthatureBankLogos;

-(void) useAsAuthatureBankLogosForCountryCode:(NSString *)countryCode;

-(void) useAuthatureBankLogosWithToken:(NSDictionary *)accessToken;

@end