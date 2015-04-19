//
//  MathTestCase.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 4/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "AppDelegate.h"

@interface MathTests : XCTestCase

@end

@implementation MathTests {
    AppDelegate *vc;
    float AK_ACCURACY;
}

- (void)setUp {
    [super setUp];
    vc = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    AK_ACCURACY = 0.000001;
}

- (void)testSum {
    XCTAssertEqualWithAccuracy(vc.mathTestInstrument.sum.value,        3.14,     FLT_EPSILON);
}

- (void)testDifference {
    XCTAssertEqualWithAccuracy(vc.mathTestInstrument.difference.value, 2.86,     FLT_EPSILON);
}

- (void)testProduct {
    XCTAssertEqualWithAccuracy(vc.mathTestInstrument.product.value,    0.42,     FLT_EPSILON);
}

- (void)testQuotient {
    XCTAssertEqualWithAccuracy(vc.mathTestInstrument.quotient.value,  21.428572, AK_ACCURACY);
}

- (void)testInverse {
    XCTAssertEqualWithAccuracy(vc.mathTestInstrument.inverse.value,    0.333333, AK_ACCURACY);
}

- (void)testFloor {
    XCTAssertEqualWithAccuracy(vc.mathTestInstrument.floor.value,      3,        FLT_EPSILON);
}

- (void)testRound {
    XCTAssertEqualWithAccuracy(vc.mathTestInstrument.round.value,      3,        FLT_EPSILON);
}

- (void)testFractionalPart {
    XCTAssertEqualWithAccuracy(vc.mathTestInstrument.fraction.value,   0.14,     FLT_EPSILON);
}

- (void)testAbsoluteValue {
    XCTAssertEqualWithAccuracy(vc.mathTestInstrument.absolute.value,  18.428571, AK_ACCURACY);
}

- (void)testLog {
    XCTAssertEqualWithAccuracy(vc.mathTestInstrument.log.value,        1.098612, AK_ACCURACY);
}

- (void)testLog10 {
    XCTAssertEqualWithAccuracy(vc.mathTestInstrument.log10.value,      0.477121, AK_ACCURACY);
}

- (void)testSquareRoot {
    XCTAssertEqualWithAccuracy(vc.mathTestInstrument.squareRoot.value, 1.732051, AK_ACCURACY);
}


@end
