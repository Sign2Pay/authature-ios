//
// Created by Mark Meeus on 02/07/15.
//

#import <Foundation/Foundation.h>

@class AuthatureBankLogoTimer;


@interface AuthatureBankLogoTimerManager : NSObject{
}
+ (AuthatureBankLogoTimer *) defaultTimer;
+ (AuthatureBankLogoTimer *) timerForCountryCode:(NSString *)countryCode;
@end