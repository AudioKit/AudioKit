//
//  AKFSignalFromMonoWithAttackAnalysis.m
//  AudioKit
//
//  Created by Adam Boulanger on 2/13/13.
//  Copyright (c) 2013 Adam Boulanger. All rights reserved.
//

#import "AKFSignalFromMonoWithAttackAnalysis.h"

@implementation AKFSignalFromMonoWithAttackAnalysis
{
    AKFunctionTable *functionTable;
    
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


- (instancetype)initWithSoundFile:(AKFunctionTable *)soundFileSource
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

- (instancetype)initWithSoundFile:(AKFunctionTable *)soundFileSource
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
        functionTable = soundFileSource;
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
           self, timeScale, ampScale, pchScale, functionTable, attFlag,
           wrapFlag, iOffset, iFFTSize, iOverlap, dbThresh
           ];
}

@end
