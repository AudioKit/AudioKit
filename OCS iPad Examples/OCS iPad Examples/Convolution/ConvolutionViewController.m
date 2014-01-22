//
//  ConvolutionViewController.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ConvolutionViewController.h"
#import "AKiOSTools.h"
#import "AKManager.h"
#import "ConvolutionInstrument.h"

@interface ConvolutionViewController () {
    ConvolutionInstrument *conv;
}
@end

@implementation ConvolutionViewController

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

- (IBAction)changeDryWet:(id)sender {
    [AKiOSTools setProperty:conv.dryWetBalance withSlider:(UISlider *)sender];
}
- (IBAction)changeDishWell:(id)sender {
    [AKiOSTools setProperty:conv.dishWellBalance withSlider:(UISlider *)sender];
}

@end
