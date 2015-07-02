//
// Created by Mark Meeus on 01/07/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "UIImageView+Authature.h"
#import "AuthatureBankLogoTimer.h"


@implementation UIImageView (Authature)

-(void) useAsAuthatureBankLogos{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBankLogoTimer)
                                                 name:BANK_LOGO_TIMER_NOTIFICATION_NAME
                                               object:nil];

    [self setImageWithURLString:[[AuthatureBankLogoTimer sharedInstance] currenLogoUrl]];
}

- (void)setImageWithURLString:(NSString *)string {
    NSURL *url = [NSURL URLWithString:string];
    [self setImageWithURL:url];
}

-(void) useAsAuthatureBankLogosWithToken:(NSDictionary *)accessToken{

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) onBankLogoTimer{
    [self setImageWithURLString:[[AuthatureBankLogoTimer sharedInstance] currenLogoUrl]];
}

@end