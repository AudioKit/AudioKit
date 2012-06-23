//
//  FMOscillatorViewController.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMGameObject.h"

@interface FMGameObjectViewController : UIViewController
{
    //ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
    FMGameObject *myFMGameObject;
}

- (IBAction)hit1:(id)sender;
- (IBAction)hit2:(id)sender;

@end
