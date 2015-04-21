//
//  TrackedFrequencyTests.m
//  OSXObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 4/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "TrackedFrequencyTestInstrument.h"

@interface TrackedFrequencyTests : XCTestCase

@end

@implementation TrackedFrequencyTests {
    TrackedFrequencyTestInstrument *testInstrument;
}

- (void)setUp {
    [super setUp];
    testInstrument = [[TrackedFrequencyTestInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
}


- (void)testTrackedFrequency {
    [testInstrument play];
    [NSThread sleepForTimeInterval:(NSTimeInterval)1.0];
    NSMutableArray *testLog = [[AKManager sharedManager] testLog];
    NSLog(@"TestLog %@", [testLog componentsJoinedByString:@", "]);
    XCTAssertEqual(testLog.count, 101);
    XCTAssertEqualWithAccuracy([testLog[2]   floatValue], 203,  1);
    XCTAssertEqualWithAccuracy([testLog[100] floatValue], 1976, 1);
}

@end
