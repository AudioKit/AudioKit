/* 
 
 LevelMeterView.h:
 
 Copyright (C) 2011 Thomas Hass
 
 This file is part of Csound iOS Examples.
 
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CsoundObj.h"
#import "CsoundValueCacheable.h"

@interface LevelMeterView : UIView <CsoundValueCacheable>
{
	BOOL mCacheDirty;
	float cachedValue;
    float* channelPtr;
    NSString* mChannelName;
	CGFloat lastY;
	NSInteger ksmps, sr;
}

@property (assign) BOOL cacheDirty;
@property (nonatomic, retain) NSString *channelName;

- (void)addToCsoundObj:(CsoundObj *)csoundObj forChannelName:(NSString *)channelName;

@end
