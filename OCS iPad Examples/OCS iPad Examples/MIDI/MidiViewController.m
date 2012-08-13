//
//  MidiViewController.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MidiViewController.h"




@interface MidiViewController ()

@end

@implementation MidiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[OCSManager sharedOCSManager] enableMidi];
    [[[OCSManager sharedOCSManager] midi] addListener:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)noteOn:(int)note velocity:(int)velocity {
    NSLog(@"Note On: %i at Velocity: %i", note, velocity);
}
-(void)noteOff:(int)note velocity:(int)velocity{
    NSLog(@"Note Off: %i at Velocity: %i", note, velocity);
}
-(void)controller:(int)controller changedToValue:(int)value {
    NSLog(@"Controller: %i = %i", controller, value);
}


@end
