//
//  AKAudioRollingWaveformPlot.h
//  AudioKit
//
//  Created by Stéphane Peter on 4/23/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "EZAudioPlot.h"

IB_DESIGNABLE
@interface AKAudioRollingWaveformPlot : EZAudioPlot

/// Override to provide the current buffer of data to graph.
- (const float *)bufferWithCsound:(CsoundObj *)cs;

@end
