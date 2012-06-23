//
//  GrainViewController.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SimpleGrainInstrument.h"

@interface GrainViewController : UIViewController
{
    SimpleGrainInstrument *myGrainInstrument;
}

- (IBAction)hit1:(id)sender;
- (IBAction)hit2:(id)sender;

@end
