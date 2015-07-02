//
// Created by Mark Meeus on 01/07/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import "UIImageView+Authature.h"
#import "AuthatureBankLogoTimer.h"
#import "AuthatureBankLogoTimerManager.h"


@implementation UIImageView (Authature)

-(void) useAsAuthatureBankLogos{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBankLogoTimer)
                                                 name:BANK_LOGO_TIMER_NOTIFICATION_NAME
                                               object:nil];

    [self setImageWithURLString:[[AuthatureBankLogoTimerManager defaultTimer] currenLogoUrl]];
}

- (void)setImageWithURLString:(NSString *)string {
    NSURL *url = [NSURL URLWithString:string];
    [self setImageWithURL:url];
}

-(void) useAsAuthatureBankLogosWithToken:(NSDictionary *)accessToken{
    [[NSNotificationCenter defaultCenter] removeObserver:self]; //we should not listen to the banklogotimer anymore.
    NSString *imageUrl = accessToken[@"account"][@"bank"][@"logo"];
    if(imageUrl != nil){
        [self setImageWithURLString:imageUrl];
    }else{
        [self setImage:nil];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) onBankLogoTimer{
    [self setImageWithURLString:[[AuthatureBankLogoTimerManager defaultTimer] currenLogoUrl]];
}

@end