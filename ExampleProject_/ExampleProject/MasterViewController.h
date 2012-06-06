//
//  MasterViewController.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Example1Controller;

@interface MasterViewController : UITableViewController {
    NSMutableArray * exampleNames;
}

@property (strong, nonatomic) Example1Controller *example1Controller;

@end
