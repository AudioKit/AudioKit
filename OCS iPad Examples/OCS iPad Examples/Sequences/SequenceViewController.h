//
//  SequenceViewController.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SequenceViewController : UIViewController 
{
    IBOutlet UITextField *durationValue;
    IBOutlet UISlider *durationSlider;
}

- (IBAction)playSequenceOfNotes:(id)sender; 
- (IBAction)playSequenceOfNoteProperties:(id)sender;
- (IBAction)playSequenceOfInstrumentProperties:(id)sender; 

- (IBAction)moveDurationSlider:(id)sender;

@end
