//
//  AEFloatConverter.h
//  The Amazing Audio Engine
//
//  Created by Michael Tyson on 25/10/2012.
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#ifdef __cplusplus
extern "C" {
#endif

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/*!
 * Universal converter to float format
 *
 *  Use this class to easily convert arbitrary audio formats to floating point
 *  for use with utilities like the Accelerate framework.
 */
@interface AEFloatConverter : NSObject

/*!
 * Initialize
 *
 * @param sourceFormat The audio format to use
 */
- (id)initWithSourceFormat:(AudioStreamBasicDescription)sourceFormat;

/*!
 * Convert audio to floating-point
 *
 *  This C function, safe to use in a Core Audio realtime thread context, will take
 *  an audio buffer list of audio in the format you provided at initialisation, and
 *  convert it into a noninterleaved float array.
 *
 * @param converter         Pointer to the converter object.
 * @param sourceBuffer      An audio buffer list containing the source audio.
 * @param targetBuffers     An array of floating-point arrays to store the converted float audio into. 
 *                          Note that you must provide the correct number of arrays, to match the number of channels.
 * @param frames            The number of frames to convert.
 * @return YES on success; NO on failure
 */
BOOL AEFloatConverterToFloat(AEFloatConverter* converter, AudioBufferList *sourceBuffer, float * const * targetBuffers, UInt32 frames);

/*!
 * Convert audio to floating-point, in a buffer list
 *
 *  This C function, safe to use in a Core Audio realtime thread context, will take
 *  an audio buffer list of audio in the format you provided at initialisation, and
 *  convert it into a noninterleaved float format.
 *
 * @param converter         Pointer to the converter object.
 * @param sourceBuffer      An audio buffer list containing the source audio.
 * @param targetBuffer      An audio buffer list to store the converted floating-point audio.
 * @param frames            The number of frames to convert.
 * @return YES on success; NO on failure
 */
BOOL AEFloatConverterToFloatBufferList(AEFloatConverter* converter, AudioBufferList *sourceBuffer,  AudioBufferList *targetBuffer, UInt32 frames);

/*!
 * Convert audio from floating-point
 *
 *  This C function, safe to use in a Core Audio realtime thread context, will take
 *  an audio buffer list of audio in the format you provided at initialisation, and
 *  convert it into a float array.
 *
 * @param converter         Pointer to the converter object.
 * @param sourceBuffers     An array of floating-point arrays containing the floating-point audio to convert.
 *                          Note that you must provide the correct number of arrays, to match the number of channels.
 * @param targetBuffer      An audio buffer list to store the converted audio into.
 * @param frames            The number of frames to convert.
 * @return YES on success; NO on failure
 */
BOOL AEFloatConverterFromFloat(AEFloatConverter* converter, float * const * sourceBuffers, AudioBufferList *targetBuffer, UInt32 frames);

/*!
 * Convert audio from floating-point, in a buffer list
 *
 *  This C function, safe to use in a Core Audio realtime thread context, will take
 *  an audio buffer list of audio in the format you provided at initialisation, and
 *  convert it into a float array.
 *
 * @param converter         Pointer to the converter object.
 * @param sourceBuffer      An audio buffer list containing the source audio.
 * @param targetBuffer      An audio buffer list to store the converted audio into.
 * @param frames            The number of frames to convert.
 * @return YES on success; NO on failure
 */
BOOL AEFloatConverterFromFloatBufferList(AEFloatConverter* converter, AudioBufferList *sourceBuffer, AudioBufferList *targetBuffer, UInt32 frames);

/*!
 * The AudioStreamBasicDescription representing the converted floating-point format
 */
@property (nonatomic, readonly) AudioStreamBasicDescription floatingPointAudioDescription;

/*!
 * The source audio format set at initialization
 */
@property (nonatomic, readonly) AudioStreamBasicDescription sourceFormat;

@end

#ifdef __cplusplus
}
#endif