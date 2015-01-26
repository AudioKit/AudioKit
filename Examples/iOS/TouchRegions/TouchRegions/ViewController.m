//
//  ViewController.m
//  TouchRegions
//
//  Created by Aurelius Prochazka on 8/6/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "ViewController.h"
#import "AKFoundation.h"
#import "FMOscillator.h"

@interface ViewController () {
    FMOscillator *fm;
    UIImageView *leftTouchImageView;
    UIImageView *rightTouchImageView;
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
    [self.leftView addObserver:self  forKeyPath:@"horizontalPercentage" options:NSKeyValueObservingOptionNew context:Nil];
    [self.leftView addObserver:self  forKeyPath:@"verticalPercentage"   options:NSKeyValueObservingOptionNew context:Nil];
    [self.rightView addObserver:self forKeyPath:@"horizontalPercentage" options:NSKeyValueObservingOptionNew context:Nil];
    [self.rightView addObserver:self forKeyPath:@"verticalPercentage"   options:NSKeyValueObservingOptionNew context:Nil];
    
    fm = [[FMOscillator alloc] init];
    [AKOrchestra addInstrument:fm];
    [AKOrchestra start];
    fm.amplitude.value = fm.amplitude.minimum;
    [fm play];
    leftTouchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-350, -350, 50, 50) ];
    leftTouchImageView.image = [UIImage imageNamed:@"circle.png"];
    rightTouchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-350, -350, 50, 50) ];
    rightTouchImageView.image = [UIImage imageNamed:@"circle.png"];
    [self.view addSubview:leftTouchImageView];
    [self.view addSubview:rightTouchImageView];
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
    float middle = self.view.frame.size.width/2.0;
    float height = self.view.frame.size.height;
    
    if ([keyPath isEqualToString:@"horizontalPercentage"]) {
        float newValue = [[change objectForKey:@"new"] floatValue];
        if (object == self.leftView) {
            fm.amplitude.value = fm.amplitude.maximum;
            fm.frequency.value  = newValue * (fm.frequency.maximum - fm.frequency.minimum) + fm.frequency.minimum;
            self.frequencyLabel.text = [NSString stringWithFormat:@"fm.baseFrequency = %0.2f", fm.frequency.value];
            leftTouchImageView.center = CGPointMake(newValue * middle, leftTouchImageView.center.y);
            //NSLog(@"%f", newValue*400);
        }
        if (object == self.rightView) {
            fm.modulatingMultiplier.value  = newValue * (fm.modulatingMultiplier.maximum - fm.modulatingMultiplier.minimum) + fm.modulatingMultiplier.minimum;
            self.modulatingMultiplierLabel.text = [NSString stringWithFormat:@"fm.modulatingMultiplier = %0.6f", fm.modulatingMultiplier.value];
            rightTouchImageView.center = CGPointMake(newValue * middle + middle, rightTouchImageView.center.y);
        }
    } else if ([keyPath isEqualToString:@"verticalPercentage"]) {
        float newValue = [[change objectForKey:@"new"] floatValue];
        if (object == self.leftView) {
            
            fm.carrierMultiplier.value  = newValue * (fm.carrierMultiplier.maximum - fm.carrierMultiplier.minimum) + fm.carrierMultiplier.minimum;
            self.carrierMultiplierLabel.text = [NSString stringWithFormat:@"fm.carrierMultiplier = %0.6f", fm.carrierMultiplier.value];
            leftTouchImageView.center = CGPointMake(leftTouchImageView.center.x, newValue*height);
        }
        if (object == self.rightView) {
            fm.modulationIndex.value  = newValue * (fm.modulationIndex.maximum - fm.modulationIndex.minimum) + fm.modulationIndex.minimum;
            self.modulationIndexLabel.text = [NSString stringWithFormat:@"fm.modulationIndex = %0.4f", fm.modulationIndex.value];
            rightTouchImageView.center = CGPointMake(rightTouchImageView.center.x, newValue*height);
        }
    } else {
        [NSException raise:@"Unexpected Keypath" format:@"%@", keyPath];
    }
    
}


@end
