//
//  AKTestCase.m
//  iOSObjectiveCAudioKit
//
//  Created by Stéphane Peter on 5/25/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"
#import "AKManager.h"

/// Common code to set up and teardown AudioKit between tests

@implementation AKTestCase

- (void)setUp {
    [super setUp];
    [[AKManager sharedManager].engine setUpForTest];
}

- (void)tearDown {
    [[AKManager sharedManager].engine teardownForTest];
    [super tearDown];
}

- (NSString *)outputFileWithName:(NSString *)name
{
    return [NSString stringWithFormat:@"%@/AKTest-%@.aiff", NSTemporaryDirectory(), name];
}

- (NSString *)md5ForFile:(NSString *)file {
    return [[NSData dataWithContentsOfFile:file] MD5];
}

- (NSString *)md5ForOutputWithDuration:(float)duration
{
    NSString *outputFile = [self outputFileWithName:@"Output"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:duration];
    return [self md5ForFile:outputFile];
}
@end
