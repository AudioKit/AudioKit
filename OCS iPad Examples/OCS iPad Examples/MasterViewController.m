//
//  MasterViewController.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MasterViewController.h"
#import "AppDelegate.h"
#import "InitialViewController.h"

// Example Controllers
#import "UnitGeneratorsViewController.h"
#import "ExpressionsViewController.h"
#import "ReverbViewController.h"
#import "PlayAudioFileViewController.h"
#import "ContinuousControlViewController.h"
#import "GrainViewController.h"
#import "UDOViewController.h"
#import "ConvolutionViewController.h"
#import "SequenceViewController.h"
#import "HarmonizerViewController.h"
#import "MidiViewController.h"
#import "PhysicalModelViewController.h"


@interface MasterViewController () {
    NSMutableArray *_objects;
    NSMutableArray *exampleNames;
}
@end

@implementation MasterViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Objective-C Sound";
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    exampleNames = [NSMutableArray arrayWithObjects:
                    @"Play a CSD File",
                    @"Play an Audio File",
                    @"Unit Generators",
                    @"Expressions",
                    @"Global Reverb",
                    @"Continuous Control",
                    @"Grain",
                    @"Sequences",
                    @"User Defined Opcodes",
                    @"Convolution",
                    @"Harmonizer",
                    @"MIDI",
                    @"Physical Models",
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
    cell.textLabel.text = exampleNames[indexPath.row];
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
            controller = [[PlayAudioFileViewController alloc] initWithNibName:@"PlayAudioFileViewController" bundle:nil];
            break;
        case 1:
            controller = [[UnitGeneratorsViewController alloc] initWithNibName:@"UnitGeneratorsViewController" bundle:nil];
            break;
        case 2:
            controller = [[ExpressionsViewController alloc] initWithNibName:@"ExpressionsViewController" bundle:nil];
            break;
        case 3:
            controller = [[ReverbViewController alloc] initWithNibName:@"ReverbViewController" bundle:nil];
            break;
        case 4:
            controller = [[ContinuousControlViewController alloc] initWithNibName:@"ContinuousControlViewController" bundle:nil];
            break;
        case 5:
            controller = [[GrainViewController alloc] initWithNibName:@"GrainViewController" bundle:nil];
            break;
        case 6:
            controller = [[SequenceViewController alloc] initWithNibName:@"SequenceViewController" bundle:nil];
            break;
        case 7:
            controller = [[UDOViewController alloc] initWithNibName:@"UDOViewController" bundle:nil];
            break;
        case 8:
            controller = [[ConvolutionViewController alloc] initWithNibName:@"ConvolutionViewController" bundle:nil];
            break;
        case 9:
            controller = [[HarmonizerViewController alloc] initWithNibName:@"HarmonizerViewController" bundle:nil];
            break;
        case 10:
            controller = [[MidiViewController alloc] initWithNibName:@"MidiViewController" bundle:nil];
            break;
        case 11:
            controller = [[PhysicalModelViewController alloc] initWithNibName:@"PhysicalModelViewController" bundle:nil];
            break;
        default:
            break;
    }
    if (controller) controller.title = exampleNames[indexPath.row];

    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    UISplitViewController* splitViewController = appDelegate.splitViewController;
    
    UIViewController* currentDetail = (UIViewController*)splitViewController.delegate;
    
    if(currentDetail.navigationItem.leftBarButtonItem != nil) {
        controller.navigationItem.leftBarButtonItem = currentDetail.navigationItem.leftBarButtonItem;
    }
    
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:splitViewController.viewControllers[0], detailNavigationController, nil];
    splitViewController.viewControllers = viewControllers;
    //splitViewController.delegate = controller;
}

@end
