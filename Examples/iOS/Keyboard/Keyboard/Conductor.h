//
//  Conductor.h
//  Keyboard
//
//  Created by Aurelius Prochazka on 1/3/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Conductor : NSObject

- (void)play:(NSInteger)key;
- (void)release:(NSInteger)key;
- (void)setReverbFeedbackLevel:(float)feedbackLevel;
- (void)setToneColor:(float)toneColor;

@end
