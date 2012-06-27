//
//  MoreGrainViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MoreGrainViewController.h"
#import "OCSManager.h"
#import "OCSOrchestra.h"

@implementation MoreGrainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    myGrainBirds = [[GrainBirds alloc] init];

    fx = [[GrainBirdsReverb alloc] initWithGrainBirds:myGrainBirds];
   
    [orch addInstrument:myGrainBirds];
    [orch addInstrument:fx];
    
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

-(IBAction)hit1:(id)sender
{
    [[myGrainBirds grainDensity] setValue:12];
    [[myGrainBirds grainDuration] setValue:0.01f];

    [[myGrainBirds pitchOffsetStartValue] setValue:0];
    [[myGrainBirds pitchOffsetFirstTarget] setValue:100];
        
    [[myGrainBirds reverbSend] setValue:0.1];
    
    [[myGrainBirds pitchClass] setValue:10.6f];
    [myGrainBirds playNoteForDuration:0.1];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playNote1Again:) userInfo:nil repeats:NO];
}

-(void)playNote1Again:(NSTimer *)aTimer
{
    [[myGrainBirds grainDuration] setValue:0.096];
    
    [[myGrainBirds pitchOffsetStartValue] setValue:100];
    [[myGrainBirds pitchOffsetFirstTarget] setValue:0];
    
    [[myGrainBirds reverbSend] setValue:0.2f];
    
    [[myGrainBirds pitchClass] setValue:11];
    [myGrainBirds playNoteForDuration:8];
    
    [timer invalidate];
    timer = nil;
}

-(IBAction)hit2:(id)sender
{
    
}
-(IBAction)hit3:(id)sender
{}
-(IBAction)hit4:(id)sender
{}
-(IBAction)hit5:(id)sender
{}
-(IBAction)hit6:(id)sender
{}

-(IBAction)startFx:(id)sender
{
    [fx start];
}

@end
