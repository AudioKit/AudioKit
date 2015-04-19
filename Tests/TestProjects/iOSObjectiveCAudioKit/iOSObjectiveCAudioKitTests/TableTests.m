//
//  TableTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 4/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface TableTests : XCTestCase

@end

@implementation TableTests {
    ViewController *vc;
    float AK_ACCURACY;
}

- (void)setUp {
    [super setUp];
    vc = (ViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    AK_ACCURACY = 0.001;
}

- (void)testStandardSineWave {
    AKTable *sine = vc.tableTestInstrument.sine;
    for (int i = 0; i < 10; i++) {
        XCTAssertEqualWithAccuracy([sine valueAtFractionalWidth:0.1 * i], sinf(0.1 * i * 2 * M_PI), AK_ACCURACY);
    }
}

- (void)testStandardSquareWave {
    AKTable *square = vc.tableTestInstrument.square;
    XCTAssertEqualWithAccuracy([square valueAtFractionalWidth:0.01],  1, AK_ACCURACY);
    XCTAssertEqualWithAccuracy([square valueAtFractionalWidth:0.49],  1, AK_ACCURACY);
    XCTAssertEqualWithAccuracy([square valueAtFractionalWidth:0.51], -1, AK_ACCURACY);
    XCTAssertEqualWithAccuracy([square valueAtFractionalWidth:0.99], -1, AK_ACCURACY);
}

- (void)testStandardTriangleWave {
    AKTable *triangle = vc.tableTestInstrument.triangle;
    XCTAssertEqualWithAccuracy([triangle valueAtFractionalWidth:0.0],  0,   AK_ACCURACY);
    XCTAssertEqualWithAccuracy([triangle valueAtFractionalWidth:0.1],  0.4, AK_ACCURACY);
    XCTAssertEqualWithAccuracy([triangle valueAtFractionalWidth:0.25], 1,   AK_ACCURACY);
    XCTAssertEqualWithAccuracy([triangle valueAtFractionalWidth:0.5],  0,   AK_ACCURACY);
    XCTAssertEqualWithAccuracy([triangle valueAtFractionalWidth:0.75], -1,  AK_ACCURACY);
}

- (void)testStandardSawtoothWave {
    AKTable *sawtooth = vc.tableTestInstrument.sawtooth;
    for (int i = 0; i < 10; i++) {
        XCTAssertEqualWithAccuracy([sawtooth valueAtFractionalWidth:0.1 * i], -1 + 2 * (0.1 * i), AK_ACCURACY);
    }
}

- (void)testStandardReverseSawtoothWave {
    AKTable *reverseSatooth = vc.tableTestInstrument.reverseSawtooth;
    for (int i = 0; i < 10; i++) {
        XCTAssertEqualWithAccuracy([reverseSatooth valueAtFractionalWidth:0.1 * i], 1 - 2 * (0.1 * i), AK_ACCURACY);
    }
}

@end
