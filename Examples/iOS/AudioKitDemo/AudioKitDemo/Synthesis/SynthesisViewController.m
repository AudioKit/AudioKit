//
//  SynthesisViewController.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "SynthesisViewController.h"
#import "AKFoundation.h"
#import "Tambourine.h"
#import "FMSynthesizer.h"


@implementation SynthesisViewController
{
    IBOutlet UIPickerView *synthesizerPickerView;
    NSArray *pickerData;
    IBOutlet UIView *topTouchView;
    
    Tambourine *tambourine;
    FMSynthesizer *fmSynthesizer;
}

- (void)viewDidAppear:(BOOL)animated    {
    [super viewDidAppear:animated];
    tambourine = [[Tambourine alloc] init];
    [AKOrchestra addInstrument:tambourine];

    fmSynthesizer = [[FMSynthesizer alloc] init];
    [AKOrchestra addInstrument:fmSynthesizer];
    
    [AKOrchestra start];
}

- (void)viewWillDisappear:(BOOL)animated   {
    [super viewWillDisappear:animated];
    [AKOrchestra reset];
    [[AKManager sharedManager] stop];
}


- (IBAction)tapTambourine:(UITapGestureRecognizer *)sender {

    CGPoint touchPoint = [sender locationInView:topTouchView];
    float scaledX = touchPoint.x / topTouchView.bounds.size.width;
    float scaledY = 1.0 - touchPoint.y / topTouchView.bounds.size.height;
    
    float intensity = scaledY*4000 + 20;
    float dampingFactor = scaledX / 2.0;
    TambourineNote *note = [[TambourineNote alloc] initWithIntensity:intensity
                                                       dampingFactor:dampingFactor];
    [tambourine playNote:note];
}


- (IBAction)tapFMOscillator:(UITapGestureRecognizer *)sender {
    
    CGPoint touchPoint = [sender locationInView:topTouchView];
    float scaledX = touchPoint.x / topTouchView.bounds.size.width;
    float scaledY = 1.0 - touchPoint.y / topTouchView.bounds.size.height;
    
    float frequency = scaledY*4000 + 20;
    float color = scaledX;
    FMSynthesizerNote *note = [[FMSynthesizerNote alloc] initWithFrequency:frequency color:color];
    [fmSynthesizer playNote:note];
}

@end
