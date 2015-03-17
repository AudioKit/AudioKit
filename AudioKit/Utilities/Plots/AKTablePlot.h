//
//  AKTablePlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/9/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKTable.h"

#import "CsoundObj.h"

@interface AKTablePlot : UIView

- (instancetype)initWithFrame:(CGRect)frame
                table:(AKTable *)table;
@property AKTable *table;

@end
