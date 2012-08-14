//
//  ContinuousControlViewController.h
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "TweakableInstrument.h"

@interface ContinuousControlViewController : UIViewController
{
    IBOutlet UISlider *amplitudeSlider;
    IBOutlet UISlider *modulationSlider;
    IBOutlet UISlider *modIndexSlider;
    IBOutlet UILabel *amplitudeLabel;
    IBOutlet UILabel *modulationLabel;
    IBOutlet UILabel *modIndexLabel;
}

- (IBAction)runInstrument:(id)sender;
- (IBAction)stopInstrument:(id)sender;
- (IBAction)scaleAmplitude:(id)sender;
- (IBAction)scaleModulation:(id)sender;

@end
