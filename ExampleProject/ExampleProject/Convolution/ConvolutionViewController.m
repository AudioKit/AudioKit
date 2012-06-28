//
//  ConvolutionViewController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ConvolutionViewController.h"
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

- (IBAction)start:(id)sender
{
    [conv playNoteForDuration:150000];
}

-(IBAction)changeDryWet:(id)sender 
{
    UISlider * mySlider = (UISlider *) sender;
    conv.dryWetBalance.value = mySlider.value;
}
-(IBAction)changeDishWell:(id)sender;
{
    UISlider * mySlider = (UISlider *) sender;
    conv.dishWellBalance.value = mySlider.value;
}

@end
