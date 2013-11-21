/* 
 
 CachedGyroscope.h:
 
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

#import "CachedGyroscope.h"

@implementation CachedGyroscope

static NSString* CS_GYRO_X = @"gyroX";
static NSString* CS_GYRO_Y = @"gyroY";
static NSString* CS_GYRO_Z = @"gyroZ";

-(id)init:(CMMotionManager*)manager {
    if (self = [super init]) {
        mManager = manager;
    }
    return self;
}

-(void)setup:(CsoundObj*)csoundObj {
    channelPtrX = [csoundObj getInputChannelPtr:CS_GYRO_X
                                    channelType:CSOUND_CONTROL_CHANNEL];
    channelPtrY = [csoundObj getInputChannelPtr:CS_GYRO_Y
                                    channelType:CSOUND_CONTROL_CHANNEL];
    channelPtrZ = [csoundObj getInputChannelPtr:CS_GYRO_Z
                                    channelType:CSOUND_CONTROL_CHANNEL];

    *channelPtrX = mManager.gyroData.rotationRate.x;
    *channelPtrY = mManager.gyroData.rotationRate.y;
    *channelPtrZ = mManager.gyroData.rotationRate.z;    

}

-(void)updateValuesToCsound {
    @autoreleasepool {
        *channelPtrX = mManager.gyroData.rotationRate.x;
        *channelPtrY = mManager.gyroData.rotationRate.y;
        *channelPtrZ = mManager.gyroData.rotationRate.z;  
    }
}


@end
