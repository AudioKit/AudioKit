//
//  GrainViewController.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSDManager.h"
#import "CSDOrchestra.h"
#import "SimpleGrainInstrument.h"

@interface GrainViewController : UIViewController
{
    SimpleGrainInstrument *myGrainInstrument;
}

-(IBAction)hit1:(id)sender;
-(IBAction)hit2:(id)sender;

@end
