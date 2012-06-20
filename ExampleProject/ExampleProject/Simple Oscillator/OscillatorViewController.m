//
//  OscillatorViewController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OscillatorViewController.h"

@implementation OscillatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CSDOrchestra * myOrchestra = [[CSDOrchestra alloc] init];    
    mySoundGenerator =  [[SoundGenerator alloc] initWithOrchestra:myOrchestra];
    [[CSDManager sharedCSDManager] runOrchestra:myOrchestra];
}

- (IBAction)hit1:(id)sender {
    [mySoundGenerator playNoteForDuration:1 Frequency:440];
}

- (IBAction)hit2:(id)sender {
    [mySoundGenerator playNoteForDuration:1 Frequency:(arc4random()%200+400)];
}

@end
