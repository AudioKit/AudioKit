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
@property (nonatomic,strong) IBOutlet NSTextView  *midiLog;
@property (nonatomic,strong) IBOutlet NSScrollView *scrollView;
@end

@implementation MIDIViewController {
    AKSoundFont *_soundFont;
    AKInstrument *_instrument;
    AKSoundFontPresetPlayer *_presetPlayer;
    AKSoundFontPreset *_selectedPreset;
    
    NSMutableString *_log;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //AKSettings.shared.loggingEnabled = YES;
    _log = [NSMutableString string];
    
    _instrument = [AKInstrument instrumentWithNumber:1];
    [AKOrchestra addInstrument:_instrument];
    
    [self.presetsButton removeAllItems];
    _soundFont = [[AKSoundFont alloc] initWithFilename:[AKManager pathToSoundFile:@"GeneralMidi" ofType:@"sf2"]];
    
    [_soundFont fetchPresets:^(AKSoundFont *font) {
        for (AKSoundFontPreset *preset in font.presets) {
            [self.presetsButton addItemWithTitle:preset.name];
        }
        [self presetChanged:self.presetsButton];
    }];
 
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(midiNoteOn:)
                   name:AKMidiNoteOnNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(midiNoteOff:)
                   name:AKMidiNoteOffNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(midiPitchWheel:)
                   name:AKMidiPitchWheelNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(midiProgramChange:)
                   name:AKMidiProgramChangeNotification
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
    [_instrument setStereoAudioOutput:_presetPlayer];
    [AKOrchestra updateInstrument:_instrument];
}

- (IBAction)playNote:(id)sender
{
    // Play a fixed note with the current preset
    [_instrument playForDuration:1.0f];
}

// ----------------------------------
// Handling of received MIDI messages
// ----------------------------------

- (void)logMessage:(NSString *)msg
{
    [self.midiStatusText setStringValue:msg];
    [_log appendFormat:@"%@\n", msg];
    [self.midiLog setString:_log];
    [[self.scrollView documentView] scrollPoint:NSMakePoint(0.0f, NSHeight([[self.scrollView documentView] bounds]))];
}

- (void)midiNoteOn:(NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logMessage:[NSString stringWithFormat:@"Note ON: %@, velocity = %@, channel %@",
                          notif.userInfo[@"note"], notif.userInfo[@"velocity"], notif.userInfo[@"channel"]]];
    });
    NSUInteger vel = [notif.userInfo[@"velocity"] integerValue];
    NSUInteger note = [notif.userInfo[@"note"] integerValue];
    if (vel > 0) {
        _presetPlayer.noteNumber = akp(note);
        _presetPlayer.velocity = akp(vel);
        [_instrument playForDuration:1.0f];
    }
}

- (void)midiNoteOff:(NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logMessage:[NSString stringWithFormat:@"Note OFF: %@, velocity = %@, channel %@",
                          notif.userInfo[@"note"], notif.userInfo[@"velocity"], notif.userInfo[@"channel"]]];
    });
    [_instrument stop];
}

- (void)midiPitchWheel:(NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logMessage:[NSString stringWithFormat:@"Pitch Wheel: %@, channel %@",
                          notif.userInfo[@"pitchWheel"], notif.userInfo[@"channel"]]];
    });
}

- (void)midiProgramChange:(NSNotification *)notif
{
    NSUInteger program = [notif.userInfo[@"program"] unsignedIntegerValue] - 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logMessage:[NSString stringWithFormat:@"Program Change: %@, channel %@",
                          notif.userInfo[@"program"], notif.userInfo[@"channel"]]];
        [self.presetsButton selectItemAtIndex:program];
        [self presetChanged:self.presetsButton];
    });
}

@end
