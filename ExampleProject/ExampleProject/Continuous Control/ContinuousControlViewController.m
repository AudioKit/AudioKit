//
//  ContinuousControlViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ContinuousControlViewController.h"

@interface ContinuousControlViewController ()

@end

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
    myContinuousControllerInstrument = [[ContinuousControlledInstrument alloc] initWithOrchestra:myOrchestra];
    [[CSDManager sharedCSDManager] runOrchestra:myOrchestra];
    
    float minValue    = [[myContinuousControllerInstrument amplitude] minimumValue];
    float maxValue    = [[myContinuousControllerInstrument amplitude] maximumValue];
    float actualValue = [[myContinuousControllerInstrument amplitude] value];
    float sliderValue = (actualValue-minValue)/(maxValue-minValue)* 100.0;
    [amplitudeSlider setValue:sliderValue];

    minValue    = [[myContinuousControllerInstrument modulation] minimumValue];
    maxValue    = [[myContinuousControllerInstrument modulation] maximumValue];
    actualValue = [[myContinuousControllerInstrument modulation] value];
    sliderValue = (actualValue-minValue)/(maxValue-minValue)* 100.0;
    [modulationSlider setValue:sliderValue];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [repeatingNoteTimer invalidate];
    repeatingNoteTimer = nil;
    [repeatingSliderTimer invalidate];
    repeatingSliderTimer = nil;
    
    //[[myContinuousControllerInstrument myContinuousManager] closeMidiIn];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(IBAction)runInstrument:(id)sender
{
    [myContinuousControllerInstrument playNoteForDuration:3.0 Frequency:(arc4random()%200+499)];
    
    if (repeatingNoteTimer) {
        return;
    } else {
        [myContinuousControllerInstrument playNoteForDuration:3.0 Frequency:(arc4random()%200-499)];
        NSTimer *noteTimer   = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self 
                                                              selector:@selector(noteTimerFireMethod:)   userInfo:nil repeats:YES];
        NSTimer *sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
                                                              selector:@selector(sliderTimerFireMethod:) userInfo:nil repeats:YES];
        NSRunLoop *rl = [NSRunLoop currentRunLoop];
        [rl addTimer:noteTimer forMode:NSDefaultRunLoopMode];
        [rl addTimer:sliderTimer forMode:NSDefaultRunLoopMode];
        
        repeatingSliderTimer = sliderTimer;
        repeatingNoteTimer = noteTimer;
    }
}

-(IBAction)stopInstrument:(id)sender
{
    [repeatingNoteTimer invalidate];
    repeatingNoteTimer = nil;
    [repeatingSliderTimer invalidate];
    repeatingSliderTimer = nil;
    
    [[CSDManager sharedCSDManager] stop];
}

-(void)noteTimerFireMethod:(NSTimer *)timer
{
    [myContinuousControllerInstrument playNoteForDuration:3.0 Frequency:(arc4random()%200+400)];
}

-(void)sliderTimerFireMethod:(NSTimer *)timer
{
    //[[myContinuousControllerInstrument myContinuousManager] continuousParamList] obj
    
    float minValue = [[myContinuousControllerInstrument modIndex] minimumValue];
    float maxValue = [[myContinuousControllerInstrument modIndex] maximumValue];
    float newValue = minValue + (arc4random()%((int) (maxValue)));
    [[myContinuousControllerInstrument modIndex] setValue:newValue];
    [modIndexSlider setValue:(newValue-minValue)/(maxValue - minValue) * 100.0];
    //NSLog(@"%0.2f", newValue);
}

-(IBAction)scaleAmplitude:(id)sender {
    UISlider * mySlider = (UISlider *) sender;
    float minValue = [[myContinuousControllerInstrument amplitude] minimumValue];
    float maxValue = [[myContinuousControllerInstrument amplitude] maximumValue];
    float newValue = (minValue + ([mySlider value]/100.0)*(maxValue-minValue));
    [[myContinuousControllerInstrument amplitude] setValue:newValue];
    //NSLog(@"%0.2f", newValue);
}

-(IBAction)scaleModulation:(id)sender {
    UISlider * mySlider = (UISlider *) sender;
    float minValue = [[myContinuousControllerInstrument modulation] minimumValue];
    float maxValue = [[myContinuousControllerInstrument modulation] maximumValue];
    float newValue = (minValue + ([mySlider value]/100.0)*(maxValue-minValue));
    [[myContinuousControllerInstrument modulation] setValue:newValue];
    //NSLog(@"%0.2f", newValue);
}

@end
