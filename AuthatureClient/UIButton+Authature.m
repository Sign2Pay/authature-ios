//
// Created by Mark Meeus on 02/07/15.
//

#import "UIButton+Authature.h"
#import "AuthatureBankLogoTimer.h"
#import "AFNetworking/UIButton+AFNetworking.h"
#import "AuthatureBankLogoTimerManager.h"

@implementation UIButton (Authature)


-(void) useAuthatureBankLogos{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBankLogoTimer)
                                                 name:BANK_LOGO_TIMER_NOTIFICATION_NAME
                                               object:nil];

    [self setImageWithURLString:[[AuthatureBankLogoTimerManager defaultTimer] currenLogoUrl]];
}

-(void) useAuthatureBankLogosWithToken:(NSDictionary *)accessToken{
    [[NSNotificationCenter defaultCenter] removeObserver:self]; //we should not listen to the banklogotimer anymore.
    NSString *imageUrl = accessToken[@"account"][@"bank"][@"logo"];
    if(imageUrl != nil){
        [self setImageWithURLString:imageUrl];
    }else{
        [self setBackgroundImage:nil forState:UIControlStateNormal];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setImageWithURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    [self setBackgroundImageForState:UIControlStateNormal withURL:url];
}

-(void) onBankLogoTimer{
    NSString *currentLogo = [[AuthatureBankLogoTimerManager defaultTimer] currenLogoUrl];
    [self setImageWithURLString:currentLogo];
}

@end