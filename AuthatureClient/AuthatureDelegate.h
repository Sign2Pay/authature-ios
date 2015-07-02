//
// Created by Mark Meeus on 29/06/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UIWebView.h>

@protocol AuthatureDelegate <NSObject>

@optional
- (UIViewController *) controllerForAuthatureWebView;

- (void) presentAuthatureWebView:(UIWebView *) webView completion:(void (^)(void))completion;

- (void) dismissAuthatureWebView;
@end