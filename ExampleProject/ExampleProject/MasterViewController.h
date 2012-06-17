//
//  MasterViewController.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayCSDFileController;

@interface MasterViewController : UITableViewController {
    NSMutableArray * exampleNames;
}

@property (strong, nonatomic) PlayCSDFileController *playCSDFileController;

@end
