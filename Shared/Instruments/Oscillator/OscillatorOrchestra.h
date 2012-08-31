//
//  OscillatorOrchestra.h
//  OCSiPad
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOrchestra.h"

#import "OscillatorInstrument.h"

@interface OscillatorOrchestra : OCSOrchestra

@property (nonatomic, strong) OscillatorInstrument *instrument;

@end
