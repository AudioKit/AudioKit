/***************************************************/
/*! \class RtWvOut
    \brief STK realtime audio (blocking) output class.

    This class provides a simplified interface to RtAudio for realtime
    audio output.  It is a subclass of WvOut.  This class makes use of
    RtAudio's callback functionality by creating a large ring-buffer
    into which data is written.  This class should not be used when
    low-latency is desired.

    RtWvOut supports multi-channel data in interleaved format.  It is
    important to distinguish the tick() method that outputs a single
    sample to all channels in a sample frame from the overloaded one
    that takes a reference to an StkFrames object for multi-channel
    and/or multi-frame data.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "RtWvOut.h"
#include <cstring>

namespace stk {

// Streaming status states.
enum { RUNNING, EMPTYING, FINISHED };

// This function is automatically called by RtAudio to get audio data for output.
int write( void *outputBuffer, void *inputBuffer, unsigned int nBufferFrames,
           double streamTime, RtAudioStreamStatus status, void *dataPointer )
{
  return ( (RtWvOut *) dataPointer )->readBuffer( outputBuffer, nBufferFrames );
}

// This function does not block.  If the user does not write output
// data to the buffer fast enough, previous data will be re-output
// (data underrun).
int RtWvOut :: readBuffer( void *buffer, unsigned int frameCount )
{
  unsigned int nSamples, nChannels = data_.channels();
  unsigned int nFrames = frameCount;
  StkFloat *input = (StkFloat *) &data_[ readIndex_ * nChannels ];
  StkFloat *output = (StkFloat *) buffer;
  long counter;

  while ( nFrames > 0 ) {

    // I'm assuming that both the RtAudio and StkFrames buffers
    // contain interleaved data.
    counter = nFrames;

    // Pre-increment read pointer and check bounds.
    readIndex_ += nFrames;
    if ( readIndex_ >= data_.frames() ) {
      counter -= readIndex_ - data_.frames();
      readIndex_ = 0;
    }

    // Copy data from the StkFrames container.
    if ( status_ == EMPTYING && framesFilled_ <= counter ) {
      nSamples = framesFilled_ * nChannels;
      unsigned int i;
      for ( i=0; i<nSamples; i++ ) *output++ = *input++;
      nSamples = (counter - framesFilled_) * nChannels;
      for ( i=0; i<nSamples; i++ ) *output++ = 0.0;
      status_ = FINISHED;
      return 1;
    }
    else {
      nSamples = counter * nChannels;
      for ( unsigned int i=0; i<nSamples; i++ )
        *output++ = *input++;
    }

    nFrames -= counter;
  }

  mutex_.lock();
  framesFilled_ -= frameCount;
  mutex_.unlock();
  if ( framesFilled_ < 0 ) {
    framesFilled_ = 0;
    //    writeIndex_ = readIndex_;
    oStream_ << "RtWvOut: audio buffer underrun!";
    handleError( StkError::WARNING );
  }

  return 0;
}


RtWvOut :: RtWvOut( unsigned int nChannels, StkFloat sampleRate, int device, int bufferFrames, int nBuffers )
  : stopped_( true ), readIndex_( 0 ), writeIndex_( 0 ), framesFilled_( 0 ), status_(0)
{
  // We'll let RtAudio deal with channel and sample rate limitations.
  RtAudio::StreamParameters parameters;
  if ( device == 0 )
    parameters.deviceId = dac_.getDefaultOutputDevice();
  else
    parameters.deviceId = device - 1;
  parameters.nChannels = nChannels;
  unsigned int size = bufferFrames;
  RtAudioFormat format = ( sizeof(StkFloat) == 8 ) ? RTAUDIO_FLOAT64 : RTAUDIO_FLOAT32;

  // Open a stream and set the callback function.
  try {
    dac_.openStream( &parameters, NULL, format, (unsigned int)Stk::sampleRate(), &size, &write, (void *)this );
  }
  catch ( RtAudioError &error ) {
    handleError( error.what(), StkError::AUDIO_SYSTEM );
  }

  data_.resize( size * nBuffers, nChannels );

  // Start writing half-way into buffer.
  writeIndex_ = (unsigned int ) (data_.frames() / 2.0);
  framesFilled_ = writeIndex_;
}

RtWvOut :: ~RtWvOut( void )
{
  // Change status flag to signal callback to clear the buffer and close.
  status_ = EMPTYING;
  while ( status_ != FINISHED || dac_.isStreamRunning() == true ) Stk::sleep( 100 );
  dac_.closeStream();
}

void RtWvOut :: start( void )
{
  if ( stopped_ ) {
    dac_.startStream();
    stopped_ = false;
  }
}

void RtWvOut :: stop( void )
{
  if ( !stopped_ ) {
    dac_.stopStream();
    stopped_ = true;
  }
}

void RtWvOut :: tick( const StkFloat sample )
{
  if ( stopped_ ) this->start();

  // Block until we have room for at least one frame of output data.
  while ( framesFilled_ == (long) data_.frames() ) Stk::sleep( 1 );

  unsigned int nChannels = data_.channels();
  StkFloat input = sample;
  clipTest( input );
  unsigned long index = writeIndex_ * nChannels;
  for ( unsigned int j=0; j<nChannels; j++ )
    data_[index++] = input;

  mutex_.lock();
  framesFilled_++;
  mutex_.unlock();
  frameCounter_++;
  writeIndex_++;
  if ( writeIndex_ == data_.frames() )
    writeIndex_ = 0;
}

void RtWvOut :: tick( const StkFrames& frames )
{
#if defined(_STK_DEBUG_)
  if ( data_.channels() != frames.channels() ) {
    oStream_ << "RtWvOut::tick(): incompatible channel value in StkFrames argument!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  if ( stopped_ ) this->start();

  // See how much space we have and fill as much as we can ... if we
  // still have samples left in the frames object, then wait and
  // repeat.
  unsigned int framesEmpty, nFrames, bytes, framesWritten = 0;
  unsigned int nChannels = data_.channels();
  while ( framesWritten < frames.frames() ) {

    // Block until we have some room for output data.
    while ( framesFilled_ == (long) data_.frames() ) Stk::sleep( 1 );
    framesEmpty = data_.frames() - framesFilled_;

    // Copy data in one chunk up to the end of the data buffer.
    nFrames = framesEmpty;
    if ( writeIndex_ + nFrames > data_.frames() )
      nFrames = data_.frames() - writeIndex_;
    if ( nFrames > frames.frames() - framesWritten )
      nFrames = frames.frames() - framesWritten;
    bytes = nFrames * nChannels * sizeof( StkFloat );
    StkFloat *samples = &data_[writeIndex_ * nChannels];
    StkFrames *ins = (StkFrames *) &frames;
    memcpy( samples, &(*ins)[framesWritten * nChannels], bytes );
    for ( unsigned int i=0; i<nFrames * nChannels; i++ ) clipTest( *samples++ );

    writeIndex_ += nFrames;
    if ( writeIndex_ == data_.frames() ) writeIndex_ = 0;

    framesWritten += nFrames;
    mutex_.lock();
    framesFilled_ += nFrames;
    mutex_.unlock();
    frameCounter_ += nFrames;
  }
}

} // stk namespace
