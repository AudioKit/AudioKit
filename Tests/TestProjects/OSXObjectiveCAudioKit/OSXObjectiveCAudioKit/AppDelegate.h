//
//  AppDelegate.h
//  OSXObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 4/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MathTestInstrument.h"
#import "TableTestInstrument.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property MathTestInstrument *mathTestInstrument;
@property TableTestInstrument *tableTestInstrument;

@end

