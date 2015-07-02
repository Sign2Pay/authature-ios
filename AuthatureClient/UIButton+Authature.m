//
// Created by Mark Meeus on 02/07/15.
//

#import "UIButton+Authature.h"
#import "AuthatureBankLogoTimer.h"
#import "AFNetworking/UIButton+AFNetworking.h"

@implementation UIButton (Authature)


-(void) useAuthatureBankLogos{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBankLogoTimer)
                                                 name:BANK_LOGO_TIMER_NOTIFICATION_NAME
                                               object:nil];

    [self setImageWithURLString:[[AuthatureBankLogoTimer sharedInstance] currenLogoUrl]];
}

-(void) useAuthatureBankLogosWithToken:(NSDictionary *)accessToken{

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setImageWithURLString:(NSString *)string {
    NSURL *url = [NSURL URLWithString:string];
    [self setBackgroundImageForState:UIControlStateNormal withURL:url];
}

-(void) onBankLogoTimer{
    NSString *currentLogo = [[AuthatureBankLogoTimer sharedInstance] currenLogoUrl];
    [self setImageWithURLString:currentLogo];
}

@end