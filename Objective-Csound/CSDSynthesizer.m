//
//  CSDSynthesizer.m
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDSynthesizer.h"

@implementation CSDSynthesizer

@synthesize options;
@synthesize sampleRate;
@synthesize controlRate;
@synthesize numberOfChannels;
@synthesize zeroDBFullScaleValue;
@synthesize instruments;
@synthesize functionStatements;

-(int) numberOfSamples {
    return sampleRate/controlRate;
}

-(void) writeString:(NSString *) content toFile:(NSString *) fileName{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    fileName = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];

    //save content to the documents directory
    [content writeToFile:fileName 
              atomically:NO 
                encoding:NSStringEncodingConversionAllowLossy 
                   error:nil];
    
}


-(void) addInstrument:(CSDInstrument *) instrument {
    [instruments addObject:instrument];
}

-(void) addFunctionStatement:(CSDFunctionStatement *)f {
    [functionStatements addObject:f];
}

-(void) sendNoteTo:(CSDInstrument *)instr WithDuration:(float)d AndParameters:(NSString *)params {
    int instr_no = [instruments indexOfObject:instr] + 1;
    [csound sendScore:[NSString stringWithFormat:@"i%i 0 %0.2f %@", instr_no, d, params]];
}
-(void) playNote:(NSDictionary *) note WithDuration:(float) d {
    int instr_no = [instruments indexOfObject:[note valueForKey:@"instrument"]] + 1;
    NSString *params = [note valueForKey:@"parameters"];
    [csound sendScore:[NSString stringWithFormat:@"i%i 0 %0.2f %@", instr_no, d, params]];
}

-(void) run {
    
    NSString * instrumentText = @"";

    for (int i = 0; i< [instruments count ]; i++) {
        CSDInstrument *currentInst = [instruments objectAtIndex:i];
        instrumentText = [instrumentText stringByAppendingFormat:@"instr %i\n", i+1];
        instrumentText = [instrumentText stringByAppendingString:[currentInst csdEntry]];
        instrumentText = [instrumentText stringByAppendingString:@"endin\n"];
    }

    NSString * functionStatementText = @"";

    for (CSDFunctionStatement * f in functionStatements) {
        functionStatementText = [functionStatementText stringByAppendingString:[f text]];
    }
    
    //instruments = [instrumentArray objectAtIndex:0];
    
    NSString * template = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"template" ofType: @"csd"]       encoding:NSUTF8StringEncoding error:nil];
    template = [NSString stringWithFormat:template, options, header, instrumentText, functionStatementText  ];

    //NSString * template = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"simple" ofType: @"csd"]       encoding:NSUTF8StringEncoding error:nil];

    
    [self writeString:template toFile:@"new.csd"];
    //[[synth csdFileContents] writeToURL:[NSURL URLWithString:@"new.csd"] atomically:YES];    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString * fileName = [NSString stringWithFormat:@"%@/new.csd", documentsDirectory];
    NSLog(@"%@",[[NSString alloc] initWithContentsOfFile:fileName
                                            usedEncoding:nil
                                                   error:nil]);
    
    [csound startCsound:fileName];
}



- (id)init
{
    self = [super init];
    if (self) {
        options = @"-odac -dm0 -+rtmidi=null -+rtaudio=null -+msg_color=0";
        sampleRate = 44100;
        controlRate = 4410;
        numberOfChannels = 1; //MONO
        zeroDBFullScaleValue = 1.0f;
        header = [NSString stringWithFormat:@"0dbfs = %f", zeroDBFullScaleValue];
        functionStatements = [[NSMutableArray alloc] init]; //@";RUN CSOUND FOR 27 HOURS\nf0 1000000";
        instruments = [[NSMutableArray alloc] init];
        csound = [[CsoundObj alloc] init];
    }
    return self;
}

@end
