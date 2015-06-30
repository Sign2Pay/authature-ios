//
// Created by Mark Meeus on 29/06/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>

@protocol AuthatureDelegate <NSObject>

@optional
- (UIViewController *) controllerForAuthatureWebView;

- (void) presentAuthatureWebView:(UIWebView *) webiew completion:(void (^)(void))completion;

- (void) dismissAuthatureWebView;

- (void) authatureUserInfoReceived:(NSDictionary *) userInfo;

- (void) processAuthatureErrorCode:(NSString *) errorCode withDescription:(NSString *) description;
@end