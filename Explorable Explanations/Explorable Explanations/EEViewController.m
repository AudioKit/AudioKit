//
//  EEViewController.m
//  Explorable Explanations
//
//  Created by Aurelius Prochazka on 9/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "EEViewController.h"

@interface EEViewController () {
    UIWebView *webView;
}

@end

@implementation EEViewController

- (id)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    webView.scalesPageToFit = YES;
    self.view = webView;
    webView.delegate = self;
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"Oscillator"
                                                         ofType:@"html"
                                                    inDirectory:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filepath];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.title = @"Objective-C Sound";
}

- (BOOL)           webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
            navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"Got Here!");
    return YES;
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
