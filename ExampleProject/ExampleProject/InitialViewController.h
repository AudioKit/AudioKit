//
//  InitialViewController.h
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/20/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

@interface InitialViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
