//
//  AKPhrase.h
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 12/12/14.
//  Copyright (c) 2014 h4y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKPhrase : NSObject

- (void)addNote:(AKNote *)note;
- (void)addNote:(AKNote *)note atTime:(float)time;

@end
