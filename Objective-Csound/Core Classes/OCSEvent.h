//
//  OCSEvent.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface OCSEvent : NSObject

@property (assign) float duration;

- (id)initWithInstrument:(OCSInstrument *)instrument
                duration:(float)duration;

@end
