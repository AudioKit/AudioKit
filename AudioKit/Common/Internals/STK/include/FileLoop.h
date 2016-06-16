#ifndef STK_FILELOOP_H
#define STK_FILELOOP_H

#include "FileWvIn.h"

namespace stk {

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

class FileLoop : protected FileWvIn
{
 public:
  //! Default constructor.
  FileLoop( unsigned long chunkThreshold = 1000000, unsigned long chunkSize = 1024 );

  //! Class constructor that opens a specified file.
  FileLoop( std::string fileName, bool raw = false, bool doNormalize = true,
            unsigned long chunkThreshold = 1000000, unsigned long chunkSize = 1024 );

  //! Class destructor.
  ~FileLoop( void );

  //! Open the specified file and load its data.
  /*!
    Data from a previously opened file will be overwritten by this
    function.  An StkError will be thrown if the file is not found,
    its format is unknown, or a read error occurs.  If the file data
    is to be loaded incrementally from disk and normalization is
    specified, a scaling will be applied with respect to fixed-point
    limits.  If the data format is floating-point, no scaling is
    performed.
  */
  void openFile( std::string fileName, bool raw = false, bool doNormalize = true );

  //! Close a file if one is open.
  void closeFile( void ) { FileWvIn::closeFile(); };

  //! Clear outputs and reset time (file) pointer to zero.
  void reset( void ) { FileWvIn::reset(); };

  //! Return the number of audio channels in the data or stream.
  unsigned int channelsOut( void ) const { return data_.channels(); };

  //! Normalize data to a maximum of +-1.0.
  /*!
    This function has no effect when data is incrementally loaded
    from disk.
  */
  void normalize( void ) { FileWvIn::normalize( 1.0 ); };

  //! Normalize data to a maximum of \e +-peak.
  /*!
    This function has no effect when data is incrementally loaded
    from disk.
  */
  void normalize( StkFloat peak ) { FileWvIn::normalize( peak ); };

  //! Return the file size in sample frames.
  unsigned long getSize( void ) const { return data_.frames(); };

  //! Return the input file sample rate in Hz (not the data read rate).
  /*!
    WAV, SND, and AIF formatted files specify a sample rate in
    their headers.  STK RAW files have a sample rate of 22050 Hz
    by definition.  MAT-files are assumed to have a rate of 44100 Hz.
  */
  StkFloat getFileRate( void ) const { return data_.dataRate(); };

  //! Set the data read rate in samples.  The rate can be negative.
  /*!
    If the rate value is negative, the data is read in reverse order.
  */
  void setRate( StkFloat rate );

  //! Set the data interpolation rate based on a looping frequency.
  /*!
    This function determines the interpolation rate based on the file
    size and the current Stk::sampleRate.  The \e frequency value
    corresponds to file cycles per second.  The frequency can be
    negative, in which case the loop is read in reverse order.
  */
  void setFrequency( StkFloat frequency ) { this->setRate( fileSize_ * frequency / Stk::sampleRate() ); };

  //! Increment the read pointer by \e time samples, modulo file size.
  void addTime( StkFloat time );

  //! Increment current read pointer by \e angle, relative to a looping frequency.
  /*!
    This function increments the read pointer based on the file
    size and the current Stk::sampleRate.  The \e anAngle value
    is a multiple of file size.
  */
  void addPhase( StkFloat angle );

  //! Add a phase offset to the current read pointer.
  /*!
    This function determines a time offset based on the file
    size and the current Stk::sampleRate.  The \e angle value
    is a multiple of file size.
  */
  void addPhaseOffset( StkFloat angle );

  //! Return the specified channel value of the last computed frame.
  /*!
    For multi-channel files, use the lastFrame() function to get
    all values from the last computed frame.  If no file data is
    loaded, the returned value is 0.0.  The \c channel argument must
    be less than the number of channels in the file data (the first
    channel is specified by 0).  However, range checking is only
    performed if _STK_DEBUG_ is defined during compilation, in which
    case an out-of-range value will trigger an StkError exception.
  */
  StkFloat lastOut( unsigned int channel = 0 ) { return FileWvIn::lastOut( channel ); };

  //! Compute a sample frame and return the specified \c channel value.
  /*!
    For multi-channel files, use the lastFrame() function to get
    all values from the computed frame.  If no file data is loaded,
    the returned value is 0.0.  The \c channel argument must be less
    than the number of channels in the file data (the first channel is
    specified by 0).  However, range checking is only performed if
    _STK_DEBUG_ is defined during compilation, in which case an
    out-of-range value will trigger an StkError exception.
  */
  StkFloat tick( unsigned int channel = 0 );

  //! Fill the StkFrames object with computed sample frames, starting at the specified channel and return the same reference.
  /*!
    The \c channel argument plus the number of output channels must
    be less than the number of channels in the StkFrames argument (the
    first channel is specified by 0).  However, range checking is only
    performed if _STK_DEBUG_ is defined during compilation, in which
    case an out-of-range value will trigger an StkError exception.
  */
  virtual StkFrames& tick( StkFrames& frames,unsigned int channel = 0 );

 protected:

  StkFrames firstFrame_;
  StkFloat phaseOffset_;

};

} // stk namespace

#endif
