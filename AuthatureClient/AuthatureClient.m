//
//  AuthatureClient.m
//  AuthatureClient
//
//  Created by Mark Meeus on 29/06/15.
//  Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthatureClient.h"
#import "AFHTTPRequestOperationManager.h"
#import "AuthatureAccessTokenStorage.h"

NSString *const AUTHATURE_SCOPE_PRE_APPROVAL = @"preapproval";
NSString *const AUTHATURE_SCOPE_AUTHENTICATE = @"authenticate";
NSString *const AUTHATURE_SCOPE_SIGNATURE_CAPTURE = @"capture";

//https://app.sign2pay.com/oauth/authorize?authature_site=app.sign2pay.com&client_id=c509fd593742b6b08adf4f0b41a4801c&response_type=code&redirect_uri=http%3A%2F%2Fauthature.com%2Foauth%2Fcallback&state=a7960190e546361df673d4a40d2d5e97c85b11e719481e2da3b19dcf47282154&device_uid=0c9468e589955074a457cca400c14fa3a6bbe077f39a5584dc3902e187b7f9fd&scope=preapproval&user_params%5Bidentifier%5D=mark.meeus%40gmail.com&user_params%5Bfirst_name%5D=Mark&user_params%5Blast_name%5D=Meeus
//NSString * AUTHATURE_URL = @"https://app.sign2pay.com/oauth/authorize?authature_site=app.sign2pay.com&client_id=c509fd593742b6b08adf4f0b41a4801c&response_type=code&redirect_uri=http%3A%2F%2Fauthature.com%2Foauth%2Fcallback&state=a7960190e546361df673d4a40d2d5e97c85b11e719481e2da3b19dcf47282154&device_uid=0c9468e589955074a457cca400c14fa3a6bbe077f39a5584dc3902e187b7f9fd&scope=preapproval&user_params%5Bidentifier%5D=mark.meeus%40gmail.com&user_params%5Bfirst_name%5D=Mark&user_params%5Blast_name%5D=Meeus";
NSString *AUTHATURE_URL = @"https://app.sign2pay.com/oauth/authorize?"
                            "?authature_site=app.sign2pay.com"
                            "&response_type=code"
                            "&client_id=%@"
                            "&redirect_uri=%@"
                            "&state=%@"
                            "&device_uid=%@"
                            "&scope=%@" //preapproval
                            "&user_params[identifier]=%@" //email
                            "&user_params[first_name]=%@"
                            "&user_params[last_name]=%@";

NSString *VERIFY_TOKEN_URL = @"https://app.sign2pay.com/oauth/token?"
                            "client_id=%@&"
                            "scope=%@&"
                            "device_uid=%@";


@interface AuthatureClient()<UIWebViewDelegate>

@property (strong, nonatomic) UIViewController *webViewController;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSString * state;

@end

@implementation AuthatureClient
- (instancetype)initWithSettings:(AuthatureClientSettings *)settings
                      userParams:(AuthatureUserParams *) userParams
                     andDelegate:(id<AuthatureDelegate>) delegate{
    self = [super init];
    if (self) {
        self.settings = settings;
        self.userParams = userParams;
        self.deviceUid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        self.delegate = delegate;
    }

    return self;
}

- (void) startAuthatureFlowForSignatureCapture{
    [self startAuthatureFlowForScope:AUTHATURE_SCOPE_SIGNATURE_CAPTURE];
}

- (void) startAuthatureFlowForAuthentication{
    [self startAuthatureFlowForScope:AUTHATURE_SCOPE_AUTHENTICATE];
}

- (void) startAuthatureFlowForPreapproval{
    [self startAuthatureFlowForScope:AUTHATURE_SCOPE_PRE_APPROVAL];
}

- (void) startAuthatureFlowForScope:(NSString *)scope{

    [self SetState];

    [self presentWebViewForScope:scope];
}

- (void)verifyStoredTokenValidityforScope:(NSString *)scope
                                 callBack:(void (^)(BOOL, NSDictionary *))callback
                            errorCallBack:(void (^)(NSError *)) errorCallback{
    NSDictionary *accessToken = [self getStoredTokenForScope:scope];
    if(accessToken != NULL) {
        [self verifyTokenValidity:accessToken
                         forScope:scope
                         callBack:callback
                    errorCallBack:errorCallback];
    }else{
        callback(FALSE, NULL);
    }
}

- (void)verifyTokenValidity:(NSDictionary *)token
                   forScope:(NSString *)scope
                   callBack:(void (^)(BOOL, NSDictionary *))callback
              errorCallBack:(void (^)(NSError *)) errorCallback  {

    NSString *url = [self buildVerifyTokenUrlForScope:scope];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"Authature iOS SDK v0.0.1" forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:[self bearerHeaderForToken:token] forHTTPHeaderField:@"Authorization"];

    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([((NSString *) responseObject[@"status"]) isEqualToString:@"ok"]){
            callback(TRUE, responseObject);
        }else{
            callback(FALSE, responseObject);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(errorCallback != NULL){
            if(operation.responseObject != nil){
                callback(FALSE, operation.responseObject);
            }
            errorCallback(error);
        }
    }];
}

- (NSString *)bearerHeaderForToken:(NSDictionary *)token{
    return [NSString stringWithFormat:@"Bearer %@", token[@"token"]];
}

- (NSString *)buildVerifyTokenUrlForScope:(NSString *)scope {
    return [NSString stringWithFormat:VERIFY_TOKEN_URL,
            [self encodeParam:self.settings.clientId],
            scope,
            [self encodeParam: self.deviceUid]
        ];
}

- (void)SetState {
    self.state = [[NSUUID UUID] UUIDString];
}

-(NSURL *) buildAuthorizationRequestURL:(NSString *)scope{
    NSString * userIdentifier = @"";
    NSString * userFirstName = @"";
    NSString * userLastName = @"";

    if(self.userParams != NULL){
        userIdentifier = self.userParams.identifier;
        userFirstName = self.userParams.firstName;
        userLastName = self.userParams.lastName;
    }else if(self.automaticTokenStorageEnabled){
        NSDictionary *accessToken = [self getStoredTokenForScope:scope];
        if(accessToken != NULL){
            userIdentifier = accessToken[@"user"][@"identifier"];
            userFirstName = accessToken[@"user"][@"first_name"];
            userLastName = accessToken[@"user"][@"last_name"];
        }
    }

    NSString *urlString = [NSString stringWithFormat:AUTHATURE_URL,
                    [self encodeParam:self.settings.clientId], //client_id
                    [self encodeParam:self.settings.callbackUrl],    //redirect_url
                    [self encodeParam:self.state],   //state
                    [self encodeParam:self.deviceUid],  //device_uid
                    scope,
                    [self encodeParam:userIdentifier], //user_params[identifier]
                    [self encodeParam:userFirstName],  //user_params[first_name]
                    [self encodeParam:userLastName]];  //user_params[last_name]

    return [NSURL URLWithString:urlString];
}

- (NSDictionary *)getStoredTokenForScope:(NSString *)scope {
    return [AuthatureAccessTokenStorage getAccessTokenForClientId:self.settings.clientId andKey:scope];
}

- (void)destroyStoredTokenForScope:(NSString *)scope{
    [AuthatureAccessTokenStorage destroyAccessTokenForClientId:self.settings.clientId
                                                        andKey:scope];
}

- (NSString *)encodeParam:(NSString *) parameter {
    return [parameter stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

-(void) loadGrantPageWithScope:(NSString *)scope{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [self buildAuthorizationRequestURL:scope]];
    [self.webView loadRequest:request];
}

-(NSString *) getStateFromUrl:(NSString *)url{
    return [[url componentsSeparatedByString:@"state="][1]
            componentsSeparatedByString:@"&"][0];
}

-(void) getResultFromCallbackUrl:(NSString *) url{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"Authature iOS SDK v0.0.1" forHTTPHeaderField:@"User-Agent"];

    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if(responseObject[@"error"]){
            [self processAuthatureErrorCode:responseObject[@"error"]
                            withDescription:responseObject[@"error_desription"]];
            [self dismissWebView];
        }else{
            [self processAccessToken:responseObject[@"access_token"]];
            [self dismissWebView];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self processCallbackError:error];
    }];
}

- (void)processAccessToken:(NSDictionary* )accessToken {
    if(self.automaticTokenStorageEnabled){
        [AuthatureAccessTokenStorage saveAccessToken:accessToken
                                         forClientId:self.settings.clientId
                                             withKey:accessToken[@"scopes"]];
    }
    if([self.delegate respondsToSelector:@selector(authatureAccessTokenReceived:)]){
        [self.delegate authatureAccessTokenReceived:accessToken];
    }
}

- (void) processCallbackError:(NSError *) error{
    if([self.delegate respondsToSelector:@selector(processAuthatureErrorCode:withDescription:)]){
        [self.delegate processAuthatureErrorCode:[error description] withDescription:@"code"];
    }
}

- (void) processAuthatureErrorCode:(NSString *) errorCode withDescription:(NSString *) description{
    if([self.delegate respondsToSelector:@selector(processAuthatureErrorCode:withDescription:)]){
        [self.delegate processAuthatureErrorCode:errorCode withDescription:description];
    }
}

#pragma mark webViewManagement
- (void)presentWebViewForScope:(NSString *)scope{

    void(^onWebViewPresented)(void) = ^void() {
        [self loadGrantPageWithScope:scope];
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
    NSLog(url, nil);

    if([url hasPrefix:self.settings.callbackUrl]){
        NSString *state = [self getStateFromUrl:url];
        if([state isEqualToString:self.state]){
            [self getResultFromCallbackUrl:url];
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
