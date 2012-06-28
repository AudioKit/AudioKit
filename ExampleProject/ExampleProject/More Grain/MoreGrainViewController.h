//
//  MoreGrainViewController.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

@interface MoreGrainViewController : UIViewController {
    
    IBOutlet UISlider *grainDurationSlider;
    IBOutlet UISlider *pitchOffsetStartSlider;
    IBOutlet UISlider *pitchOffsetTargetSlider;
    IBOutlet UISlider * pitchClassSlider;
    
    IBOutlet UILabel *grainDurationLabel;
    IBOutlet UILabel *pitchOffsetStartLabel;
    IBOutlet UILabel *pitchOffsetTargetLabel;
    IBOutlet UILabel *pitchClassLabel;
}

-(IBAction)hit1:(id)sender;
-(IBAction)hit2:(id)sender;
-(IBAction)hit3:(id)sender;
-(IBAction)hit4:(id)sender;
-(IBAction)hit5:(id)sender;
-(IBAction)startFx:(id)sender;

-(IBAction)scaleGrainDensity:(id)sender;
-(IBAction)pitchOffsetStartMod:(id)sender;
-(IBAction)pitchOffsetTargetMod:(id)sender;
-(IBAction)pitchClassMod:(id)sender;

@end
