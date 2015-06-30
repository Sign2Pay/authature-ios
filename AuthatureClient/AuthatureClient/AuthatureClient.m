//
//  AuthatureClient.m
//  AuthatureClient
//
//  Created by Mark Meeus on 29/06/15.
//  Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthatureClient.h"
#import "AuthatureClientSettings.h"
#import "AFHTTPRequestOperationManager.h"


//https://app.sign2pay.com/oauth/authorize?authature_site=app.sign2pay.com&client_id=c509fd593742b6b08adf4f0b41a4801c&response_type=code&redirect_uri=http%3A%2F%2Fauthature.com%2Foauth%2Fcallback&state=a7960190e546361df673d4a40d2d5e97c85b11e719481e2da3b19dcf47282154&device_uid=0c9468e589955074a457cca400c14fa3a6bbe077f39a5584dc3902e187b7f9fd&scope=preapproval&user_params%5Bidentifier%5D=mark.meeus%40gmail.com&user_params%5Bfirst_name%5D=Mark&user_params%5Blast_name%5D=Meeus
//NSString * AUTHATURE_URL = @"https://app.sign2pay.com/oauth/authorize?authature_site=app.sign2pay.com&client_id=c509fd593742b6b08adf4f0b41a4801c&response_type=code&redirect_uri=http%3A%2F%2Fauthature.com%2Foauth%2Fcallback&state=a7960190e546361df673d4a40d2d5e97c85b11e719481e2da3b19dcf47282154&device_uid=0c9468e589955074a457cca400c14fa3a6bbe077f39a5584dc3902e187b7f9fd&scope=preapproval&user_params%5Bidentifier%5D=mark.meeus%40gmail.com&user_params%5Bfirst_name%5D=Mark&user_params%5Blast_name%5D=Meeus";
NSString * AUTHATURE_URL = @"https://app.sign2pay.com/oauth/authorize?authature_site=app.sign2pay.com&"
                            "response_type=code&"
                            "client_id=%@&"
                            "redirect_uri=%@"
                            "&state=%@"
                            "&device_uid=%@&"
                            "scope=%@&" //preapproval
                            "user_params[identifier]=%@&" //email
                            "user_params[first_name]=%@&"
                            "user_params[last_name]=%@";

@interface AuthatureClient()<UIWebViewDelegate>

@property (strong, nonatomic) UIViewController *webViewController;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSString * state;

-(void) loadGrantPage;

@end

@implementation AuthatureClient
- (instancetype)initWithSettings:(AuthatureClientSettings *)settings
                            user:(AuthatureUser*) user
                        delegate:(id<AuthatureDelegate>) delegate{
    self = [super init];
    if (self) {
        self.settings = settings;
        self.user = user;
        self.deviceUid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        self.delegate = delegate;
    }

    return self;
}

- (void)startPreApproval{

    [self SetState];

    [self presentWebView];
}

- (void)SetState {
    self.state = [[NSUUID UUID] UUIDString];
}

-(NSURL *) buildAuthorizationRequestURL{
    NSString * userIdentifier = @"";
    NSString * userFirstName = @"";
    NSString * userLastName = @"";

    if(self.user != NULL){
        userIdentifier = self.user.identifier;
        userFirstName = self.user.firstName;
        userLastName = self.user.lastName;
    }

    NSString *urlString = [NSString stringWithFormat:AUTHATURE_URL,
                    [self encodeParam:self.settings.clientId], //client_id
                    [self encodeParam:self.settings.callbackUrl],    //redirect_url
                    [self encodeParam:self.state],   //state
                    [self encodeParam:self.deviceUid],  //device_uid
                    @"preapproval", //scope
                    [self encodeParam:userIdentifier], //user_params[identifier]
                    [self encodeParam:userFirstName],  //user_params[first_name]
                    [self encodeParam:userLastName]];  //user_params[last_name]

    return [NSURL URLWithString:urlString];
}

- (NSString *)encodeParam:(NSString *) parameter {
    return [parameter stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

-(void) loadGrantPage{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [self buildAuthorizationRequestURL]];
    [((UIWebView *)self.webView) loadRequest:request];
}

-(NSDictionary *) parseStateAndCodeFromUrl:(NSString *)url{
    NSString *state = [[url componentsSeparatedByString:@"state="][1]
            componentsSeparatedByString:@"&"][0];
    NSString *code = [[url componentsSeparatedByString:@"code="][1]
            componentsSeparatedByString:@"&"][0];

    return @{
            @"state" : state,
            @"code" : code
    };
}

-(void) getTokenFromCallbackUrl:(NSString *) url{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"Authature iOS SDK v0.0.1" forHTTPHeaderField:@"UserAgent"];

    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);

    }];
}

#pragma mark webViewManagement
- (void)presentWebView{

    void(^onWebViewPresented)(void) = ^void() {
        [self loadGrantPage];
    };

    self.webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.webView.delegate = self;

    if([self.delegate respondsToSelector:@selector(presentAuthatureWebView:completion:)]){
        [self.delegate presentAuthatureWebView:self.webView
                                    completion:onWebViewPresented];
    }else{
        UIViewController* hostController = [self.delegate controllerForAuthatureWebView];

        self.webViewController =  [[UIViewController alloc] init];
        self.webViewController.view = self.webView;

        [hostController presentViewController:self.webViewController
                                     animated:NO
                                   completion:onWebViewPresented];
    }
}

- (void) dismissWebView{
    if([self.delegate respondsToSelector:@selector(dismissAuthatureWebView)]){
        [self.delegate dismissAuthatureWebView];
    }else{
        [[self.delegate controllerForAuthatureWebView] dismissViewControllerAnimated:NO
                                                                          completion:NULL];
    }
    self.webView = NULL;
    self.webViewController = NULL;

}
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    NSString *url = [request.mainDocumentURL absoluteString];
    NSLog(@"shouldStartLoadWithRequest");
    NSLog(url);

    if([url hasPrefix:self.settings.callbackUrl]){
        [self dismissWebView];
        NSDictionary *stateAndCode = [self parseStateAndCodeFromUrl:url];
        if([stateAndCode[@"state"] isEqualToString:self.state]){
            [self getTokenFromCallbackUrl:url];
        }
        return NO;
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{

    NSLog(@"Did start loading");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"Did finish loading");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"ERROR LOADING PAGE");
}

@end
