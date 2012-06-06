//
//  OscillatorViewController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OscillatorViewController.h"


@interface OscillatorViewController ()

@end

@implementation OscillatorViewController

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
    
    CSDOrchestra * orch = [[CSDOrchestra alloc] init];    
    
    myOscillator =  [[Oscillator alloc] initWithOrchestra:orch];

    [[CSDManager sharedCSDManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender {
    [myOscillator playNoteForDuration:30 withFrequency:440];
}

- (IBAction)hit2:(id)sender {
    [myOscillator playNoteForDuration:1 withFrequency:(arc4random()%200+400)];
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

@end
