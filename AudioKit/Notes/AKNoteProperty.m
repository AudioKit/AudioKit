//
//  AKNoteProperty.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
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
        _isContinuous = YES;
    }
    return self;
}

- (void)setName:(NSString *)newName
{
    [self setParameterString:[NSString stringWithFormat:@"i%@%@", newName, @(self.parameterID)]];
}

- (void)setValue:(float)newValue
{
    [super setValue:newValue];
    if (_isContinuous) [_note updateProperties];
}

- (void)setValue:(float)floatValue afterDelay:(float)time
{
    [super setValue:floatValue];
    if (_isContinuous) [_note updatePropertiesAfterDelay:time];
}

+ (instancetype)duration
{
    AKNoteProperty *dur = [[self alloc] initWithMinimum:-2 maximum:1000000];
    [dur setParameterString:@"p3"];
    return dur;
}

@end
