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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(IBAction)runInstrument:(id)sender
{
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
        repeatingSliderTimer = sliderTimer;
        repeatingNoteTimer = noteTimer;
    }
}

-(void)noteTimerFireMethod
{
    [myContinuousControllerInstrument playNoteForDuration:3.0 Pitch:(arc4random()%200+400)];
}

-(void)sliderTimerFireMethod
{
    //WORKING HERE: adding slider to control via manager
    //[[myContinuousControllerInstrument myContinuousManager] continuousParamList
}

@end
