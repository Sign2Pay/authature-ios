//
// Created by Mark Meeus on 01/07/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <objc/runtime.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import "UIImageView+Authature.h"
static char IMAGE_URLS_KEY;
static char CURRENT_IMAGE_URLS_KEY;
static NSString *BANK_LOGO_TIMER_NOTIFICATION_NAME = @"Authature/BankLogoTimer";
static NSString *MISSING_BANK_LOGO = @"https://app.sign2pay.com/banks/missing.png";

@interface AuthatureBankLogoTimer : NSObject
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation AuthatureBankLogoTimer
+(AuthatureBankLogoTimer *) sharedInstance{
    static AuthatureBankLogoTimer *sharedTimer= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTimer = [[self alloc] init];
        sharedTimer.timer = [NSTimer scheduledTimerWithTimeInterval:2
                                         target:sharedTimer
                                       selector:@selector(onTimer)
                                       userInfo:nil
                                        repeats:YES];

    });

    return sharedTimer;
}


-(void) onTimer{
    [[NSNotificationCenter defaultCenter] postNotificationName:BANK_LOGO_TIMER_NOTIFICATION_NAME
                                                        object:nil];
}

@end

@implementation UIImageView (Authature)

+ (UIImage*) imageViewWithBankLogos{
    UIImageView *imageView =[[UIImageView alloc] init];
    [imageView  useAsAuthatureBankLogos];
    return imageView;
}

- (NSArray *) imageUrls{
    return (NSArray *)objc_getAssociatedObject(self, &IMAGE_URLS_KEY);
}

- (void) setImageUrls:(NSArray *) urls{
    objc_setAssociatedObject(self, &IMAGE_URLS_KEY, urls, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *) currentImageIndex{
    return (NSNumber *)objc_getAssociatedObject(self, &CURRENT_IMAGE_URLS_KEY);
}

- (int) setCurrentIndex:(NSNumber *)index{
    objc_setAssociatedObject(self, &CURRENT_IMAGE_URLS_KEY, index, OBJC_ASSOCIATION_RETAIN);
}

-(void) useAsAuthatureBankLogos{
    [AuthatureBankLogoTimer sharedInstance]; //make sure the instance is there
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBankLogoTimer)
                                                 name:BANK_LOGO_TIMER_NOTIFICATION_NAME
                                               object:nil];
    [self initImageUrls];
    [self setImageWithURLString:MISSING_BANK_LOGO];
}

- (void)setImageWithURLString:(NSString *)string {
    NSURL *url = [NSURL URLWithString:string];
    [self setImageWithURL:url];
}

-(void) useAsAuthatureBankLogosWithToken:(NSDictionary *)accessToken{

}

-(void) initImageUrls{
    NSMutableArray *imageUrls = [NSMutableArray array];
    [self setImageUrls:imageUrls];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"Authature iOS SDK v0.0.1" forHTTPHeaderField:@"User-Agent"];

    NSString *banksUrl = @"http://api.sign2pay.com/api/v2/banks.json";

    [manager GET:banksUrl  parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
        [imageUrls removeAllObjects];
        for(NSDictionary *bankInfo in responseObject){
            [imageUrls addObject:bankInfo[@"logo"]];
        }
        if(imageUrls.count > 0){
            [self setImageWithURLString:[imageUrls firstObject]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

-(void) onBankLogoTimer{
    NSArray *imageUrls = [self imageUrls];

    NSNumber *currentIndex = [self currentImageIndex];
    int currentIndexInt = [currentIndex intValue];
    currentIndexInt ++;
    if(currentIndexInt >= imageUrls.count){
        currentIndexInt = 0;
    }
    currentIndex = [NSNumber numberWithInt:currentIndexInt];
    [self setCurrentIndex:currentIndex];

    if(currentIndexInt < imageUrls.count){
        NSString *imageUrl = [imageUrls objectAtIndex:currentIndexInt];
        [self setImageWithURLString:imageUrl];
    }
}

@end