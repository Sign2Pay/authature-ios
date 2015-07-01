//
// Created by Mark Meeus on 01/07/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"

@interface UIImageView (Authature)

+ (UIImage*) imageViewWithBankLogos;

-(void) useAsAuthatureBankLogos;

-(void) useAsAuthatureBankLogosWithToken:(NSDictionary *)accessToken;

@end