//
//  AKTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/1/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"
#import "csound.h"

@implementation AKTable {
    CsoundObj *_csoundObj;
    CSOUND *_cs;
}

static int currentID = 2000;

+ (void)resetID {
    @synchronized(self) {
        currentID = 2000;
    }
}

// Returns a pointer to the table managed internally by Csound
- (float *)values
{
    NSAssert(csoundTableLength(_cs, _number) == _size, @"Inconsistent table sizes (not %@)", @(_size));

    float *ptr;
    int len = csoundGetTable(_cs, &ptr, _number);
    if (len > 0) {
        return ptr;
    }
    return NULL;
}

- (instancetype)initWithSize:(NSUInteger)tableSize
{
    self = [super init];
    if (self) {
        @synchronized([self class]) {
            _number = currentID++;
        }
        _size = tableSize;
        _csoundObj = [[AKManager sharedManager] engine];
        _cs = [_csoundObj getCsound];
        [_csoundObj updateOrchestra:self.orchestraString];
    }
    return self;
}

- (instancetype)init {
    return [self initWithSize:16384];
}

+ (instancetype)table {
    return [[AKTable alloc] init];
}

- (instancetype)initWithArray:(NSArray<NSNumber *> *)array {
    self = [super init];
    if (self) {
        @synchronized([self class]) {
            _number = currentID++;
        }
        _size = [array count];
        _csoundObj = [[AKManager sharedManager] engine];
        _cs = [_csoundObj getCsound];
        [_csoundObj updateOrchestra:self.orchestraString];
        float *table = self.values;
        
        if (table) {
            for (int i = 0; i < _size; i++) {
                table[i] = [array[i] floatValue];
            }
        }
    }
    return self;
}

- (float)valueAtIndex:(NSUInteger)index
{
    NSAssert(index < _size, @"Index out of bounds: %@", @(index));
    if (index < _size) {
        float *vals = self.values;
        if (vals) {
            return vals[index];
        }
    }
    return 0.0f;
}

- (float)valueAtFractionalWidth:(float)fractionalWidth
{
    NSAssert(fractionalWidth <= 1, @"Fractional width out of bounds:%f", fractionalWidth);
    if (fractionalWidth <= 1) {
        float *vals = self.values;
        if (vals) {
            return vals[(NSUInteger)(fractionalWidth * _size)];
        }
    }
    return 0.0f;
}
- (void)populateTableWithGenerator:(AKTableGenerator *)tableGenerator
{
    NSString *parameters = [[tableGenerator parametersWithSize:self.size] componentsJoinedByString:@", "];
    
    NSString *orchString = [NSString stringWithFormat:
                            @"giTable%d ftgen %d, 0, %@, %d, %@",
                            _number, _number, @(_size), [tableGenerator generationRoutineNumber], parameters];
    [_csoundObj updateOrchestra:orchString];
}

- (void)operateOnTableWithFunction:(float (^)(float))function
{
    float *table = self.values;
    if (table) {
        for (int i = 0; i < _size; i++) {
            table[i] = function(table[i]);
        }
    }
}

- (void)populateTableWithIndexFunction:(float (^)(NSUInteger))function
{
    float *table = self.values;
    if (table) {
        for (int i = 0; i < _size; i++) {
            table[i] = function(i);
        }
    }
}

- (void)populateTableWithFractionalWidthFunction:(float (^)(float))function
{
    float *table = self.values;
    if (table) {
        for (int i = 0; i < _size; i++) {
            float x = (float) i / _size;
            table[i] = function(x);
        }
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
    float *table = self.values;
    if (table) {
        float max = 0.0;
        for (int i = 0; i < _size; i++) {
            max = MAX(max, fabsf(table[i]));
        }
        if (max > 0.0) {
            [self scaleBy:1.0/max];
        }
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
    [standarSineWave populateTableWithGenerator:[[AKFourierSeriesTableGenerator alloc] init]];
    return standarSineWave;
}

+ (instancetype)standardSquareWave
{
    AKTable *standardSquareWave = [[AKTable alloc] init];
    [standardSquareWave populateTableWithGenerator:[AKLineTableGenerator squareWave]];
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
    return [NSString stringWithFormat:@"giTable%d ftgen %d, 0, %@, 2, 0", _number, _number, @(_size)];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%d", _number];
}

- (AKConstant *)length
{
    AKConstant *cst = [[AKConstant alloc] init];
    [cst setParameterString:[NSString stringWithFormat:@"ftlen(%d)", _number]];
    return cst;
}

@end
