/* 
 
 CachedButton.m:
 
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
#import "CachedButton.h"

@implementation CachedButton

@synthesize channelName = mChannelName;


-(void)updateValueCache:(id)sender {
    cachedValue = 1;
    self.cacheDirty = YES;
}

-(id)init:(UIButton*)button channelName:(NSString*)channelName {
    if (self = [super init]) {
        self.channelName = channelName;
        mButton = [button retain];
    }
    return self;
}


-(void)setup:(CsoundObj*)csoundObj {
    cachedValue = mButton.isSelected ? 1 : 0;
    self.cacheDirty = YES;
    channelPtr = [csoundObj getInputChannelPtr:self.channelName];
    [mButton addTarget:self action:@selector(updateValueCache:) forControlEvents:UIControlEventTouchDown];
    [mButton sendActionsForControlEvents:UIControlEventTouchDown];

}


-(void)updateValuesToCsound {
    if (self.cacheDirty) {
        *channelPtr = cachedValue;
        
        self.cacheDirty = (cachedValue == 1);
        cachedValue = 0;
    }
}

-(void)cleanup {
    [mButton removeTarget:self action:@selector(updateValueCache:) forControlEvents:UIControlEventTouchDown];
}

-(void)dealloc {
    [mChannelName release];
    [super dealloc];
}

@end
