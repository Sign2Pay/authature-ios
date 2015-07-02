//
// Created by Mark Meeus on 29/06/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UIWebView.h>

/**
* Protocol specification for a non-optional delegate for the Authature Client.
* This protocol is used to integrate the UIWebView used by AuthatureClient in your applications view hierarchy.
*/
@protocol AuthatureDelegate <NSObject>

/**
* Although all methods are marked as optional, you have to implement one of these 2 strategies
* 1: Simply implement controllerForAuthatureWebView
* 2: Implement  presentAuthatureWebView:completion:
* and           dismissAuthatureWebView
*/
@optional
/**
* The controller returned will be used to present the webView
*/
- (UIViewController *) controllerForAuthatureWebView;

/**
* Implement this method if you want to control how the webview is presented
* The callback should be called to let the AuthatureClient know that the webView is ready
*/
- (void) presentAuthatureWebView:(UIWebView *) webView completion:(void (^)(void))completion;

/**
* This method has to be implemented if the client presented the webView with presentAuthatureWebView:completion:
*/
- (void) dismissAuthatureWebView;
@end