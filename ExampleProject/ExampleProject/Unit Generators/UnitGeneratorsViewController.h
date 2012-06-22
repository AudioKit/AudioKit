//
//  UnitGeneratorsViewController.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCSManager.h"
#import "OCSOrchestra.h"
#import "UnitGenSoundGenerator.h"

@interface UnitGeneratorsViewController : UIViewController
{
    UnitGenSoundGenerator *myUnitGenSoundGenerator;
    OCSOrchestra *myOrchestra;
}

-(IBAction)hit1:(id)sender;
-(IBAction)hit2:(id)sender;

@end
