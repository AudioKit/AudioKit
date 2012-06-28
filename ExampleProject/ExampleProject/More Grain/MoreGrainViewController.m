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
#import "GrainBirds.h"
#import "GrainBirdsReverb.h"

@interface MoreGrainViewController ()
{
    GrainBirds *myGrainBirds;
    GrainBirdsReverb *fx;
    
    NSTimer *timer;
}
@end

@implementation MoreGrainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    myGrainBirds = [[GrainBirds alloc] init];

    fx = [[GrainBirdsReverb alloc] initWithGrainBirds:myGrainBirds];
   
    [orch addInstrument:myGrainBirds];
    [orch addInstrument:fx];
    
    [[OCSManager sharedOCSManager] setZeroDBFullScaleValue:[NSNumber numberWithInt:10000]];
    
    [[OCSManager sharedOCSManager] runOrchestra:orch];
    
    //reset this back to the default
    [[OCSManager sharedOCSManager] setZeroDBFullScaleValue:[NSNumber numberWithFloat:1.0f]];
}

-(IBAction)hit1:(id)sender
{
    NSLog(@"hit1");
    [[myGrainBirds grainDensity] setValue:12];
    [[myGrainBirds grainDuration] setValue:0.01f];

    [[myGrainBirds pitchOffsetStartValue] setValue:0];
    [[myGrainBirds pitchOffsetFirstTarget] setValue:100];
        
    [[myGrainBirds reverbSend] setValue:0.1];
    
    [[myGrainBirds pitchClass] setValue:10.6f];
    
    [self updateSliders];    
    [myGrainBirds playNoteForDuration:0.1];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playNote1Again:) userInfo:nil repeats:NO];
}

-(void)playNote1Again:(NSTimer *)aTimer
{
    NSLog(@"Playing note 1 again");
    [[myGrainBirds grainDuration] setValue:0.096];
    [[myGrainBirds grainDensity] setValue:12];
    
    [[myGrainBirds pitchOffsetStartValue] setValue:100];
    [[myGrainBirds pitchOffsetFirstTarget] setValue:0];
    
    [[myGrainBirds reverbSend] setValue:0.2f];
    
    [[myGrainBirds pitchClass] setValue:11];
    
    [self updateSliders];
    [myGrainBirds playNoteForDuration:8];
    
    [timer invalidate];
    timer = nil;
}

-(IBAction)hit2:(id)sender
{
     NSLog(@"hit2"); 
    [[myGrainBirds grainDensity] setValue:12];
    [[myGrainBirds grainDuration] setValue:0.01f];
    
    [[myGrainBirds pitchOffsetStartValue] setValue:0];
    [[myGrainBirds pitchOffsetFirstTarget] setValue:100];
    
    [[myGrainBirds reverbSend] setValue:0.1];
    
    [[myGrainBirds pitchClass] setValue:10.6f];
    
    [self updateSliders];
    
    [myGrainBirds playNoteForDuration:0.1];
    
        timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playNote2Again:) userInfo:nil repeats:NO];
}

-(void)playNote2Again:(NSTimer *)aTimer
{
    NSLog(@"Playing note 2 again");
    
    [[myGrainBirds pitchClass] setValue:10.6f];
    
    [self updateSliders];
    
    [myGrainBirds playNoteForDuration:0.1];
    
    [timer invalidate];
    timer = nil;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playNote2Final:) userInfo:nil repeats:NO];
}

-(void)playNote2Final:(NSTimer *)aTimer 
{
    NSLog(@"Playing note 2 final");
    [[myGrainBirds grainDuration] setValue:0.096f];
    
    [[myGrainBirds pitchOffsetStartValue] setValue:100];
    [[myGrainBirds pitchOffsetFirstTarget] setValue:0];
    
    [[myGrainBirds reverbSend] setValue:0.2];
    
    [[myGrainBirds pitchClass] setValue:11.2f];
    
    [self updateSliders];
    
    [myGrainBirds playNoteForDuration:0.1];
    
    [timer invalidate];
    timer = nil;
}

-(IBAction)hit3:(id)sender
{
    NSLog(@"hit3");
    [grainDurationSlider setValue:[grainDurationSlider maximumValue]];
    
    [[myGrainBirds grainDensity] setValue:10000];
    [[myGrainBirds grainDuration] setValue:0.0004f];
    
    [[myGrainBirds pitchOffsetStartValue] setValue:1000];
    [[myGrainBirds pitchOffsetFirstTarget] setValue:0];
    
    [[myGrainBirds reverbSend] setValue:0.1];
    
    [[myGrainBirds pitchClass] setValue:9.46f];
    
    [self updateSliders];
    
    [myGrainBirds playNoteForDuration:5];
    
    [timer invalidate];
    timer = nil;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(playNote3Again:) userInfo:nil repeats:NO];
}

-(void)playNote3Again:(NSTimer *)aTimer
{
    int t = 10;
    [[myGrainBirds pitchOffsetStartValue] setValue:0];
    [[myGrainBirds pitchOffsetFirstTarget] setValue:1500];
    
    [[myGrainBirds pitchClass] setValue:11.03f];
    
    [self updateSliders];
    
    [myGrainBirds playNoteForDuration:t];
    [timer invalidate];
    timer = nil;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector(hit3:) userInfo:nil repeats:NO];
}

-(IBAction)hit4:(id)sender
{
    NSLog(@"hit4"); 
    [[myGrainBirds grainDensity] setValue:12];
    [[myGrainBirds grainDuration] setValue:0.01f];
    
    [[myGrainBirds pitchOffsetStartValue] setValue:0];
    [[myGrainBirds pitchOffsetFirstTarget] setValue:100];
    
    [[myGrainBirds reverbSend] setValue:0.1];
    
    [[myGrainBirds pitchClass] setValue:10.6f];
    
    [self updateSliders];
    [myGrainBirds playNoteForDuration:0.1];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(playNote4Again:) userInfo:nil repeats:NO];
}

-(void)playNote4Again:(NSTimer *)aTimer
{
    [myGrainBirds playNoteForDuration:0.1];
    [timer invalidate];
    timer = nil;
}

-(IBAction)hit5:(id)sender
{
    NSLog(@"hit5"); 
    [[myGrainBirds grainDensity] setValue:12];
    [[myGrainBirds grainDuration] setValue:0.096f];
    
    [[myGrainBirds pitchOffsetStartValue] setValue:100];
    [[myGrainBirds pitchOffsetFirstTarget] setValue:0];
    
    [[myGrainBirds reverbSend] setValue:0.2];
    
    [[myGrainBirds pitchClass] setValue:11.03f];
    
    [self updateSliders];
    
    [myGrainBirds playNoteForDuration:5];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(playNote5Again:) userInfo:nil repeats:NO];
}

-(void)playNote5Again:(NSTimer *)aTimer
{
    NSLog(@"play 5 again"); 
    [[myGrainBirds grainDensity] setValue:50];
    [[myGrainBirds grainDuration] setValue:3.0];
    
    [[myGrainBirds pitchOffsetStartValue] setValue:400];
    [[myGrainBirds pitchOffsetFirstTarget] setValue:100];
    
    [[myGrainBirds reverbSend] setValue:0.3];
    
    [[myGrainBirds pitchClass] setValue:11.06f];
    
    [self updateSliders];
    
    [myGrainBirds playNoteForDuration:5];
    [timer invalidate];
    timer = nil;
}

-(IBAction)startFx:(id)sender
{
    [fx start];
}

#pragma mark - sliders
-(IBAction)scaleGrainDensity:(id)sender
{
    UISlider * mySlider = (UISlider *) sender;
    float minValue = [[myGrainBirds grainDensity] minimumValue];
    float maxValue = [[myGrainBirds grainDensity] maximumValue];
    float newValue = 1+ (minValue + ((powf(10.0, [mySlider value]))/10000.0)*(maxValue-minValue));
    myGrainBirds.grainDensity.value = newValue;
    
    if (newValue < 100) {
        myGrainBirds.grainDuration.value = 1/newValue;
    }
    NSLog(@"sliderVal: %f, gden: %f, gdur: %f",[mySlider value], [[myGrainBirds grainDensity] value], [[myGrainBirds grainDuration] value]);
}

-(IBAction)pitchOffsetStartMod:(id)sender
{
    UISlider * mySlider = (UISlider *)sender;
    float minValue = [[myGrainBirds pitchOffsetStartValue] minimumValue];
    float maxValue = [[myGrainBirds pitchOffsetStartValue] maximumValue];
    float newValue = minValue + ([mySlider value]/100.0)*(maxValue-minValue);
    myGrainBirds.pitchOffsetStartValue.value = newValue;
    
    NSLog(@"sliderVal: %f, pchOffStart: %f",[mySlider value], [[myGrainBirds pitchOffsetStartValue] value]);
}
-(IBAction)pitchOffsetTargetMod:(id)sender
{
    UISlider * mySlider = (UISlider *)sender;
    float minValue = [[myGrainBirds pitchOffsetFirstTarget] minimumValue];
    float maxValue = [[myGrainBirds pitchOffsetFirstTarget] maximumValue];
    float newValue = minValue + ([mySlider value]/100.0)*(maxValue-minValue);
    myGrainBirds.pitchOffsetFirstTarget.value = newValue;
    
    NSLog(@"sliderVal: %f, pchOffTarget: %f",[mySlider value], [[myGrainBirds pitchOffsetFirstTarget] value]);
}
-(IBAction)pitchClassMod:(id)sender
{
    UISlider * mySlider = (UISlider *)sender;
    float minValue = [[myGrainBirds pitchClass] minimumValue];
    float maxValue = [[myGrainBirds pitchClass] maximumValue];
    float newValue = minValue + ([mySlider value]/100.0)*(maxValue-minValue);
    myGrainBirds.pitchClass.value = newValue;
    
    NSLog(@"sliderVal: %f, pchOffStart: %f",[mySlider value], [[myGrainBirds pitchClass] value]);

}

-(void)updateSliders
{
    [grainDurationSlider setValue:[[myGrainBirds grainDuration] value]];
    [pitchClassSlider setValue:[[myGrainBirds pitchClass] value]];
    [pitchOffsetStartSlider setValue:[[myGrainBirds pitchOffsetStartValue] value]];
    [pitchOffsetTargetSlider setValue:[[myGrainBirds pitchOffsetFirstTarget] value]];
}

@end
