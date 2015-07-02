//
// Created by Mark Meeus on 29/06/15.
// Copyright (c) 2015 Sign2Pay. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
* The user Params object used to initialize the AuthatureClient
*/
@interface AuthatureUserParams : NSObject
/**
* The users First Name
* The users Last Name
* The user identifier (email address)
*/
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *identifier;
@end