//
//  MIDIViewController.m
//  AudioKitDemo
//
//  Created by Stéphane Peter on 7/6/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "MIDIViewController.h"
#import "AKFoundation.h"

@interface MIDIViewController ()

@property (nonatomic,weak) IBOutlet NSPopUpButton *presetsButton;
@property (nonatomic,weak) IBOutlet NSTextField *midiStatusText;

@end

@implementation MIDIViewController {
    AKSoundFont *_soundFont;
    AKInstrument *_instrument;
    AKSoundFontPresetPlayer *_presetPlayer;
    AKSoundFontPreset *_selectedPreset;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _instrument = [AKInstrument instrumentWithNumber:1];
    [AKOrchestra addInstrument:_instrument];
    
    [self.presetsButton removeAllItems];
    _soundFont = [[AKSoundFont alloc] initWithFilename:[AKManager pathToSoundFile:@"GeneralMidi" ofType:@"sf2"]
                                            completion:^(AKSoundFont *font) {
                                                for (AKSoundFontPreset *preset in font.presets) {
                                                    [self.presetsButton addItemWithTitle:preset.name];
                                                }
                                                [self.presetsButton selectItemAtIndex:0];
                                            }];
 
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(midiNoteOn:)
                   name:AKMidiNoteOnNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(midiNoteOff:)
                   name:AKMidiNoteOnNotification
                 object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)presetChanged:(NSPopUpButton *)sender
{
    _selectedPreset = [_soundFont findPresetNamed:sender.selectedItem.title];
    NSAssert(_selectedPreset, @"Failed to find preset named '%@' in the soundfont.", sender.selectedItem.title);
    
    _presetPlayer = [[AKSoundFontPresetPlayer alloc] initWithSoundFontPreset:_selectedPreset];
    _presetPlayer.frequencyMultiplier = akp(1.5);
    _presetPlayer.amplitude = akp(0.1);
    [_instrument setStereoAudioOutput:_presetPlayer];
}

- (IBAction)playNote:(id)sender
{
    // TODO: Play a fixed note with the current preset
    [_instrument playForDuration:1.0f];
}

// ----------------------------------
// Handling of received MIDI messages
// ----------------------------------

- (void)midiNoteOn:(NSNotification *)notif
{
    
}

- (void)midiNoteOff:(NSNotification *)notif
{
    
}

@end
