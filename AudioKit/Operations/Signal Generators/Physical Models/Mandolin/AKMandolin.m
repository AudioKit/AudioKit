//
//  AKMandolin.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's mandol:
//  http://www.csounds.com/manual/html/mandol.html
//

#import "AKMandolin.h"
#import "AKSoundFileTable.h"

@interface AKMandolin () {
    AKControl *ksize;
    AKControl *kfreq;
    AKControl *kdetune;
    AKControl *kpluck;
    AKControl *kgain;
    AKControl *kamp;
}
@end

@implementation AKMandolin

- (instancetype)initWithBodySize:(AKControl *)bodySize
                       frequency:(AKControl *)frequency
            pairedStringDetuning:(AKControl *)pairedStringDetuning
                   pluckPosition:(AKControl *)pluckPosition
                        loopGain:(AKControl *)loopGain
                       amplitude:(AKControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ksize = bodySize;
        kfreq = frequency;
        kdetune = pairedStringDetuning;
        kpluck = pluckPosition;
        kgain = loopGain;
        kamp = amplitude;
    }
    return self;
}

- (NSString *)stringForCSD {
    NSString *file;
    file = [[NSBundle mainBundle] pathForResource:@"mandpluk" ofType:@"aif"];
    AKSoundFileTable *fileTable;
    fileTable = [[AKSoundFileTable alloc] initWithFilename:file];
    
    return [NSString stringWithFormat:
            @"%@\n"
            @"%@ mandol %@, %@, %@, %@, %@, %@, %@",
            [fileTable stringForCSD],
            self, kamp, kfreq, kpluck, kdetune, kgain, ksize, fileTable];
}

@end