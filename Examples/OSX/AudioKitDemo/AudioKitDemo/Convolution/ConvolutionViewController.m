//
//  ConvolutionViewController.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "ConvolutionViewController.h"
#import "AKFoundation.h"
#import "AKTools.h"
#import "ConvolutionInstrument.h"


@implementation ConvolutionViewController
{
    ConvolutionInstrument *convolutionInstrument;
}

- (void)viewDidAppear {
    convolutionInstrument = [[ConvolutionInstrument alloc] init];
    [AKOrchestra addInstrument:convolutionInstrument];
    [AKOrchestra start];
}

- (void)viewDidDisappear {
    [convolutionInstrument stop];
    [[AKManager sharedManager] stop];
    [AKOrchestra reset];
}

- (IBAction)start:(id)sender {
    [convolutionInstrument play];
}

- (IBAction)stop:(id)sender {
    [convolutionInstrument stop];
}

- (IBAction)changeDryWet:(NSSlider *)sender {
    [AKTools setProperty:convolutionInstrument.dryWetBalance withSlider:sender];
}
- (IBAction)changeDishWell:(NSSlider *)sender {
    [AKTools setProperty:convolutionInstrument.dishWellBalance withSlider:sender];
}


@end
