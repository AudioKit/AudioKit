//
//  EZAudioFloatConverter.h
//  EZAudio
//
//  Created by Syed Haris Ali, revision history on Githbub.
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

//------------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------------

FOUNDATION_EXPORT UInt32 const EZAudioFloatConverterDefaultPacketSize;

//------------------------------------------------------------------------------
#pragma mark - EZAudioFloatConverter
//------------------------------------------------------------------------------

@interface EZAudioFloatConverter : NSObject

//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------

+ (instancetype)converterWithInputFormat:(AudioStreamBasicDescription)inputFormat;

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

@property (nonatomic, assign, readonly) AudioStreamBasicDescription inputFormat;
@property (nonatomic, assign, readonly) AudioStreamBasicDescription floatFormat;

//------------------------------------------------------------------------------
#pragma mark - Instance Methods
//------------------------------------------------------------------------------

- (instancetype)initWithInputFormat:(AudioStreamBasicDescription)inputFormat;

//------------------------------------------------------------------------------

- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers;

//------------------------------------------------------------------------------

- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers
                    packetDescriptions:(AudioStreamPacketDescription *)packetDescriptions;

//------------------------------------------------------------------------------

@end
