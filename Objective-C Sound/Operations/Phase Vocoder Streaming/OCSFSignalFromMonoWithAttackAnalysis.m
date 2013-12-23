//
//  OCSFSignalFromMonoWithAttackAnalysis.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 2/13/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "OCSFSignalFromMonoWithAttackAnalysis.h"

@interface OCSFSignalFromMonoWithAttackAnalysis()
{
    OCSFTable *fTable;
    
    OCSControl *timeScale;
    OCSControl *ampScale;
    OCSControl *pchScale;
    
    OCSConstant *iFFTSize;
    OCSConstant *iOverlap;
    OCSConstant *iWinSize;
    OCSConstant *iOffset;
    
    OCSControl *wrapFlag;
    OCSControl *attFlag;
    OCSConstant *dbThresh;
    
}

@end

@implementation OCSFSignalFromMonoWithAttackAnalysis


-(instancetype)initWithSoundFile:(OCSFTable *)soundFileSource
                      timeScaler:(OCSControl *)timeScaler
                 amplitudeScaler:(OCSControl *)amplitudeScaler
                     pitchScaler:(OCSControl *)pitchScaler
{
    return [self initWithSoundFile:soundFileSource
                        timeScaler:timeScaler
                   amplitudeScaler:amplitudeScaler
                       pitchScaler:pitchScaler
                           fftSize:ocspi(2048)
                           overlap:ocspi(512)
                   tableReadOffset:ocspi(0)
             audioSourceWraparound:ocspi(1)
                   onsetProcessing:ocsp(1)
             onsetDecibelThreshold:ocspi(1)];
}

-(instancetype)initWithSoundFile:(OCSFTable *)soundFileSource
                      timeScaler:(OCSControl *)timeScaler
                 amplitudeScaler:(OCSControl *)amplitudeScaler
                     pitchScaler:(OCSControl *)pitchScaler
                         fftSize:(OCSConstant *)fftSize
                         overlap:(OCSConstant *)overlap
                 tableReadOffset:(OCSConstant *)tableReadOffset
           audioSourceWraparound:(OCSControl *)wraparoundFlag
                 onsetProcessing:(OCSControl *)onsetProcessingFlag
           onsetDecibelThreshold:(OCSConstant *)onsetDecibelThreshold
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
