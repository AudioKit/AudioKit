//
//  AKNoteProperty.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKNoteProperty.h"
#import "AKNote.h"

@implementation AKNoteProperty

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pValue = 0;
        [self setName:@"NoteProperty"];
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
        _value        = initialValue;
        _initialValue = initialValue;
        _minimum = minimum;
        _maximum = maximum;
    }
    return self;
}

- (void)setName:(NSString *)newName {
    [self setParameterString:[NSString stringWithFormat:@"i%@%i", newName, _myID]];
}

- (void)setValue:(Float32)newValue {
    _value = newValue;
    if (_minimum && newValue < _minimum) {
        _value = _minimum;
        NSLog(@"%@ out of bounds, assigning to minimum", self);
    }
    else if (_maximum && newValue > _maximum) {
        _value = _maximum;
        NSLog(@"%@ out of bounds, assigning to maximum", self);
    }
    [_note updateProperties];
}

- (void)reset {
    self.value = self.initialValue;
}

- (void)randomize;
{
    float width = _maximum - _minimum;
    [self setValue:(((float) rand() / RAND_MAX) * width) + _minimum];
}

+ (instancetype)duration {
    AKNoteProperty *dur = [[self alloc] initWithMinimum:-2 maximum:1000000];
    [dur setParameterString:@"p3"];
    return dur;
}

@end
