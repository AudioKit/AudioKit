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

#include "FileWrite.h"
#include <string>
#include <cstdio>
#include <cstring>
#include <cmath>

namespace stk {

const FileWrite::FILE_TYPE FileWrite :: FILE_RAW = 1;
const FileWrite::FILE_TYPE FileWrite :: FILE_WAV = 2;
const FileWrite::FILE_TYPE FileWrite :: FILE_SND = 3;
const FileWrite::FILE_TYPE FileWrite :: FILE_AIF = 4;
const FileWrite::FILE_TYPE FileWrite :: FILE_MAT = 5;

// WAV header structure. See
// http://www-mmsp.ece.mcgill.ca/documents/audioformats/WAVE/Docs/rfc2361.txt
// for information regarding format codes.
struct WaveHeader {
  char riff[4];           // "RIFF"
  SINT32 fileSize;        // in bytes
  char wave[4];           // "WAVE"
  char fmt[4];            // "fmt "
  SINT32 chunkSize;       // in bytes (16 for PCM)
  SINT16 formatCode;      // 1=PCM, 2=ADPCM, 3=IEEE float, 6=A-Law, 7=Mu-Law
  SINT16 nChannels;       // 1=mono, 2=stereo
  SINT32 sampleRate;
  SINT32 bytesPerSecond;
  SINT16 bytesPerSample;  // 2=16-bit mono, 4=16-bit stereo
  SINT16 bitsPerSample;
  SINT16 cbSize;          // size of extension
  SINT16 validBits;       // valid bits per sample
  SINT32 channelMask;     // speaker position mask
  char subformat[16];     // format code and GUID
  char fact[4];           // "fact"
  SINT32 factSize;        // fact chunk size
  SINT32 frames;          // sample frames
};

// SND (AU) header structure (NeXT and Sun).
struct SndHeader {
  char pref[4];
  SINT32 headerBytes;
  SINT32 dataBytes;
  SINT32 format;
  SINT32 sampleRate;
  SINT32 nChannels;
  char comment[16];
};

// AIFF/AIFC header structure ... only the part common to both
// formats.
struct AifHeader {
  char form[4];                // "FORM"
  SINT32 formSize;             // in bytes
  char aiff[4];                // "AIFF" or "AIFC"
  char comm[4];                // "COMM"
  SINT32 commSize;             // "COMM" chunk size (18 for AIFF, 24 for AIFC)
  SINT16 nChannels;            // number of channels
  unsigned long sampleFrames;  // sample frames of audio data
  SINT16 sampleSize;           // in bits
  unsigned char srate[10];     // IEEE 754 floating point format
};

struct AifSsnd {
  char ssnd[4];               // "SSND"
  SINT32 ssndSize;            // "SSND" chunk size
  unsigned long offset;       // data offset in data block (should be 0)
  unsigned long blockSize;    // not used by STK (should be 0)
};

// MAT-file 5 header structure.
struct MatHeader {
  char heading[124];   // Header text field
  SINT16 hff[2];       // Header flag fields
  SINT32 fs[16];       // Sample rate data element
  SINT32 adf[11];      // Array data format fields
  // There's more, but it's of variable length
};

FileWrite :: FileWrite()
  : fd_( 0 )
{
}

FileWrite::FileWrite( std::string fileName, unsigned int nChannels, FILE_TYPE type, Stk::StkFormat format )
  : fd_( 0 )
{
  this->open( fileName, nChannels, type, format );
}

FileWrite :: ~FileWrite()
{
  this->close();
}

void FileWrite :: close( void )
{
  if ( fd_ == 0 ) return;

  if ( fileType_ == FILE_RAW )
    fclose( fd_ );
  else if ( fileType_ == FILE_WAV )
    this->closeWavFile();
  else if ( fileType_ == FILE_SND )
    this->closeSndFile();
  else if ( fileType_ == FILE_AIF )
    this->closeAifFile();
  else if ( fileType_ == FILE_MAT )
    this->closeMatFile();

  fd_ = 0;
}

bool FileWrite :: isOpen( void )
{
  if ( fd_ ) return true;
  else return false;
}

void FileWrite :: open( std::string fileName, unsigned int nChannels, FileWrite::FILE_TYPE type, Stk::StkFormat format )
{
  // Call close() in case another file is already open.
  this->close();

  if ( nChannels < 1 ) {
    oStream_ << "FileWrite::open: then channels argument must be greater than zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  channels_ = nChannels;
  fileType_ = type;

  if ( format != STK_SINT8 && format != STK_SINT16 &&
       format != STK_SINT24 && format != STK_SINT32 &&
       format != STK_FLOAT32 && format != STK_FLOAT64 ) {
    oStream_ << "FileWrite::open: unknown data type (" << format << ") specified!";
    handleError( StkError::FUNCTION_ARGUMENT );
  } 
  dataType_ = format;

  bool result = false;
  if ( fileType_ == FILE_RAW ) {
    if ( channels_ != 1 ) {
      oStream_ << "FileWrite::open: STK RAW files are, by definition, always monaural (channels = " << nChannels << " not supported)!";
      handleError( StkError::FUNCTION_ARGUMENT );
    }
    result = setRawFile( fileName );
  }
  else if ( fileType_ == FILE_WAV )
    result = setWavFile( fileName );
  else if ( fileType_ == FILE_SND )
    result = setSndFile( fileName );
  else if ( fileType_ == FILE_AIF )
    result = setAifFile( fileName );
  else if ( fileType_ == FILE_MAT )
    result = setMatFile( fileName );
  else {
    oStream_ << "FileWrite::open: unknown file type (" << fileType_ << ") specified!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  if ( result == false )
    handleError( StkError::FILE_ERROR );

  frameCounter_ = 0;
}

bool FileWrite :: setRawFile( std::string fileName )
{
  if ( fileName.find( ".raw" ) == std::string::npos ) fileName += ".raw";
  fd_ = fopen( fileName.c_str(), "wb" );
  if ( !fd_ ) {
    oStream_ << "FileWrite: could not create RAW file: " << fileName << '.';
    return false;
  }

  if ( dataType_ != STK_SINT16 ) {
    dataType_ = STK_SINT16;
    oStream_ << "FileWrite: using 16-bit signed integer data format for file " << fileName << '.';
    handleError( StkError::WARNING );
  }

  byteswap_ = false;
#ifdef __LITTLE_ENDIAN__
  byteswap_ = true;
#endif

  oStream_ << "FileWrite: creating RAW file: " << fileName;
  handleError( StkError::STATUS );
  return true;
}

bool FileWrite :: setWavFile( std::string fileName )
{
  if ( fileName.find( ".wav" ) == std::string::npos ) fileName += ".wav";
  fd_ = fopen( fileName.c_str(), "wb" );
  if ( !fd_ ) {
    oStream_ << "FileWrite: could not create WAV file: " << fileName;
    return false;
  }

  struct WaveHeader hdr = { {'R','I','F','F'}, 44, {'W','A','V','E'}, {'f','m','t',' '}, 16, 1, 1,
                            (SINT32) Stk::sampleRate(), 0, 2, 16, 0, 0, 0, 
                            {'\x01','\x00','\x00','\x00','\x00','\x00','\x10','\x00','\x80','\x00','\x00','\xAA','\x00','\x38','\x9B','\x71'},
                            {'f','a','c','t'}, 4, 0 };
  hdr.nChannels = (SINT16) channels_;
  if ( dataType_ == STK_SINT8 )
    hdr.bitsPerSample = 8;
  else if ( dataType_ == STK_SINT16 )
    hdr.bitsPerSample = 16;
  else if ( dataType_ == STK_SINT24 )
    hdr.bitsPerSample = 24;
  else if ( dataType_ == STK_SINT32 )
    hdr.bitsPerSample = 32;
  else if ( dataType_ == STK_FLOAT32 ) {
    hdr.formatCode = 3;
    hdr.bitsPerSample = 32;
  }
  else if ( dataType_ == STK_FLOAT64 ) {
    hdr.formatCode = 3;
    hdr.bitsPerSample = 64;
  }
  hdr.bytesPerSample = (SINT16) (channels_ * hdr.bitsPerSample / 8);
  hdr.bytesPerSecond = (SINT32) (hdr.sampleRate * hdr.bytesPerSample);

  unsigned int bytesToWrite = 36;
  if ( channels_ > 2 || hdr.bitsPerSample > 16 ) { // use extensible format
    bytesToWrite = 72;
    hdr.chunkSize += 24;
    hdr.formatCode = 0xFFFE;
    hdr.cbSize = 22;
    hdr.validBits = hdr.bitsPerSample;
    SINT16 *subFormat = (SINT16 *)&hdr.subformat[0];
    if ( dataType_ == STK_FLOAT32 || dataType_ == STK_FLOAT64 )
      *subFormat = 3;
    else *subFormat = 1;
  }

  byteswap_ = false;
#ifndef __LITTLE_ENDIAN__
  byteswap_ = true;
  swap32((unsigned char *)&hdr.chunkSize);
  swap16((unsigned char *)&hdr.formatCode);
  swap16((unsigned char *)&hdr.nChannels);
  swap32((unsigned char *)&hdr.sampleRate);
  swap32((unsigned char *)&hdr.bytesPerSecond);
  swap16((unsigned char *)&hdr.bytesPerSample);
  swap16((unsigned char *)&hdr.bitsPerSample);
  swap16((unsigned char *)&hdr.cbSize);
  swap16((unsigned char *)&hdr.validBits);
  swap16((unsigned char *)&hdr.subformat[0]);
  swap32((unsigned char *)&hdr.factSize);
#endif

  char data[4] = {'d','a','t','a'};
  SINT32 dataSize = 0;
  if ( fwrite(&hdr, 1, bytesToWrite, fd_) != bytesToWrite ) goto error;
  if ( fwrite(&data, 4, 1, fd_) != 1 ) goto error;
  if ( fwrite(&dataSize, 4, 1, fd_) != 1 ) goto error;

  oStream_ << "FileWrite: creating WAV file: " << fileName;
  handleError( StkError::STATUS );
  return true;

 error:
  oStream_ << "FileWrite: could not write WAV header for file: " << fileName;
  return false;
}

void FileWrite :: closeWavFile( void )
{
  int bytesPerSample = 1;
  if ( dataType_ == STK_SINT16 )
    bytesPerSample = 2;
  else if ( dataType_ == STK_SINT24 )
    bytesPerSample = 3;
  else if ( dataType_ == STK_SINT32 || dataType_ == STK_FLOAT32 )
    bytesPerSample = 4;
  else if ( dataType_ == STK_FLOAT64 )
    bytesPerSample = 8;

  bool useExtensible = false;
  int dataLocation = 40;
  if ( bytesPerSample > 2 || channels_ > 2 ) {
    useExtensible = true;
    dataLocation = 76;
  }

  SINT32 bytes = (SINT32) (frameCounter_ * channels_ * bytesPerSample);
  if ( bytes % 2 ) { // pad extra byte if odd
    signed char sample = 0;
    fwrite( &sample, 1, 1, fd_ );
  }
#ifndef __LITTLE_ENDIAN__
  swap32((unsigned char *)&bytes);
#endif
  fseek( fd_, dataLocation, SEEK_SET ); // jump to data length
  fwrite( &bytes, 4, 1, fd_ );

  bytes = (SINT32) (frameCounter_ * channels_ * bytesPerSample + 44);
  if ( useExtensible ) bytes += 36;
#ifndef __LITTLE_ENDIAN__
  swap32((unsigned char *)&bytes);
#endif
  fseek( fd_, 4, SEEK_SET ); // jump to file size
  fwrite( &bytes, 4, 1, fd_ );

  if ( useExtensible ) { // fill in the "fact" chunk frames value
    bytes = (SINT32) frameCounter_;
#ifndef __LITTLE_ENDIAN__
    swap32((unsigned char *)&bytes);
#endif
    fseek( fd_, 68, SEEK_SET );
    fwrite( &bytes, 4, 1, fd_ );
  }

  fclose( fd_ );
}

bool FileWrite :: setSndFile( std::string fileName )
{
  std::string name( fileName );
  if ( fileName.find( ".snd" ) == std::string::npos ) fileName += ".snd";
  fd_ = fopen( fileName.c_str(), "wb" );
  if ( !fd_ ) {
    oStream_ << "FileWrite: could not create SND file: " << fileName;
    return false;
  }

  struct SndHeader hdr = {".sn", 40, 0, 3, (SINT32) Stk::sampleRate(), 1, "Created by STK"};
  hdr.pref[3] = 'd';
  hdr.nChannels = channels_;
  if ( dataType_ == STK_SINT8 )
    hdr.format = 2;
  else if ( dataType_ == STK_SINT16 )
    hdr.format = 3;
  else if ( dataType_ == STK_SINT24 )
    hdr.format = 4;
  else if ( dataType_ == STK_SINT32 )
    hdr.format = 5;
  else if ( dataType_ == STK_FLOAT32 )
    hdr.format = 6;
  else if ( dataType_ == STK_FLOAT64 )
    hdr.format = 7;

  byteswap_ = false;
#ifdef __LITTLE_ENDIAN__
  byteswap_ = true;
  swap32 ((unsigned char *)&hdr.headerBytes);
  swap32 ((unsigned char *)&hdr.format);
  swap32 ((unsigned char *)&hdr.sampleRate);
  swap32 ((unsigned char *)&hdr.nChannels);
#endif

  if ( fwrite(&hdr, 4, 10, fd_) != 10 ) {
    oStream_ << "FileWrite: Could not write SND header for file " << fileName << '.';
    return false;
  }

  oStream_ << "FileWrite: creating SND file: " << fileName;
  handleError( StkError::STATUS );
  return true;
}

void FileWrite :: closeSndFile( void )
{
  int bytesPerSample = 1;
  if ( dataType_ == STK_SINT16 )
    bytesPerSample = 2;
  else if ( dataType_ == STK_SINT24 )
    bytesPerSample = 3;
  else if ( dataType_ == STK_SINT32 )
    bytesPerSample = 4;
  else if ( dataType_ == STK_FLOAT32 )
    bytesPerSample = 4;
  else if ( dataType_ == STK_FLOAT64 )
    bytesPerSample = 8;

  SINT32 bytes = (SINT32) (frameCounter_ * bytesPerSample * channels_);
#ifdef __LITTLE_ENDIAN__
  swap32 ((unsigned char *)&bytes);
#endif
  fseek(fd_, 8, SEEK_SET); // jump to data size
  fwrite(&bytes, 4, 1, fd_);
  fclose(fd_);
}

bool FileWrite :: setAifFile( std::string fileName )
{
  std::string name( fileName );
  if ( fileName.find( ".aif" ) == std::string::npos ) fileName += ".aif";
  fd_ = fopen( fileName.c_str(), "wb" );
  if ( !fd_ ) {
    oStream_ << "FileWrite: could not create AIF file: " << fileName;
    return false;
  }

  // Common parts of AIFF/AIFC header.
  struct AifHeader hdr = {{'F','O','R','M'}, 46, {'A','I','F','F'}, {'C','O','M','M'}, 18, 0, 0, 16, "0"};
  struct AifSsnd ssnd = {{'S','S','N','D'}, 8, 0, 0};
  hdr.nChannels = channels_;
  if ( dataType_ == STK_SINT8 )
    hdr.sampleSize = 8;
  else if ( dataType_ == STK_SINT16 )
    hdr.sampleSize = 16;
  else if ( dataType_ == STK_SINT24 )
    hdr.sampleSize = 24;
  else if ( dataType_ == STK_SINT32 )
    hdr.sampleSize = 32;
  else if ( dataType_ == STK_FLOAT32 ) {
    hdr.aiff[3] = 'C';
    hdr.sampleSize = 32;
    hdr.commSize = 24;
  }
  else if ( dataType_ == STK_FLOAT64 ) {
    hdr.aiff[3] = 'C';
    hdr.sampleSize = 64;
    hdr.commSize = 24;
  }

  // For AIFF files, the sample rate is stored in a 10-byte,
  // IEEE Standard 754 floating point number, so we need to
  // convert to that.
  SINT16 i;
  unsigned long exp;
  unsigned long rate = (unsigned long) Stk::sampleRate();
  memset( hdr.srate, 0, 10 );
  exp = rate;
  for ( i=0; i<32; i++ ) {
    exp >>= 1;
    if ( !exp ) break;
  }
  i += 16383;
#ifdef __LITTLE_ENDIAN__
  swap16((unsigned char *)&i);
#endif
  memcpy( hdr.srate, &i, sizeof(SINT16) );

  for ( i=32; i; i-- ) {
    if ( rate & 0x80000000 ) break;
    rate <<= 1;
  }

#ifdef __LITTLE_ENDIAN__
  swap32((unsigned char *)&rate);
#endif
  memcpy( hdr.srate + 2, &rate, sizeof(rate) );

  byteswap_ = false;  
#ifdef __LITTLE_ENDIAN__
  byteswap_ = true;
  swap32((unsigned char *)&hdr.formSize);
  swap32((unsigned char *)&hdr.commSize);
  swap16((unsigned char *)&hdr.nChannels);
  swap16((unsigned char *)&hdr.sampleSize);
  swap32((unsigned char *)&ssnd.ssndSize);
  swap32((unsigned char *)&ssnd.offset);
  swap32((unsigned char *)&ssnd.blockSize);
#endif

  // The structure boundaries don't allow a single write of 54 bytes.
  if ( fwrite(&hdr, 4, 5, fd_) != 5 ) goto error;
  if ( fwrite(&hdr.nChannels, 2, 1, fd_) != 1 ) goto error;
  if ( fwrite(&hdr.sampleFrames, 4, 1, fd_) != 1 ) goto error;
  if ( fwrite(&hdr.sampleSize, 2, 1, fd_) != 1 ) goto error;
  if ( fwrite(&hdr.srate, 10, 1, fd_) != 1 ) goto error;

  if ( dataType_ == STK_FLOAT32 ) {
    char type[4] = {'f','l','3','2'};
    char zeroes[2] = { 0, 0 };
    if ( fwrite(&type, 4, 1, fd_) != 1 ) goto error;
    if ( fwrite(&zeroes, 2, 1, fd_) != 1 ) goto error;
  }
  else if ( dataType_ == STK_FLOAT64 ) {
    char type[4] = {'f','l','6','4'};
    char zeroes[2] = { 0, 0 };
    if ( fwrite(&type, 4, 1, fd_) != 1 ) goto error;
    if ( fwrite(&zeroes, 2, 1, fd_) != 1 ) goto error;
  }
  
  if ( fwrite(&ssnd, 4, 4, fd_) != 4 ) goto error;

  oStream_ << "FileWrite: creating AIF file: " << fileName;
  handleError( StkError::STATUS );
  return true;

 error:
  oStream_ << "FileWrite: could not write AIF header for file: " << fileName;
  return false;
}

void FileWrite :: closeAifFile( void )
{
  unsigned long frames = (unsigned long) frameCounter_;
#ifdef __LITTLE_ENDIAN__
  swap32((unsigned char *)&frames);
#endif
  fseek(fd_, 22, SEEK_SET); // jump to "COMM" sampleFrames
  fwrite(&frames, 4, 1, fd_);

  int bytesPerSample = 1;
  if ( dataType_ == STK_SINT16 )
    bytesPerSample = 2;
  if ( dataType_ == STK_SINT24 )
    bytesPerSample = 3;
  else if ( dataType_ == STK_SINT32 || dataType_ == STK_FLOAT32 )
    bytesPerSample = 4;
  else if ( dataType_ == STK_FLOAT64 )
    bytesPerSample = 8;

  unsigned long bytes = frameCounter_ * bytesPerSample * channels_ + 46;
  if ( dataType_ == STK_FLOAT32 || dataType_ == STK_FLOAT64 ) bytes += 6;
#ifdef __LITTLE_ENDIAN__
  swap32((unsigned char *)&bytes);
#endif
  fseek(fd_, 4, SEEK_SET); // jump to file size
  fwrite(&bytes, 4, 1, fd_);

  bytes = frameCounter_ * bytesPerSample * channels_ + 8;
  if ( dataType_ == STK_FLOAT32 || dataType_ == STK_FLOAT64 ) bytes += 6;
#ifdef __LITTLE_ENDIAN__
  swap32((unsigned char *)&bytes);
#endif
  if ( dataType_ == STK_FLOAT32 || dataType_ == STK_FLOAT64 )
    fseek(fd_, 48, SEEK_SET); // jump to "SSND" chunk size
  else
    fseek(fd_, 42, SEEK_SET); // jump to "SSND" chunk size
  fwrite(&bytes, 4, 1, fd_);

  fclose( fd_ );
}

bool FileWrite :: setMatFile( std::string fileName )
{
  if ( fileName.find( ".mat" ) == std::string::npos ) fileName += ".mat";
  fd_ = fopen( fileName.c_str(), "w+b" );
  if ( !fd_ ) {
    oStream_ << "FileWrite: could not create MAT file: " << fileName;
    return false;
  }

  if ( dataType_ != STK_FLOAT64 ) {
    dataType_ = STK_FLOAT64;
    oStream_ << "FileWrite: using 64-bit floating-point data format for file " << fileName << '.';
    handleError( StkError::DEBUG_PRINT );
  }

  struct MatHeader hdr;
  strcpy( hdr.heading,"MATLAB 5.0 MAT-file, Generated using the Synthesis ToolKit in C++ (STK). By Perry R. Cook and Gary P. Scavone." );
  for ( size_t i =strlen(hdr.heading); i<124; i++ ) hdr.heading[i] = ' ';

  // Header Flag Fields
  hdr.hff[0] = (SINT16) 0x0100;   // Version field
  hdr.hff[1] = (SINT16) 'M';      // Endian indicator field ("MI")
  hdr.hff[1] <<= 8;
  hdr.hff[1] += 'I';

  // Write sample rate in array data element
  hdr.fs[0] = (SINT32) 14;       // Matlab array data type value
  hdr.fs[1] = (SINT32) 56;        // Size of data element to follow (in bytes)

  // Numeric Array Subelements (4):
  // 1. Array Flags
  hdr.fs[2] = (SINT32) 6;     // Matlab 32-bit unsigned integer data type value
  hdr.fs[3] = (SINT32) 8;     // 8 bytes of data to follow
  hdr.fs[4] = (SINT32) 6;     // Double-precision array, no array flags set
  hdr.fs[5] = (SINT32) 0;     // 4 bytes undefined
  // 2. Array Dimensions
  hdr.fs[6] = (SINT32) 5;     // Matlab 32-bit signed integer data type value
  hdr.fs[7] = (SINT32) 8;     // 8 bytes of data to follow (2D array)
  hdr.fs[8] = (SINT32) 1;     // 1 row
  hdr.fs[9] = (SINT32) 1;     // 1 column
  // 3. Array Name (small data format element)
  hdr.fs[10] = 0x00020001;
  hdr.fs[11] = 's' << 8;
  hdr.fs[11] += 'f';
  // 4. Real Part
  hdr.fs[12] = 9;             // Matlab IEEE 754 double data type
  hdr.fs[13] = 8;             // 8 bytes of data to follow
  FLOAT64 *sampleRate = (FLOAT64 *)&hdr.fs[14];
  *sampleRate = (FLOAT64) Stk::sampleRate();

  // Write audio samples in array data element
  hdr.adf[0] = (SINT32) 14;       // Matlab array data type value
  hdr.adf[1] = (SINT32) 0;        // Size of file after this point to end (in bytes)

  // Numeric Array Subelements (4):
  // 1. Array Flags
  hdr.adf[2] = (SINT32) 6;        // Matlab 32-bit unsigned integer data type value
  hdr.adf[3] = (SINT32) 8;        // 8 bytes of data to follow
  hdr.adf[4] = (SINT32) 6;        // Double-precision array, no array flags set
  hdr.adf[5] = (SINT32) 0;        // 4 bytes undefined
  // 2. Array Dimensions
  hdr.adf[6] = (SINT32) 5;        // Matlab 32-bit signed integer data type value
  hdr.adf[7] = (SINT32) 8;        // 8 bytes of data to follow (2D array)
  hdr.adf[8] = (SINT32) channels_; // This is the number of rows
  hdr.adf[9] = (SINT32) 0;        // This is the number of columns

  // 3. Array Name We'll use fileName for the matlab array name (as
  // well as the file name), though we might need to strip off a
  // leading directory path.  If fileName is 4 characters or less, we
  // have to use a small data format element for the array name data
  // element.  Otherwise, the array name must be formatted in 8-byte
  // increments (up to 31 characters + NULL).
  std::string name = fileName;
  size_t found;
  found = name.find_last_of("/\\");
  name = name.substr(found+1);
  SINT32 namelength = (SINT32) name.size() - 4; // strip off the ".mat" extension
  if ( namelength > 31 ) namelength = 31; // Truncate name to 31 characters.
  if ( namelength > 4 ) {
    hdr.adf[10] = (SINT32) 1;        // Matlab 8-bit signed integer data type value
  }
  else { // Compressed data element format
    hdr.adf[10] = (namelength << 16) + 1;
  }

  SINT32 headsize = 40;        // Number of bytes in audio data element so far.

  // Write the fixed portion of the header
  if ( fwrite(&hdr, 236, 1, fd_) != 1 ) goto error;

  // Write MATLAB array name
  SINT32 tmp;
  if ( namelength > 4 ) {
    if ( fwrite(&namelength, 4, 1, fd_) != 1) goto error;
    if ( fwrite(name.c_str(), namelength, 1, fd_) != 1 ) goto error;
    tmp = (SINT32) ceil((float)namelength / 8);
    if ( fseek(fd_, tmp*8-namelength, SEEK_CUR) == -1 ) goto error;
    headsize += tmp * 8;
  }
  else { // Compressed data element format
    if ( fwrite(name.c_str(), namelength, 1, fd_) != 1 ) goto error;
    tmp = 4 - namelength;
    if ( fseek(fd_, tmp, SEEK_CUR) == -1 ) goto error;
  }

  // Finish writing known header information
  //4. Real Part
  tmp = 9;        // Matlab IEEE 754 double data type
  if ( fwrite(&tmp, 4, 1, fd_) != 1 ) goto error;
  tmp = 0;        // Size of real part subelement in bytes (8 per sample)
  if ( fwrite(&tmp, 4, 1, fd_) != 1 ) goto error;
  headsize += 8;  // Total number of bytes in data element so far

  if ( fseek(fd_, 196, SEEK_SET) == -1 ) goto error;
  if ( fwrite(&headsize, 4, 1, fd_) != 1 ) goto error; // Write header size ... will update at end
  if ( fseek(fd_, 0, SEEK_END) == -1 ) goto error;

  byteswap_ = false;
  oStream_ << "FileWrite: creating MAT-file: " << fileName;
  handleError( StkError::STATUS );

  return true;

 error:
  oStream_ << "FileWrite: could not write MAT-file header for file " << fileName << '.';
  return false;
}

void FileWrite :: closeMatFile( void )
{
  fseek(fd_, 228, SEEK_SET); // jump to number of columns
  fwrite(&frameCounter_, 4, 1, fd_);

  SINT32 headsize, temp;
  fseek(fd_, 196, SEEK_SET);  // jump to header size
  if (fread(&headsize, 4, 1, fd_) < 4) {
      oStream_ << "FileWrite: could not read MAT-file header size.";
      goto close_file;
  }

  temp = headsize;
  headsize += (SINT32) (frameCounter_ * 8 * channels_);
  fseek(fd_, 196, SEEK_SET);
  // Write file size (minus some header info)
  fwrite(&headsize, 4, 1, fd_);

  fseek(fd_, temp+196, SEEK_SET); // jumpt to data size (in bytes)
  temp = (SINT32) (frameCounter_ * 8 * channels_);
  fwrite(&temp, 4, 1, fd_);

close_file:
  fclose(fd_);
}

void FileWrite :: write( StkFrames& buffer )
{
  if ( fd_ == 0 ) {
    oStream_ << "FileWrite::write(): a file has not yet been opened!";
    handleError( StkError::WARNING );
    return;
  }

  if ( buffer.channels() != channels_ ) {
    oStream_ << "FileWrite::write(): number of channels in the StkFrames argument does not match that specified to open() function!";
    handleError( StkError::FUNCTION_ARGUMENT );
    return;
  }

  unsigned long nSamples = buffer.size();
  if ( dataType_ == STK_SINT16 ) {
    SINT16 sample;
    for ( unsigned long k=0; k<nSamples; k++ ) {
      sample = (SINT16) (buffer[k] * 32767.0);
      //sample = ((SINT16) (( buffer[k] + 1.0 ) * 32767.5 + 0.5)) - 32768;
      if ( byteswap_ ) swap16( (unsigned char *)&sample );
      if ( fwrite(&sample, 2, 1, fd_) != 1 ) goto error;
    }
  }
  else if ( dataType_ == STK_SINT8 ) {
    if ( fileType_ == FILE_WAV ) { // 8-bit WAV data is unsigned!
      unsigned char sample;
      for ( unsigned long k=0; k<nSamples; k++ ) {
        sample = (unsigned char) (buffer[k] * 127.0 + 128.0);
        if ( fwrite(&sample, 1, 1, fd_) != 1 ) goto error;
      }
    }
    else {
      signed char sample;
      for ( unsigned long k=0; k<nSamples; k++ ) {
        sample = (signed char) (buffer[k] * 127.0);
        //sample = ((signed char) (( buffer[k] + 1.0 ) * 127.5 + 0.5)) - 128;
        if ( fwrite(&sample, 1, 1, fd_) != 1 ) goto error;
      }
    }
  }
  else if ( dataType_ == STK_SINT32 ) {
    SINT32 sample;
    for ( unsigned long k=0; k<nSamples; k++ ) {
      sample = (SINT32) (buffer[k] * 2147483647.0);
      //sample = ((SINT32) (( buffer[k] + 1.0 ) * 2147483647.5 + 0.5)) - 2147483648;
      if ( byteswap_ ) swap32( (unsigned char *)&sample );
      if ( fwrite(&sample, 4, 1, fd_) != 1 ) goto error;
    }
  }
  else if ( dataType_ == STK_FLOAT32 ) {
    FLOAT32 sample;
    for ( unsigned long k=0; k<nSamples; k++ ) {
      sample = (FLOAT32) (buffer[k]);
      if ( byteswap_ ) swap32( (unsigned char *)&sample );
      if ( fwrite(&sample, 4, 1, fd_) != 1 ) goto error;
    }
  }
  else if ( dataType_ == STK_FLOAT64 ) {
    FLOAT64 sample;
    for ( unsigned long k=0; k<nSamples; k++ ) {
      sample = (FLOAT64) (buffer[k]);
      if ( byteswap_ ) swap64( (unsigned char *)&sample );
      if ( fwrite(&sample, 8, 1, fd_) != 1 ) goto error;
    }
  }
  else if ( dataType_ == STK_SINT24 ) {
    SINT32 sample;
    for ( unsigned long k=0; k<nSamples; k++ ) {
      sample = (SINT32) (buffer[k] * 8388607.0);
      if ( byteswap_ ) {
        swap32( (unsigned char *)&sample );
        unsigned char *ptr = (unsigned char *) &sample;
        if ( fwrite(ptr+1, 3, 1, fd_) != 1 ) goto error;
      }
      else
        if ( fwrite(&sample, 3, 1, fd_) != 1 ) goto error;
    }
  }

  frameCounter_ += buffer.frames();
  return;

 error:
  oStream_ << "FileWrite::write(): error writing data to file!";
  handleError( StkError::FILE_ERROR );
}

} // stk namespace
