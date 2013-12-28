//
//  OCSNoteProperty.m
//  Objective-C Sound
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

- (id) init
{
    self = [super init];
    if (self) {
        _pValue = 0;
        [self setName:@"NoteProperty"];
    }
    return self;
}


- (instancetype)initWithMinimumValue:(float)minimumValue
                        maximumValue:(float)maximumValue;
{
    return [self initWithValue:minimumValue
                  minimumValue:minimumValue
                  maximumValue:maximumValue];
}

- (instancetype)initWithValue:(float)initialValue
                 minimumValue:(float)minimumValue
                 maximumValue:(float)maximumValue;
{
    self = [self init];
    if (self) {
        _value        = initialValue;
        _minimumValue = minimumValue;
        _maximumValue = maximumValue;
    }
    return self;
}

- (void)setName:(NSString *)newName {
    [self setParameterString:[NSString stringWithFormat:@"i%@%i", newName, _myID]];
}

- (void)setValue:(Float32)newValue {
    _value = newValue;
    if (_minimumValue && newValue < _minimumValue) {
        _value = _minimumValue;
        NSLog(@"%@ out of bounds, assigning to minimum", self);
    }
    else if (_maximumValue && newValue > _maximumValue) {
        _value = _maximumValue;
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
    OCSNoteProperty *dur = [[self alloc] initWithMinimumValue:-2 maximumValue:1000000];
    [dur setParameterString:@"p3"];
    return dur;
}

@end
