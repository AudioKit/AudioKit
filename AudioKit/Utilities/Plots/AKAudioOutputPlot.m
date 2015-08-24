//
//  AKAudioOutputPlot.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioOutputPlot.h"
#import "AKFoundation.h"
#import "AKSettings.h"
#import "CsoundObj.h"


@implementation AKAudioOutputPlot

- (void)defaultValues
{
    [super defaultValues];
    self.lineColor = [AKColor greenColor];
}

- (NSData *)bufferWithCsound:(CsoundObj *)cs
{
    return [cs getOutSamples];
}

@end
