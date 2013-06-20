//
//  MIDIController.h
//  OCS Mac Examples
//
//  Created by Aurelius Prochazka on 8/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIDIController : NSObject 

@property (weak) IBOutlet NSTextField *modulationLabel;
@property (weak) IBOutlet NSTextField *controllerValueLabel;
@property (weak) IBOutlet NSTextField *controllerNumberLabel;
@property (weak) IBOutlet NSTextField *channelLabel;
@property (weak) IBOutlet NSTextField *noteLabel;
@property (weak) IBOutlet NSTextField *pitchBendLabel;
@property (weak) IBOutlet NSSlider *modulationSlider;
@property (weak) IBOutlet NSSlider *controllerSlider;
@property (weak) IBOutlet NSSlider *pitchBendSlider;

- (IBAction)enableMIDI:(id)sender;

@end
