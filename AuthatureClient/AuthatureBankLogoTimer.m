//
// Created by Mark Meeus on 02/07/15.
//

#import "AuthatureBankLogoTimer.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "BlocksKit/BlocksKit.h"

@interface AuthatureBankLogoTimer()
@property(nonatomic) int currentBankLogoUrlIndex;
@property(strong, nonatomic) NSTimer *timer;
@end

@implementation AuthatureBankLogoTimer {

}

static NSString *MISSING_BANK_LOGO = @"https://app.sign2pay.com/banks/missing.png";

+(AuthatureBankLogoTimer *) sharedInstance{
    static AuthatureBankLogoTimer *sharedTimer= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTimer = [[self alloc] init];
        [sharedTimer initImageUrls];
        sharedTimer.timer = [NSTimer scheduledTimerWithTimeInterval:2
                                                             target:sharedTimer
                                                           selector:@selector(onTimer)
                                                           userInfo:nil
                                                            repeats:YES];

    });

    return sharedTimer;
}


-(void) onTimer{
    self.currentBankLogoUrlIndex++;

    if(self.currentBankLogoUrlIndex >= self.bankLogoUrls.count){
        self.currentBankLogoUrlIndex  = 0;
    }

    if(self.currentBankLogoUrlIndex < self.bankLogoUrls.count){
        self.currenLogoUrl = [self.bankLogoUrls objectAtIndex:self.currentBankLogoUrlIndex];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:BANK_LOGO_TIMER_NOTIFICATION_NAME
                                                        object:self];
}


-(void) initImageUrls{
    self.bankLogoUrls = [NSMutableArray array];
    self.currenLogoUrl = MISSING_BANK_LOGO;
    self.currentBankLogoUrlIndex = -1;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"Authature iOS SDK v0.0.1" forHTTPHeaderField:@"User-Agent"];

    NSString *banksUrl = @"http://api.sign2pay.com/api/v2/banks.json";

    [manager GET:banksUrl  parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
        self.bankLogoUrls = [responseObject bk_map:^id(id bankInfo) {
            return bankInfo[@"logo"];
        }];

        if(self.bankLogoUrls.count > 0){
            self.currenLogoUrl = [self.bankLogoUrls firstObject];
            self.currentBankLogoUrlIndex = 0;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}
@end