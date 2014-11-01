//
//  ViewController.m
//  TouchRegions
//
//  Created by Aurelius Prochazka on 8/6/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "ViewController.h"
#import "AKFoundation.h"
#import "FMOscillator.h"

@interface ViewController () {
    FMOscillator *fm;
}
@property (strong, nonatomic) IBOutlet UIView *leftView;
@property (strong, nonatomic) IBOutlet UIView *rightView;
@property (strong, nonatomic) IBOutlet UILabel *frequencyLabel;
@property (strong, nonatomic) IBOutlet UILabel *carrierMultiplierLabel;
@property (strong, nonatomic) IBOutlet UILabel *modulatingMultiplierLabel;
@property (strong, nonatomic) IBOutlet UILabel *modulationIndexLabel;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.leftView addObserver:self forKeyPath:@"horizontalPercentage"  options:NSKeyValueObservingOptionNew context:Nil];
    [self.leftView addObserver:self forKeyPath:@"verticalPercentage"    options:NSKeyValueObservingOptionNew context:Nil];
    [self.rightView addObserver:self forKeyPath:@"horizontalPercentage" options:NSKeyValueObservingOptionNew context:Nil];
    [self.rightView addObserver:self forKeyPath:@"verticalPercentage"   options:NSKeyValueObservingOptionNew context:Nil];
    
    AKOrchestra *orchestra = [[AKOrchestra alloc] init];
    fm = [[FMOscillator alloc] init];
    [orchestra addInstrument:fm];
    [[AKManager sharedAKManager] runOrchestra:orchestra];
    [fm play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"horizontalPercentage"]) {
        float newValue = [[change objectForKey:@"new"] floatValue];
        if (object == self.leftView) {
            fm.frequency.value  = newValue * (fm.frequency.maximum - fm.frequency.minimum) + fm.frequency.minimum;
            self.frequencyLabel.text = [NSString stringWithFormat:@"%0.2f", fm.frequency.value];
        }
        if (object == self.rightView) {
            fm.modulatingMultiplier.value  = newValue * (fm.modulatingMultiplier.maximum - fm.modulatingMultiplier.minimum) + fm.modulatingMultiplier.minimum;
            self.modulatingMultiplierLabel.text = [NSString stringWithFormat:@"%0.6f", fm.modulatingMultiplier.value];
        }
    } else if ([keyPath isEqualToString:@"verticalPercentage"]) {
        float newValue = [[change objectForKey:@"new"] floatValue];
        if (object == self.leftView) {
            
            fm.carrierMultiplier.value  = newValue * (fm.carrierMultiplier.maximum - fm.carrierMultiplier.minimum) + fm.carrierMultiplier.minimum;
            self.carrierMultiplierLabel.text = [NSString stringWithFormat:@"%0.6f", fm.carrierMultiplier.value];
        }
        if (object == self.rightView) {
            fm.modulationIndex.value  = newValue * (fm.modulationIndex.maximum - fm.modulationIndex.minimum) + fm.modulationIndex.minimum;
            self.modulationIndexLabel.text = [NSString stringWithFormat:@"%0.4f", fm.modulationIndex.value];
        }
    } else {
        [NSException raise:@"Unexpected Keypath" format:@"%@", keyPath];
    }
    
}


@end
