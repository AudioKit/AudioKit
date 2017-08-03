//
//  EZAudioPlotGL.h
//  EZAudio
//
//  Created by Syed Haris Ali on 11/22/13.
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

#import <GLKit/GLKit.h>
#import "EZPlot.h"
#if !TARGET_OS_IPHONE
#import <OpenGL/OpenGL.h>
#endif

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef struct
{
    GLfloat x;
    GLfloat y;
} EZAudioPlotGLPoint;

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlotGL
//------------------------------------------------------------------------------

/**
 EZAudioPlotGL is a subclass of either a GLKView on iOS or an NSOpenGLView on OSX. As of 0.6.0 this class no longer depends on an embedded GLKViewController for iOS as the display link is just manually managed within this single view instead. The EZAudioPlotGL provides the same kind of audio plot as the EZAudioPlot, but uses OpenGL to GPU-accelerate the drawing of the points, which means you can fit a lot more points and complex geometries.
 */
#if TARGET_OS_IPHONE
@interface EZAudioPlotGL : GLKView
#elif TARGET_OS_MAC
@interface EZAudioPlotGL : NSOpenGLView
#endif

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Customizing The Plot's Appearance
///-----------------------------------------------------------

/**
 The default background color of the plot. For iOS the color is specified as a UIColor while for OSX the color is an NSColor. The default value on both platforms is a sweet looking green. 
 @warning On OSX, if you set the background to a value where the alpha component is 0 then the EZAudioPlotGL will automatically set its superview to be layer-backed.
 */
#if TARGET_OS_IPHONE
@property (nonatomic, strong) IBInspectable UIColor *backgroundColor;
#elif TARGET_OS_MAC
@property (nonatomic, strong) IBInspectable NSColor *backgroundColor;
#endif

//------------------------------------------------------------------------------

/**
 The default color of the plot's data (i.e. waveform, y-axis values). For iOS the color is specified as a UIColor while for OSX the color is an NSColor. The default value on both platforms is white.
 */
#if TARGET_OS_IPHONE
@property (nonatomic, strong) IBInspectable UIColor *color;
#elif TARGET_OS_MAC
@property (nonatomic, strong) IBInspectable NSColor *color;
#endif

//------------------------------------------------------------------------------

/**
 The plot's gain value, which controls the scale of the y-axis values. The default value of the gain is 1.0f and should always be greater than 0.0f.
 */
@property (nonatomic, assign) IBInspectable  float gain;

//------------------------------------------------------------------------------

/**
 The type of plot as specified by the `EZPlotType` enumeration (i.e. a buffer or rolling plot type). Default is EZPlotTypeBuffer.
 */
@property (nonatomic, assign) EZPlotType plotType;

//------------------------------------------------------------------------------

/**
 A BOOL indicating whether or not to fill in the graph. A value of YES will make a filled graph (filling in the space between the x-axis and the y-value), while a value of NO will create a stroked graph (connecting the points along the y-axis). Default is NO.
 */
@property (nonatomic, assign) IBInspectable BOOL shouldFill;

//------------------------------------------------------------------------------

/**
 A boolean indicating whether the graph should be rotated along the x-axis to give a mirrored reflection. This is typical for audio plots to produce the classic waveform look. A value of YES will produce a mirrored reflection of the y-values about the x-axis, while a value of NO will only plot the y-values. Default is NO.
 */
@property (nonatomic, assign) IBInspectable BOOL shouldMirror;

//------------------------------------------------------------------------------
#pragma mark - Updating The Plot
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Updating The Plot
///-----------------------------------------------------------

/**
 Updates the plot with the new buffer data and tells the view to redraw itself. Caller will provide a float array with the values they expect to see on the y-axis. The plot will internally handle mapping the x-axis and y-axis to the current view port, any interpolation for fills effects, and mirroring.
 @param buffer     A float array of values to map to the y-axis.
 @param bufferSize The size of the float array that will be mapped to the y-axis.
 */
-(void)updateBuffer:(float *)buffer withBufferSize:(UInt32)bufferSize;

//------------------------------------------------------------------------------
#pragma mark - Adjust Resolution
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Adjusting The Resolution
///-----------------------------------------------------------

/**
 Sets the length of the rolling history buffer (i.e. the number of points in the rolling plot's buffer). Can grow or shrink the display up to the maximum size specified by the `maximumRollingHistoryLength` method. Will return the actual set value, which will be either the given value if smaller than the `maximumRollingHistoryLength` or `maximumRollingHistoryLength` if a larger value is attempted to be set.
 @param  historyLength The new length of the rolling history buffer.
 @return The new value equal to the historyLength or the `maximumRollingHistoryLength`.
 */
-(int)setRollingHistoryLength:(int)historyLength;

//------------------------------------------------------------------------------

/**
 Provides the length of the rolling history buffer (i.e. the number of points in the rolling plot's buffer).
 *  @return An int representing the length of the rolling history buffer
 */
-(int)rollingHistoryLength;

//------------------------------------------------------------------------------
#pragma mark - Clearing The Plot
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Clearing The Plot
///-----------------------------------------------------------

/**
 Clears all data from the audio plot (includes both EZPlotTypeBuffer and EZPlotTypeRolling)
 */
-(void)clear;

//------------------------------------------------------------------------------
#pragma mark - Start/Stop Display Link
//------------------------------------------------------------------------------

/**
 Call this method to tell the EZAudioDisplayLink to stop drawing temporarily.
 */
- (void)pauseDrawing;

//------------------------------------------------------------------------------

/**
  Call this method to manually tell the EZAudioDisplayLink to start drawing again.
 */
- (void)resumeDrawing;

//------------------------------------------------------------------------------
#pragma mark - Subclass
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Customizing The Drawing
///-----------------------------------------------------------

/**
 This method is used to perform the actual OpenGL drawing code to clear the background and draw the lines representing the 2D audio plot. Subclasses can use the current implementation as an example and implement their own custom geometries. This is the analogy of overriding the drawRect: method in an NSView or UIView.
 @param points       An array of EZAudioPlotGLPoint structures representing the mapped audio data to x,y coordinates. The x-axis goes from 0 to the number of points (pointCount) while the y-axis goes from -1 to 1. Check out the implementation of this method to see how the model view matrix of the base effect is transformed to map this properly to the viewport.
 @param pointCount   A UInt32 representing the number of points contained in the points array.
 @param baseEffect   An optional GLKBaseEffect to use as a default shader. Call prepareToDraw on the base effect before any glDrawArrays call.
 @param vbo          The Vertex Buffer Object used to buffer the point data.
 @param vab          The Vertex Array Buffer used to bind the Vertex Buffer Object. This is a Mac only thing, you can ignore this completely on iOS.
 @param interpolated A BOOL indicating whether the data has been interpolated. This means the point data is twice as long, where every other point is 0 on the y-axis to allow drawing triangle stripes for filled in waveforms. Typically if the point data is interpolated you will be using the GL_TRIANGLE_STRIP drawing mode, while non-interpolated plots will just use a GL_LINE_STRIP drawing mode.
 @param mirrored     A BOOL indicating whether the plot should be mirrored about the y-axis (or whatever geometry you come up with).
 @param gain         A float representing a gain that should be used to influence the height or intensity of your geometry's shape. A gain of 0.0 means silence, a gain of 1.0 means full volume (you're welcome to boost this to whatever you want).
 */
- (void)redrawWithPoints:(EZAudioPlotGLPoint *)points
              pointCount:(UInt32)pointCount
              baseEffect:(GLKBaseEffect *)baseEffect
      vertexBufferObject:(GLuint)vbo
       vertexArrayBuffer:(GLuint)vab
            interpolated:(BOOL)interpolated
                mirrored:(BOOL)mirrored
                    gain:(float)gain;

//------------------------------------------------------------------------------

/**
 Called during the OpenGL run loop to constantly update the drawing 60 fps. Callers can use this force update the screen while subclasses can override this for complete control over their rendering. However, subclasses are more encouraged to use the `redrawWithPoints:pointCount:baseEffect:vertexBufferObject:vertexArrayBuffer:interpolated:mirrored:gain:`
 */
- (void)redraw;

//------------------------------------------------------------------------------

/**
 Called after the view has been created. Subclasses should use to add any additional methods needed instead of overriding the init methods.
 */
- (void)setup;

//------------------------------------------------------------------------------

/**
 Main method used to copy the sample data from the source buffer and update the
 plot. Subclasses can overwrite this method for custom behavior.
 @param data   A float array of the sample data. Subclasses should copy this data to a separate array to avoid threading issues.
 @param length The length of the float array as an int.
 */
- (void)setSampleData:(float *)data length:(int)length;

///-----------------------------------------------------------
/// @name Subclass Methods
///-----------------------------------------------------------

/**
 Provides the default length of the rolling history buffer when the plot is initialized. Default is `EZAudioPlotDefaultHistoryBufferLength` constant.
 @return An int describing the initial length of the rolling history buffer.
 */
- (int)defaultRollingHistoryLength;

//------------------------------------------------------------------------------

/**
 Provides the default maximum rolling history length - that is, the maximum amount of points the `setRollingHistoryLength:` method may be set to. If a length higher than this is set then the plot will likely crash because the appropriate resources are only allocated once during the plot's initialization step. Defualt is `EZAudioPlotDefaultMaxHistoryBufferLength` constant.
 @return An int describing the maximum length of the absolute rolling history buffer.
 */
- (int)maximumRollingHistoryLength;

//------------------------------------------------------------------------------

@end