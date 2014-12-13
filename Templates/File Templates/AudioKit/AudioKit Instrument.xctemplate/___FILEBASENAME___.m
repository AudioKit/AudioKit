//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"

@implementation ___FILEBASENAMEASIDENTIFIER___

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        ___FILEBASENAMEASIDENTIFIER___Note *note = [[___FILEBASENAMEASIDENTIFIER___Note alloc] init];
        [self addNoteProperty:note.frequency];
        [self addNoteProperty:note.amplitude];

        // Instrument Properties
        _pan = [[AKInstrumentProperty alloc] initWithValue:1.0 minimum:0.0 maximum:1.0];
        [self addProperty:_pan];

        // Instrument Definition
        AKFMOscillator *oscillator = [AKFMOscillator audio];
        oscillator.baseFrequency = note.frequency;
        oscillator.amplitude = note.amplitude;
        [self connect:oscillator];

        AKPanner *panner = [[AKPanner alloc] initWithAudioSource:oscillator pan:_pan];
        [self connect:panner];

        // Output to global effects processing
        _auxilliaryOutput = [AKStereoAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:panner];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - ___FILEBASENAMEASIDENTIFIER___ Note
// -----------------------------------------------------------------------------


@implementation ___FILEBASENAMEASIDENTIFIER___Note

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frequency = [[AKNoteProperty alloc] initWithValue:440 minimum:100 maximum:20000];
        [self addProperty:_frequency];

        _amplitude = [[AKNoteProperty alloc] initWithValue:0.0 minimum:0 maximum:1];
        [self addProperty:_amplitude];

        // Optionally set a default note duration
        self.duration.value = 1.0;
    }
    return self;
}

- (instancetype)initWithFrequency:(float)frequency amplitude:(float)amplitude;
{
    self = [self init];
    if (self) {
        _frequency.value = frequency;
        _amplitude.value = amplitude;
    }
    return self;
}

@end
