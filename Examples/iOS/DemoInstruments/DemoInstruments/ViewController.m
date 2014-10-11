//
//  ViewController.m
//  DemoInstruments
//
//  Created by Aurelius Prochazka on 7/5/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "ViewController.h"

#import "AKFoundation.h"

#import "ExpressionInstrument.h"
#import "UnitGeneratorInstrument.h"

@implementation ViewController
{
    ExpressionInstrument *expressionInstrument;
    UnitGeneratorInstrument *unitGeneratorInstrument;
    BOOL isExpressionInstrumentPlaying;
    BOOL isUnitGeneratorInstrumentPlaying;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    
    expressionInstrument = [[ExpressionInstrument alloc] init];
    unitGeneratorInstrument = [[UnitGeneratorInstrument alloc] init];
    
    [orch addInstrument:expressionInstrument];
    [orch addInstrument:unitGeneratorInstrument];
    
    [[AKManager sharedAKManager] runOrchestra:orch];
}

- (IBAction)toggleExpressionInstrument:(id)sender {
    if (isExpressionInstrumentPlaying) {
        [expressionInstrument stop];
        isExpressionInstrumentPlaying = NO;
    } else {
        [expressionInstrument play];
        isExpressionInstrumentPlaying = YES;
    }
}

- (IBAction)toggleUnitGeneratorInstrument:(id)sender {
    if (isUnitGeneratorInstrumentPlaying) {
        [unitGeneratorInstrument stop];
        isUnitGeneratorInstrumentPlaying = NO;
    } else {
        [unitGeneratorInstrument play];
        isUnitGeneratorInstrumentPlaying = YES;
    }
}


@end
