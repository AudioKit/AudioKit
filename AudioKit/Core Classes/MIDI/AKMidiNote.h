//
//  AKMidiNote.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/21/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKNote.h"

@interface AKMidiNote : AKNote

@property AKNoteProperty *notenumber;
@property AKNoteProperty *velocity;

@end
