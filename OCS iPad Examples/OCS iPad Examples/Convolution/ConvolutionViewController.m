//
//  ConvolutionViewController.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ConvolutionViewController.h"
#import "OCSiOSTools.h"
#import "OCSManager.h"
#import "ConvolutionInstrument.h"

@interface ConvolutionViewController () {
    ConvolutionInstrument *conv;
}
@end

@implementation ConvolutionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    conv = [[ConvolutionInstrument alloc] init];
    [orch addInstrument:conv];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)start:(id)sender {
    [conv play];
}

-(IBAction)changeDryWet:(id)sender {
    [OCSiOSTools setProperty:conv.dryWetBalance withSlider:(UISlider *)sender];
}
-(IBAction)changeDishWell:(id)sender {
    [OCSiOSTools setProperty:conv.dishWellBalance withSlider:(UISlider *)sender];
}

@end
