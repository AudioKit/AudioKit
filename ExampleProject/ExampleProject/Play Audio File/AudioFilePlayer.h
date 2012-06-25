//
//  AudioFilePlayer.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface AudioFilePlayer : OCSInstrument {
    OCSProperty *frequencyMultiplier;
}


- (id)init;
- (void)play;
- (void)playWithFrequencyMultiplier:(float)freqMutiplier;

@end
