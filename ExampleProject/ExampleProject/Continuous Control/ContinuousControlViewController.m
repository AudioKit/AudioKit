//
//  ContinuousControlViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ContinuousControlViewController.h"

@implementation ContinuousControlViewController

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
    myTweakableInstrument = [[TweakableInstrument alloc] initWithOrchestra:myOrchestra];
    [[CSDManager sharedCSDManager] runOrchestra:myOrchestra];
    
    float minValue    = [[myTweakableInstrument amplitude] minimumValue];
    float maxValue    = [[myTweakableInstrument amplitude] maximumValue];
    float actualValue = [[myTweakableInstrument amplitude] value];
    float sliderValue = (actualValue-minValue)/(maxValue-minValue)* 100.0;
    [amplitudeSlider setValue:sliderValue];

    minValue    = [[myTweakableInstrument modulation] minimumValue];
    maxValue    = [[myTweakableInstrument modulation] maximumValue];
    actualValue = [[myTweakableInstrument modulation] value];
    sliderValue = (actualValue-minValue)/(maxValue-minValue)* 100.0;
    [modulationSlider setValue:sliderValue];
}

-(void) viewDidDisappear:(BOOL)animated 
{
    [repeatingNoteTimer invalidate];
    repeatingNoteTimer = nil;
    [repeatingSliderTimer invalidate];
    repeatingSliderTimer = nil;
    //[[myTweakableInstrument myPropertyManager] closeMidiIn];
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

-(IBAction)runInstrument:(id)sender
{
    [myTweakableInstrument playNoteForDuration:3.0 Frequency:(arc4random()%200+499)];
    
    if (repeatingNoteTimer) {
        return;
    } else {
        repeatingNoteTimer   = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self 
                                                              selector:@selector(noteTimerFireMethod:)   userInfo:nil repeats:YES];
        repeatingSliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
                                                              selector:@selector(sliderTimerFireMethod:) userInfo:nil repeats:YES];
//        NSRunLoop *rl = [NSRunLoop currentRunLoop];
//        [rl addTimer:noteTimer forMode:NSDefaultRunLoopMode];
//        [rl addTimer:sliderTimer forMode:NSDefaultRunLoopMode];
//        
//        repeatingSliderTimer = sliderTimer;
//        repeatingNoteTimer = noteTimer;
    }
}

-(IBAction)stopInstrument:(id)sender
{
    [repeatingNoteTimer invalidate];
    repeatingNoteTimer = nil;
    [repeatingSliderTimer invalidate];
    repeatingSliderTimer = nil;
}

-(void)noteTimerFireMethod:(NSTimer *)timer
{
    [myTweakableInstrument playNoteForDuration:3.0 Frequency:(arc4random()%200+400)];
}

-(void)sliderTimerFireMethod:(NSTimer *)timer
{
    float minValue = [[myTweakableInstrument modIndex] minimumValue];
    float maxValue = [[myTweakableInstrument modIndex] maximumValue];
    float newValue = minValue + (arc4random()%((int) (maxValue)));    
    myTweakableInstrument.modIndex.value = newValue;
    [modIndexSlider setValue:(newValue-minValue)/(maxValue - minValue) * 100.0];
}

-(IBAction)scaleAmplitude:(id)sender {
    UISlider * mySlider = (UISlider *) sender;
    float minValue = [[myTweakableInstrument amplitude] minimumValue];
    float maxValue = [[myTweakableInstrument amplitude] maximumValue];
    float newValue = (minValue + ([mySlider value]/100.0)*(maxValue-minValue));
    myTweakableInstrument.amplitude.value = newValue;
}

-(IBAction)scaleModulation:(id)sender {
    UISlider * mySlider = (UISlider *) sender;
    float minValue = [[myTweakableInstrument modulation] minimumValue];
    float maxValue = [[myTweakableInstrument modulation] maximumValue];
    float newValue = (minValue + ([mySlider value]/100.0)*(maxValue-minValue));    
    myTweakableInstrument.modulation.value = newValue;
}

@end
