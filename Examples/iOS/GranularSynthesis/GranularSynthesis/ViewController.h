    //
//  ViewController.h
//  GranularSynthTest
//
//  Created by Nicholas Arner on 9/2/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISlider *averageGrainDurationSlider;
- (IBAction)averageGrainDurationControl:(id)sender;
@property (strong, nonatomic) IBOutlet UISlider *grainDensitySlider;
- (IBAction)grainDensityControl:(id)sender;
@property (strong, nonatomic) IBOutlet UISlider *freqDevSlider;
- (IBAction)freqDevControl:(id)sender;
@property (strong, nonatomic) IBOutlet UISlider *amplitudeSlider;
- (IBAction)amplitudeControl:(id)sender;

@end
