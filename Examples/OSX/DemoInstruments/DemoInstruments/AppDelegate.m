//
//  AppDelegate.m
//  DemoInstruments
//
//  Created by Aurelius Prochazka on 8/4/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AppDelegate.h"
#import "AKFoundation.h"
#import "ExpressionInstrument.h"
#import "UnitGeneratorInstrument.h"

@interface AppDelegate ()
{
    __weak NSButton *_expressionStartButton;
    __weak NSButton *_grainStartButton;
    __weak NSButton *_unitGeneratorStartButton;
    ExpressionInstrument *expressionInstrument;
    UnitGeneratorInstrument *unitGeneratorInstrument;
    BOOL isExpressionInstrumentPlaying;
    BOOL isGrainInstrumentPlaying;
    BOOL isUnitGeneratorInstrumentPlaying;
}
@property (weak) IBOutlet NSButton *expressionStartButton;
@property (weak) IBOutlet NSButton *grainStartButton;
@property (weak) IBOutlet NSButton *unitGeneratorStartButton;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
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
        self.expressionStartButton.title = @"Start";
    } else {
        [expressionInstrument play];
        isExpressionInstrumentPlaying = YES;
        self.expressionStartButton.title = @"Stop";
    }
}


- (IBAction)toggleUnitGeneratorInstrument:(id)sender {
    if (isUnitGeneratorInstrumentPlaying) {
        [unitGeneratorInstrument stop];
        isUnitGeneratorInstrumentPlaying = NO;
        self.unitGeneratorStartButton.title = @"Start";
    } else {
        [unitGeneratorInstrument play];
        isUnitGeneratorInstrumentPlaying = YES;
        self.unitGeneratorStartButton.title = @"Stop";
    }
}


@end
