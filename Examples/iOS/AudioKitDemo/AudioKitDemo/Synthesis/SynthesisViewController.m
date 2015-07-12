//
//  SynthesisViewController.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "SynthesisViewController.h"
#import "AKFoundation.h"
#import "FMSynthesizer.h"


@implementation SynthesisViewController
{
    IBOutlet UIView *fmSynthesizerTouchView;
    IBOutlet UIView *tambourineTouchView;
    
    AKTambourineInstrument *tambourine;
    FMSynthesizer *fmSynthesizer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tambourine = [[AKTambourineInstrument alloc] init];
    [AKOrchestra addInstrument:tambourine];
    
    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:tambourine.output];
    [AKOrchestra addInstrument:amp];
    [amp start];

    fmSynthesizer = [[FMSynthesizer alloc] init];
    [AKOrchestra addInstrument:fmSynthesizer];
}

- (IBAction)tapTambourine:(UITapGestureRecognizer *)sender {

    CGPoint touchPoint = [sender locationInView:tambourineTouchView];
    float scaledX = touchPoint.x / tambourineTouchView.bounds.size.width;
    float scaledY = 1.0 - touchPoint.y / tambourineTouchView.bounds.size.height;
    
    float intensity = scaledY*4000 + 20;
    float dampingFactor = scaledX / 2.0;
    AKTambourineNote *note = [[AKTambourineNote alloc] initWithIntensity:intensity
                                                           dampingFactor:dampingFactor];
    [tambourine playNote:note];
}


- (IBAction)tapFMOscillator:(UITapGestureRecognizer *)sender {
    
    CGPoint touchPoint = [sender locationInView:fmSynthesizerTouchView];
    float scaledX = touchPoint.x / fmSynthesizerTouchView.bounds.size.width;
    float scaledY = 1.0 - touchPoint.y / fmSynthesizerTouchView.bounds.size.height;
    
    float frequency = scaledY*400;
    float color = scaledX;
    FMSynthesizerNote *note = [[FMSynthesizerNote alloc] initWithFrequency:frequency color:color];
    [fmSynthesizer playNote:note];
}

@end
