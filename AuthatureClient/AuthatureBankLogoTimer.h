//
// Created by Mark Meeus on 02/07/15.
//

#import <Foundation/Foundation.h>

/**
* AuthatureBankLogoTimer is used internally by UIImage+Authathure and UIButton+Authature to keep track of the current image.
* Notifications are posted to NSNotificationCenter with "Authature/BankLogoTimer";
*/
static NSString *BANK_LOGO_TIMER_NOTIFICATION_NAME = @"Authature/BankLogoTimer";

@interface AuthatureBankLogoTimer : NSObject

/**
* The shared instance
*/
+(AuthatureBankLogoTimer *) sharedInstance;

/**
* The current default logo (Based on the device's IP address)
*/
-(NSString *)currentDefaultLogo;

/**
* The current logo for a specific country code.
*/
-(NSString *)currentLogoUrlForCountryCode:(NSString *)countryCode;
@end