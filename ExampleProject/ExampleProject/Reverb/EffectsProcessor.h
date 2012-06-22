//
//  EffectsProcessor.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
#import "OCSInstrument.h"
#import "ToneGenerator.h"
#import "OCSReverb.h"
#import "OCSOutputStereo.h"
#import "OCSAssignment.h"

@interface EffectsProcessor : OCSInstrument 

@property (nonatomic, strong) OCSParam * input;

-(id) initWithOrchestra:(OCSOrchestra *)orch 
          ToneGenerator:(ToneGenerator *) toneGenerator;
-(void) start;

@end
