//
// Created by Mark Meeus on 02/07/15.
//

#import <Foundation/Foundation.h>

static NSString *BANK_LOGO_TIMER_NOTIFICATION_NAME = @"Authature/BankLogoTimer";

@interface AuthatureBankLogoTimer : NSObject

+(AuthatureBankLogoTimer *) sharedInstance;

-(NSString *)currentDefaultLogo;

-(NSString *)currentLogoUrlForCountryCode:(NSString *)countryCode;
@end