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

static CGFloat const AK_ACCURACY = 0.000001f;

@interface MathTests : XCTestCase

@end

@implementation MathTests {
    MathTestInstrument *mathTestInstrument;
}

- (void)setUp {
    [super setUp];
    mathTestInstrument = [(AppDelegate *)[[NSApplication sharedApplication] delegate] mathTestInstrument];;
}

- (void)testSum {
    XCTAssertEqualWithAccuracy(mathTestInstrument.sum.value,        3.14,     FLT_EPSILON);
}

- (void)testDifference {
    XCTAssertEqualWithAccuracy(mathTestInstrument.difference.value, 2.86,     FLT_EPSILON);
}

- (void)testProduct {
    XCTAssertEqualWithAccuracy(mathTestInstrument.product.value,    0.42,     FLT_EPSILON);
}

- (void)testQuotient {
    XCTAssertEqualWithAccuracy(mathTestInstrument.quotient.value,  21.428572, AK_ACCURACY);
}

- (void)testInverse {
    XCTAssertEqualWithAccuracy(mathTestInstrument.inverse.value,    0.333333, AK_ACCURACY);
}

- (void)testFloor {
    XCTAssertEqualWithAccuracy(mathTestInstrument.floor.value,      3,        FLT_EPSILON);
}

- (void)testRound {
    XCTAssertEqualWithAccuracy(mathTestInstrument.round.value,      3,        FLT_EPSILON);
}

- (void)testFractionalPart {
    XCTAssertEqualWithAccuracy(mathTestInstrument.fraction.value,   0.14,     FLT_EPSILON);
}

- (void)testAbsoluteValue {
    XCTAssertEqualWithAccuracy(mathTestInstrument.absolute.value,  18.428571, AK_ACCURACY);
}

- (void)testLog {
    XCTAssertEqualWithAccuracy(mathTestInstrument.log.value,        1.098612, AK_ACCURACY);
}

- (void)testLog10 {
    XCTAssertEqualWithAccuracy(mathTestInstrument.log10.value,      0.477121, AK_ACCURACY);
}

- (void)testSquareRoot {
    XCTAssertEqualWithAccuracy(mathTestInstrument.squareRoot.value, 1.732051, AK_ACCURACY);
}


@end
