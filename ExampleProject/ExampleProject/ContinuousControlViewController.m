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
    myContinuousControllerInstrument = [[ContinuousControlledInstrument alloc]
                                            initWithOrchestra:myOrchestra];
    [[CSDManager sharedCSDManager] updateValueCacheWithContinuousParams:myOrchestra];
    [[CSDManager sharedCSDManager] runOrchestra:myOrchestra];
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
    [myContinuousControllerInstrument playNoteForDuration:3.0 Pitch:(arc4random()%200+499)];
    
    if (repeatingNoteTimer) {
        return;
    } else {
        [myContinuousControllerInstrument playNoteForDuration:3.0 Pitch:(arc4random()%200-499)];
        NSTimer *noteTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                          target:self 
                                                        selector:@selector(noteTimerFireMethod:)
                                                        userInfo:nil
                                                         repeats:YES];
        NSTimer *sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                              target:self 
                                                            selector:@selector(sliderTimerFireMethod:)
                                                            userInfo:nil
                                                             repeats:YES];
        NSRunLoop *rl = [NSRunLoop currentRunLoop];
        [rl addTimer:noteTimer forMode:NSDefaultRunLoopMode];
        [rl addTimer:sliderTimer forMode:NSDefaultRunLoopMode];
        
        repeatingSliderTimer = sliderTimer;
        repeatingNoteTimer = noteTimer;
    }
}

-(IBAction)stopInstrument:(id)sender
{
    repeatingNoteTimer = nil;
    repeatingSliderTimer = nil;
    [[CSDManager sharedCSDManager] stop];
}

-(void)noteTimerFireMethod:(NSTimer *)timer
{
    [myContinuousControllerInstrument playNoteForDuration:3.0 Pitch:(arc4random()%200+400)];
}

-(void)sliderTimerFireMethod:(NSTimer *)timer
{
    //[[myContinuousControllerInstrument myContinuousManager] continuousParamList] obj
    
    int minValue = [[myContinuousControllerInstrument modIndexContinuous] minimumValue];
    int maxValue = [[myContinuousControllerInstrument modIndexContinuous] maximumValue];
    [[myContinuousControllerInstrument modIndexContinuous] setValue:(arc4random()%(minValue+maxValue))];
}

@end
