//
// Created by Mark Meeus on 30/06/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import "AuthatureAccessTokenStorage.h"


@implementation AuthatureAccessTokenStorage {

}

+ (NSDictionary *) getAccessTokenForClientId:(NSString *) clientId{
    NSString *path = [self getUserTokenPathForClientId:clientId];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (void) saveAccessTokenForClientId:(NSDictionary*) accessToken forClientId:(NSString *) clientId{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
    NSString *path = [self getUserTokenPathForClientId:clientId];
    NSError *error;
    [data writeToFile:path options:NSAtomicWrite | NSDataWritingFileProtectionComplete
                error:&error];
}

+ (NSString *) getUserTokenPathForClientId:(NSString *)clientId{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *directory = [NSString stringWithFormat:@"%@/Authature/%@", [paths firstObject], clientId];

    if(![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return [directory stringByAppendingString:@"/access_token"];
}
@end