//
//  AudioFilePlayer.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSLoopingOscillator.h"
#import "OCSReverb.h"
#import "OCSOutputStereo.h"

@interface AudioFilePlayer : OCSInstrument

- (id)init;
- (void)play;

@end
