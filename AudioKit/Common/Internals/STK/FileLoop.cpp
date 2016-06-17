/***************************************************/
/*! \class FileLoop
    \brief STK file looping / oscillator class.

    This class provides audio file looping functionality.  Any audio
    file that can be loaded by FileRead can be looped using this
    class.

    FileLoop supports multi-channel data.  It is important to
    distinguish the tick() method that computes a single frame (and
    returns only the specified sample of a multi-channel frame) from
    the overloaded one that takes an StkFrames object for
    multi-channel and/or multi-frame data.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "FileLoop.h"
#include <cmath>

namespace stk {

FileLoop :: FileLoop( unsigned long chunkThreshold, unsigned long chunkSize )
  : FileWvIn( chunkThreshold, chunkSize ), phaseOffset_(0.0)
{
  Stk::addSampleRateAlert( this );
}

FileLoop :: FileLoop( std::string fileName, bool raw, bool doNormalize,
                      unsigned long chunkThreshold, unsigned long chunkSize )
  : FileWvIn( chunkThreshold, chunkSize ), phaseOffset_(0.0)
{
  this->openFile( fileName, raw, doNormalize );
  Stk::addSampleRateAlert( this );
}

FileLoop :: ~FileLoop( void )
{
  Stk::removeSampleRateAlert( this );
}

void FileLoop :: openFile( std::string fileName, bool raw, bool doNormalize )
{
  // Call close() in case another file is already open.
  this->closeFile();

  // Attempt to open the file ... an error might be thrown here.
  file_.open( fileName, raw );

  // Determine whether chunking or not.
  if ( file_.fileSize() > chunkThreshold_ ) {
    chunking_ = true;
    chunkPointer_ = 0;
    data_.resize( chunkSize_ + 1, file_.channels() );
    if ( doNormalize ) normalizing_ = true;
    else normalizing_ = false;
  }
  else {
    chunking_ = false;
    data_.resize( file_.fileSize() + 1, file_.channels() );
  }

  // Load all or part of the data.
  file_.read( data_, 0, doNormalize );

  if ( chunking_ ) { // If chunking, save the first sample frame for later.
    firstFrame_.resize( 1, data_.channels() );
    for ( unsigned int i=0; i<data_.channels(); i++ )
      firstFrame_[i] = data_[i];
  }
  else {  // If not chunking, copy the first sample frame to the last.
    for ( unsigned int i=0; i<data_.channels(); i++ )
      data_( data_.frames() - 1, i ) = data_[i];
  }

  // Resize our lastOutputs container.
  lastFrame_.resize( 1, file_.channels() );

  // Close the file unless chunking
  fileSize_ = file_.fileSize();
  if ( !chunking_ ) file_.close();

  // Set default rate based on file sampling rate.
  this->setRate( data_.dataRate() / Stk::sampleRate() );

  if ( doNormalize & !chunking_ ) this->normalize();

  this->reset();
}

void FileLoop :: setRate( StkFloat rate )
{
  rate_ = rate;

  if ( fmod( rate_, 1.0 ) != 0.0 ) interpolate_ = true;
  else interpolate_ = false;
}

void FileLoop :: addTime( StkFloat time )
{
  // Add an absolute time in samples.
  time_ += time;

  while ( time_ < 0.0 )
    time_ += fileSize_;
  while ( time_ >= fileSize_ )
    time_ -= fileSize_;
}

void FileLoop :: addPhase( StkFloat angle )
{
  // Add a time in cycles (one cycle = fileSize).
  time_ += fileSize_ * angle;

  while ( time_ < 0.0 )
    time_ += fileSize_;
  while ( time_ >= fileSize_ )
    time_ -= fileSize_;
}

void FileLoop :: addPhaseOffset( StkFloat angle )
{
  // Add a phase offset in cycles, where 1.0 = fileSize.
  phaseOffset_ = fileSize_ * angle;
}

StkFloat FileLoop :: tick( unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= data_.channels() ) {
    oStream_ << "FileLoop::tick(): channel argument and soundfile data are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  // Check limits of time address ... if necessary, recalculate modulo
  // fileSize.
  while ( time_ < 0.0 )
    time_ += fileSize_;
  while ( time_ >= fileSize_ )
    time_ -= fileSize_;

  StkFloat tyme = time_;
  if ( phaseOffset_ ) {
    tyme += phaseOffset_;
    while ( tyme < 0.0 )
      tyme += fileSize_;
    while ( tyme >= fileSize_ )
      tyme -= fileSize_;
  }

  if ( chunking_ ) {

    // Check the time address vs. our current buffer limits.
    if ( ( time_ < (StkFloat) chunkPointer_ ) ||
         ( time_ > (StkFloat) ( chunkPointer_ + chunkSize_ - 1 ) ) ) {

      while ( time_ < (StkFloat) chunkPointer_ ) { // negative rate
        chunkPointer_ -= chunkSize_ - 1; // overlap chunks by one frame
        if ( chunkPointer_ < 0 ) chunkPointer_ = 0;
      }
      while ( time_ > (StkFloat) ( chunkPointer_ + chunkSize_ - 1 ) ) { // positive rate
        chunkPointer_ += chunkSize_ - 1; // overlap chunks by one frame
        if ( chunkPointer_ + chunkSize_ > fileSize_ ) { // at end of file
          chunkPointer_ = fileSize_ - chunkSize_ + 1; // leave extra frame at end of buffer
          // Now fill extra frame with first frame data.
          for ( unsigned int j=0; j<firstFrame_.channels(); j++ )
            data_( data_.frames() - 1, j ) = firstFrame_[j];
        }
      }

      // Load more data.
      file_.read( data_, chunkPointer_, normalizing_ );
    }

    // Adjust index for the current buffer.
    tyme -= chunkPointer_;
  }

  if ( interpolate_ ) {
    for ( unsigned int i=0; i<lastFrame_.size(); i++ )
      lastFrame_[i] = data_.interpolate( tyme, i );
  }
  else {
    for ( unsigned int i=0; i<lastFrame_.size(); i++ )
      lastFrame_[i] = data_( (size_t) tyme, i );
  }

  // Increment time, which can be negative.
  time_ += rate_;

  return lastFrame_[channel];
}

StkFrames& FileLoop :: tick( StkFrames& frames, unsigned int channel)
{
  if ( !file_.isOpen() ) {
#if defined(_STK_DEBUG_)
    oStream_ << "FileLoop::tick(): no file data is loaded!";
    handleError( StkError::DEBUG_PRINT );
#endif
  return frames;
  }
        
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "FileLoop::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif
        
  StkFloat *samples = &frames[channel];
  unsigned int j, hop = frames.channels() - nChannels;
  if ( nChannels == 1 ) {
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
    *samples++ = tick();
  }
  else {
    for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
      *samples++ = tick();
      for ( j=1; j<nChannels; j++ )
        *samples++ = lastFrame_[j];
      }
    }
  return frames;
        
}

} // stk namespace
