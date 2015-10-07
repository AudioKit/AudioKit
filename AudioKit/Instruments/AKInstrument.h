//
//  AKInstrument.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKCompatibility.h"
#import "AKOrchestra.h"
#import "AKParameter+Operation.h"
#import "AKAudio.h"
#import "AKStereoAudio.h"
#import "AKPhrase.h"
#import "AKNote.h"
#import "AKNoteProperty.h"
#import "AKInstrumentProperty.h"

@class AKEvent;

/** Manages functions that most AK instruments need to have.*/

NS_ASSUME_NONNULL_BEGIN
@interface AKInstrument : NSObject

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

/// Instantiates a new instrument
+ (instancetype)instrument;

/// Instantiates a new instrument at a given instrument number
/// @param instrumentNumber Unique number to assign this instrument, useful when overwriting an instrument
+ (instancetype)instrumentWithNumber:(NSUInteger)instrumentNumber;

/// Instantiates a new instrument at a given instrument number
/// @param instrumentNumber Unique number to assign this instrument, useful when overwriting an instrument
- (instancetype)initWithNumber:(NSUInteger)instrumentNumber;

/// A string uniquely defined by the instrument class name and a unique integer.
- (NSString *)uniqueName;

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void)resetID;

// -----------------------------------------------------------------------------
#  pragma mark - Properties
// -----------------------------------------------------------------------------

/// Unique instrument number
@property NSUInteger instrumentNumber;


/// Array of instrument properties available for the instrument.
@property NSMutableArray<AKInstrumentProperty *> *properties;


/// Array of note properties available to events.
@property NSMutableArray<AKNoteProperty *> *noteProperties;

/// Add an instrument property explicitly (normally this happens automatically)
/// @param newProperty New property to add to the instrument.
- (void) addProperty:(AKInstrumentProperty *)newProperty;

/// Helper function to create a property with the usually values and add it to the instrument
/// @param value   Current value of the note property
/// @param minimum Minimum value
/// @param maximum Maximum value
- (AKInstrumentProperty *)createPropertyWithValue:(float)value
                                          minimum:(float)minimum
                                          maximum:(float)maximum;

/// Add a note property to the instrument explicitly (normally happens automatically)
/// @param newNoteProperty New note property instrument needs to be aware of.
- (void)addNoteProperty:(AKNoteProperty *)newNoteProperty;



// -----------------------------------------------------------------------------
#  pragma mark - Operations
// -----------------------------------------------------------------------------

/// All UDOs that are required by the instrument are stored here and declared before the instrument block.
@property NSMutableSet<NSString *> *userDefinedOperations;

/// Globally accessible parameters used for cross-instrument communication
@property NSMutableSet<AKParameter *> *globalParameters;

/// Adds the operation to the AKInstrument.
/// @param newOperation New operation to add to the instrument.
- (void)connect:(AKParameter *)newOperation;

/// Sets a parameter to be the audio output of the AKInstrument.  Equivalent to declaring and connect AKAudioOutput.
/// @param audio Operation output that you want to be played.
- (void)setAudioOutput:(AKParameter *)audio;

/// Sets a parameter to be the audio output of the AKInstrument.  Equivalent to declaring and connect AKAudioOutput.
/// @param leftInput  Operation's output to send to the left channel
/// @param rightInput Operation's output to send to the right channel
- (void)setAudioOutputWithLeftAudio:(AKParameter *)leftInput rightAudio:(AKParameter *)rightInput;

/// Sets a parameter to be the audio output of the AKInstrument.  Equivalent to declaring and connect AKAudioOutput.
/// @param stereo Stereo Operation output that you want to be played.
- (void)setStereoAudioOutput:(AKStereoAudio *)stereo;

/// Appending a value to an output, usually a globally accessibly audio stream
/// @param output Parameter being set.
/// @param input  Parameter being read.
- (void)appendOutput:(AKParameter *)output withInput:(AKParameter *)input;

/// Deprecated function, please use appendOutput:withInput:
/// @param output Parameter being set.
/// @param input  Parameter being read.
- (void)assignOutput:(AKParameter *)output to:(AKParameter *)input;

/// Explicitly set the output of one parameter to another, useful for tracking
/// @param parameter Output or overwritten parameter
/// @param input     Input parameter
- (void)setParameter:(AKParameter *)parameter to:(AKParameter *)input;

/// Shortcut for setting a parameter's value to zero.
/// @param parameterToReset Parameter whose value will be reset to zero.
- (void)resetParameter:(AKParameter *)parameterToReset;

/// Log parameter values at a given frequency with a message.
/// @param message   Message to print first. Usually something like "myParameter = "
/// @param parameter The parameter to log the float value of
/// @param timeInterval Time in seconds between printouts.
- (void)enableParameterLog:(NSString *)message
                 parameter:(AKParameter *)parameter
              timeInterval:(NSTimeInterval)timeInterval;

- (void)logChangesToParameter:(AKParameter *)parameter withMessage:(NSString *)message;

// -----------------------------------------------------------------------------
#  pragma mark - Csound Implementation
// -----------------------------------------------------------------------------

// The textual respresentation of the instrument in CSD form.
- (NSString *)stringForCSD;

// The CSD line that deactivates all notes created by the instrument
- (NSString *)stopStringForCSD;

/// Play an instrument that contains no note properties ie. uses a generic
/// AKNote to begin playback for a specific amount of time.
/// @param playDuration Length of time in seconds to play the instrument.
- (void)playForDuration:(NSTimeInterval)playDuration;

/// For instruments that do not create note instances, play the instrument with infinite duration.
- (void)play;

/// Equivalent to "play" but reads better for instruments that do not play notes, such as processors.
- (void)start;

/// Restart an instrument after a pause
- (void)restart;

/// Play the given note
/// @param note The note that will be played.
- (void)playNote:(AKNote *)note;

/// Play the given note after a delay
/// @param note The note that will be played.
/// @param delay The amount of time in seconds to wait until playing the note
- (void)playNote:(AKNote *)note afterDelay:(NSTimeInterval)delay;

/// Stop the given note
/// @param note The note that will be stopped.
- (void)stopNote:(AKNote *)note;

/// Stop the given note after a delay
/// @param note The note that will be stopped.
/// @param delay The amount of time in seconds to wait until stopping the note
- (void)stopNote:(AKNote *)note afterDelay:(NSTimeInterval)delay;

/// Play the given note phrase
/// @param phrase The note phrase that will be played.
- (void)playPhrase:(AKPhrase *)phrase;

/// Repeat a note phrase
/// @param phrase The note phrase that will be played.
- (void)repeatPhrase:(AKPhrase *)phrase;

/// Repeat a note phrase periodically
/// @param phrase The note phrase that will be played.
/// @param duration The period in seconds between playbacks
- (void)repeatPhrase:(AKPhrase *)phrase duration:(NSTimeInterval)duration;

/// Stop repeating the phrase
- (void)stopPhrase;

/// Stop all notes created by the instrument
- (void)stop;

// -----------------------------------------------------------------------------
#  pragma mark - Resource allocation
// -----------------------------------------------------------------------------

/// Set a limit to the number of notes to allocate at any one time. Note which exceed this limit will be deallocated.
/// Defaults to zero, which is equivalent to setting no limit.
/// See http://www.csounds.com/manual/html/maxalloc.html for more info.
@property NSUInteger maximumNoteAllocation;

@end
NS_ASSUME_NONNULL_END
