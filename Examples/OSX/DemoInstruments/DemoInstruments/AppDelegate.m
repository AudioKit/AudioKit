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
#import "GrainInstrument.h"
#import "UnitGeneratorInstrument.h"

@interface AppDelegate ()
{
    __weak NSButton *_expressionStartButton;
    __weak NSButton *_grainStartButton;
    __weak NSButton *_unitGeneratorStartButton;
    ExpressionInstrument *expressionInstrument;
    GrainInstrument *grainInstrument;
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
    grainInstrument = [[GrainInstrument alloc] init];
    unitGeneratorInstrument = [[UnitGeneratorInstrument alloc] init];
    
    [orch addInstrument:expressionInstrument];
    [orch addInstrument:grainInstrument];
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

- (IBAction)toggleGrainInstrument:(id)sender {
    if (isGrainInstrumentPlaying) {
        [grainInstrument stop];
        isGrainInstrumentPlaying = NO;
        self.grainStartButton.title = @"Start";
    } else {
        [grainInstrument play];
        isGrainInstrumentPlaying = YES;
        self.grainStartButton.title = @"Stop";
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
