//
//  OCSMandolin.m
//  Objective-C Sound
//
//  Auto-generated from database on 12/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's mandol:
//  http://www.csounds.com/manual/html/mandol.html
//

#import "OCSMandolin.h"
#import "OCSSoundFileTable.h"

@interface OCSMandolin () {
    OCSControl *ksize;
    OCSControl *kfreq;
    OCSControl *kdetune;
    OCSControl *kpluck;
    OCSControl *kgain;
    OCSControl *kamp;
}
@end

@implementation OCSMandolin

- (id)initWithBodySize:(OCSControl *)bodySize
             frequency:(OCSControl *)frequency
  pairedStringDetuning:(OCSControl *)pairedStringDetuning
         pluckPosition:(OCSControl *)pluckPosition
              loopGain:(OCSControl *)loopGain
             amplitude:(OCSControl *)amplitude
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
    OCSSoundFileTable *fileTable;
    fileTable = [[OCSSoundFileTable alloc] initWithFilename:file];
    
    return [NSString stringWithFormat:
            @"%@\n"
            @"%@ mandol %@, %@, %@, %@, %@, %@, %@",
            [fileTable stringForCSD],
            self, kamp, kfreq, kpluck, kdetune, kgain, ksize, fileTable];
}

@end