//
//  ViewController.m
//  Convolution
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "ViewController.h"
#import "AKFoundation.h"
#import "AKTools.h"
#import "ConvolutionInstrument.h"

@implementation ViewController
{
    ConvolutionInstrument *conv;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    [AKTools setProperty:conv.dryWetBalance withSlider:(UISlider *)sender];
}
- (IBAction)changeDishWell:(id)sender {
    [AKTools setProperty:conv.dishWellBalance withSlider:(UISlider *)sender];
}


@end
