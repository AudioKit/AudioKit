//
//  AnalysisViewController.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/23/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AnalysisViewController.h"
#import "AKFoundation.h"

@implementation AnalysisViewController
{
    AKMicrophone *microphone;
    AKAudioAnalyzer *analyzer;

    IBOutlet NSTextField *frequencyLabel;
    IBOutlet NSTextField *amplitudeLabel;
    IBOutlet NSTextField *noteNameWithSharpsLabel;
    IBOutlet NSTextField *noteNameWithFlatsLabel;

    NSArray *noteFrequencies;
    NSArray *noteNamesWithSharps;
    NSArray *noteNamesWithFlats;

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
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    [analyzer start];
    [microphone start];

    analysisSequence = [AKSequence sequence];
    updateAnalysis = [[AKEvent alloc] initWithBlock:^{
        [self updateUI];
        [analysisSequence addEvent:updateAnalysis afterDuration:0.1];
    }];
    [analysisSequence addEvent:updateAnalysis];
    [analysisSequence play];
}

- (void)viewWillDisappear {
    [analyzer stop];
    [microphone stop];
}

- (void)updateUI {

    if (analyzer.trackedAmplitude.value > 0.1) {
        frequencyLabel.stringValue = [NSString stringWithFormat:@"%0.1f", analyzer.trackedFrequency.value];

        float frequency = analyzer.trackedFrequency.value;
        while (frequency > [noteFrequencies.lastObject floatValue]) {
            frequency = frequency / 2.0;
        }
        while (frequency < [noteFrequencies.firstObject floatValue]) {
            frequency = frequency * 2.0;
        }

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
        NSString *noteName = [NSString stringWithFormat:@"%@%d", noteNamesWithSharps[index], octave];
        noteNameWithSharpsLabel.stringValue = noteName;
        noteName = [NSString stringWithFormat:@"%@%d", noteNamesWithFlats[index], octave];
        noteNameWithFlatsLabel.stringValue = noteName;

        [frequencyLabel setNeedsDisplay];
        [amplitudeLabel setNeedsDisplay];
        [noteNameWithSharpsLabel setNeedsDisplay];
        [noteNameWithFlatsLabel setNeedsDisplay];
    }
    amplitudeLabel.stringValue = [NSString stringWithFormat:@"%0.2f", analyzer.trackedAmplitude.value];

}
@end
