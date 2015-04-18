//
//  ViewController.m
//  TableDemo
//
//  Created by Aurelius Prochazka on 4/17/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "ViewController.h"
#import "AKFoundation.h"
#import "AKTablePlot.h"
#import "OscillatorInstrument.h"

@interface ViewController () {
    OscillatorInstrument *oscillatorInstrument;
    NSArray *waveforms;
    BOOL isPlaying;
    IBOutlet UISegmentedControl *choices;
    IBOutlet AKTablePlot *tablePlot;
    IBOutlet AKPropertyLabel *frequencyLabel;
    IBOutlet AKPropertySlider *frequencySlider;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    oscillatorInstrument = [[OscillatorInstrument alloc] init];
    [AKOrchestra addInstrument:oscillatorInstrument];
    
    isPlaying = NO;
    
    // The standard square wave goes from -1 to 1 producing a clicking sound
    AKTable *playableSquare = [AKTable standardSquareWave];
    // but scaling to just below 1 works fine
    [playableSquare scaleBy:0.99999];
    
    waveforms = @[[AKTable standardSawtoothWave],
                  [AKTable standardSineWave],
                  playableSquare,
                  [AKTable standardTriangleWave]];

    choices.selectedSegmentIndex = 1; // Sine wave by default
    [self changeWaveform:choices];
    
    frequencyLabel.property  = oscillatorInstrument.frequency;
    frequencySlider.property = oscillatorInstrument.frequency;
}

- (IBAction)play:(UIButton *)sender {
    if (isPlaying) {
        [oscillatorInstrument stop];
        [sender setTitle:@"Play" forState:UIControlStateNormal];
        isPlaying = NO;
    } else {
        [oscillatorInstrument play];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        isPlaying = YES;
    }
}

- (IBAction)changeWaveform:(UISegmentedControl *)sender
{
    NSUInteger index = sender.selectedSegmentIndex;
    oscillatorInstrument.oscillator.waveform = waveforms[index];
    tablePlot.table = waveforms[index];
    [AKOrchestra updateInstrument:oscillatorInstrument];
    
    if (isPlaying) [oscillatorInstrument restart];
}




@end
