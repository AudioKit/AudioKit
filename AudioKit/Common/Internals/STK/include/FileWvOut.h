#ifndef STK_FILEWVOUT_H
#define STK_FILEWVOUT_H

#include "WvOut.h"
#include "FileWrite.h"

namespace stk {

/***************************************************/
/*! \class FileWvOut
    \brief STK audio file output class.

    This class inherits from WvOut.  It provides a "tick-level"
    interface to the FileWrite class.

    FileWvOut writes samples to an audio file and supports
    multi-channel data.  It is important to distinguish the tick()
    method that outputs a single sample to all channels in a sample
    frame from the overloaded one that takes a reference to an
    StkFrames object for multi-channel and/or multi-frame data.

    See the FileWrite class for a description of the supported audio
    file formats.

    Currently, FileWvOut is non-interpolating and the output rate is
    always Stk::sampleRate().

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class FileWvOut : public WvOut
{
 public:

  //! Default constructor with optional output buffer size argument.
  /*!
    The output buffer size defines the number of frames that are
    accumulated between writes to disk.
  */
  FileWvOut( unsigned int bufferFrames = 1024 );

  //! Overloaded constructor used to specify a file name, type, and data format with this object.
  /*!
    An StkError is thrown for invalid argument values or if an error occurs when initializing the output file.
  */
  FileWvOut( std::string fileName,
             unsigned int nChannels = 1,
             FileWrite::FILE_TYPE type = FileWrite::FILE_WAV,
             Stk::StkFormat format = STK_SINT16,
             unsigned int bufferFrames = 1024 );

  //! Class destructor.
  virtual ~FileWvOut();

  //! Open a new file with the specified parameters.
  /*!
    If a file was previously open, it will be closed.  An StkError
    will be thrown if any of the specified arguments are invalid or a
    file error occurs during opening.
  */
  void openFile( std::string fileName,
                 unsigned int nChannels,
                 FileWrite::FILE_TYPE type,
                 Stk::StkFormat format );

  //! Close a file if one is open.
  /*!
    Any data remaining in the internal buffer will be written to
    the file before closing.
  */
  void closeFile( void );

  //! Output a single sample to all channels in a sample frame.
  /*!
    An StkError is thrown if an output error occurs.
  */
  void tick( const StkFloat sample );

  //! Output the StkFrames data.
  /*!
    An StkError will be thrown if an output error occurs.  An
    StkError will also be thrown if _STK_DEBUG_ is defined during
    compilation and there is an incompatability between the number of
    channels in the FileWvOut object and that in the StkFrames object.
  */
  void tick( const StkFrames& frames );

 protected:

  void incrementFrame( void );

  FileWrite file_;
  unsigned int bufferFrames_;
  unsigned int bufferIndex_;
  unsigned int iData_;

};

} // stk namespace

#endif
