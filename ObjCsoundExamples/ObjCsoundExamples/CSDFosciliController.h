//
//  CSDFosciliController.h
//  ObjCsoundExamples
//
//  Created by Adam Boulanger on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSDSynthesizer.h"
#import "CSDInstrument.h"

#import "CSDFunctionStatement.h"
#import "CSDFoscili.h"
#import "CSDOscillator.h"

@interface CSDFosciliController : UIViewController <UISplitViewControllerDelegate>
{
    CSDSynthesizer *synth;
    CSDInstrument *myInstrument;
}

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

-(IBAction)hit1:(id)sender;
-(IBAction)hit2:(id)sender;

@end
