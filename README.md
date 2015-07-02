# authature-ios

The Authature iOS SDK is designed to facilitate the integration Authature within your iOS apps.

##Getting started
Drag and drop authature-ios directory into your project.

(A pod will be released soon)

## Setting-up the AuthatureClient

First create an instance of AuthatureClientSettings to hold your client details:
```objective-c
self.client = [[AuthatureClientSettings alloc] initWithClientId:@"your-client-id"
                                      callbackUrl:@"your-servers-oauth-callback-url"];
```

With this settings object, you can instantiate an AuthatureClient. 
AuthatureClient uses a UIWebView to load the OAuth2 pages. 
The delegate gives you control over where this webview ends up in your view hierachy.
More info on the delegate below.

```objective-c
self.client = [[AuthatureClient alloc] initWithSettings:clientSettings
                                 delegate:authatureDelegate];
```

### Starting an Authature flow

Depending on your setup Authature supports different scopes.
You can start the flow for any of these scopes by calling the corresponding method

All these methods have 2 blocks as parameters, a successCallback and an errorCallback.
(note, since this is async, its is best to keep a strong reference to the client)
Capture (to capture the signature)
```objective-c
[client startAuthatureFlowForSignatureCaptureWithSuccess:(void(^)(NSDictionary *))successCallback
                                              andFailure:(void(^)(NSString *, NSString *))errorCallback];
```

Authenticate (to authenticate the user)
```objective-c
[client startAuthatureFlowForAuthenticationWithSuccess:(void(^)(NSDictionary *))successCallback
                                            andFailure:(void(^)(NSString *, NSString *))errorCallback];
```

PreApprove (to preapprove payments)
```objective-c
[client startAuthatureFlowForPreapprovalWithSuccess:(void(^)(NSDictionary *))successCallback
                                         andFailure:(void(^)(NSString *, NSString *))errorCallback];
```

If you want a combination of scopes you can call the more generic method:
```objective-c
[client startAuthatureFlowForScope:(void(^)(NSDictionary *))successCallback
                        andFailure:(void(^)(NSString *, NSString *))errorCallback];
```

### The delegate

The AuthatureClient uses a webview to go throught Authature's OAuth2 flow.

You have to implement either this method, which has to return a controller that can be used to present a view.

```objective-c
- (UIViewController *) controllerForAuthatureWebView;
```

or these 2 methods where you can control how the webview is presented and dismissed.
Use this approach if you want to animate the transition.

```objective-c
- (void) presentAuthatureWebView:(UIWebView *) webView
                      completion:(void (^ (void))completion;

- (void) dismissAuthatureWebView;
```

After the Authature flow is finished, the AuthatureClient calls the delegate with one of these methods.

When the the flow resulted in a token:

```objective-c
- (void) authatureAccessTokenReceived:(NSDictionary *) accessToken;
```

When the flow resulted in an error:

```objective-c
- (void) processAuthatureErrorCode:(NSString *)
         errorCode withDescription:(NSString *) description;
```

###Token verification
You can use the AuthatureClient instance to verify if a token is (still) valid for a certain scope.
You can do so by calling:

```objective-c
[authatureClient verifyValidity:token
                      forScope:AUTHATURE_SCOPE_PRE_APPROVAL
                      callBack:^(BOOL valid, NSDictionary *dictionary) {}
                 errorCallBack:^(NSError *error) {}];
```

###Token storage
The AuthatureClient can be configured to automatically store a token per requested scope (off by default).
If you turn on this feature, the AuthatureClient will always send user details into the Authature flow if a new token is requested. This way, your users don't have to re-enter their details (e-mail) when going through the flow.

Turn it on like this:
```objective-c
authatureClient.automaticTokenStorageEnabled = TRUE;
```

If you want to get the automatically stored token for a scope:
```objective-c
[authatureClient getStoredTokenForScope:AUTHATURE_SCOPE_PRE_APPROVAL];
```

Likewise, you you want to validate a stored token for it's scope

```objective-c
[authatureClient verifyStoredTokenValidityforScope:AUTHATURE_SCOPE_PRE_APPROVAL
                                          callBack:^(BOOL valid, NSDictionary *dictionary) {}
                                     errorCallBack:^(NSError *error) {}];
```
