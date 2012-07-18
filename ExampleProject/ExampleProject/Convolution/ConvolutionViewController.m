//
//  ConvolutionViewController.m
//  Objective-Csound Example
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ConvolutionViewController.h"
#import "Helper.h"
#import "OCSManager.h"
#import "ConvolutionInstrument.h"

@interface ConvolutionViewController () {
    ConvolutionInstrument *conv;
    OCSEvent *playback;
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
    //[conv playNoteForDuration:150000];
    playback = [[OCSEvent alloc] initWithInstrument:conv];
    [playback trigger];
}

-(IBAction)changeDryWet:(id)sender 
{
    conv.dryWetBalance.value = [Helper scaleValueFromSlider:sender 
                                                    minimum:kDryWetBalanceMin 
                                                    maximum:kDryWetBalanceMax];

}
-(IBAction)changeDishWell:(id)sender;
{
    conv.dishWellBalance.value = [Helper scaleValueFromSlider:sender 
                                                      minimum:kDishWellBalanceMin 
                                                      maximum:kDishWellBalanceMax];

}

@end
