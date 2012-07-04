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
    GrainBirds *grainBirds;
    GrainBirdsReverb *fx;
    
    NSTimer *timer;
}
@end

@implementation MoreGrainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    grainBirds = [[GrainBirds alloc] init];

    fx = [[GrainBirdsReverb alloc] initWithGrainBirds:grainBirds];
   
    [orch addInstrument:grainBirds];
    [orch addInstrument:fx];
    
    [[[OCSManager sharedOCSManager] header] setZeroDBFullScaleValue:10000];
    
    [[OCSManager sharedOCSManager] runOrchestra:orch];
    
    //reset this back to the default
    [[[OCSManager sharedOCSManager] header] setZeroDBFullScaleValue:1];
}

-(IBAction)hit1:(id)sender
{
    NSLog(@"hit1");
    [[grainBirds grainDensity] setValue:12];
    [[grainBirds grainDuration] setValue:0.01f];

    [[grainBirds pitchOffsetStartValue] setValue:0];
    [[grainBirds pitchOffsetFirstTarget] setValue:100];
        
    [[grainBirds reverbSend] setValue:0.1];
    
    [[grainBirds pitchClass] setValue:10.6f];
    
    [self updateSliders];    
    [grainBirds playNoteForDuration:0.1];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playNote1Again:) userInfo:nil repeats:NO];
}

-(void)playNote1Again:(NSTimer *)aTimer
{
    NSLog(@"Playing note 1 again");
    [[grainBirds grainDuration] setValue:0.096];
    [[grainBirds grainDensity] setValue:12];
    
    [[grainBirds pitchOffsetStartValue] setValue:100];
    [[grainBirds pitchOffsetFirstTarget] setValue:0];
    
    [[grainBirds reverbSend] setValue:0.2f];
    
    [[grainBirds pitchClass] setValue:11];
    
    [self updateSliders];
    [grainBirds playNoteForDuration:8];
    
    [timer invalidate];
    timer = nil;
}

-(IBAction)hit2:(id)sender
{
     NSLog(@"hit2"); 
    [[grainBirds grainDensity] setValue:12];
    [[grainBirds grainDuration] setValue:0.01f];
    
    [[grainBirds pitchOffsetStartValue] setValue:0];
    [[grainBirds pitchOffsetFirstTarget] setValue:100];
    
    [[grainBirds reverbSend] setValue:0.1];
    
    [[grainBirds pitchClass] setValue:10.6f];
    
    [self updateSliders];
    
    [grainBirds playNoteForDuration:0.1];
    
        timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playNote2Again:) userInfo:nil repeats:NO];
}

-(void)playNote2Again:(NSTimer *)aTimer
{
    NSLog(@"Playing note 2 again");
    
    [[grainBirds pitchClass] setValue:10.6f];
    
    [self updateSliders];
    
    [grainBirds playNoteForDuration:0.1];
    
    [timer invalidate];
    timer = nil;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playNote2Final:) userInfo:nil repeats:NO];
}

-(void)playNote2Final:(NSTimer *)aTimer 
{
    NSLog(@"Playing note 2 final");
    [[grainBirds grainDuration] setValue:0.096f];
    
    [[grainBirds pitchOffsetStartValue] setValue:100];
    [[grainBirds pitchOffsetFirstTarget] setValue:0];
    
    [[grainBirds reverbSend] setValue:0.2];
    
    [[grainBirds pitchClass] setValue:11.2f];
    
    [self updateSliders];
    
    [grainBirds playNoteForDuration:0.1];
    
    [timer invalidate];
    timer = nil;
}

-(IBAction)hit3:(id)sender
{
    NSLog(@"hit3");
    [grainDurationSlider setValue:[grainDurationSlider maximumValue]];
    
    [[grainBirds grainDensity] setValue:10000];
    [[grainBirds grainDuration] setValue:0.0004f];
    
    [[grainBirds pitchOffsetStartValue] setValue:1000];
    [[grainBirds pitchOffsetFirstTarget] setValue:0];
    
    [[grainBirds reverbSend] setValue:0.1];
    
    [[grainBirds pitchClass] setValue:9.46f];
    
    [self updateSliders];
    
    [grainBirds playNoteForDuration:5];
    
    [timer invalidate];
    timer = nil;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(playNote3Again:) userInfo:nil repeats:NO];
}

-(void)playNote3Again:(NSTimer *)aTimer
{
    int t = 10;
    [[grainBirds pitchOffsetStartValue] setValue:0];
    [[grainBirds pitchOffsetFirstTarget] setValue:1500];
    
    [[grainBirds pitchClass] setValue:11.03f];
    
    [self updateSliders];
    
    [grainBirds playNoteForDuration:t];
    [timer invalidate];
    timer = nil;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector(hit3:) userInfo:nil repeats:NO];
}

-(IBAction)hit4:(id)sender
{
    NSLog(@"hit4"); 
    [[grainBirds grainDensity] setValue:12];
    [[grainBirds grainDuration] setValue:0.01f];
    
    [[grainBirds pitchOffsetStartValue] setValue:0];
    [[grainBirds pitchOffsetFirstTarget] setValue:100];
    
    [[grainBirds reverbSend] setValue:0.1];
    
    [[grainBirds pitchClass] setValue:10.6f];
    
    [self updateSliders];
    [grainBirds playNoteForDuration:0.1];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(playNote4Again:) userInfo:nil repeats:NO];
}

-(void)playNote4Again:(NSTimer *)aTimer
{
    [grainBirds playNoteForDuration:0.1];
    [timer invalidate];
    timer = nil;
}

-(IBAction)hit5:(id)sender
{
    NSLog(@"hit5"); 
    [[grainBirds grainDensity] setValue:12];
    [[grainBirds grainDuration] setValue:0.096f];
    
    [[grainBirds pitchOffsetStartValue] setValue:100];
    [[grainBirds pitchOffsetFirstTarget] setValue:0];
    
    [[grainBirds reverbSend] setValue:0.2];
    
    [[grainBirds pitchClass] setValue:11.03f];
    
    [self updateSliders];
    
    [grainBirds playNoteForDuration:5];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(playNote5Again:) userInfo:nil repeats:NO];
}

-(void)playNote5Again:(NSTimer *)aTimer
{
    NSLog(@"play 5 again"); 
    [[grainBirds grainDensity] setValue:50];
    [[grainBirds grainDuration] setValue:3.0];
    
    [[grainBirds pitchOffsetStartValue] setValue:400];
    [[grainBirds pitchOffsetFirstTarget] setValue:100];
    
    [[grainBirds reverbSend] setValue:0.3];
    
    [[grainBirds pitchClass] setValue:11.06f];
    
    [self updateSliders];
    
    [grainBirds playNoteForDuration:5];
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
    float minValue = [[grainBirds grainDensity] minimumValue];
    float maxValue = [[grainBirds grainDensity] maximumValue];
    float newValue = 1+ (minValue + ((powf(10.0, [mySlider value]))/10000.0)*(maxValue-minValue));
    grainBirds.grainDensity.value = newValue;
    
    if (newValue < 100) {
        grainBirds.grainDuration.value = 1/newValue;
    }
    NSLog(@"sliderVal: %f, gden: %f, gdur: %f",[mySlider value], [[grainBirds grainDensity] value], [[grainBirds grainDuration] value]);
}

-(IBAction)pitchOffsetStartMod:(id)sender
{
    UISlider * mySlider = (UISlider *)sender;
    float minValue = [[grainBirds pitchOffsetStartValue] minimumValue];
    float maxValue = [[grainBirds pitchOffsetStartValue] maximumValue];
    float newValue = minValue + ([mySlider value]/100.0)*(maxValue-minValue);
    grainBirds.pitchOffsetStartValue.value = newValue;
    
    NSLog(@"sliderVal: %f, pchOffStart: %f",[mySlider value], [[grainBirds pitchOffsetStartValue] value]);
}
-(IBAction)pitchOffsetTargetMod:(id)sender
{
    UISlider * mySlider = (UISlider *)sender;
    float minValue = [[grainBirds pitchOffsetFirstTarget] minimumValue];
    float maxValue = [[grainBirds pitchOffsetFirstTarget] maximumValue];
    float newValue = minValue + ([mySlider value]/100.0)*(maxValue-minValue);
    grainBirds.pitchOffsetFirstTarget.value = newValue;
    
    NSLog(@"sliderVal: %f, pchOffTarget: %f",[mySlider value], [[grainBirds pitchOffsetFirstTarget] value]);
}
-(IBAction)pitchClassMod:(id)sender
{
    UISlider * mySlider = (UISlider *)sender;
    float minValue = [[grainBirds pitchClass] minimumValue];
    float maxValue = [[grainBirds pitchClass] maximumValue];
    float newValue = minValue + ([mySlider value]/100.0)*(maxValue-minValue);
    grainBirds.pitchClass.value = newValue;
    
    NSLog(@"sliderVal: %f, pchOffStart: %f",[mySlider value], [[grainBirds pitchClass] value]);
}

-(void)updateSliders
{
    [grainDurationSlider setValue:[[grainBirds grainDuration] value]];
    [pitchClassSlider setValue:[[grainBirds pitchClass] value]];
    [pitchOffsetStartSlider setValue:[[grainBirds pitchOffsetStartValue] value]];
    [pitchOffsetTargetSlider setValue:[[grainBirds pitchOffsetFirstTarget] value]];
}

@end
