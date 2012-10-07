//
//  OscillatorViewController.m
//  Explorable Explanations
//
//  Created by Aurelius Prochazka on 9/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OscillatorViewController.h"
#import "OCSManager.h"
#import "OscillatorInstrument.h"

@interface OscillatorViewController () {
    UIWebView *webView;
    
    OCSOrchestra *orchestra;
    OscillatorInstrument *oscillator;
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
    webView.multipleTouchEnabled = YES;
    self.title = @"Objective-C Sound: Oscillator";
        
}

- (void) viewDidAppear:(BOOL)animated
{
    oscillator = [[OscillatorInstrument alloc] init];
    orchestra = [[OCSOrchestra alloc] init];
    [orchestra addInstrument:oscillator];
    [[OCSManager sharedOCSManager] runOrchestra:orchestra];
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
        
        if([action isEqualToString:@"play"]) {
            [oscillator play];
        } else if([action isEqualToString:@"stop"]) {
            [oscillator stop];
        } else if([action isEqualToString:@"dict"]) {
            NSArray *keys   = [[components objectAtIndex:2] componentsSeparatedByString:@","];
            NSArray *values = [[components objectAtIndex:3] componentsSeparatedByString:@","];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
            for (NSString *var in dict) {
                if ([var isEqualToString:@"frequency"] ) {
                    oscillator.frequency.value = [[dict objectForKey:var] floatValue];
                } else if ([var isEqualToString:@"amplitude"] ) {
                    oscillator.amplitude.value = [[dict objectForKey:var] floatValue];
                }
            }
        }
        return NO;
    }
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated  {
    [[OCSManager sharedOCSManager] stop];
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
