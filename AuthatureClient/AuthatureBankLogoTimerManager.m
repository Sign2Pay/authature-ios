//
// Created by Mark Meeus on 02/07/15.
//

#import "AuthatureBankLogoTimerManager.h"
#import "AuthatureBankLogoTimer.h"

static NSDictionary *_bankLogoTimersPerCountryCode;
static AuthatureBankLogoTimer *_defaultBankLogoTimer;

@implementation AuthatureBankLogoTimerManager {

}

+ (AuthatureBankLogoTimer *)defaultTimer {
    if(_defaultBankLogoTimer == nil){
        _defaultBankLogoTimer = [[AuthatureBankLogoTimer  alloc]init];
    }
    return _defaultBankLogoTimer;
}

+ (AuthatureBankLogoTimer *)timerForCountryCode:(NSString *)countryCode {
    return _bankLogoTimersPerCountryCode[countryCode];
}


@end