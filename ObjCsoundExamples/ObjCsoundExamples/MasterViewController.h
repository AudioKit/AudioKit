//
//  MasterViewController.h
//  ObjCsoundExamples
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class CSDFosciliController;

@interface MasterViewController : UITableViewController
{
    NSArray *objectiveCsoundExperiments;
    NSArray *objectiveCsoundExperimentDetails;
}
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) CSDFosciliController *csdFosciliController;

@property (strong, nonatomic) NSArray *objectiveCsoundExperiments;
@property (strong, nonatomic) NSArray *objectiveCsoundExperimentDetails;

@end
