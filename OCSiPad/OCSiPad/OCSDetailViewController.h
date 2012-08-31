//
//  OCSDetailViewController.h
//  OCSiPad
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OCSDetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) id detailItem;

@end
