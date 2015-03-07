//
//  AKFloatPlot.h
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 3/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AKFloatPlot : UIView

@property float minimum;
@property float maximum;

- (instancetype)initWithMinimum:(float)minimum
                        maximum:(float)maximum;
- (void)updateWithValue:(float)value;
@end
