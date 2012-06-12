//
//  ExpressionsViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ExpressionsViewController.h"

@interface ExpressionsViewController ()

@end

@implementation ExpressionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    myOrchestra = [[CSDOrchestra alloc] init];
    myToneGenerator = [[ExpressionToneGenerator alloc] initWithOrchestra:myOrchestra];
    [[CSDManager sharedCSDManager] runOrchestra:myOrchestra];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)viewWillUnload
{
    [[CSDManager sharedCSDManager] stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(IBAction)hit1:(id)sender
{
    [myToneGenerator playNoteForDuration:9 Pitch:360];
}
-(IBAction)hit2:(id)sender
{
    [myToneGenerator playNoteForDuration:9 Pitch:410];
}

@end
