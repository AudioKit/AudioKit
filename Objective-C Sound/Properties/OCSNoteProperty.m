//
//  OCSNoteProperty.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSNoteProperty.h"
#import "OCSNote.h"

@interface OCSNoteProperty() {
    OCSNote *myNote;
    int pValue;
}
@end

@implementation OCSNoteProperty

@synthesize minimumValue, maximumValue;
@synthesize value=currentValue;
@synthesize name;

@synthesize pValue;
@synthesize note=myNote;


- (id) init
{
    self = [super init];
    if (self) {
        pValue = 0;
        [self setName:@"NoteProperty"];
    }
    return self;
}


- (id)initWithMinValue:(float)minValue
              maxValue:(float)maxValue;
{
    return [self initWithValue:minValue minValue:minValue maxValue:maxValue];
}

- (id)initWithValue:(float)initialValue
           minValue:(float)minValue
           maxValue:(float)maxValue;
{
    self = [self init];
    if (self) {
        currentValue = initialValue;
        minimumValue = minValue;
        maximumValue = maxValue;
    }
    return self;
}

- (void)setName:(NSString *)newName {
    [self setParameterString:[NSString stringWithFormat:@"i%@%i", newName, _myID]];
}

- (void)setValue:(Float32)newValue {
    currentValue = newValue;
    if (minimumValue && newValue < minimumValue) {
        currentValue = minimumValue;
        NSLog(@"%@ out of bounds, assigning to minimum", self);
    }
    else if (maximumValue && newValue > maximumValue) {
        currentValue = maximumValue;
        NSLog(@"%@ out of bounds, assigning to maximum", self);
    }
    [myNote updateProperties];
}


- (void)randomize;
{
    float width = maximumValue - minimumValue;
    [self setValue:(((float) rand() / RAND_MAX) * width) + minimumValue];
}

@end
