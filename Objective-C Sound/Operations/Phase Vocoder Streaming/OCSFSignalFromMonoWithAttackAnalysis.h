//
//  OCSFSignalFromMonoWithAttackAnalysis.h
//  SoundGenerator
//
//  Created by Adam Boulanger on 2/13/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"
#import "OCSFSignal.h"
#import "OCSAudio.h"

@interface OCSFSignalFromMonoWithAttackAnalysis : OCSFSignal

-(id)initWithSoundFile:(OCSFTable *)soundFileSource
              timeScaler:(OCSControl *)timeScaler
         amplitudeScaler:(OCSControl *)amplitudeScaler
             pitchScaler:(OCSControl *)pitchScaler;

-(id)initWithSoundFile:(OCSFTable *)soundFileSource
              timeScaler:(OCSControl *)timeScaler
         amplitudeScaler:(OCSControl *)amplitudeScaler
             pitchScaler:(OCSControl *)pitchScaler
                 fftSize:(OCSConstant *)fftSize
                 overlap:(OCSConstant *)overlap
         tableReadOffset:(OCSConstant *)tableReadOffset
   audioSourceWraparound:(OCSControl *)wraparoundFlag
         onsetProcessing:(OCSControl *)onsetProcessingFlag
    onsetDecibelThreshold:(OCSConstant *)onsetDecibelThreshold;


@end
