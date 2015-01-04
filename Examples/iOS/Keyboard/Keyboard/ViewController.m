//
//  ViewController.m
//  Keyboard
//
//  Created by Aurelius Prochazka on 10/31/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "ViewController.h"

#import "AKFoundation.h"
#import "Conductor.h"


@interface ViewController () {


    Conductor *conductor;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    conductor = [[Conductor alloc] init];
}

- (IBAction)keyPressed:(id)sender
{
    UILabel *key = (UILabel *)sender;
    NSInteger index = [key tag];
    [key setBackgroundColor:[UIColor redColor]];
    [conductor play:index];
}

- (IBAction)keyReleased:(id)sender
{
    UILabel *key = (UILabel *)sender;
    NSInteger index = [key tag];
    if ((index == 1) || (index == 3) || (index == 6) || (index == 8) || (index == 10)) {
        [key setBackgroundColor:[UIColor blackColor]];
    } else {
        [key setBackgroundColor:[UIColor whiteColor]];
    }
    [conductor release:index];
}

- (IBAction)reverbSliderValueChanged:(id)sender
{
    [conductor setReverbFeedbackLevel:[(UISlider *)sender value]];
}

- (IBAction)toneColorSliderValueChanged:(id)sender
{
    [conductor setToneColor:[(UISlider *)sender value]];
}

@end