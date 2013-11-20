//
//  FMOscillatorViewController.m
//  Explorable Explanations
//
//  Created by Aurelius Prochazka on 9/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMOscillatorViewController.h"
#import "OCSManager.h"
#import "FMOscillatorInstrument.h"

@interface FMOscillatorViewController () {
    UIWebView *webView;    
    OCSOrchestra *orchestra;
    FMOscillatorInstrument *fmOscillator;
}

@end

@implementation FMOscillatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    webView.scalesPageToFit = YES;
    self.view = webView;
    webView.delegate = self;
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"FMOscillator"
                                                         ofType:@"html"
                                                    inDirectory:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filepath];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    webView.multipleTouchEnabled = YES;
    self.title = @"Objective-C Sound: FM Oscillator";
}

- (void) viewDidAppear:(BOOL)animated
{
    fmOscillator = [[FMOscillatorInstrument alloc] init];
    orchestra = [[OCSOrchestra alloc] init];
    [orchestra addInstrument:fmOscillator];
    [[OCSManager sharedOCSManager] runOrchestra:orchestra];
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
        if([action isEqualToString:@"play"]) {
            [fmOscillator play];
        } else if([action isEqualToString:@"stop"]) {
            [fmOscillator stop];
            
        } else if([action isEqualToString:@"dict"]) {
            NSArray *keys   = [components[2] componentsSeparatedByString:@","];
            NSArray *values = [components[3] componentsSeparatedByString:@","];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
            for (NSString *key in dict) {
                if ([key  isEqual: @"frequency"] ) {
                    fmOscillator.frequency.value = [dict[key] floatValue];
                } else if ([key isEqualToString:@"amplitude"] ) {
                    fmOscillator.amplitude.value = [dict[key] floatValue];
                } else if ([key isEqualToString:@"carrierMultiplier"] ) {
                    fmOscillator.carrierMultiplier.value = [dict[key] floatValue];
                } else if ([key isEqualToString:@"modulatingMultiplier"] ) {
                    fmOscillator.modulatingMultiplier.value = [dict[key] floatValue];
                } else if ([key isEqualToString:@"modulationIndex"] ) {
                    fmOscillator.modulationIndex.value = [dict[key] floatValue];
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
