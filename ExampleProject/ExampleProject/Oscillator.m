//
//  Oscillator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "Oscillator.h"

@implementation Oscillator
@synthesize orchestra;

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra {
    self = [super init];
    if (self) {
        orchestra = newOrchestra;
        instrumentNumberInOrchestra = [orchestra addInstrument:self];

        //Define P-columns beyond p1-p3
        //iFrequency = @"p4";
        iFrequency = [CSDParam paramForColumn:4];
        //Define Constants
        iAmplitude = 0.4;
        iFTableSize = 4096;
    }
    return self;
}

-(id) initUsingOpcodes:(CSDOrchestra *)newOrchestra {
    self = [super init];
    if (self) {
        orchestra = newOrchestra;
        instrumentNumberInOrchestra = [orchestra addInstrument:self];
        
        CSDFunctionTable * iSine = [[CSDFunctionTable alloc] initWithType:kGenSine 
                                                                UsingSize:iFTableSize];
        [self addOpcode:iSine];
        
        CSDOscillator * aOut = [CSDOscillator oscillatorWithAmplitude:[CSDParam paramFromFloat:iAmplitude] 
                                                            Frequency:iFrequency
                                                        FunctionTable:[CSDParam paramFromOpcode:iSine]];
         
        CSDOscillator * aOut = [[CSDOscillator alloc] initWithAmplitude:iAmplitude 
                                                              Frequency:iFrequency
                                                          FunctionTable:iSine];
        [self addOpcode:aOut];
        
        /CSDOut * out = [[CSDOut alloc] initWithOut:aOut];
        [self addOpcode:out];

        
    }
    return self;
}

-(NSString *) textForOrchestra2 {
    

    
    
    
    NSString * text=  @"iSine ftgentmp 0, 0, 4096, 10, 1\n"
                       "aOut1 oscil 0.4, p4, iSine\n"
                       "out aOut1";
    return text;
}

-(NSString *) textForOrchestra {
    NSString * text=  @"iSine ftgentmp 0, 0, 4096, 10, 1\n"
                       "aOut1 oscil 0.4, p4, iSine\n"
                       "out aOut1";
    return text;
}

-(void) playNoteForDuration:(float)iDuration withFrequency:(float)iFreq {
    NSString * note = [NSString stringWithFormat:@"%0.2f %0.2f", iDuration, iFreq];
    [[CSDManager sharedCSDManager] playNote:note OnInstrument:instrumentNumberInOrchestra];
}

@end
