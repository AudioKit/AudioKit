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

        // Instrument Properties
        _pan = [[AKInstrumentProperty alloc] initWithValue:1.0 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKFMOscillator *oscillator = [AKFMOscillator oscillator];
        oscillator.baseFrequency = note.frequency;
        oscillator.amplitude = note.amplitude;

        AKPanner *panner = [[AKPanner alloc] initWithAudioSource:oscillator pan:_pan];

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
        _frequency = [self createPropertyWithValue:440 minimum:100 maximum:20000];
        _amplitude = [self createPropertyWithValue:0 minimum:0 maximum:1];

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
