//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"

@implementation ___FILEBASENAMEASIDENTIFIER___

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super init];
    if (self) {

        // Instrument Properties
        _feedback = [self createPropertyWithValue:0.0 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKReverb *reverb = [[AKReverb alloc] initWithAudioSource:audioSource
                                                   feedbackLevel:_feedback
                                                 cutoffFrequency:akp(4000)];

        // Audio Output
        [self setStereoAudioOutput:reverb];

        // Reset Inputs
        [self resetParameter:audioSource];
    }
    return self;
}
@end
