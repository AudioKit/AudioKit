//
//  Tambourine.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Tambourine.h"

@implementation Tambourine

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        TambourineNote *note = [[TambourineNote alloc] init];
        [self addNoteProperty:note.intensity];
        [self addNoteProperty:note.dampingFactor];

        AKTambourine *tambourine = [AKTambourine tambourine];
        tambourine.intensity = note.intensity;
        tambourine.dampingFactor = note.dampingFactor;
        [self setAudioOutput:tambourine];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - Tambourine Note
// -----------------------------------------------------------------------------


@implementation TambourineNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _intensity = [[AKNoteProperty alloc] initWithValue:20.0 minimum:0 maximum:1000];
        [self addProperty:_intensity];

        _dampingFactor = [[AKNoteProperty alloc] initWithValue:0 minimum:0 maximum:1];
        [self addProperty:_dampingFactor];


        // Optionally set a default note duration
        self.duration.value = 1.0;
    }
    return self;
}

- (instancetype)initWithIntensity:(float)intensity dampingFactor:(float)dampingFactor;
{
    self = [self init];
    if (self) {
        _intensity.value = intensity;
        _dampingFactor.value = dampingFactor;
    }
    return self;
}

@end
