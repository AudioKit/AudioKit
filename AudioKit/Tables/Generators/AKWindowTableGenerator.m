//
//  AKWindowTableGenerator.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKWindowTableGenerator.h"

@implementation AKWindowTableGenerator {
    int type;
    float extra_term;
}

- (int)generationRoutineNumber {
    return -20;
}

- (instancetype)initHammingWindow
{
    self = [super init];
    if (self) type = 1;
    return self;
}

+ (instancetype)hammingWindow {
    return [[self alloc] initHammingWindow];
}

- (instancetype)initHannWindow
{
    self = [super init];
    if (self) type = 2;
    return self;
}

+ (instancetype)hannWindow {
    return [[self alloc] initHannWindow];
}

- (instancetype)initBartlettTriangleWindow
{
    self = [super init];
    if (self) type = 3;
    return self;
}

+ (instancetype)bartlettTriangleWindow {
    return [[self alloc] initBartlettTriangleWindow];
}


- (instancetype)initBlackmanThreeTermWindow
{
    self = [super init];
    if (self) type = 4;
    return self;
}

+ (instancetype)blackmanThreeTermWindow {
    return [[self alloc] initBlackmanThreeTermWindow];
}


- (instancetype)initBlackmanHarrisFourTermWindow
{
    self = [super init];
    if (self) type = 5;
    return self;
}

+ (instancetype)blackmanHarrisFourTermWindow {
    return [[self alloc] initBlackmanHarrisFourTermWindow];
}

- (instancetype)initGaussianWindow {
    return [self initGaussianWindowWithStandardDeviation:1.0f];
}

+ (instancetype)gaussianWindow {
    return [[self alloc] initGaussianWindow];
}

- (instancetype)initGaussianWindowWithStandardDeviation:(float)standardDeviation
{
    self = [super init];
    if (self) {
        type = 6;
        extra_term = standardDeviation;
    }
    return self;
}

+ (instancetype)gaussianWindowWithStandardDeviation:(float)standardDeviation {
    return [[self alloc] initGaussianWindowWithStandardDeviation:standardDeviation];
}

- (instancetype)initKaiserWindow {
    return [self initKaiserWindowWithOpenness:1.0f];
}

+ (instancetype)kaiserWindow {
    return [[self alloc] initKaiserWindow];
}

- (instancetype)initKaiserWindowWithOpenness:(float)openness{
    self = [super init];
    if (self) {
        type = 7;
        extra_term = openness;
    }
    return self;
}

+ (instancetype)kaiserWindowWithOpenness:(float)openness {
    return [[self alloc] initKaiserWindowWithOpenness:openness];
}

- (instancetype)initRectangleWindow
{
    self = [super init];
    if (self) type = 8;
    return self;
}

+ (instancetype)rectangleWindow {
    return [[self alloc] initRectangleWindow];
}

- (instancetype)initSyncWindow
{
    self = [super init];
    if (self) type = 9;
    return self;
}

+ (instancetype)syncWindow {
    return [[self alloc] initSyncWindow];
}

- (NSArray *)parametersWithSize:(NSUInteger)size
{
    if (type == 6 || type == 7) {
        return @[@(type), @1, @(extra_term)];
    } else {
        return @[@(type)];
    }
}

@end
