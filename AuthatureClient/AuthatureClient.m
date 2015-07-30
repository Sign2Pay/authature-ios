//
//  AuthatureClient.m
//  AuthatureClient
//
//  Created by Mark Meeus on 29/06/15.
//  Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import "AuthatureClient.h"
#import "AFHTTPRequestOperationManager.h"
#import "AuthatureAccessTokenStorage.h"

NSString *const AUTHATURE_SCOPE_PRE_APPROVAL = @"preapproval";
NSString *const AUTHATURE_SCOPE_AUTHENTICATE = @"authenticate";
NSString *const AUTHATURE_SCOPE_SIGNATURE_CAPTURE = @"capture";

NSString *AUTHATURE_URL = @"https://app.sign2pay.com/oauth/authorize?"
                            "?authature_site=app.sign2pay.com"
                            "&response_type=code"
                            "&client_id=%@"
                            "&redirect_uri=%@"
                            "&state=%@"
                            "&device_uid=%@"
                            "&scope=%@"
                            "&user_params[identifier]=%@"
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
@property (nonatomic, copy) void (^currentActionCallback)(NSDictionary *);
@property (nonatomic, copy) void (^currentActionErrorCallback)(NSString *, NSString *);
@end

@implementation AuthatureClient

- (instancetype)initWithSettings:(AuthatureClientSettings *)settings
                     andDelegate:(id<AuthatureDelegate>) delegate{
    self = [super init];
    if (self) {
        self.settings = settings;
        self.deviceUid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        self.delegate = delegate;
    }

    return self;
}

- (void) startAuthatureFlowForSignatureCaptureWithUserParams:(AuthatureUserParams *) userParams
                                                     success:(void(^)(NSDictionary *))successCallback
                                                  andFailure:(void(^)(NSString *, NSString *))errorCallback;{
    [self startAuthatureFlowForScope:AUTHATURE_SCOPE_SIGNATURE_CAPTURE
            withUserParams:userParams
                         success:successCallback
                          andFailure:errorCallback];
}

- (void) startAuthatureFlowForAuthenticationWithUserParams:(AuthatureUserParams *) userParams
                                                   success:(void(^)(NSDictionary *))successCallback
                                                andFailure:(void(^)(NSString *, NSString *))errorCallback;{
    [self startAuthatureFlowForScope:AUTHATURE_SCOPE_AUTHENTICATE
            withUserParams:userParams
                         success:successCallback
                          andFailure:errorCallback];
}

- (void) startAuthatureFlowForPreapprovalWithUserParams:(AuthatureUserParams *) userParams
                                                success:(void(^)(NSDictionary *))successCallback
                                             andFailure:(void(^)(NSString *, NSString *))errorCallback;{
    [self startAuthatureFlowForScope:AUTHATURE_SCOPE_PRE_APPROVAL
                        withUserParams:userParams
                         success:successCallback
                          andFailure:errorCallback];
}

- (void) startAuthatureFlowForScope:(NSString *)scope
                        withUserParams:(AuthatureUserParams *) userParams
                        success:(void(^)(NSDictionary *))successCallback
                         andFailure:(void(^)(NSString *, NSString *))errorCallback;{

    self.currentActionCallback = successCallback;
    self.currentActionErrorCallback = errorCallback;

    [self SetState];

    [self presentWebViewForScope:scope andUserParams:userParams];
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
            }else{
                errorCallback(error);
            }
        }
    }];
}

- (NSDictionary *)getStoredTokenForScope:(NSString *)scope {
    return [AuthatureAccessTokenStorage getAccessTokenForClientId:self.settings.clientId andKey:scope];
}

- (void)destroyStoredTokenForScope:(NSString *)scope{
    [AuthatureAccessTokenStorage destroyAccessTokenForClientId:self.settings.clientId
                                                        andKey:scope];
}

#pragma mark privates
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

- (NSString *)encodeParam:(NSString *) parameter {
    return [parameter stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

-(NSURL *) buildAuthorizationRequestURLForScope:(NSString *)scope
                                  andUserParams:(AuthatureUserParams *) userParams{
    NSString * userIdentifier = @"";
    NSString * userFirstName = @"";
    NSString * userLastName = @"";

    if(userParams != NULL){
        userIdentifier = userParams.identifier;
        userFirstName = userParams.firstName;
        userLastName = userParams.lastName;
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

-(void) loadGrantPageWithScope:(NSString *)scope
                 andUserParams:(AuthatureUserParams *)userParams{

    NSURL *url = [self buildAuthorizationRequestURLForScope:scope
                                              andUserParams:userParams];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
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

    [self dismissWebView];

    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if(responseObject[@"error"]){
            [self processAuthatureErrorCode:responseObject[@"error"]
                            withDescription:responseObject[@"error_description"]];
        }else{
            [self processAccessToken:responseObject[@"access_token"]];
        }
        [self releaseCallbacks];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self processCallbackError:error];
        [self releaseCallbacks];

    }];
}

- (void)releaseCallbacks {
    self.currentActionCallback = nil;
    self.currentActionErrorCallback = nil;
}

- (void)processAccessToken:(NSDictionary* )accessToken {
    if(self.automaticTokenStorageEnabled){
        [AuthatureAccessTokenStorage saveAccessToken:accessToken
                                         forClientId:self.settings.clientId
                                             withKey:accessToken[@"scopes"]];
    }

    self.currentActionCallback(accessToken);
}

- (void) processCallbackError:(NSError *) error{
    self.currentActionErrorCallback(@"code", [error description]);

}

- (void) processAuthatureErrorCode:(NSString *) errorCode withDescription:(NSString *) description{
    self.currentActionErrorCallback(errorCode, description);

}

#pragma mark webViewManagement
- (void)presentWebViewForScope:(NSString *)scope
                 andUserParams:(AuthatureUserParams *)userParams{
    
    self.webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.webView.delegate = self;
    
    if([self.delegate respondsToSelector:@selector(authatureWebViewLoadStarted)]){
        [self.delegate authatureWebViewLoadStarted];
    }
    [self loadGrantPageWithScope:scope andUserParams:userParams];
    
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

    if([self.delegate respondsToSelector:@selector(authatureWebViewGotDismissed)]){
        [self.delegate authatureWebViewGotDismissed];
    }
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    NSString *url = [request.mainDocumentURL absoluteString];

    if([url hasPrefix:self.settings.callbackUrl]){
        NSString *state = [self getStateFromUrl:url];
        if([state isEqualToString:self.state]){
            [self getResultFromCallbackUrl:url];
        }
        return NO;
    }
    return YES;
}

//- (void)webViewDidStartLoad:(UIWebView *)webView{
//}
//
- (void)webViewDidFinishLoad:(UIWebView *)webView{

    if([self.delegate respondsToSelector:@selector(authatureWebViewReady)]){
        [self.delegate authatureWebViewReady];
    }

    if([self.delegate respondsToSelector:@selector(presentAuthatureWebView:completion:)]){
        [self.delegate presentAuthatureWebView:self.webView
                                    completion:nil];
    }else{
        UIViewController* hostController = [self.delegate controllerForAuthatureWebView];
        
        self.webViewController =  [[UIViewController alloc] init];
        self.webViewController.view = self.webView;
        
        [hostController presentViewController:self.webViewController
                                     animated:NO
                                   completion:nil];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if(error.userInfo )
    {
        NSString *urlString = error.userInfo[@"NSErrorFailingURLStringKey"];
        if([urlString hasPrefix:self.settings.callbackUrl]){
            //expected since we aren't loading this in the UIWebView
            return;
        }
    }

    [self dismissWebView];
    self.currentActionErrorCallback(@"WebViewError", [error description]);
    [self releaseCallbacks];
}

@end
