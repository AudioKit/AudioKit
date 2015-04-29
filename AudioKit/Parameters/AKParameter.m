//
//  AKParameter.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/5/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter.h"
#import "AKSum.h"
#import "AKDifference.h"
#import "AKProduct.h"
#import "AKInverse.h"
#import "AKSingleInputMathOperation.h"

@implementation AKParameter

static int currentID = 1;

+ (void) resetID {
    @synchronized(self) {
        currentID = 1;
    }
}

// -----------------------------------------------------------------------------
#  pragma mark - Initialization and String Representation
// -----------------------------------------------------------------------------

- (void) _commonInit
{
    @synchronized([self class]) {
        _parameterID = currentID++;
    }
    _state = @"unconnected";
    _dependencies = @[];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initGlobalWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        [self _commonInit];
        _parameterString = [NSString stringWithFormat:@"ga%@%@", name, @(_parameterID)];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        [self _commonInit];
        _parameterString = [NSString stringWithFormat:@"a%@%@", name, @(_parameterID)];
    }
    return self;
}

- (instancetype)initWithExpression:(NSString *)expression
{
    self = [super init];
    if (self) {
        [self _commonInit];
        _parameterString = [NSString stringWithString:expression];
    }
    return self;
}

+ (instancetype)parameterWithString:(NSString *)name
{
    return [[self alloc] initWithString:name];
}

+ (instancetype)globalParameter
{
    return [[self alloc] initGlobalWithString:@"Global"];
}

+ (instancetype)globalParameterWithString:(NSString *)name
{
    return [[self alloc] initGlobalWithString:name];
}

+ (instancetype)parameterWithFormat:(NSString *)format, ...
{
    va_list argumentList;
    va_start(argumentList, format);
    return [[self alloc] initWithExpression:[[NSString alloc] initWithFormat:format arguments:argumentList]];
    va_end(argumentList);
}

- (NSString *)description
{
    return _parameterString;
}

// -----------------------------------------------------------------------------
#  pragma mark - Initialization and Range Definition
// -----------------------------------------------------------------------------

- (instancetype)initWithValue:(float)initialValue
{
    self = [self init];
    if (self) {
        self.value        = initialValue;
        self.initialValue = initialValue;
    }
    return self;
}

- (instancetype)initWithMinimum:(float)minimum
                        maximum:(float)maximum;
{
    return [self initWithValue:minimum
                       minimum:minimum
                       maximum:maximum];
}

- (instancetype)initWithValue:(float)initialValue
                      minimum:(float)minimum
                      maximum:(float)maximum;
{
    self = [self init];
    if (self) {
        self.value        = initialValue;
        self.initialValue = initialValue;
        self.minimum = minimum;
        self.maximum = maximum;
    }
    return self;
}

- (void)scaleWithValue:(float)value
               minimum:(float)minimum
               maximum:(float)maximum
{
    float percentage = (value-minimum)/(maximum - minimum);
    float width = self.maximum - self.minimum;
    self.value = self.minimum + percentage * width;
}

- (void)reset {
    self.value = self.initialValue;
}

- (void)randomize
{
    float width = self.maximum - self.minimum;
    float random = ((float)arc4random() / 0x100000000);
    [self setValue:((random * width) + self.minimum)];
}

- (float)floatValue {
    return _value;
}

- (void)setFloatValue:(float)floatValue {
    self.value = floatValue;
}
// -----------------------------------------------------------------------------
#  pragma mark - Helper Functions
// -----------------------------------------------------------------------------

- (instancetype)plus:(AKParameter *)additionalParameter
{
    AKSum *sum = [[AKSum alloc] initWithFirstInput:self secondInput:additionalParameter];
    return sum;
}

- (instancetype)minus:(AKParameter *)subtrahend
{
    AKDifference *difference = [[AKDifference alloc] initWithInput:self minus:subtrahend];
    return difference;
}

- (instancetype)scaledBy:(AKParameter *)scalingFactor
{
    AKProduct *product = [[AKProduct alloc] initWithFirstInput:self secondInput:scalingFactor];
    return product;
}

- (instancetype)dividedBy:(AKParameter *)divisor
{
    AKProduct *quotient = [[AKProduct alloc] initWithFirstInput:self secondInput:divisor.inverse];
    return quotient;
}

- (instancetype)inverse
{
    AKInverse *inverse = [[AKInverse alloc] initWIthInput:self];
    return inverse;
}

- (instancetype)mathWithOperation:(NSString *)operation
{
    AKSingleInputMathOperation *output;
    output = [[AKSingleInputMathOperation alloc] initWithFunctionString:operation input:self];
    return output;
}

- (instancetype)floor          { return [self mathWithOperation:@"floor"]; }
- (instancetype)round          { return [self mathWithOperation:@"round"]; }
- (instancetype)fractionalPart { return [self mathWithOperation:@"frac"];  }

- (instancetype)absoluteValue  { return [self mathWithOperation:@"abs"];   }
- (instancetype)log            { return [self mathWithOperation:@"log"];   }
- (instancetype)log10          { return [self mathWithOperation:@"log10"]; }
- (instancetype)squareRoot     { return [self mathWithOperation:@"sqrt"];  }

- (instancetype)amplitudeFromFullScaleDecibel {
    return [self mathWithOperation:@"ampdbfs"];
}


@end
