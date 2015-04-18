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

@interface ViewController () {
    AKInstrument *instrument;
    AKOscillator *oscillator;
    NSArray *waveforms;
    BOOL isPlaying;
    IBOutlet AKTablePlot *tablePlot;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    instrument = [[AKInstrument alloc] initWithNumber:1];
    oscillator = [AKOscillator oscillator];
    [instrument setAudioOutput:oscillator];
    [AKOrchestra addInstrument:instrument];
    
    isPlaying = NO;
    
    // The standard square wave goes from -1 to 1 producing a clicking sound
    AKTable *playableSquare = [AKTable standardSquareWave];
    // but scaling to just below 1 works fine
    [playableSquare scaleBy:0.99999];
    
    waveforms = @[[AKTable standardSawtoothWave],
                  [AKTable standardSineWave],
                  playableSquare,
                  [AKTable standardTriangleWave]];
    tablePlot.table = waveforms[0];
}

- (IBAction)play:(UIButton *)sender {
    if (isPlaying) {
        [instrument stop];
        [sender setTitle:@"Play" forState:UIControlStateNormal];
        isPlaying = NO;
    } else {
        [instrument play];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        isPlaying = YES;
    }
}

- (IBAction)changeWaveform:(UISegmentedControl *)sender
{
    NSUInteger index = [sender selectedSegmentIndex];
    oscillator.waveform = waveforms[index];
    tablePlot.table = waveforms[index];
    [AKOrchestra updateInstrument:instrument];
    
    if (isPlaying) [instrument restart];
}



@end
