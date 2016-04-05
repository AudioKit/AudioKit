/***************************************************/
/*! \class RtWvIn
    \brief STK realtime audio (blocking) input class.

    This class provides a simplified interface to RtAudio for realtime
    audio input.  It is a subclass of WvIn.  This class makes use of
    RtAudio's callback functionality by creating a large ring-buffer
    from which data is read.  This class should not be used when
    low-latency is desired.

    RtWvIn supports multi-channel data in both interleaved and
    non-interleaved formats.  It is important to distinguish the
    tick() method that computes a single frame (and returns only the
    specified sample of a multi-channel frame) from the overloaded one
    that takes an StkFrames object for multi-channel and/or
    multi-frame data.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "RtWvIn.h"
#include <cstring>

namespace stk {

// This function is automatically called by RtAudio to supply input audio data.
int read( void *outputBuffer, void *inputBuffer, unsigned int nBufferFrames,
          double streamTime, RtAudioStreamStatus status, void *dataPointer )
{
  ( (RtWvIn *) dataPointer )->fillBuffer( inputBuffer, nBufferFrames );
  return 0;
}

// This function does not block.  If the user does not read the buffer
// data fast enough, unread data will be overwritten (data overrun).
void RtWvIn :: fillBuffer( void *buffer, unsigned int nFrames )
{
  StkFloat *samples = (StkFloat *) buffer;
  unsigned int counter, iStart, nSamples = nFrames * data_.channels();

  while ( nSamples > 0 ) {

    // I'm assuming that both the RtAudio and StkFrames buffers
    // contain interleaved data.
    iStart = writeIndex_ * data_.channels();
    counter = nSamples;

    // Pre-increment write pointer and check bounds.
    writeIndex_ += nSamples / data_.channels();
    if ( writeIndex_ >= data_.frames() ) {
      writeIndex_ = 0;
      counter = data_.size() - iStart;
    }

    // Copy data to the StkFrames container.
    for ( unsigned int i=0; i<counter; i++ )
      data_[iStart++] = *samples++;

    nSamples -= counter;
  }

  mutex_.lock();
  framesFilled_ += nFrames;
  mutex_.unlock();
  if ( framesFilled_ > data_.frames() ) {
    framesFilled_ = data_.frames();
    oStream_ << "RtWvIn: audio buffer overrun!";
    handleError( StkError::WARNING );
  }
}

RtWvIn :: RtWvIn( unsigned int nChannels, StkFloat sampleRate, int device, int bufferFrames, int nBuffers )
  : stopped_( true ), readIndex_( 0 ), writeIndex_( 0 ), framesFilled_( 0 )
{
  // We'll let RtAudio deal with channel and sample rate limitations.
  RtAudio::StreamParameters parameters;
  if ( device == 0 )
    parameters.deviceId = adc_.getDefaultInputDevice();
  else
    parameters.deviceId = device - 1;
  parameters.nChannels = nChannels;
  unsigned int size = bufferFrames;
  RtAudioFormat format = ( sizeof(StkFloat) == 8 ) ? RTAUDIO_FLOAT64 : RTAUDIO_FLOAT32;

  try {
    adc_.openStream( NULL, &parameters, format, (unsigned int)Stk::sampleRate(), &size, &read, (void *)this );
  }
  catch ( RtAudioError &error ) {
    handleError( error.what(), StkError::AUDIO_SYSTEM );
  }

  data_.resize( size * nBuffers, nChannels );
  lastFrame_.resize( 1, nChannels );
}

RtWvIn :: ~RtWvIn()
{
  if ( !stopped_ ) adc_.stopStream();
  adc_.closeStream();
}

void RtWvIn :: start()
{
  if ( stopped_ ) {
    adc_.startStream();
    stopped_ = false;
  }
}

void RtWvIn :: stop()
{
  if ( !stopped_ ) {
    adc_.stopStream();
    stopped_ = true;
    for ( unsigned int i=0; i<lastFrame_.size(); i++ ) lastFrame_[i] = 0.0;
  }
}

StkFloat RtWvIn :: tick( unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= data_.channels() ) {
    oStream_ << "RtWvIn::tick(): channel argument is incompatible with streamed channels!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  if ( stopped_ ) this->start();

  // Block until at least one frame is available.
  while ( framesFilled_ == 0 ) Stk::sleep( 1 );

  unsigned long index = readIndex_ * lastFrame_.channels();
  for ( unsigned int i=0; i<lastFrame_.size(); i++ )
    lastFrame_[i] = data_[index++];

  mutex_.lock();
  framesFilled_--;
  mutex_.unlock();
  readIndex_++;
  if ( readIndex_ >= data_.frames() )
    readIndex_ = 0;

  return lastFrame_[channel];
}

StkFrames& RtWvIn :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "RtWvIn::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  if ( stopped_ ) this->start();

  // See how much space we have and fill as much as we can ... if we
  // still have space left in the frames object, then wait and repeat.
  unsigned int nFrames, bytes, framesRead = 0;
  while ( framesRead < frames.frames() ) {

    // Block until we have some input data.
    while ( framesFilled_ == 0 ) Stk::sleep( 1 );

    // Copy data in one chunk up to the end of the data buffer.
    nFrames = framesFilled_;
    if ( readIndex_ + nFrames > data_.frames() )
      nFrames = data_.frames() - readIndex_;
    if ( nFrames > frames.frames() - framesRead )
      nFrames = frames.frames() - framesRead;
    bytes = nFrames * nChannels * sizeof( StkFloat );
    StkFloat *samples = &data_[readIndex_ * nChannels];
    unsigned int hop = frames.channels() - nChannels;
    if ( hop == 0 ) 
      memcpy( &frames[framesRead * nChannels], samples, bytes );
    else {
      StkFloat *fSamples = &frames[channel];
      unsigned int j;
      for ( unsigned int i=0; i<frames.frames(); i++, fSamples += hop ) {
        for ( j=1; j<nChannels; j++ )
          *fSamples++ = *samples++;
      }
    }

    readIndex_ += nFrames;
    if ( readIndex_ == data_.frames() ) readIndex_ = 0;

    framesRead += nFrames;
    mutex_.lock();
    framesFilled_ -= nFrames;
    mutex_.unlock();
  }

  unsigned long index = (frames.frames() - 1) * nChannels;
  for ( unsigned int i=0; i<lastFrame_.size(); i++ )
    lastFrame_[i] = frames[channel+index++];

  return frames;
}

} // stk namespace
