//
//  ContinuousControlViewController.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSDManager.h"
#import "CSDOrchestra.h"
#import "ContinuousControlledInstrument.h"

@interface ContinuousControlViewController : UIViewController
{
    CSDOrchestra *myOrchestra;
    ContinuousControlledInstrument *myContinuousControllerInstrument;
    
    NSTimer *repeatingNoteTimer;
    NSTimer *repeatingSliderTimer;
}

-(IBAction)runInstrument:(id)sender;

@end
