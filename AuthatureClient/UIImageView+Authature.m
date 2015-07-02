//
// Created by Mark Meeus on 01/07/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <objc/runtime.h>
#import "UIImageView+Authature.h"
#import "AuthatureBankLogoTimer.h"

@implementation UIImageView (Authature)
-(void) useAsAuthatureBankLogos{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBankLogoTimer)
                                                 name:BANK_LOGO_TIMER_NOTIFICATION_NAME
                                               object:nil];
    [self updateImage];

}

- (void)useAsAuthatureBankLogosForCountryCode:(NSString *)countryCode {
    [self setCountryCode:countryCode];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBankLogoTimer)
                                                 name:BANK_LOGO_TIMER_NOTIFICATION_NAME
                                               object:nil];
    [self updateImage];
}

-(void) useAsAuthatureBankLogosWithToken:(NSDictionary *)accessToken{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self setImageWithURLString:accessToken[@"account"][@"bank"][@"logo"]];
}

-(NSString *)countryCode{
    return objc_getAssociatedObject(self, @selector(countryCode)) ;
}

-(void) setCountryCode:(NSString *)countryCode
{
    objc_setAssociatedObject(self, @selector(countryCode), countryCode, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc{
    objc_setAssociatedObject(self, @selector(countryCode), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) onBankLogoTimer{
    [self updateImage];
}

-(void) updateImage{
    NSString *countryCode = [self countryCode];
    if(countryCode){
        [self setImageWithURLString:[[AuthatureBankLogoTimer sharedInstance] currentLogoUrlForCountryCode:countryCode]];
    }else{
        [self setImageWithURLString:[AuthatureBankLogoTimer sharedInstance].currentDefaultLogo];
    }
}

- (void)setImageWithURLString:(NSString *)string {
    NSURL *url = [NSURL URLWithString:string];
    [self setImageWithURL:url];
}

@end