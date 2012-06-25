//
//  MoreGrainViewController.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "GrainBirds.h"
#import "GrainBirdsReverb.h"

@interface MoreGrainViewController : UIViewController
{
    GrainBirds *myGrainBirds;
    GrainBirdsReverb *fx;
    
    NSTimer *timer;
}

-(IBAction)hit1:(id)sender;
-(IBAction)hit2:(id)sender;
-(IBAction)hit3:(id)sender;
-(IBAction)hit4:(id)sender;
-(IBAction)hit5:(id)sender;
-(IBAction)hit6:(id)sender;
-(IBAction)startFx:(id)sender;

@end
