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
    myOrchestra = [[CSDOrchestra alloc] init];    
    mySoundGenerator =  [[SoundGenerator alloc] initWithOrchestra:myOrchestra];
    [[CSDManager sharedCSDManager] runOrchestra:myOrchestra];
}

- (IBAction)hit1:(id)sender {
    [mySoundGenerator playNoteForDuration:1 Pitch:440];
}

- (IBAction)hit2:(id)sender {
    [mySoundGenerator playNoteForDuration:1 Pitch:(arc4random()%200+400)];
}

-(void) viewWillUnload {
    [[CSDManager sharedCSDManager] stop];
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
