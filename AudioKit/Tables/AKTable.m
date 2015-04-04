//
//  AKTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/1/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@implementation AKTable {
    MYFLT *table;
    CsoundObj *csoundObj;
    CSOUND *cs;
}

static int currentID = 2000;
+ (void)resetID { currentID = 2000; }

- (instancetype)initWithSize:(int)tableSize
{
    self = [super init];
    if (self) {
        _number = currentID++;
        _size = tableSize;
        table = malloc(_size *sizeof(MYFLT));
        csoundObj = [[AKManager sharedManager] engine];
        cs = [csoundObj getCsound];
        [csoundObj updateOrchestra:[self orchestraString]];
    }
    return self;
}

- (instancetype)init {
    return [self initWithSize:16384];
}

+ (instancetype)table {
    return [[AKTable alloc] init];
}

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _number = currentID++;
        _size = (int)[array count];
        table = malloc(_size *sizeof(MYFLT));
        csoundObj = [[AKManager sharedManager] engine];
        cs = [csoundObj getCsound];
        [csoundObj updateOrchestra:[self orchestraString]];
        
        
        while (csoundTableLength(cs, _number) != _size) {
            // do nothing
        }
        csoundGetTable(cs, &table, _number);
        for (int i = 0; i < _size; i++) {
            MYFLT value = (MYFLT)[array[i] floatValue];
            NSLog(@"%@ %f %f", array[i], [array[i] floatValue], value);
            table[i] = value;
        }
    }
    return self;
}

- (void)dealloc {
    free(table);
}

- (void)populateTableWithGenerator:(AKTableGenerator *)tableGenerator
{
    NSString *parameters = [[tableGenerator parametersWithSize:self.size] componentsJoinedByString:@", "];
    
    NSString *orchString = [NSString stringWithFormat:
                            @"giTable%d ftgen %d, 0, %d, %d, %@",
                            _number, _number, _size, [tableGenerator generationRoutineNumber], parameters];
    NSLog(@"%@",orchString);
    [csoundObj updateOrchestra:orchString];
}

- (void)operateOnTableWithFunction:(float (^)(float))function
{
    while (csoundTableLength(cs, _number) != _size) {
        // do nothing
    }
    csoundGetTable(cs, &table, _number);
    for (int i = 0; i < _size; i++) {
        table[i] = function(table[i]);
    }
}

- (void)populateTableWithIndexFunction:(float (^)(int))function
{
    while (csoundTableLength(cs, _number) != _size) {
        // do nothing
    }
    csoundGetTable(cs, &table, _number);
    for (int i = 0; i < _size; i++) {
        table[i] = function(i);
    }
}

- (void)populateTableWithFractionalWidthFunction:(float (^)(float))function
{
    while (csoundTableLength(cs, _number) != _size) {
        // do nothing
    }
    csoundGetTable(cs, &table, _number);
    for (int i = 0; i < _size; i++) {
        float x = (float) i / _size;
        table[i] = function(x);
    }
}

- (void)scaleBy:(float)scalingFactor
{
    [self operateOnTableWithFunction:^(float y) {
        return y*scalingFactor;
    }];
}

- (void)normalize
{
    while (csoundTableLength(cs, _number) != _size) {
        // do nothing
    }
    csoundGetTable(cs, &table, _number);
    float max = 0.0;
    for (int i = 0; i < _size; i++) {
        max = MAX(max, fabsf(table[i]));
    }
    if (max > 0.0) {
        [self scaleBy:1.0/max];
    }
}

- (void)absoluteValue
{
    [self operateOnTableWithFunction:^(float y) {
        return fabsf(y);
    }];
}

+ (instancetype)standardSineWave
{
    AKTable *standarSineWave = [[AKTable alloc] init];
    [standarSineWave populateTableWithFractionalWidthFunction:^(float x) {
        return sinf(M_PI*2*x);
    }];
    return standarSineWave;
}

+ (instancetype)standardSquareWave
{
    AKTable *standardSquareWave = [[AKTable alloc] init];
    [standardSquareWave populateTableWithGenerator:[AKLineTableGenerator squareWave]];
//    [standardSquareWave populateTableWithFractionalWidthFunction:^(float x) {
//        if (x < 0.5) {
//            return 1.0f;
//        } else {
//            return -1.0f;
//        }
//    }];
    return standardSquareWave;
}

+ (instancetype)standardTriangleWave {
    AKTable *standardTriangleWave = [[AKTable alloc] init];
    [standardTriangleWave populateTableWithGenerator:[AKLineTableGenerator triangleWave]];
    return standardTriangleWave;
}
+ (instancetype)standardSawtoothWave {
    AKTable *standardSawtoothWave = [[AKTable alloc] init];
    [standardSawtoothWave populateTableWithGenerator:[AKLineTableGenerator sawtoothWave]];
    return standardSawtoothWave;
}
+ (instancetype)standardReverseSawtoothWave {
    AKTable *standardReverseSawtoothWave = [[AKTable alloc] init];
    [standardReverseSawtoothWave populateTableWithGenerator:[AKLineTableGenerator reverseSawtoothWave]];
    return standardReverseSawtoothWave;
}

- (NSString *)orchestraString
{
    return [NSString stringWithFormat:@"giTable%d ftgen %d, 0, %d, 2, 0", _number, _number, _size];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%d", _number];
}

- (AKConstant *)length
{
    AKConstant *new = [[AKConstant alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ftlen(%d)", _number]];
    return new;
}

@end
