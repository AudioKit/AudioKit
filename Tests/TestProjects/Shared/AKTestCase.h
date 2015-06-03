//
//  AKTestCase.h
//  iOSObjectiveCAudioKit
//
//  Created by Stéphane Peter on 5/25/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//


#import <XCTest/XCTest.h>

#import "AKFoundation.h"
#import "NSData+MD5.h"

@interface AKTestCase : XCTestCase

- (NSString *)outputFileWithName:(NSString *)name;
- (NSString *)md5ForFile:(NSString *)file;
- (NSString *)md5ForOutputWithDuration:(float)duration;
@end
