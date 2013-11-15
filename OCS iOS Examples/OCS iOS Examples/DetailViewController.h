//
//  DetailViewController.h
//  OCS iOS Examples
//
//  Created by Aurelius Prochazka on 11/14/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
