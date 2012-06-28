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

- (IBAction)hit1:(id)sender
{
    [conv playNoteForDuration:15];
}

- (IBAction)hit2:(id)sender
{
    [conv playNoteForDuration:5];
}


@end
