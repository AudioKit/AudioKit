//
//  OscillatorViewController.h
//  Objective-Csound Example
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

@interface OscillatorViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UILabel *frequencyLabel;

- (IBAction)playA:(id)sender;
- (IBAction)playRandomFrequency:(id)sender;
@end
