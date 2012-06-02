/* 
 
 SliderMidiWidgetWrapper.m:
 
 Copyright (C) 2011 Steven Yi
 
 This file is part of Csound for iOS.
 
 The Csound for iOS Library is free software; you can redistribute it
 and/or modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.   
 
 Csound is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with Csound; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 02111-1307 USA
 
 
 */
#import "SliderMidiWidgetWrapper.h"

@implementation SliderMidiWidgetWrapper

-(id)init:(UISlider *)slider {
    if (self = [super init]) {
        mSlider = [slider retain];
    }
    return self;
}

-(void)dealloc {
    [mSlider release];
    [super dealloc];
}

-(void)setValueSelector:(NSNumber*)value {
    [mSlider setValue:[value floatValue] animated:YES];
    [mSlider sendActionsForControlEvents:UIControlEventValueChanged];

}

-(void)setMIDIValue:(int)midiValue {
    NSLog(@"SetMIDIValue: %d", midiValue);
    float percent = midiValue / 127.0f;
    float sliderRange = mSlider.maximumValue - mSlider.minimumValue;
    float newValue = (percent * sliderRange) + mSlider.minimumValue;;
    [self performSelectorOnMainThread:@selector(setValueSelector:) withObject:[NSNumber numberWithFloat:newValue] waitUntilDone:NO];
}

@end
