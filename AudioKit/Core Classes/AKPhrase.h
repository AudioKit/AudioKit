//
//  AKPhrase.h
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 12/12/14.
//  Copyright (c) 2014 h4y. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKNote;
@class AKInstrument;

@interface AKPhrase : NSObject

- (void)addNote:(AKNote *)note;
- (void)addNote:(AKNote *)note atTime:(float)time;
- (void)playUsingInstrument:(AKInstrument *)instrument;

@end
