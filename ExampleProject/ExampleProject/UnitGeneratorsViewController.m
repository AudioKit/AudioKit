//
//  UnitGeneratorsViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UnitGeneratorsViewController.h"

@interface UnitGeneratorsViewController ()

@end

@implementation UnitGeneratorsViewController

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
    myUnitGenSoundGenerator = [[UnitGenSoundGenerator alloc] initWithOrchestra:myOrchestra];
    [[CSDManager sharedCSDManager] runOrchestra:myOrchestra];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(IBAction)hit1:(id)sender
{
    [myUnitGenSoundGenerator playNoteForDuration:9.0];
}

-(IBAction)hit2:(id)sender
{
    [myUnitGenSoundGenerator playNoteForDuration:3.0];
}

@end
