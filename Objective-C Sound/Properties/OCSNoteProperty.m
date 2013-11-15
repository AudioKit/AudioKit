//
//  OCSNoteProperty.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSNoteProperty.h"
#import "OCSNote.h"

//@interface OCSNoteProperty() {
//    OCSNote *myNote;
//    int pValue;
//}
//@end

@implementation OCSNoteProperty

@synthesize value=currentValue;

- (id) init
{
    self = [super init];
    if (self) {
        _pValue = 0;
        [self setName:@"NoteProperty"];
    }
    return self;
}


- (instancetype)initWithMinValue:(float)minValue
              maxValue:(float)maxValue;
{
    return [self initWithValue:minValue minValue:minValue maxValue:maxValue];
}

- (instancetype)initWithValue:(float)initialValue
           minValue:(float)minValue
           maxValue:(float)maxValue;
{
    self = [self init];
    if (self) {
        currentValue = initialValue;
        _minimumValue = minValue;
        _maximumValue = maxValue;
    }
    return self;
}

- (void)setName:(NSString *)newName {
    [self setParameterString:[NSString stringWithFormat:@"i%@%i", newName, _myID]];
}

- (void)setValue:(Float32)newValue {
    currentValue = newValue;
    if (_minimumValue && newValue < _minimumValue) {
        currentValue = _minimumValue;
        NSLog(@"%@ out of bounds, assigning to minimum", self);
    }
    else if (_maximumValue && newValue > _maximumValue) {
        currentValue = _maximumValue;
        NSLog(@"%@ out of bounds, assigning to maximum", self);
    }
    [_note updateProperties];
}


- (void)randomize;
{
    float width = _maximumValue - _minimumValue;
    [self setValue:(((float) rand() / RAND_MAX) * width) + _minimumValue];
}

+ (id)duration {
    OCSNoteProperty *dur = [[self alloc] initWithMinValue:-2 maxValue:1000000];
    [dur setParameterString:@"p3"];
    return dur;
}

@end
