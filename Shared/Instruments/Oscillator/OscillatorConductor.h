//
//  OscillatorConductor.h
//  OCSiPad
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

@interface OscillatorConductor : NSObject

- (void)setFrequency:(float)frequency;
- (void)setAmplitude:(float)amplitude;
- (void)startSound;
- (void)stopSound;
- (void)quit;

@end
