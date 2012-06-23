//
//  ContinuousControlViewController.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "TweakableInstrument.h"

@interface ContinuousControlViewController : UIViewController
{
    TweakableInstrument *myTweakableInstrument;
    
    NSTimer *repeatingNoteTimer;
    NSTimer *repeatingSliderTimer;
    
    IBOutlet UISlider * amplitudeSlider;
    IBOutlet UISlider * modulationSlider;
    IBOutlet UISlider * modIndexSlider;
}

- (IBAction)runInstrument:(id)sender;
- (IBAction)stopInstrument:(id)sender;
- (IBAction)scaleAmplitude:(id)sender;
- (IBAction)scaleModulation:(id)sender;

@end
