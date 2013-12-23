//
//  ExpressionsViewController.m
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ExpressionsViewController.h"
#import "OCSManager.h"
#import "ExpressionToneGenerator.h"

@interface ExpressionsViewController () {
    ExpressionToneGenerator *myToneGenerator;
}
@end

@implementation ExpressionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    myToneGenerator = [[ExpressionToneGenerator alloc] init];
    [orch addInstrument:myToneGenerator];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender
{
    [myToneGenerator playForDuration:3];
}
- (IBAction)hit2:(id)sender
{
    [myToneGenerator playForDuration:9];
}

@end
