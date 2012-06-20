//
//  ExpressionsViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ExpressionsViewController.h"

@implementation ExpressionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    myOrchestra = [[CSDOrchestra alloc] init];
    myToneGenerator = [[ExpressionToneGenerator alloc] initWithOrchestra:myOrchestra];
    [[CSDManager sharedCSDManager] runOrchestra:myOrchestra];
}

-(IBAction)hit1:(id)sender
{
    [myToneGenerator playNoteForDuration:9 Frequency:360];
}
-(IBAction)hit2:(id)sender
{
    [myToneGenerator playNoteForDuration:9 Frequency:410];
}

@end
