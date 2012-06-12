//
//  MasterViewController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MasterViewController.h"
#import "AppDelegate.h"

#import "Example1Controller.h"
#import "OscillatorViewController.h"
#import "FMGameObjectViewController.h"
#import "UnitGeneratorsViewController.h"
#import "ExpressionsViewController.h"
#import "ReverbViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

@synthesize example1Controller = _example1Controller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Objective-Csound";
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    exampleNames = [NSMutableArray arrayWithObjects:@"Example 1", 
                    @"Simple Oscillator", 
                    @"Simple FM",
                    @"Unit Generators",
                    @"Expressions",
                    @"Global Reverb",
                    nil];
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return exampleNames.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Whatever";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    // Configure the cell.
    cell.textLabel.text = [exampleNames objectAtIndex:indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController* controller;
    switch (indexPath.row) {
        case 0:
            controller = [[Example1Controller alloc] initWithNibName:@"Example1Controller" bundle:nil];
            break;
        case 1:
            controller = [[OscillatorViewController alloc] initWithNibName:@"OscillatorViewController" bundle:nil];
            break;
        case 2:
            controller = [[FMGameObjectViewController alloc] initWithNibName:@"FMGameObjectViewController"
                                                                  bundle:nil];
            break;
        case 3:
            controller = [[UnitGeneratorsViewController alloc] initWithNibName:@"UnitGeneratorsViewController" bundle:nil];
            break;
        case 4:
            controller = [[ExpressionsViewController alloc] initWithNibName:@"ExpressionsViewController" bundle:nil];
            break;
        case 5:
            controller = [[ReverbViewController alloc] initWithNibName:@"ReverbViewController" bundle:nil];
            break;
        default:
            break;
    }

    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    UISplitViewController* splitViewController = appDelegate.splitViewController;
    
    UIViewController* currentDetail = (UIViewController*)splitViewController.delegate;
    
    if(currentDetail.navigationItem.leftBarButtonItem != nil) {
        controller.navigationItem.leftBarButtonItem = currentDetail.navigationItem.leftBarButtonItem;
    }
    
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:[splitViewController.viewControllers objectAtIndex:0], detailNavigationController, nil];
    splitViewController.viewControllers = viewControllers;
    //splitViewController.delegate = controller;

    
    
}

@end
