//
//  ViewController.m
//  HelloObjectiveC
//
//  Created by Aurelius Prochazka on 1/27/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#import "ViewController.h"

@import AudioKit;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    AKManager *audiokit = [AKManager sharedInstance];
    AKOscillator *osc = [[AKOscillator alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
