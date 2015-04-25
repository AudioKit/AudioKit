//
//  SynthesisViewController.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/23/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "SynthesisViewController.h"
#import "AKFoundation.h"
#import "FMSynthesizer.h"


@implementation SynthesisViewController
{
    IBOutlet NSView *fmSynthesizerTouchView;
    IBOutlet NSView *tambourineTouchView;
    
    Tambourine *tambourine;
    FMSynthesizer *fmSynthesizer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    tambourine = [[Tambourine alloc] init];
    [AKOrchestra addInstrument:tambourine];
    
    fmSynthesizer = [[FMSynthesizer alloc] init];
    [AKOrchestra addInstrument:fmSynthesizer];
}

- (IBAction)tapTambourine:(NSClickGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:tambourineTouchView];
    float scaledX = touchPoint.x / tambourineTouchView.bounds.size.width;
    float scaledY = 1.0 - touchPoint.y / tambourineTouchView.bounds.size.height;
    
    float intensity = scaledY*4000 + 20;
    float dampingFactor = scaledX / 2.0;
    TambourineNote *note = [[TambourineNote alloc] initWithIntensity:intensity
                                                       dampingFactor:dampingFactor];
    [tambourine playNote:note];
}


- (IBAction)tapFMOscillator:(NSClickGestureRecognizer *)sender {
    
    CGPoint touchPoint = [sender locationInView:fmSynthesizerTouchView];
    float scaledX = touchPoint.x / fmSynthesizerTouchView.bounds.size.width;
    float scaledY = 1.0 - touchPoint.y / fmSynthesizerTouchView.bounds.size.height;
    
    float frequency = scaledY*4000 + 20;
    float color = scaledX;
    FMSynthesizerNote *note = [[FMSynthesizerNote alloc] initWithFrequency:frequency color:color];
    [fmSynthesizer playNote:note];
}

@end
