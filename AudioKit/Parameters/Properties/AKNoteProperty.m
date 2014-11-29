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

- (void)setName:(NSString *)newName {
    [self setParameterString:[NSString stringWithFormat:@"i%@%i", newName, _myID]];
}

- (void)setValue:(float)newValue {
    [super setValue:newValue];
    [_note updateProperties];
}

+ (instancetype)duration {
    AKNoteProperty *dur = [[self alloc] initWithMinimum:-2 maximum:1000000];
    [dur setParameterString:@"p3"];
    return dur;
}

@end
