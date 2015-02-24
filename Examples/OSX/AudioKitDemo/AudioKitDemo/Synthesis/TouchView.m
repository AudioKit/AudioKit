//
//  TouchView.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/23/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "TouchView.h"

@implementation TouchView

- (void)drawRect:(NSRect)dirtyRect {
    // set any NSColor for filling, say white:
    [[NSColor colorWithCalibratedRed:0.090 green:0.671 blue:0.094 alpha:1.000] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
