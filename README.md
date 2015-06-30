# authature-ios

The Authature iOS SDK is designed to facilitate the integration Authature within your iOS apps.


The SDK supplies integration points at different levels of abstraction.

Using the low-level api you can manipulate every aspect of the Authature flow and token management.

The UI level sdk gives you less flexibilitiy but makes it dead simple to integrete Authature in your app.

## Low-level api aka AuthatureClient
### Setting-up the AuthatureClient


First create an instance of AuthatureClientSettings to hold your client details:

```objective-c
[[AuthatureClientSettings alloc] initWithClientId:@"your-client-id"
                                      callbackUrl:@"your-servers-oauth-callback-url"];
```

With this settings object, you can instantiate an AuthatureClient. A delegate is also needed, see below for further details.

```objective-c
[[AuthatureClient alloc] initWithSettings:clientSettings
                                 delegate:authatureDelegate];
```
 
### Starting an Authature flow

Depending on your setup Authature supports different scopes.
You can start the flow for any of these scopes by calling the corresponding method

Capture (to capture the signature)
```objective-c
[authatureClient  startGetTokenForSignatureCapture]
```

Authenticate (to authenticate the user)
```objective-c
[authatureClient  startGetTokenForAuthentication]
```

PreApprove (to preapprove payments) 
```objective-c
[authatureClient  startGetTokenForPreApproval]
```

If you want a combination of scopes you can call the more generic method:
```objective-c
[authatureClient  startGetTokenForScope:@"authenticate,capture"]
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
