//
//  AppDelegate.m
//  Convolution
//
//  Created by Aurelius Prochazka on 7/27/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AppDelegate.h"
#import "AKFoundation.h"
#import "ConvolutionInstrument.h"
#import "AKOSXTools.h"

@interface AppDelegate() {
    ConvolutionInstrument *conv;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    conv = [[ConvolutionInstrument alloc] init];
    [orch addInstrument:conv];
    [[AKManager sharedAKManager] runOrchestra:orch];
}

- (IBAction)start:(id)sender {
    [conv play];
}

- (IBAction)stop:(id)sender {
    [conv stop];
}

- (IBAction)changeDryWet:(id)sender {
    [AKOSXTools setProperty:conv.dryWetBalance withSlider:(NSSlider *)sender];
}
- (IBAction)changeDishWell:(id)sender {
    [AKOSXTools setProperty:conv.dishWellBalance withSlider:(NSSlider *)sender];
}



@end
