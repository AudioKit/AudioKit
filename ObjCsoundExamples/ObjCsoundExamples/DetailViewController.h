//
//  DetailViewController.h
//  ObjCsoundExamples
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CSDSynthesizer.h"
#import "CSDInstrument.h"
#import "CSDFunctionStatement.h"
#import "CSDOscillator.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>{
    CSDSynthesizer * synth;
    CSDInstrument * myInstrument;
}

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;


- (IBAction)hit1:(id)sender;
- (IBAction)hit2:(id)sender;

@end
