//
//  ViewController.h
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
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
