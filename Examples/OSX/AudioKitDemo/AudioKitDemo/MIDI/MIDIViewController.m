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

@end

@implementation MIDIViewController {
    AKSoundFont *soundFont;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    soundFont = [[AKSoundFont alloc] initWithFilename:[AKManager pathToSoundFile:@"GeneralMidi" ofType:@"sf2"]];
    
}

- (void)viewDidAppear
{
    [super viewDidAppear];

    NSAssert(soundFont.loaded, @"Soundfont is not loaded");
    for (AKSoundFontPreset *preset in soundFont.presets) {
        [self.presetsButton addItemWithTitle:preset.name];
    }
}
    
@end
