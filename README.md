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
[client startAuthatureFlowForSignatureCaptureWithSuccess:^(NSDictionary *dictionary) {
        //ok
    } andFailure:^(NSString *code, NSString *description) {
        //fail
    }];
```

Authenticate (to authenticate the user)
```objective-c
[client startAuthatureFlowForAuthenticationWithSuccess:^(NSDictionary *dictionary) {
        //ok
    } andFailure:^(NSString *code, NSString *description) {
        /fail
    }];
```

PreApprove (to preapprove payments)
```objective-c
[client startAuthatureFlowForPreapprovalWithSuccess:^(NSDictionary *dictionary) {
        //ok
    } andFailure:^(NSString *code, NSString *description) {
        //fail
    }];
```

If you want a combination of scopes you can call the more generic method:
```objective-c
[client startAuthatureFlowForScope:@"authanticate,preapproveSuccess" withSuccess:^(NSDictionary *dictionary) {
      //ok
    } andFailure:^(NSString *code, NSString *description) {
      //fail
    }];
```

## The delegate

The AuthatureClient uses a webview to go through Authature's OAuth2 flow.

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

##Token storage
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

Likewise, if you want to validate a stored token for it's scope

```objective-c
[authatureClient verifyStoredTokenValidityforScope:AUTHATURE_SCOPE_PRE_APPROVAL
                                          callBack:^(BOOL valid, NSDictionary *dictionary) {}
                                     errorCallBack:^(NSError *error) {}];
```

##Token verification
You can use the AuthatureClient instance to verify if a token is (still) valid for a certain scope.
You can do so by calling:

```objective-c
[authatureClient verifyValidity:token
                      forScope:AUTHATURE_SCOPE_PRE_APPROVAL
                      callBack:^(BOOL valid, NSDictionary *dictionary) {}
                 errorCallBack:^(NSError *error) {}];
```

If you are using the automatic token storage, you can verify the stored token by calling:
```objective-c
[[self getAuthatureClient] verifyStoredTokenValidityforScope:AUTHATURE_SCOPE_PRE_APPROVAL
                                                    callBack:^(BOOL tokenIsValid, NSDictionary *responseObject) {}
                                               errorCallBack:^(NSError *error) {}];
```

##AuthatureAccessTokenStorage
You can also conveniently interact with the token storage directly to add/remove your tokens.
Tokens are organized by clientId and a key per token.
TIP: A good candidate for the key is the token value of the access token.
Store a token like this:
```objective-c
[AuthatureAccessTokenStorage saveAccessToken:accessToken
                                 forClientId:clientId
                                     withKey:accessToken[@"token"];
```                       

Reading a token:
```objective-c
return [AuthatureAccessTokenStorage getAccessTokenForClientId:clientId 
                                                       andKey:"123"];
````

Delete a token:
```objective-c
[AuthatureAccessTokenStorage destroyAccessTokenForClientId:clientId
                                                    andKey:accessToken[@"token"]];
```

##UI Components
When Authature is combined with Sign2Pay, a token can be linked to a bank account.
For conversion reason, you may want to display the logo's of supported banks in your app.
Also, when the user has a token for the preapprove scope the logo of that bank (f.i. on a checkout button)

UIImageView+Authature and UIButton+Authature add methods to UIImageView and UIButton to make this happen.

Rotate the images of the supported banks based on the user'sIP  in a UIImage:
```objective-c
[imageView useAsAuthatureBankLogos];
```

Rotate the images of the supported banks on the user's IP on a UIButton:
```objective-c
[button useAuthatureBankLogos];
```

Rotate the images of the supported banks for a specific country in a UIImage
```objective-c
[imageView useAsAuthatureBankLogosForCountryCode:@"BE"];
```
Rotate the images of the supported banks a specific country on a UIButton:
```objective-c
[button useAuthatureBankLogosForCountryCode:@"BE"];
```

Show the bank logo for the account linked to a given token on a UIView
```objective-c
[imageView useAsAuthatureBankLogosWithToken:tokenForCheckout];
````
Show the bank logo for the account linked to a given token on a UIButton
```objective-c
[button useAuthatureBankLogosWithToken:tokenForCheckout];
````
