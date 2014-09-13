//
//  AKFSignalFromMonoWithAttackAnalysis.m
//  AudioKit
//
//  Created by Adam Boulanger on 2/13/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "AKFSignalFromMonoWithAttackAnalysis.h"

@implementation AKFSignalFromMonoWithAttackAnalysis
{
    AKFTable *fTable;
    
    AKControl *timeScale;
    AKControl *ampScale;
    AKControl *pchScale;
    
    AKConstant *iFFTSize;
    AKConstant *iOverlap;
    AKConstant *iWinSize;
    AKConstant *iOffset;
    
    AKControl *wrapFlag;
    AKControl *attFlag;
    AKConstant *dbThresh;
}


- (instancetype)initWithSoundFile:(AKFTable *)soundFileSource
                 timeScalingRatio:(AKControl *)timeScalingRatio
                       pitchRatio:(AKControl *)pitchRatio
{
    return [self initWithSoundFile:soundFileSource
                        timeScaler:timeScalingRatio
                   amplitudeScaler:akpi(1)
                       pitchScaler:pitchRatio
                           fftSize:akpi(1024)
                           overlap:akpi(256)
                   tableReadOffset:akpi(0)
             audioSourceWraparound:akpi(1)
                   onsetProcessing:akp(1)
             onsetDecibelThreshold:akpi(1)];
}

- (instancetype)initWithSoundFile:(AKFTable *)soundFileSource
                       timeScaler:(AKControl *)timeScaler
                  amplitudeScaler:(AKControl *)amplitudeScaler
                      pitchScaler:(AKControl *)pitchScaler
                          fftSize:(AKConstant *)fftSize
                          overlap:(AKConstant *)overlap
                  tableReadOffset:(AKConstant *)tableReadOffset
            audioSourceWraparound:(AKControl *)wraparoundFlag
                  onsetProcessing:(AKControl *)onsetProcessingFlag
            onsetDecibelThreshold:(AKConstant *)onsetDecibelThreshold
{
    self = [super initWithString:[self operationName]];
    if( self) {
        fTable = soundFileSource;
        iFFTSize = fftSize;
        iOverlap = overlap;
        iOffset = tableReadOffset;
        
        timeScale = timeScaler;
        ampScale = amplitudeScaler;
        pchScale = pitchScaler;
        
        wrapFlag = wraparoundFlag;
        attFlag = onsetProcessingFlag;
        dbThresh = onsetDecibelThreshold;
    }
    return self;
}

// Csound Prototype: fsig pvstanal ktimescal, kamp, kpitch, ktab, [kdetect, kwrap, ioffset,ifftsize, ihop, idbthresh]
- (NSString *)stringForCSD
{
    return[NSString stringWithFormat:
           @"%@ pvstanal %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
           self, timeScale, ampScale, pchScale, fTable, attFlag,
           wrapFlag, iOffset, iFFTSize, iOverlap, dbThresh
           ];
}

@end
