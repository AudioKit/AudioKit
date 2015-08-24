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
    AKMidiInstrument *_instrument;
    AKSoundFontPresetPlayer *_presetPlayer;
    AKSoundFontPreset *_selectedPreset;
    
    NSMutableString *_log;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //AKSettings.shared.loggingEnabled = YES;
    _log = [NSMutableString string];
    [[AKManager sharedManager] setIsLogging:YES];
    _instrument = [[AKMidiInstrument alloc] init];
    _instrument.instrumentNumber = 1;
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
    
    _instrument = [[AKMidiInstrument alloc] init];
    _instrument.instrumentNumber = 1;
    
    _presetPlayer = [[AKSoundFontPresetPlayer alloc] initWithSoundFontPreset:_selectedPreset];
    _presetPlayer.noteNumber = _instrument.note.notenumber;
    [_instrument enableParameterLog:@"nn" parameter:_instrument.note.notenumber timeInterval:100];
    _presetPlayer.velocity = _instrument.note.velocity;
    
    [_instrument setStereoAudioOutput:_presetPlayer];
    [AKOrchestra updateInstrument:_instrument];
    [_instrument startListeningOnAllMidiChannels];
}

- (IBAction)playNote:(id)sender
{
    AKMidiEvent *noteon = [AKMidiEvent eventWithNoteOn:60 channel:1 velocity:100];
    AKMidiEvent *noteoff = [AKMidiEvent eventWithNoteOff:60 channel:1 velocity:100];

    [[AKManager sharedManager].midi sendEvent:noteon];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[AKManager sharedManager].midi sendEvent:noteoff];
    });
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
}

- (void)midiNoteOff:(NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logMessage:[NSString stringWithFormat:@"Note OFF: %@, velocity = %@, channel %@",
                          notif.userInfo[@"note"], notif.userInfo[@"velocity"], notif.userInfo[@"channel"]]];
    });
//    [_instrument stop];
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
