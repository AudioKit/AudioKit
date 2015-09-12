//
//  MIDIViewController.m
//  AudioKitDemo
//
//  Created by Stéphane Peter on 8/3/15.
//  Copyright © 2015 Aurelius Prochazka. All rights reserved.
//

#import "MIDIViewController.h"
#import "AKFoundation.h"

@interface MIDIViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation MIDIViewController {
    IBOutlet UIPickerView *_presetsPicker;
    IBOutlet UITableView *_messagesTable;
    
    AKSoundFont *_soundFont;
    AKMidiInstrument *_instrument;
    AKSoundFontPresetPlayer *_presetPlayer;
    AKSoundFontPreset *_selectedPreset;
    NSMutableArray<NSString *> *_log;
    NSArray<AKSoundFontPreset *> *_presets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _log = [NSMutableArray array];
    [[AKManager sharedManager] setIsLogging:YES];
    _instrument = [[AKMidiInstrument alloc] init];
    _instrument.instrumentNumber = 1;
    [AKOrchestra addInstrument:_instrument];
    
    _soundFont = [[AKSoundFont alloc] initWithFilename:[AKManager pathToSoundFile:@"GeneralMidi" ofType:@"sf2"]];
    
    [_soundFont fetchPresets:^(AKSoundFont *font) {
        _presets = font.presets;
        [_presetsPicker reloadAllComponents];
        [_presetsPicker selectRow:0 inComponent:0 animated:NO];
        [self pickerView:_presetsPicker didSelectRow:0 inComponent:0]; // Doesn't get called automatically
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [_log addObject:msg];
    [_messagesTable reloadData];
    [_messagesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_log.count-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
        [_presetsPicker selectRow:program inComponent:0 animated:YES];
        [self pickerView:_presetsPicker didSelectRow:program inComponent:0]; // Doesn't get called automatically
    });
}

#pragma mark - Picker View delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _presets.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    AKSoundFontPreset *preset = _presets[row];
    return [NSString stringWithFormat:@"%@: %@",@(row),preset.name];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    _selectedPreset = _presets[row];
    
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

#pragma mark - Table View delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _log.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LogCell"];
    }
    cell.textLabel.text = _log[indexPath.row];
    return cell;
}

@end
