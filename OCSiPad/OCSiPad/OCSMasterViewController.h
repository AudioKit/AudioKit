//
//  OCSMasterViewController.h
//  OCSiPad
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OCSDetailViewController;

@interface OCSMasterViewController : UITableViewController

@property (strong, nonatomic) OCSDetailViewController *detailViewController;

@end
