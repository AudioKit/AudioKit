//
//  RootViewController.m
//  Explorable Explanations
//
//  Created by Aurelius Prochazka on 9/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "RootViewController.h"
#import "OscillatorViewController.h"
#import "FMOscillatorViewController.h"

@interface RootViewController () {
    UIWebView *webView;
}

@end

@implementation RootViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

-(void) displayMenu {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    webView.scalesPageToFit = YES;
    self.view = webView;
    webView.delegate = self;
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"index"
                                                         ofType:@"html"
                                                    inDirectory:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filepath];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.title = @"Objective-C Sound";
    self.navigationController.navigationBarHidden = NO;
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(displayMenu)];
    self.navigationItem.rightBarButtonItem = menuButton;
}

- (BOOL)           webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
            navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    
    if ([components count] > 1 &&
        [(NSString *)components[0] isEqualToString:@"tangleapp"])
    {
        NSString *action = (NSString *)components[1];

        if([action isEqualToString:@"goto"]) {
            NSString *page = (NSString *)components[2];
            
            if ([page isEqualToString:@"Oscillator"] ) {
                [self.navigationController pushViewController:[[OscillatorViewController alloc] init] animated:YES];
            }
            if ([page isEqualToString:@"FMOscillator"] ) {
                [self.navigationController pushViewController:[[FMOscillatorViewController alloc] init] animated:YES];
            }

        }
        return NO;
    }
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
