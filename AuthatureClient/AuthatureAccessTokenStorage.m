//
// Created by Mark Meeus on 30/06/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthatureAccessTokenStorage.h"
#import "NSArray+BlocksKit.h"


@implementation AuthatureAccessTokenStorage {

}

+ (NSDictionary *) getAccessTokenForClientId:(NSString *) clientId andKey:(NSString *) key{
    NSString *path = [self getUserTokenPathForClientId:clientId andKey:key];
    return [self tokenFromFile:path];
}

+ (void) saveAccessToken:(NSDictionary*) accessToken forClientId:(NSString *) clientId withKey:(NSString *)key{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
    NSString *path = [self getUserTokenPathForClientId:clientId andKey:key];
    NSError *error;
    [data writeToFile:path options:NSAtomicWrite | NSDataWritingFileProtectionComplete
                error:&error];
}

+ (NSString *) getUserTokenPathForClientId:(NSString *)clientId andKey:(NSString *)key{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *directory = [NSString stringWithFormat:@"%@/Authature/%@", [paths firstObject], clientId];

    if(![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return [directory stringByAppendingFormat:@"/%@", key];
}

+ (NSArray *) allAccessTokensForClientId:(NSString *)clientId{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *directory = [NSString stringWithFormat:@"%@/Authature/%@", [paths firstObject], clientId];

    if([[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        NSArray* tokenFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory
                                                                            error:NULL];
        return [tokenFiles bk_map:^id(NSString *tokenFileName) {
            NSString *tokenPath = [self getUserTokenPathForClientId:clientId
                                                             andKey:tokenFileName];
            return [self tokenFromFile:tokenPath];
        }];
    }
    return [NSArray array];
}

+ (void) destroyAccessTokenForClientId:(NSString *)clientId andKey:(NSString *)key{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *directory = [NSString stringWithFormat:@"%@/Authature/%@", [paths firstObject], clientId];
    NSString *tokenPath = [self getUserTokenPathForClientId:clientId andKey:key];
    if([[NSFileManager defaultManager] fileExistsAtPath:tokenPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:tokenPath error:nil];
    }
}
+(NSDictionary *) tokenFromFile:(NSString *)path{
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}
@end