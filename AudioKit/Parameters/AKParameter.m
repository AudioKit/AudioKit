//
//  AKParameter.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/5/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter.h"

@implementation AKParameter

static int currentID = 1;

// -----------------------------------------------------------------------------
#  pragma mark - Initialization and String Representation
// -----------------------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    _myID = currentID++;
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

- (instancetype)initGlobalWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        _parameterString = [NSString stringWithFormat:@"ga%@%i", name, _myID];
    }
    return self;
}

+ (instancetype)globalParameterWithString:(NSString *)name
{
    return [[self alloc] initGlobalWithString:name];
}

+(id)parameterWithFormat:(NSString *)format, ...
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

- (instancetype)initWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        _parameterString = [NSString stringWithFormat:@"a%@%i", name, _myID];
    }
    return self;
}

- (instancetype)initWithExpression:(NSString *)expression
{
    self = [super init];
    if (self) {
        _parameterString = [NSString stringWithString:expression];
    }
    return self;
}

+(void) resetID {
    currentID = 1;
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


// -----------------------------------------------------------------------------
#  pragma mark - Helper Functions
// -----------------------------------------------------------------------------

- (instancetype)plus:(AKParameter *)additionalParameter
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) + (%@))", self, additionalParameter]];
    return new;
}

- (instancetype)minus:(AKParameter *)subtractedParameter
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) - (%@))", self, subtractedParameter]];
    return new;
}

- (instancetype)scaledBy:(AKParameter *)scalingFactor
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) * (%@))", self, scalingFactor]];
    return new;
}

- (instancetype)dividedBy:(AKParameter *)divisor
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) / (%@))", self, divisor]];
    return new;
}

- (instancetype)inverse
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"(1/(%@))", self]];
    return new;
}

- (instancetype)mathWithOperation:(NSString *)operation{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"%@(%@)", operation, _parameterString]];
    return new;
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
