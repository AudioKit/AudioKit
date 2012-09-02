//
//  OCSDetailViewController.m
//  OCSiPad
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSDetailViewController.h"
#import "OscillatorConductor.h"

@interface OCSDetailViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation OCSDetailViewController

#pragma mark - Managing the detail item
@synthesize conductor = _conductor;
@synthesize webView = _webView;


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

    NSString *page = @"index"; // by default
    
    if (self.detailItem) {
        page = [self.detailItem description];
        self.title = page;
    }
    NSString *filepath = [[NSBundle mainBundle] pathForResource:page
                                                         ofType:@"html"
                                                    inDirectory:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filepath];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];

}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setConductor:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    
    if ([components count] > 1&&
        [(NSString *)[components objectAtIndex:0] isEqualToString:@"tangleapp"])
    {
        NSString *action = (NSString *)[components objectAtIndex:1];
        if([action isEqualToString:@"start"]) {
            [_conductor startSound];
        }
        if([action isEqualToString:@"set"]) {
            NSString *var = (NSString *)[components objectAtIndex:2];
            float val = [(NSString *)[components objectAtIndex:3] floatValue];
            
            //NSLog(@"%@ = %g", var, val);
            if ([var isEqualToString:@"frequency"] ) {
                [_conductor setFrequency:val];
            }
            if ([var isEqualToString:@"amplitude"] ) {
                [_conductor setAmplitude:val];
            }
        }
        return NO;
    }
    return YES;
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Menu", @"Menu");
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
