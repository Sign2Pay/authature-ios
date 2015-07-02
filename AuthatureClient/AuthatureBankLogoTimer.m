//
// Created by Mark Meeus on 02/07/15.
//

#import "AuthatureBankLogoTimer.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "BlocksKit/BlocksKit.h"

static NSString *MISSING_BANK_LOGO = @"https://app.sign2pay.com/banks/missing.png";
static NSString *BASE_BANKS_URL = @"http://api.sign2pay.com/api/v2/banks.json";

@interface BankLogoCollection: NSObject

@property(strong, nonatomic) NSArray *bankLogoUrls;

@property(nonatomic) int currentBankLogoUrlIndex;

@property(strong, nonatomic) NSString *currentLogoUrl;

@end

@implementation BankLogoCollection
-(void) moveNext{
    self.currentBankLogoUrlIndex++;

    if(self.currentBankLogoUrlIndex >= self.bankLogoUrls.count){
        self.currentBankLogoUrlIndex  = 0;
    }

    if(self.currentBankLogoUrlIndex < self.bankLogoUrls.count){
        self.currentLogoUrl = [self.bankLogoUrls objectAtIndex:self.currentBankLogoUrlIndex];
    }

}
-(void) initImageUrlsWithCountryCode:(NSString *)countryCode {
    NSString *url = [NSString stringWithFormat:@"%@?country_code=%@", BASE_BANKS_URL, [countryCode uppercaseString]];
    [self loadImageUrlsFromUrl:url];
}

-(void) initImageUrls{
    [self loadImageUrlsFromUrl:BASE_BANKS_URL];
}

-(void) loadImageUrlsFromUrl:(NSString *)url{
    self.bankLogoUrls = [NSMutableArray array];
    self.currentLogoUrl = MISSING_BANK_LOGO;
    self.currentBankLogoUrlIndex = -1;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"Authature iOS SDK v0.0.1" forHTTPHeaderField:@"User-Agent"];

    [manager GET:url  parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
        self.bankLogoUrls = [responseObject bk_map:^id(id bankInfo) {
            return bankInfo[@"logo"];
        }];

        if(self.bankLogoUrls.count > 0){
            self.currentLogoUrl = [self.bankLogoUrls firstObject];
            self.currentBankLogoUrlIndex = 0;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}
@end

@interface AuthatureBankLogoTimer()

@property (strong, nonatomic) NSMutableDictionary *logosPerCountry;

@property(strong, nonatomic) NSTimer *timer;

@end

@implementation AuthatureBankLogoTimer {

}

+(AuthatureBankLogoTimer *) sharedInstance{
    static AuthatureBankLogoTimer *sharedTimer= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTimer = [[self alloc] init];
        sharedTimer.logosPerCountry = [NSMutableDictionary dictionary];
        sharedTimer.logosPerCountry[@"default"] = [[BankLogoCollection alloc]init];
        [sharedTimer.logosPerCountry[@"default"] initImageUrls];
        sharedTimer.timer = [NSTimer scheduledTimerWithTimeInterval:2
                                                             target:sharedTimer
                                                           selector:@selector(onTimer)
                                                           userInfo:nil
                                                            repeats:YES];

    });

    return sharedTimer;
}


-(void) onTimer{

    [self.logosPerCountry.allValues bk_each:^(id obj) {
        [((BankLogoCollection *)obj) moveNext];
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName:BANK_LOGO_TIMER_NOTIFICATION_NAME
                                                        object:self];
}

-(NSString *)currentDefaultLogo{
    return ((BankLogoCollection *)self.logosPerCountry[@"default"]).currentLogoUrl;
}

- (NSString *)currentLogoUrlForCountryCode:(NSString *)countryCode {
    NSString *upcasedCode = [countryCode uppercaseString];
    if(!self.logosPerCountry[upcasedCode]){
        BankLogoCollection *collection = [[BankLogoCollection alloc]init];
        [collection initImageUrlsWithCountryCode:upcasedCode];
        [self.logosPerCountry setObject:collection
                                 forKey:upcasedCode];
    }

    return ((BankLogoCollection *)self.logosPerCountry[upcasedCode]).currentLogoUrl;
}

@end