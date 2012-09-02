//
//  AppDelegate.h
//  Explorable Explanations
//
//  Created by Aurelius Prochazka on 9/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EEViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) EEViewController *viewController;
@property (strong, nonatomic) UINavigationController *navController;
@end
