//
//  AnalysisViewController.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AnalysisViewController.h"
#import "AKFoundation.h"

@implementation AnalysisViewController
{
    AKMicrophone *microphone;
    AKAudioAnalyzer *analyzer;

    IBOutlet UILabel *frequencyLabel;
    IBOutlet UILabel *amplitudeLabel;
    IBOutlet UILabel *noteNameLabel;

    NSArray<NSNumber *> *noteFrequencies;
    NSArray<NSString *> *noteNamesWithSharps;
    NSArray<NSString *> *noteNamesWithFlats;

    IBOutlet AKInstrumentPropertyPlot *amplitudePlot;
    IBOutlet AKInstrumentPropertyPlot *frequencyPlot;
    AKInstrumentProperty *normalizedFrequency;
    IBOutlet AKFloatPlot *normalizedFrequencyPlot;
    AKSequence *analysisSequence;
    AKEvent *updateAnalysis;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    noteFrequencies = @[@16.35,@17.32,@18.35,@19.45,@20.6,@21.83,@23.12,@24.5,@25.96,@27.5,@29.14,@30.87];
    noteNamesWithSharps = @[@"C", @"C♯",@"D",@"D♯",@"E",@"F",@"F♯",@"G",@"G♯",@"A",@"A♯",@"B"];
    noteNamesWithFlats  = @[@"C", @"D♭",@"D",@"E♭",@"E",@"F",@"G♭",@"G",@"A♭",@"A",@"B♭",@"B"];

    AKSettings.shared.audioInputEnabled = YES;

    microphone = [[AKMicrophone alloc] init];
    [AKOrchestra addInstrument:microphone];
    analyzer = [[AKAudioAnalyzer alloc] initWithInput:microphone.output];
    [AKOrchestra addInstrument:analyzer];
    amplitudePlot.property = analyzer.trackedAmplitude;

    normalizedFrequency = [[AKInstrumentProperty alloc] initWithValue:0.0 minimum:16.35 maximum:30.87];
    frequencyPlot.property = analyzer.trackedFrequency;
    frequencyPlot.plottedValue = normalizedFrequency;

    normalizedFrequencyPlot.minimum = 15;
    normalizedFrequencyPlot.maximum = 32;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [analyzer start];
    [microphone start];

    analysisSequence = [AKSequence sequence];
    updateAnalysis = [[AKEvent alloc] initWithBlock:^{
        [self performSelectorOnMainThread:@selector(updateUI) withObject:self waitUntilDone:NO];
        [analysisSequence addEvent:updateAnalysis afterDuration:0.1];
    }];

    [analysisSequence addEvent:updateAnalysis];
    [analysisSequence play];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [analyzer stop];
    [microphone stop];
}

- (void)updateUI {

    if (analyzer.trackedAmplitude.value > 0.1) {
        frequencyLabel.text = [NSString stringWithFormat:@"%0.1f", analyzer.trackedFrequency.value];

        float frequency = analyzer.trackedFrequency.value;
        while (frequency > [noteFrequencies.lastObject floatValue]) {
            frequency = frequency / 2.0;
        }
        while (frequency < [noteFrequencies.firstObject floatValue]) {
            frequency = frequency * 2.0;
        }
        normalizedFrequency.value = frequency;
        float hue = (frequency - [noteFrequencies.firstObject floatValue]) / ([noteFrequencies.lastObject floatValue] - [noteFrequencies.firstObject floatValue]);
        frequencyPlot.lineColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
        [normalizedFrequencyPlot updateWithValue:frequency];
        float minDistance = 10000;
        int index =  0;
        for (int i = 0; i < noteFrequencies.count; i++) {
            float distance = fabs([noteFrequencies[i] floatValue] - frequency);
            if (distance < minDistance) {
                index = i;
                minDistance = distance;
            }
        }
        int octave = (int)log2f(analyzer.trackedFrequency.value / frequency);
        NSString *noteName = [NSString stringWithFormat:@"%@%d / %@%d", noteNamesWithSharps[index], octave, noteNamesWithFlats[index], octave];
        noteNameLabel.text = noteName;

        [frequencyLabel setNeedsDisplay];
        [amplitudeLabel setNeedsDisplay];
        [noteNameLabel  setNeedsDisplay];
    }
    amplitudeLabel.text = [NSString stringWithFormat:@"%0.2f", analyzer.trackedAmplitude.value];

}

@end
