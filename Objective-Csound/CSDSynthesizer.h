//
//  CsoundSynthesizer.h
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CsoundObj.h"
#import "CSDInstrument.h"
#import "CSDFunctionStatement.h"

@protocol CSDOpcode
-(NSString *) textWithPValue:(int)p;
@end

@interface CSDSynthesizer : NSObject {
@private     
    CsoundObj * csound;
    //Orchestra
    NSString * header;
    
    //Score
    NSString * noteList; 
}
//Header Variables 
@property (nonatomic, strong) NSString * options;
@property (nonatomic, strong) NSMutableArray * instruments;
@property (nonatomic, strong) NSMutableArray * functionStatements;
@property int sampleRate;
//@property int controlRate;
//ARB - noticing that most csound-iOS files don't specify kr
//  in our tests we had to delete kr and just use ksmps to avoid distortion
@property int samplesPerControlPeriod; 
@property int numberOfChannels;
@property float zeroDBFullScaleValue;

//-(int) numberOfSamples;
-(void) run;
-(void) stopCsound;
-(void) resetSynth;

-(void) addInstrument:(CSDInstrument *) instrument;
-(void) addFunctionStatement:(CSDFunctionStatement *) f;

-(void) sendNoteTo:(CSDInstrument *)instr WithDuration:(float) d AndParameters:(NSString *)params;
-(void) playNote:(NSDictionary *) note WithDuration:(float) d;

//-(void) addInstrument:(int) instr 
//               AtRate:(NSString *)rate 
//           WithOutput:(NSString *)output;
//
@end
