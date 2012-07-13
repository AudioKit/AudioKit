//
//  MidifiedInstrumentViewController.h
//  Objective-Csound
//
//  Created by Adam Boulanger on 7/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MidifiedInstrumentViewController : UIViewController {
    IBOutlet UISwitch *noteOnSwitch;
    
    IBOutlet UISlider *frequencySlider;
    IBOutlet UILabel *frequencyLabel;
    
    IBOutlet UISlider *modulationSlider;
    IBOutlet UILabel *modulationLabel;
    
    IBOutlet UISlider *midiCutoffSlider;
    IBOutlet UILabel *midiCutoffLabel;
}

-(IBAction)noteOnOff:(id)sender;

-(IBAction)moveFrequencySlider:(id)sender;
-(IBAction)moveModulationSlider:(id)sender;

-(IBAction)midiPanic:(id)sender;

@end
