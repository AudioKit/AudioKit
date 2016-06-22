/***************************************************/
/*! \class FileWvIn
    \brief STK audio file input class.

    This class inherits from WvIn.  It provides a "tick-level"
    interface to the FileRead class.  It also provides variable-rate
    playback functionality.  Audio file support is provided by the
    FileRead class.  Linear interpolation is used for fractional read
    rates.

    FileWvIn supports multi-channel data.  It is important to
    distinguish the tick() method that computes a single frame (and
    returns only the specified sample of a multi-channel frame) from
    the overloaded one that takes an StkFrames object for
    multi-channel and/or multi-frame data.

    FileWvIn will either load the entire content of an audio file into
    local memory or incrementally read file data from disk in chunks.
    This behavior is controlled by the optional constructor arguments
    \e chunkThreshold and \e chunkSize.  File sizes greater than \e
    chunkThreshold (in sample frames) will be read incrementally in
    chunks of \e chunkSize each (also in sample frames).

    When the file end is reached, subsequent calls to the tick()
    functions return zeros and isFinished() returns \e true.

    See the FileRead class for a description of the supported audio
    file formats.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "FileWvIn.h"
#include <cmath>

namespace stk {

FileWvIn :: FileWvIn( unsigned long chunkThreshold, unsigned long chunkSize )
  : finished_(true), interpolate_(false), time_(0.0), rate_(0.0),
    chunkThreshold_(chunkThreshold), chunkSize_(chunkSize)
{
  Stk::addSampleRateAlert( this );
}

FileWvIn :: FileWvIn( std::string fileName, bool raw, bool doNormalize,
                      unsigned long chunkThreshold, unsigned long chunkSize )
  : finished_(true), interpolate_(false), time_(0.0), rate_(0.0),
    chunkThreshold_(chunkThreshold), chunkSize_(chunkSize)
{
  openFile( fileName, raw, doNormalize );
  Stk::addSampleRateAlert( this );
}

FileWvIn :: ~FileWvIn()
{
  this->closeFile();
  Stk::removeSampleRateAlert( this );
}

void FileWvIn :: sampleRateChanged( StkFloat newRate, StkFloat oldRate )
{
  if ( !ignoreSampleRateChange_ )
    this->setRate( oldRate * rate_ / newRate );
}

void FileWvIn :: closeFile( void )
{
  if ( file_.isOpen() ) file_.close();
  finished_ = true;
  lastFrame_.resize( 0, 0 );
}

void FileWvIn :: openFile( std::string fileName, bool raw, bool doNormalize )
{
  // Call close() in case another file is already open.
  this->closeFile();

  // Attempt to open the file ... an error might be thrown here.
  file_.open( fileName, raw );

  // Determine whether chunking or not.
  if ( file_.fileSize() > chunkThreshold_ ) {
    chunking_ = true;
    chunkPointer_ = 0;
    data_.resize( chunkSize_, file_.channels() );
    if ( doNormalize ) normalizing_ = true;
    else normalizing_ = false;
  }
  else {
    chunking_ = false;
    data_.resize( (size_t) file_.fileSize(), file_.channels() );
  }

  // Load all or part of the data.
  file_.read( data_, 0, doNormalize );

  // Resize our lastFrame container.
  lastFrame_.resize( 1, file_.channels() );

  // Close the file unless chunking
  fileSize_ = file_.fileSize();
  if ( !chunking_ ) file_.close();

  // Set default rate based on file sampling rate.
  this->setRate( data_.dataRate() / Stk::sampleRate() );

  if ( doNormalize & !chunking_ ) this->normalize();

  this->reset();
}

void FileWvIn :: reset(void)
{
  time_ = (StkFloat) 0.0;
  for ( unsigned int i=0; i<lastFrame_.size(); i++ ) lastFrame_[i] = 0.0;
  finished_ = false;
}

void FileWvIn :: normalize(void)
{
  this->normalize( 1.0 );
}

// Normalize all channels equally by the greatest magnitude in all of the data.
void FileWvIn :: normalize( StkFloat peak )
{
  // When chunking, the "normalization" scaling is performed by FileRead.
  if ( chunking_ ) return;

  size_t i;
  StkFloat max = 0.0;

  for ( i=0; i<data_.size(); i++ ) {
    if ( fabs( data_[i] ) > max )
      max = (StkFloat) fabs((double) data_[i]);
  }

  if ( max > 0.0 ) {
    max = 1.0 / max;
    max *= peak;
    for ( i=0; i<data_.size(); i++ )
      data_[i] *= max;
  }
}

void FileWvIn :: setRate( StkFloat rate )
{
  rate_ = rate;

  // If negative rate and at beginning of sound, move pointer to end
  // of sound.
  if ( (rate_ < 0) && (time_ == 0.0) ) time_ = fileSize_ - 1.0;

  if ( fmod( rate_, 1.0 ) != 0.0 ) interpolate_ = true;
  else interpolate_ = false;
}

void FileWvIn :: addTime( StkFloat time )   
{
  // Add an absolute time in samples 
  time_ += time;

  if ( time_ < 0.0 ) time_ = 0.0;
  if ( time_ > fileSize_ - 1.0 ) {
    time_ = fileSize_ - 1.0;
    for ( unsigned int i=0; i<lastFrame_.size(); i++ ) lastFrame_[i] = 0.0;
    finished_ = true;
  }
}

StkFloat FileWvIn :: tick( unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= data_.channels() ) {
    oStream_ << "FileWvIn::tick(): channel argument and soundfile data are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  if ( finished_ ) return 0.0;

  if ( time_ < 0.0 || time_ > (StkFloat) ( fileSize_ - 1.0 ) ) {
    for ( unsigned int i=0; i<lastFrame_.size(); i++ ) lastFrame_[i] = 0.0;
    finished_ = true;
    return 0.0;
  }

  StkFloat tyme = time_;
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
        if ( chunkPointer_ + chunkSize_ > fileSize_ ) // at end of file
          chunkPointer_ = fileSize_ - chunkSize_;
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

StkFrames& FileWvIn :: tick( StkFrames& frames, unsigned int channel)
{
  if ( !file_.isOpen() ) {
#if defined(_STK_DEBUG_)
    oStream_ << "FileWvIn::tick(): no file data is loaded!";
    handleError( StkError::DEBUG_PRINT );
#endif
    return frames;
  }

  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "FileWvIn::tick(): channel and StkFrames arguments are incompatible!";
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
