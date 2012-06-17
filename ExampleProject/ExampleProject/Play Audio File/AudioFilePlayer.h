//
//  AudioFilePlayer.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"
#import "CSDLoopingOscillator.h"
#import "CSDReverb.h"
#import "CSDOutputStereo.h"

@interface AudioFilePlayer : CSDInstrument

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) play;
@end
