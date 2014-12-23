//
//  AppDelegate.m
//  Convolution
//
//  Created by Aurelius Prochazka on 7/27/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AppDelegate.h"
#import "AKFoundation.h"
#import "AKTools.h"
#import "ConvolutionInstrument.h"

@implementation AppDelegate
{
    ConvolutionInstrument *conv;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    conv = [[ConvolutionInstrument alloc] init];
    [AKOrchestra addInstrument:conv];
    [AKOrchestra start];
}

- (IBAction)start:(id)sender {
    [conv play];
}

- (IBAction)stop:(id)sender {
    [conv stop];
}

- (IBAction)changeDryWet:(id)sender {
    [AKTools setProperty:conv.dryWetBalance withSlider:(NSSlider *)sender];
}
- (IBAction)changeDishWell:(id)sender {
    [AKTools setProperty:conv.dishWellBalance withSlider:(NSSlider *)sender];
}

@end
