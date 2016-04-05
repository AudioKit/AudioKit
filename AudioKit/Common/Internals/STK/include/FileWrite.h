#ifndef STK_FILEWRITE_H
#define STK_FILEWRITE_H

#include "Stk.h"

namespace stk {

/***************************************************/
/*! \class FileWrite
    \brief STK audio file output class.

    This class provides output support for various
    audio file formats.

    FileWrite writes samples to an audio file.  It supports
    multi-channel data.

    FileWrite currently supports uncompressed WAV, AIFF, AIFC, SND
    (AU), MAT-file (Matlab), and STK RAW file formats.  Signed integer
    (8-, 16-, 24-, and 32-bit) and floating- point (32- and 64-bit)
    data types are supported.  STK RAW files use 16-bit integers by
    definition.  MAT-files will always be written as 64-bit floats.
    If a data type specification does not match the specified file
    type, the data type will automatically be modified.  Compressed
    data types are not supported.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class FileWrite : public Stk
{
 public:

  typedef unsigned long FILE_TYPE;

  static const FILE_TYPE FILE_RAW; /*!< STK RAW file type. */
  static const FILE_TYPE FILE_WAV; /*!< WAV file type. */
  static const FILE_TYPE FILE_SND; /*!< SND (AU) file type. */
  static const FILE_TYPE FILE_AIF; /*!< AIFF file type. */
  static const FILE_TYPE FILE_MAT; /*!< Matlab MAT-file type. */

  //! Default constructor.
  FileWrite( void );

  //! Overloaded constructor used to specify a file name, type, and data format with this object.
  /*!
    An StkError is thrown for invalid argument values or if an error occurs when initializing the output file.
  */
  FileWrite( std::string fileName, unsigned int nChannels = 1, FILE_TYPE type = FILE_WAV, Stk::StkFormat format = STK_SINT16 );

  //! Class destructor.
  virtual ~FileWrite();

  //! Create a file of the specified type and name and output samples to it in the given data format.
  /*!
    An StkError is thrown for invalid argument values or if an error occurs when initializing the output file.
  */
  void open( std::string fileName, unsigned int nChannels = 1,
             FileWrite::FILE_TYPE type = FILE_WAV, Stk::StkFormat format = STK_SINT16 );

  //! If a file is open, write out samples in the queue and then close it.
  void close( void );

  //! Returns \e true if a file is currently open.
  bool isOpen( void );

  //! Write sample frames from the StkFrames object to the file.
  /*!
    An StkError will be thrown if the number of channels in the
    StkFrames argument does not agree with the number of channels
    specified when opening the file.
   */
  void write( StkFrames& buffer );

 protected:

  // Write STK RAW file header.
  bool setRawFile( std::string fileName );

  // Write WAV file header.
  bool setWavFile( std::string fileName );

  // Close WAV file, updating the header.
  void closeWavFile( void );

  // Write SND (AU) file header.
  bool setSndFile( std::string fileName );

  // Close SND file, updating the header.
  void closeSndFile( void );

  // Write AIFF file header.
  bool setAifFile( std::string fileName );

  // Close AIFF file, updating the header.
  void closeAifFile( void );

  // Write MAT-file header.
  bool setMatFile( std::string fileName );

  // Close MAT-file, updating the header.
  void closeMatFile( void );

  FILE *fd_;
  FILE_TYPE fileType_;
  StkFormat dataType_;
  unsigned int channels_;
  unsigned long frameCounter_;
  bool byteswap_;

};

} // stk namespace

#endif
