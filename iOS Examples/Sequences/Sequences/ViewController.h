//
//  ViewController.h
//  Sequences
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    IBOutlet UITextField *durationValue;
    IBOutlet UISlider *durationSlider;
}

- (IBAction)playSequenceOfNotes:(id)sender;
- (IBAction)playSequenceOfNoteProperties:(id)sender;
- (IBAction)playSequenceOfInstrumentProperties:(id)sender;

- (IBAction)moveDurationSlider:(id)sender;
@end
