//
//  EZAudioDevice.m
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

#import "EZAudioDevice.h"
#import "EZAudioUtilities.h"

@interface EZAudioDevice ()

@property (nonatomic, copy, readwrite) NSString *name;

#if TARGET_OS_IPHONE

@property (nonatomic, strong, readwrite) AVAudioSessionPortDescription *port;
@property (nonatomic, strong, readwrite) AVAudioSessionDataSourceDescription *dataSource;

#elif TARGET_OS_MAC

@property (nonatomic, assign, readwrite) AudioDeviceID deviceID;
@property (nonatomic, copy, readwrite) NSString *manufacturer;
@property (nonatomic, assign, readwrite) NSInteger inputChannelCount;
@property (nonatomic, assign, readwrite) NSInteger outputChannelCount;
@property (nonatomic, copy, readwrite) NSString *UID;

#endif

@end

@implementation EZAudioDevice

#if TARGET_OS_IPHONE

//------------------------------------------------------------------------------

+ (EZAudioDevice *)currentInputDevice
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    AVAudioSessionPortDescription *port = [[[session currentRoute] inputs] firstObject];
    AVAudioSessionDataSourceDescription *dataSource = [session inputDataSource];
    EZAudioDevice *device = [[EZAudioDevice alloc] init];
    device.port = port;
    device.dataSource = dataSource;
    return device;
}

//------------------------------------------------------------------------------

+ (EZAudioDevice *)currentOutputDevice
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    AVAudioSessionPortDescription *port = [[[session currentRoute] outputs] firstObject];
    AVAudioSessionDataSourceDescription *dataSource = [session outputDataSource];
    EZAudioDevice *device = [[EZAudioDevice alloc] init];
    device.port = port;
    device.dataSource = dataSource;
    return device;
}

//------------------------------------------------------------------------------

+ (NSArray *)inputDevices
{
    __block NSMutableArray *devices = [NSMutableArray array];
    [self enumerateInputDevicesUsingBlock:^(EZAudioDevice *device, BOOL *stop)
    {
        [devices addObject:device];
    }];
    return devices;
}

//------------------------------------------------------------------------------

+ (NSArray *)outputDevices
{
    __block NSMutableArray *devices = [NSMutableArray array];
    [self enumerateOutputDevicesUsingBlock:^(EZAudioDevice *device, BOOL *stop)
     {
         [devices addObject:device];
     }];
    return devices;
}

//------------------------------------------------------------------------------

+ (void)enumerateInputDevicesUsingBlock:(void (^)(EZAudioDevice *, BOOL *))block
{
    if (!block)
    {
        return;
    }
    
    NSArray *inputs = [[AVAudioSession sharedInstance] availableInputs];
    if (inputs == nil)
    {
        NSLog(@"Audio session is not active! In order to enumerate the audio devices you must set the category and set active the audio session for your iOS app before calling this function.");
        return;
    }
    
    BOOL stop;
    for (AVAudioSessionPortDescription *inputDevicePortDescription in inputs)
    {
        // add any additional sub-devices
        NSArray *dataSources = [inputDevicePortDescription dataSources];
        if (dataSources.count)
        {
            for (AVAudioSessionDataSourceDescription *inputDeviceDataSourceDescription in dataSources)
            {
                EZAudioDevice *device = [[EZAudioDevice alloc] init];
                device.port = inputDevicePortDescription;
                device.dataSource = inputDeviceDataSourceDescription;
                block(device, &stop);
            }
        }
        else
        {
            EZAudioDevice *device = [[EZAudioDevice alloc] init];
            device.port = inputDevicePortDescription;
            block(device, &stop);
        }
    }
}

//------------------------------------------------------------------------------

+ (void)enumerateOutputDevicesUsingBlock:(void (^)(EZAudioDevice *, BOOL *))block
{
    if (!block)
    {
        return;
    }
    
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    NSArray *portDescriptions = [currentRoute outputs];
    
    BOOL stop;
    for (AVAudioSessionPortDescription *outputDevicePortDescription in portDescriptions)
    {
        // add any additional sub-devices
        NSArray *dataSources = [outputDevicePortDescription dataSources];
        if (dataSources.count)
        {
            for (AVAudioSessionDataSourceDescription *outputDeviceDataSourceDescription in dataSources)
            {
                EZAudioDevice *device = [[EZAudioDevice alloc] init];
                device.port = outputDevicePortDescription;
                device.dataSource = outputDeviceDataSourceDescription;
                block(device, &stop);
            }
        }
        else
        {
            EZAudioDevice *device = [[EZAudioDevice alloc] init];
            device.port = outputDevicePortDescription;
            block(device, &stop);
        }
    }
}

//------------------------------------------------------------------------------

- (NSString *)name
{
    NSMutableString *name = [NSMutableString string];
    if (self.port)
    {
        [name appendString:self.port.portName];
    }
    if (self.dataSource)
    {
        [name appendFormat:@": %@", self.dataSource.dataSourceName];
    }
    return name;
}

//------------------------------------------------------------------------------

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ { port: %@, data source: %@ }",
            [super description],
            self.port,
            self.dataSource];
}

//------------------------------------------------------------------------------

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:self.class])
    {
        EZAudioDevice *device = (EZAudioDevice *)object;
        BOOL isPortUIDEqual = [device.port.UID isEqualToString:self.port.UID];
        BOOL isDataSourceIDEqual = device.dataSource.dataSourceID.longValue == self.dataSource.dataSourceID.longValue;
        return isPortUIDEqual && isDataSourceIDEqual;
    }
    else
    {
        return [super isEqual:object];
    }
}

#elif TARGET_OS_MAC

+ (void)enumerateDevicesUsingBlock:(void(^)(EZAudioDevice *device,
                                            BOOL *stop))block
{
    if (!block)
    {
        return;
    }
    
    // get the present system devices
    AudioObjectPropertyAddress address = [self addressForPropertySelector:kAudioHardwarePropertyDevices];
    UInt32 devicesDataSize;
    [EZAudioUtilities checkResult:AudioObjectGetPropertyDataSize(kAudioObjectSystemObject,
                                                                 &address,
                                                                 0,
                                                                 NULL,
                                                                 &devicesDataSize)
                        operation:"Failed to get data size"];
    
    // enumerate devices
    NSInteger count = devicesDataSize / sizeof(AudioDeviceID);
    AudioDeviceID *deviceIDs = (AudioDeviceID *)malloc(devicesDataSize);
    
    // fill in the devices
    [EZAudioUtilities checkResult:AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                                             &address,
                                                             0,
                                                             NULL,
                                                             &devicesDataSize,
                                                             deviceIDs)
                        operation:"Failed to get device IDs for available devices on OSX"];

    BOOL stop = NO;
    for (UInt32 i = 0; i < count; i++)
    {
        AudioDeviceID deviceID = deviceIDs[i];
        EZAudioDevice *device = [[EZAudioDevice alloc] init];
        device.deviceID = deviceID;
        device.manufacturer = [self manufacturerForDeviceID:deviceID];
        device.name = [self namePropertyForDeviceID:deviceID];
        device.UID = [self UIDPropertyForDeviceID:deviceID];
        device.inputChannelCount = [self channelCountForScope:kAudioObjectPropertyScopeInput forDeviceID:deviceID];
        device.outputChannelCount = [self channelCountForScope:kAudioObjectPropertyScopeOutput forDeviceID:deviceID];
        block(device, &stop);
        if (stop)
        {
            break;
        }
    }
    
    free(deviceIDs);
}

//------------------------------------------------------------------------------

+ (NSArray *)devices
{
    __block NSMutableArray *devices = [NSMutableArray array];
    [self enumerateDevicesUsingBlock:^(EZAudioDevice *device, BOOL *stop)
    {
        [devices addObject:device];
    }];
    return devices;
}

//------------------------------------------------------------------------------

+ (EZAudioDevice *)deviceWithPropertySelector:(AudioObjectPropertySelector)propertySelector
{
    AudioDeviceID deviceID;
    UInt32 propSize = sizeof(AudioDeviceID);
    AudioObjectPropertyAddress address = [self addressForPropertySelector:propertySelector];
    [EZAudioUtilities checkResult:AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                                             &address,
                                                             0,
                                                             NULL,
                                                             &propSize,
                                                             &deviceID)
                        operation:"Failed to get device device on OSX"];
    EZAudioDevice *device = [[EZAudioDevice alloc] init];
    device.deviceID = deviceID;
    device.manufacturer = [self manufacturerForDeviceID:deviceID];
    device.name = [self namePropertyForDeviceID:deviceID];
    device.UID = [self UIDPropertyForDeviceID:deviceID];
    device.inputChannelCount = [self channelCountForScope:kAudioObjectPropertyScopeInput forDeviceID:deviceID];
    device.outputChannelCount = [self channelCountForScope:kAudioObjectPropertyScopeOutput forDeviceID:deviceID];
    return device;
}

//------------------------------------------------------------------------------

+ (EZAudioDevice *)currentInputDevice
{
    return [self deviceWithPropertySelector:kAudioHardwarePropertyDefaultInputDevice];
}

//------------------------------------------------------------------------------

+ (EZAudioDevice *)currentOutputDevice
{
    return [self deviceWithPropertySelector:kAudioHardwarePropertyDefaultOutputDevice];
}

//------------------------------------------------------------------------------

+ (NSArray *)inputDevices
{
    __block NSMutableArray *devices = [NSMutableArray array];
    [self enumerateDevicesUsingBlock:^(EZAudioDevice *device, BOOL *stop)
    {
        if (device.inputChannelCount > 0)
        {
            [devices addObject:device];
        }
    }];
    return devices;
}

//------------------------------------------------------------------------------

+ (NSArray *)outputDevices
{
    __block NSMutableArray *devices = [NSMutableArray array];
    [self enumerateDevicesUsingBlock:^(EZAudioDevice *device, BOOL *stop)
    {
        if (device.outputChannelCount > 0)
        {
            [devices addObject:device];
        }
    }];
    return devices;
}

//------------------------------------------------------------------------------
#pragma mark - Utility
//------------------------------------------------------------------------------

+ (AudioObjectPropertyAddress)addressForPropertySelector:(AudioObjectPropertySelector)selector
{
    AudioObjectPropertyAddress address;
    address.mScope = kAudioObjectPropertyScopeGlobal;
    address.mElement = kAudioObjectPropertyElementMaster;
    address.mSelector = selector;
    return address;
}

//------------------------------------------------------------------------------

+ (NSString *)stringPropertyForSelector:(AudioObjectPropertySelector)selector
                           withDeviceID:(AudioDeviceID)deviceID
{
    AudioObjectPropertyAddress address = [self addressForPropertySelector:selector];
    CFStringRef string;
    UInt32 propSize = sizeof(CFStringRef);
    NSString *errorString = [NSString stringWithFormat:@"Failed to get device property (%u)",(unsigned int)selector];
    [EZAudioUtilities checkResult:AudioObjectGetPropertyData(deviceID,
                                                             &address,
                                                             0,
                                                             NULL,
                                                             &propSize,
                                                             &string)
                            operation:errorString.UTF8String];
    return (__bridge_transfer NSString *)string;
}

//------------------------------------------------------------------------------

+ (NSInteger)channelCountForScope:(AudioObjectPropertyScope)scope
                      forDeviceID:(AudioDeviceID)deviceID
{
    AudioObjectPropertyAddress address;
    address.mScope = scope;
    address.mElement = kAudioObjectPropertyElementMaster;
    address.mSelector = kAudioDevicePropertyStreamConfiguration;
    
    UInt32 dataSize = 0;
    [EZAudioUtilities checkResult:AudioObjectGetPropertyDataSize(deviceID,
                                                                 &address,
                                                                 0,
                                                                 NULL,
                                                                 &dataSize)
                        operation:"Failed to get buffer size"];
    
    AudioBufferList *bufferList = (AudioBufferList *)(malloc(dataSize));

    [EZAudioUtilities checkResult:AudioObjectGetPropertyData(deviceID,
                                                 &address,
                                                 0,
                                                 NULL,
                                                 &dataSize,
                                                 bufferList)
                        operation:"Failed to get buffer list"];
    
    UInt32 numBuffers = bufferList->mNumberBuffers;
    
    NSInteger channelCount = 0;
    for (NSInteger i = 0; i < numBuffers; i++)
    {
        channelCount += bufferList->mBuffers[i].mNumberChannels;
    }
    
    free(bufferList), bufferList = NULL;
    
    return channelCount;
}

//------------------------------------------------------------------------------

+ (NSString *)manufacturerForDeviceID:(AudioDeviceID)deviceID
{
    return [self stringPropertyForSelector:kAudioDevicePropertyDeviceManufacturerCFString
                              withDeviceID:deviceID];
}

//------------------------------------------------------------------------------

+ (NSString *)namePropertyForDeviceID:(AudioDeviceID)deviceID
{
    return [self stringPropertyForSelector:kAudioDevicePropertyDeviceNameCFString
                              withDeviceID:deviceID];
}

//------------------------------------------------------------------------------

+ (NSString *)UIDPropertyForDeviceID:(AudioDeviceID)deviceID
{
    return [self stringPropertyForSelector:kAudioDevicePropertyDeviceUID
                              withDeviceID:deviceID];
}

//------------------------------------------------------------------------------

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ { deviceID: %i, manufacturer: %@, name: %@, UID: %@, inputChannelCount: %ld, outputChannelCount: %ld }",
            [super description],
            self.deviceID,
            self.manufacturer,
            self.name,
            self.UID,
            self.inputChannelCount,
            self.outputChannelCount];
}

//------------------------------------------------------------------------------

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:self.class])
    {
        EZAudioDevice *device = (EZAudioDevice *)object;
        return [self.UID isEqualToString:device.UID];
    }
    else
    {
        return [super isEqual:object];
    }
}

//------------------------------------------------------------------------------

#endif

@end
