//
//  MasterViewController.h
//  OCS iOS Examples
//
//  Created by Aurelius Prochazka on 11/14/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
