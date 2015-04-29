//
//  ViewController.h
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 4/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKFoundation.h"
#import "MathTestInstrument.h"
#import "TableTestInstrument.h"

@interface ViewController : UIViewController

@property MathTestInstrument *mathTestInstrument;
@property TableTestInstrument *tableTestInstrument;

@end

