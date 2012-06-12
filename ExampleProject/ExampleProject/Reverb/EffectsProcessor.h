//
//  EffectsProcessor.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"
#import "CSDManager.h"
#import "CSDReverb.h"
#import "CSDParamConstant.h"
#import "CSDOutputStereo.h"
#import "CSDAssignment.h"

@interface EffectsProcessor : CSDInstrument {
    CSDParam * input;
}
@property (nonatomic, strong) CSDParam * input;
-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) start;

@end
