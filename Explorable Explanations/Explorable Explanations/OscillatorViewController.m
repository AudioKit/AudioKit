//
//  OscillatorViewController.m
//  Explorable Explanations
//
//  Created by Aurelius Prochazka on 9/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OscillatorViewController.h"
#import "OscillatorConductor.h"

@interface OscillatorViewController () {
    UIWebView *webView;
    OscillatorConductor *conductor;
}
@end

@implementation OscillatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    webView.scalesPageToFit = YES;
    self.view = webView;
    webView.delegate = self;
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"Oscillator"
                                                         ofType:@"html"
                                                    inDirectory:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filepath];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.title = @"Objective-C Sound: Oscillator";
    
    
}

- (void) viewDidAppear:(BOOL)animated
{
    conductor = [[OscillatorConductor alloc] init];
}

- (BOOL)           webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
            navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    
    if ([components count] > 1 &&
        [(NSString *)[components objectAtIndex:0] isEqualToString:@"tangleapp"])
    {
        NSString *action = (NSString *)[components objectAtIndex:1];
        if([action isEqualToString:@"start"]) {
            [conductor startSound];
        }
        if([action isEqualToString:@"stop"]) {
            [conductor stopSound];
        }
        if([action isEqualToString:@"set"]) {
            NSString *var = (NSString *)[components objectAtIndex:2];
            float val = [(NSString *)[components objectAtIndex:3] floatValue];
            
            //NSLog(@"%@ = %g", var, val);
            if ([var isEqualToString:@"frequency"] ) {
                [conductor setFrequency:val];
            }
            if ([var isEqualToString:@"amplitude"] ) {
                [conductor setAmplitude:val];
            }
        }
        return NO;
    }
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated  {
    [conductor quit];
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

@end
