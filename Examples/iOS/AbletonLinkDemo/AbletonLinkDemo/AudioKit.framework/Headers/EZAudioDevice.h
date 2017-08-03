//
//  EZAudioDevice.h
//  EZAudio
//
//  Created by Syed Haris Ali on 6/25/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#if TARGET_OS_IPHONE
#import <AVFoundation/AVFoundation.h>
#elif TARGET_OS_MAC
#endif

/**
 The EZAudioDevice provides an interface for getting the available input and output hardware devices on iOS and OSX. On iOS the EZAudioDevice uses the available devices found from the AVAudioSession, while on OSX the EZAudioDevice wraps the AudioHardware API to find any devices that are connected including the built-in devices (for instance, Built-In Microphone, Display Audio). Since the AVAudioSession and AudioHardware APIs are quite different the EZAudioDevice has different properties available on each platform. The EZMicrophone now supports setting any specific EZAudioDevice from the `inputDevices` function.
 */
@interface EZAudioDevice : NSObject

//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// @name Getting The Devices
//------------------------------------------------------------------------------

/**
 Provides the current EZAudioDevice that is being used to pull input.
 @return An EZAudioDevice instance representing the currently selected input device.
 */
+ (EZAudioDevice *)currentInputDevice;

//------------------------------------------------------------------------------

/**
 Provides the current EZAudioDevice that is being used to output audio.
 @return An EZAudioDevice instance representing the currently selected ouotput device.
 */
+ (EZAudioDevice *)currentOutputDevice;

//------------------------------------------------------------------------------

/**
 Enumerates all the available input devices and returns the result in an NSArray of EZAudioDevice instances.
 @return An NSArray containing EZAudioDevice instances, one for each available input device.
 */
+ (NSArray *)inputDevices;

//------------------------------------------------------------------------------

/**
 Enumerates all the available output devices and returns the result in an NSArray of EZAudioDevice instances.
 @return An NSArray of output EZAudioDevice instances.
 */
+ (NSArray *)outputDevices;

#if TARGET_OS_IPHONE

//------------------------------------------------------------------------------

/**
 Enumerates all the available input devices.
    - iOS only
 @param block When enumerating this block executes repeatedly for each EZAudioDevice found. It contains two arguments - first, the EZAudioDevice found, then a pointer to a stop BOOL to allow breaking out of the enumeration)
 */
+ (void)enumerateInputDevicesUsingBlock:(void(^)(EZAudioDevice *device,
                                                 BOOL *stop))block;

//------------------------------------------------------------------------------

/**
 Enumerates all the available output devices.
 - iOS only
 @param block When enumerating this block executes repeatedly for each EZAudioDevice found. It contains two arguments - first, the EZAudioDevice found, then a pointer to a stop BOOL to allow breaking out of the enumeration)
 */
+ (void)enumerateOutputDevicesUsingBlock:(void (^)(EZAudioDevice *device,
                                                   BOOL *stop))block;

#elif TARGET_OS_MAC

/**
 Enumerates all the available devices and returns the result in an NSArray of EZAudioDevice instances.
    - OSX only
 @return An NSArray of input and output EZAudioDevice instances.
 */
+ (NSArray *)devices;

//------------------------------------------------------------------------------

/**
 Enumerates all the available devices. 
    - OSX only
 @param block When enumerating this block executes repeatedly for each EZAudioDevice found. It contains two arguments - first, the EZAudioDevice found, then a pointer to a stop BOOL to allow breaking out of the enumeration)
 */
+ (void)enumerateDevicesUsingBlock:(void(^)(EZAudioDevice *device,
                                            BOOL *stop))block;

#endif

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 An NSString representing a human-reable version of the device.
 */
@property (nonatomic, copy, readonly) NSString *name;

#if TARGET_OS_IPHONE

/**
 An AVAudioSessionPortDescription describing an input or output hardware port.
    - iOS only
 */
@property (nonatomic, strong, readonly) AVAudioSessionPortDescription *port;

//------------------------------------------------------------------------------

/**
 An AVAudioSessionDataSourceDescription describing a specific data source for the `port` provided.
    - iOS only
 */
@property (nonatomic, strong, readonly) AVAudioSessionDataSourceDescription *dataSource;

#elif TARGET_OS_MAC

/**
 An AudioDeviceID representing the device in the AudioHardware API.
    - OSX only
 */
@property (nonatomic, assign, readonly) AudioDeviceID deviceID;

//------------------------------------------------------------------------------

/**
 An NSString representing the name of the manufacturer of the device.
    - OSX only
 */
@property (nonatomic, copy, readonly) NSString *manufacturer;

//------------------------------------------------------------------------------

/**
 An NSInteger representing the number of input channels available.
    - OSX only
 */
@property (nonatomic, assign, readonly) NSInteger inputChannelCount;

//------------------------------------------------------------------------------

/**
 An NSInteger representing the number of output channels available.
    - OSX only
 */
@property (nonatomic, assign, readonly) NSInteger outputChannelCount;

//------------------------------------------------------------------------------

/**
 An NSString representing the persistent identifier for the AudioDevice.
    - OSX only
 */
@property (nonatomic, copy, readonly) NSString *UID;

#endif

@end
