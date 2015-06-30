//
// Created by Mark Meeus on 29/06/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import "AuthatureClientSettings.h"


@implementation AuthatureClientSettings {

}
- (instancetype)initWithClientId:(NSString *)clientId
                     callbackUrl:(NSString *)callbackUrl{

    self = [super init];
    if (self) {
        self.clientId = clientId;
        self.callbackUrl = callbackUrl;
    }

    return self;
}

@end