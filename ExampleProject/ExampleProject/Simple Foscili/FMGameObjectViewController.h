//
//  FMOscillatorViewController.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMGameObject.h"

#import "OCSOrchestra.h"

@interface FMGameObjectViewController : UIViewController
{
    //ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
    FMGameObject *myFMGameObject;
}

- (IBAction)hit1:(id)sender;
- (IBAction)hit2:(id)sender;

@end
