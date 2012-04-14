//
//  DetailViewController.m
//  ObjCsoundExamples
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    synth = [[CSDSynthesizer alloc] init];
    CSDFunctionStatement * f1 =  [[CSDFunctionStatement alloc] initWithNumber:1 
                                                                     LoadTime:0 
                                                                    TableSize:4096 
                                                                   GenRoutine:10 
                                                                AndParameters:@"1"];
    [synth addFunctionStatement:f1];
    
    myInstrument =  [[CSDInstrument alloc] initWithOutput:@"aout1"];
    CSDOscillator * oscil1 =  [[CSDOscillator alloc] initWithOutput:@"aout1" 
                                                          Amplitude:@"p" 
                                                          Frequency:@"p" 
                                                      FunctionTable:f1 
                                                  AndOptionalPhases:nil];
    [myInstrument addOpcode:oscil1];
    [synth addInstrument:myInstrument];
    [synth run];
}

- (IBAction)hit1:(id)sender {
    [synth playNote:[myInstrument createNoteWithParameters:@"0.5 440"] WithDuration:1];
}

- (IBAction)hit2:(id)sender {
    [synth playNote:[myInstrument createNoteWithParameters:@"1.0 660"] WithDuration:1];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
