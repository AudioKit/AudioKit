//
//  OCSNoteProperty.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSProperty.h"
@class OCSNote;

@interface OCSNoteProperty : OCSProperty

- (id) initWithNote:(OCSNote *)note
       initialValue:(float)initialValue
           minValue:(float)minValue
           maxValue:(float)maxValue;

@end
