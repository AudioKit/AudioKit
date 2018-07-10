// WAV audio loader and writer. Public domain. See "unlicense" statement at the end of this file.
// dr_wav - v0.7 - 2017-11-04
//
// David Reid - mackron@gmail.com

// USAGE
//
// This is a single-file library. To use it, do something like the following in one .c file.
//     #define DR_WAV_IMPLEMENTATION
//     #include "dr_wav.h"
//
// You can then #include this file in other parts of the program as you would with any other header file. Do something
// like the following to read audio data:
//
//     drwav wav;
//     if (!drwav_init_file(&wav, "my_song.wav")) {
//         // Error opening WAV file.
//     }
//
//     drwav_int32* pDecodedInterleavedSamples = malloc(wav.totalSampleCount * sizeof(drwav_int32));
//     size_t numberOfSamplesActuallyDecoded = drwav_read_s32(&wav, wav.totalSampleCount, pDecodedInterleavedSamples);
//
//     ...
//
//     drwav_uninit(&wav);
//
// You can also use drwav_open() to allocate and initialize the loader for you:
//
//     drwav* pWav = drwav_open_file("my_song.wav");
//     if (pWav == NULL) {
//         // Error opening WAV file.
//     }
//
//     ...
//
//     drwav_close(pWav);
//
// If you just want to quickly open and read the audio data in a single operation you can do something like this:
//
//     unsigned int channels;
//     unsigned int sampleRate;
//     drwav_uint64 totalSampleCount;
//     float* pSampleData = drwav_open_and_read_file_s32("my_song.wav", &channels, &sampleRate, &totalSampleCount);
//     if (pSampleData == NULL) {
//         // Error opening and reading WAV file.
//     }
//
//     ...
//
//     drwav_free(pSampleData);
//
// The examples above use versions of the API that convert the audio data to a consistent format (32-bit signed PCM, in
// this case), but you can still output the audio data in it's internal format (see notes below for supported formats):
//
//     size_t samplesRead = drwav_read(&wav, wav.totalSampleCount, pDecodedInterleavedSamples);
//
// You can also read the raw bytes of audio data, which could be useful if dr_wav does not have native support for
// a particular data format:
//
//     size_t bytesRead = drwav_read_raw(&wav, bytesToRead, pRawDataBuffer);
//
//
// dr_wav has seamless support the Sony Wave64 format. The decoder will automatically detect it and it should Just Work
// without any manual intervention.
//
//
// dr_wav can also be used to output WAV files. This does not currently support compressed formats. To use this, look at
// drwav_open_write(), drwav_open_file_write(), etc. Use drwav_write() to write samples, or drwav_write_raw() to write
// raw data in the "data" chunk.
//
//     drwav_data_format format;
//     format.container = drwav_container_riff;     // <-- drwav_container_riff = normal WAV files, drwav_container_w64 = Sony Wave64.
//     format.format = DR_WAVE_FORMAT_PCM;          // <-- Any of the DR_WAVE_FORMAT_* codes.
//     format.channels = 2;
//     format.sampleRate = 44100;
//     format.bitsPerSample = 16;
//     drwav* pWav = drwav_open_file_write("data/recording.wav", &format);
//
//     ...
//
//     drwav_uint64 samplesWritten = drwav_write(pWav, sampleCount, pSamples);
//
//
//
// OPTIONS
// #define these options before including this file.
//
// #define DR_WAV_NO_CONVERSION_API
//   Disables conversion APIs such as drwav_read_f32() and drwav_s16_to_f32().
//
// #define DR_WAV_NO_STDIO
//   Disables drwav_open_file(), drwav_open_file_write(), etc.
//
//
//
// QUICK NOTES
// - Samples are always interleaved.
// - The default read function does not do any data conversion. Use drwav_read_f32() to read and convert audio data
//   to IEEE 32-bit floating point samples, drwav_read_s32() to read samples as signed 32-bit PCM and drwav_read_s16()
//   to read samples as signed 16-bit PCM. Tested and supported internal formats include the following:
//   - Unsigned 8-bit PCM
//   - Signed 12-bit PCM
//   - Signed 16-bit PCM
//   - Signed 24-bit PCM
//   - Signed 32-bit PCM
//   - IEEE 32-bit floating point.
//   - IEEE 64-bit floating point.
//   - A-law and u-law
//   - Microsoft ADPCM
//   - IMA ADPCM (DVI, format code 0x11)
// - dr_wav will try to read the WAV file as best it can, even if it's not strictly conformant to the WAV format.


#ifndef dr_wav_h
#define dr_wav_h

#include <stddef.h>

#if defined(_MSC_VER) && _MSC_VER < 1600
typedef   signed char    drwav_int8;
typedef unsigned char    drwav_uint8;
typedef   signed short   drwav_int16;
typedef unsigned short   drwav_uint16;
typedef   signed int     drwav_int32;
typedef unsigned int     drwav_uint32;
typedef   signed __int64 drwav_int64;
typedef unsigned __int64 drwav_uint64;
#else
#include <stdint.h>
typedef int8_t           drwav_int8;
typedef uint8_t          drwav_uint8;
typedef int16_t          drwav_int16;
typedef uint16_t         drwav_uint16;
typedef int32_t          drwav_int32;
typedef uint32_t         drwav_uint32;
typedef int64_t          drwav_int64;
typedef uint64_t         drwav_uint64;
#endif
typedef drwav_uint8      drwav_bool8;
typedef drwav_uint32     drwav_bool32;
#define DRWAV_TRUE       1
#define DRWAV_FALSE      0

#ifdef __cplusplus
extern "C" {
#endif

// Common data formats.
#define DR_WAVE_FORMAT_PCM          0x1
#define DR_WAVE_FORMAT_ADPCM        0x2
#define DR_WAVE_FORMAT_IEEE_FLOAT   0x3
#define DR_WAVE_FORMAT_ALAW         0x6
#define DR_WAVE_FORMAT_MULAW        0x7
#define DR_WAVE_FORMAT_DVI_ADPCM    0x11
#define DR_WAVE_FORMAT_EXTENSIBLE   0xFFFE

typedef enum
{
    drwav_seek_origin_start,
    drwav_seek_origin_current
} drwav_seek_origin;

typedef enum
{
    drwav_container_riff,
    drwav_container_w64
} drwav_container;

// Callback for when data is read. Return value is the number of bytes actually read.
//
// pUserData   [in]  The user data that was passed to drwav_init(), drwav_open() and family.
// pBufferOut  [out] The output buffer.
// bytesToRead [in]  The number of bytes to read.
//
// Returns the number of bytes actually read.
//
// A return value of less than bytesToRead indicates the end of the stream. Do _not_ return from this callback until
// either the entire bytesToRead is filled or you have reached the end of the stream.
typedef size_t (* drwav_read_proc)(void* pUserData, void* pBufferOut, size_t bytesToRead);

// Callback for when data is written. Returns value is the number of bytes actually written.
//
// pUserData    [in]  The user data that was passed to drwav_init_write(), drwav_open_write() and family.
// pData        [out] A pointer to the data to write.
// bytesToWrite [in]  The number of bytes to write.
//
// Returns the number of bytes actually written.
//
// If the return value differs from bytesToWrite, it indicates an error.
typedef size_t (* drwav_write_proc)(void* pUserData, const void* pData, size_t bytesToWrite);

// Callback for when data needs to be seeked.
//
// pUserData [in] The user data that was passed to drwav_init(), drwav_open() and family.
// offset    [in] The number of bytes to move, relative to the origin. Will never be negative.
// origin    [in] The origin of the seek - the current position or the start of the stream.
//
// Returns whether or not the seek was successful.
//
// Whether or not it is relative to the beginning or current position is determined by the "origin" parameter which
// will be either drwav_seek_origin_start or drwav_seek_origin_current.
typedef drwav_bool32 (* drwav_seek_proc)(void* pUserData, int offset, drwav_seek_origin origin);

// Structure for internal use. Only used for loaders opened with drwav_open_memory().
typedef struct
{
    const drwav_uint8* data;
    size_t dataSize;
    size_t currentReadPos;
} drwav__memory_stream;

// Structure for internal use. Only used for writers opened with drwav_open_memory_write().
typedef struct
{
    void** ppData;
    size_t* pDataSize;
    size_t dataSize;
    size_t dataCapacity;
    size_t currentWritePos;
} drwav__memory_stream_write;

typedef struct
{
    drwav_container container;  // RIFF, W64.
    drwav_uint32 format;        // DR_WAVE_FORMAT_*
    drwav_uint32 channels;
    drwav_uint32 sampleRate;
    drwav_uint32 bitsPerSample;
} drwav_data_format;

typedef struct
{
    // The format tag exactly as specified in the wave file's "fmt" chunk. This can be used by applications
    // that require support for data formats not natively supported by dr_wav.
    drwav_uint16 formatTag;

    // The number of channels making up the audio data. When this is set to 1 it is mono, 2 is stereo, etc.
    drwav_uint16 channels;

    // The sample rate. Usually set to something like 44100.
    drwav_uint32 sampleRate;

    // Average bytes per second. You probably don't need this, but it's left here for informational purposes.
    drwav_uint32 avgBytesPerSec;

    // Block align. This is equal to the number of channels * bytes per sample.
    drwav_uint16 blockAlign;

    // Bit's per sample.
    drwav_uint16 bitsPerSample;

    // The size of the extended data. Only used internally for validation, but left here for informational purposes.
    drwav_uint16 extendedSize;

    // The number of valid bits per sample. When <formatTag> is equal to WAVE_FORMAT_EXTENSIBLE, <bitsPerSample>
    // is always rounded up to the nearest multiple of 8. This variable contains information about exactly how
    // many bits a valid per sample. Mainly used for informational purposes.
    drwav_uint16 validBitsPerSample;

    // The channel mask. Not used at the moment.
    drwav_uint32 channelMask;

    // The sub-format, exactly as specified by the wave file.
    drwav_uint8 subFormat[16];
} drwav_fmt;

typedef struct
{
    // A pointer to the function to call when more data is needed.
    drwav_read_proc onRead;

    // A pointer to the function to call when data needs to be written. Only used when the drwav object is opened in write mode.
    drwav_write_proc onWrite;

    // A pointer to the function to call when the wav file needs to be seeked.
    drwav_seek_proc onSeek;

    // The user data to pass to callbacks.
    void* pUserData;


    // Whether or not the WAV file is formatted as a standard RIFF file or W64.
    drwav_container container;


    // Structure containing format information exactly as specified by the wav file.
    drwav_fmt fmt;

    // The sample rate. Will be set to something like 44100.
    drwav_uint32 sampleRate;

    // The number of channels. This will be set to 1 for monaural streams, 2 for stereo, etc.
    drwav_uint16 channels;

    // The bits per sample. Will be set to somthing like 16, 24, etc.
    drwav_uint16 bitsPerSample;

    // The number of bytes per sample.
    drwav_uint16 bytesPerSample;

    // Equal to fmt.formatTag, or the value specified by fmt.subFormat if fmt.formatTag is equal to 65534 (WAVE_FORMAT_EXTENSIBLE).
    drwav_uint16 translatedFormatTag;

    // The total number of samples making up the audio data. Use <totalSampleCount> * <bytesPerSample> to calculate
    // the required size of a buffer to hold the entire audio data.
    drwav_uint64 totalSampleCount;


    // The size in bytes of the data chunk.
    drwav_uint64 dataChunkDataSize;
    
    // The position in the stream of the first byte of the data chunk. This is used for seeking.
    drwav_uint64 dataChunkDataPos;

    // The number of bytes remaining in the data chunk.
    drwav_uint64 bytesRemaining;


    // A hack to avoid a DRWAV_MALLOC() when opening a decoder with drwav_open_memory().
    drwav__memory_stream memoryStream;
    drwav__memory_stream_write memoryStreamWrite;

    // Generic data for compressed formats. This data is shared across all block-compressed formats.
    struct
    {
        drwav_uint64 iCurrentSample;    // The index of the next sample that will be read by drwav_read_*(). This is used with "totalSampleCount" to ensure we don't read excess samples at the end of the last block.
    } compressed;
    
    // Microsoft ADPCM specific data.
    struct
    {
        drwav_uint32 bytesRemainingInBlock;
        drwav_uint16 predictor[2];
        drwav_int32  delta[2];
        drwav_int32  cachedSamples[4];  // Samples are stored in this cache during decoding.
        drwav_uint32 cachedSampleCount;
        drwav_int32  prevSamples[2][2]; // The previous 2 samples for each channel (2 channels at most).
    } msadpcm;

    // IMA ADPCM specific data.
    struct
    {
        drwav_uint32 bytesRemainingInBlock;
        drwav_int32  predictor[2];
        drwav_int32  stepIndex[2];
        drwav_int32  cachedSamples[16]; // Samples are stored in this cache during decoding.
        drwav_uint32 cachedSampleCount;
    } ima;
} drwav;


// Initializes a pre-allocated drwav object.
//
// onRead    [in]           The function to call when data needs to be read from the client.
// onSeek    [in]           The function to call when the read position of the client data needs to move.
// pUserData [in, optional] A pointer to application defined data that will be passed to onRead and onSeek.
//
// Returns true if successful; false otherwise.
//
// Close the loader with drwav_uninit().
//
// This is the lowest level function for initializing a WAV file. You can also use drwav_init_file() and drwav_init_memory()
// to open the stream from a file or from a block of memory respectively.
//
// If you want dr_wav to manage the memory allocation for you, consider using drwav_open() instead. This will allocate
// a drwav object on the heap and return a pointer to it.
//
// See also: drwav_init_file(), drwav_init_memory(), drwav_uninit()
drwav_bool32 drwav_init(drwav* pWav, drwav_read_proc onRead, drwav_seek_proc onSeek, void* pUserData);

// Initializes a pre-allocated drwav object for writing.
//
// onWrite   [in]           The function to call when data needs to be written.
// onSeek    [in]           The function to call when the write position needs to move.
// pUserData [in, optional] A pointer to application defined data that will be passed to onWrite and onSeek.
//
// Returns true if successful; false otherwise.
//
// Close the writer with drwav_uninit().
//
// This is the lowest level function for initializing a WAV file. You can also use drwav_init_file() and drwav_init_memory()
// to open the stream from a file or from a block of memory respectively.
//
// If you want dr_wav to manage the memory allocation for you, consider using drwav_open() instead. This will allocate
// a drwav object on the heap and return a pointer to it.
//
// See also: drwav_init_file_write(), drwav_init_memory_write(), drwav_uninit()
drwav_bool32 drwav_init_write(drwav* pWav, const drwav_data_format* pFormat, drwav_write_proc onWrite, drwav_seek_proc onSeek, void* pUserData);

// Uninitializes the given drwav object.
//
// Use this only for objects initialized with drwav_init().
void drwav_uninit(drwav* pWav);


// Opens a wav file using the given callbacks.
//
// onRead    [in]           The function to call when data needs to be read from the client.
// onSeek    [in]           The function to call when the read position of the client data needs to move.
// pUserData [in, optional] A pointer to application defined data that will be passed to onRead and onSeek.
//
// Returns null on error.
//
// Close the loader with drwav_close().
//
// This is the lowest level function for opening a WAV file. You can also use drwav_open_file() and drwav_open_memory()
// to open the stream from a file or from a block of memory respectively.
//
// This is different from drwav_init() in that it will allocate the drwav object for you via DRWAV_MALLOC() before
// initializing it.
//
// See also: drwav_open_file(), drwav_open_memory(), drwav_close()
drwav* drwav_open(drwav_read_proc onRead, drwav_seek_proc onSeek, void* pUserData);

// Opens a wav file for writing using the given callbacks.
//
// onWrite   [in]           The function to call when data needs to be written.
// onSeek    [in]           The function to call when the write position needs to move.
// pUserData [in, optional] A pointer to application defined data that will be passed to onWrite and onSeek.
//
// Returns null on error.
//
// Close the loader with drwav_close().
//
// This is the lowest level function for opening a WAV file. You can also use drwav_open_file_write() and drwav_open_memory_write()
// to open the stream from a file or from a block of memory respectively.
//
// This is different from drwav_init_write() in that it will allocate the drwav object for you via DRWAV_MALLOC() before
// initializing it.
//
// See also: drwav_open_file_write(), drwav_open_memory_write(), drwav_close()
drwav* drwav_open_write(const drwav_data_format* pFormat, drwav_write_proc onWrite, drwav_seek_proc onSeek, void* pUserData);

// Uninitializes and deletes the the given drwav object.
//
// Use this only for objects created with drwav_open().
void drwav_close(drwav* pWav);


// Reads raw audio data.
//
// This is the lowest level function for reading audio data. It simply reads the given number of
// bytes of the raw internal sample data.
//
// Consider using drwav_read_s16(), drwav_read_s32() or drwav_read_f32() for reading sample data in
// a consistent format.
//
// Returns the number of bytes actually read.
size_t drwav_read_raw(drwav* pWav, size_t bytesToRead, void* pBufferOut);

// Reads a chunk of audio data in the native internal format.
//
// This is typically the most efficient way to retrieve audio data, but it does not do any format
// conversions which means you'll need to convert the data manually if required.
//
// If the return value is less than <samplesToRead> it means the end of the file has been reached or
// you have requested more samples than can possibly fit in the output buffer.
//
// This function will only work when sample data is of a fixed size and uncompressed. If you are
// using a compressed format consider using drwav_read_raw() or drwav_read_s16/s32/f32/etc().
drwav_uint64 drwav_read(drwav* pWav, drwav_uint64 samplesToRead, void* pBufferOut);

// Seeks to the given sample.
//
// Returns true if successful; false otherwise.
drwav_bool32 drwav_seek_to_sample(drwav* pWav, drwav_uint64 sample);


// Writes raw audio data.
//
// Returns the number of bytes actually written. If this differs from bytesToWrite, it indicates an error.
size_t drwav_write_raw(drwav* pWav, size_t bytesToWrite, const void* pData);

// Writes audio data based on sample counts.
//
// Returns the number of samples written.
drwav_uint64 drwav_write(drwav* pWav, drwav_uint64 samplesToWrite, const void* pData);



//// Convertion Utilities ////
#ifndef DR_WAV_NO_CONVERSION_API

// Reads a chunk of audio data and converts it to signed 16-bit PCM samples.
//
// Returns the number of samples actually read.
//
// If the return value is less than <samplesToRead> it means the end of the file has been reached.
drwav_uint64 drwav_read_s16(drwav* pWav, drwav_uint64 samplesToRead, drwav_int16* pBufferOut);

// Low-level function for converting unsigned 8-bit PCM samples to signed 16-bit PCM samples.
void drwav_u8_to_s16(drwav_int16* pOut, const drwav_uint8* pIn, size_t sampleCount);

// Low-level function for converting signed 24-bit PCM samples to signed 16-bit PCM samples.
void drwav_s24_to_s16(drwav_int16* pOut, const drwav_uint8* pIn, size_t sampleCount);

// Low-level function for converting signed 32-bit PCM samples to signed 16-bit PCM samples.
void drwav_s32_to_s16(drwav_int16* pOut, const drwav_int32* pIn, size_t sampleCount);

// Low-level function for converting IEEE 32-bit floating point samples to signed 16-bit PCM samples.
void drwav_f32_to_s16(drwav_int16* pOut, const float* pIn, size_t sampleCount);

// Low-level function for converting IEEE 64-bit floating point samples to signed 16-bit PCM samples.
void drwav_f64_to_s16(drwav_int16* pOut, const double* pIn, size_t sampleCount);

// Low-level function for converting A-law samples to signed 16-bit PCM samples.
void drwav_alaw_to_s16(drwav_int16* pOut, const drwav_uint8* pIn, size_t sampleCount);

// Low-level function for converting u-law samples to signed 16-bit PCM samples.
void drwav_mulaw_to_s16(drwav_int16* pOut, const drwav_uint8* pIn, size_t sampleCount);


// Reads a chunk of audio data and converts it to IEEE 32-bit floating point samples.
//
// Returns the number of samples actually read.
//
// If the return value is less than <samplesToRead> it means the end of the file has been reached.
drwav_uint64 drwav_read_f32(drwav* pWav, drwav_uint64 samplesToRead, float* pBufferOut);

// Low-level function for converting unsigned 8-bit PCM samples to IEEE 32-bit floating point samples.
void drwav_u8_to_f32(float* pOut, const drwav_uint8* pIn, size_t sampleCount);

// Low-level function for converting signed 16-bit PCM samples to IEEE 32-bit floating point samples.
void drwav_s16_to_f32(float* pOut, const drwav_int16* pIn, size_t sampleCount);

// Low-level function for converting signed 24-bit PCM samples to IEEE 32-bit floating point samples.
void drwav_s24_to_f32(float* pOut, const drwav_uint8* pIn, size_t sampleCount);

// Low-level function for converting signed 32-bit PCM samples to IEEE 32-bit floating point samples.
void drwav_s32_to_f32(float* pOut, const drwav_int32* pIn, size_t sampleCount);

// Low-level function for converting IEEE 64-bit floating point samples to IEEE 32-bit floating point samples.
void drwav_f64_to_f32(float* pOut, const double* pIn, size_t sampleCount);

// Low-level function for converting A-law samples to IEEE 32-bit floating point samples.
void drwav_alaw_to_f32(float* pOut, const drwav_uint8* pIn, size_t sampleCount);

// Low-level function for converting u-law samples to IEEE 32-bit floating point samples.
void drwav_mulaw_to_f32(float* pOut, const drwav_uint8* pIn, size_t sampleCount);


// Reads a chunk of audio data and converts it to signed 32-bit PCM samples.
//
// Returns the number of samples actually read.
//
// If the return value is less than <samplesToRead> it means the end of the file has been reached.
drwav_uint64 drwav_read_s32(drwav* pWav, drwav_uint64 samplesToRead, drwav_int32* pBufferOut);

// Low-level function for converting unsigned 8-bit PCM samples to signed 32-bit PCM samples.
void drwav_u8_to_s32(drwav_int32* pOut, const drwav_uint8* pIn, size_t sampleCount);

// Low-level function for converting signed 16-bit PCM samples to signed 32-bit PCM samples.
void drwav_s16_to_s32(drwav_int32* pOut, const drwav_int16* pIn, size_t sampleCount);

// Low-level function for converting signed 24-bit PCM samples to signed 32-bit PCM samples.
void drwav_s24_to_s32(drwav_int32* pOut, const drwav_uint8* pIn, size_t sampleCount);

// Low-level function for converting IEEE 32-bit floating point samples to signed 32-bit PCM samples.
void drwav_f32_to_s32(drwav_int32* pOut, const float* pIn, size_t sampleCount);

// Low-level function for converting IEEE 64-bit floating point samples to signed 32-bit PCM samples.
void drwav_f64_to_s32(drwav_int32* pOut, const double* pIn, size_t sampleCount);

// Low-level function for converting A-law samples to signed 32-bit PCM samples.
void drwav_alaw_to_s32(drwav_int32* pOut, const drwav_uint8* pIn, size_t sampleCount);

// Low-level function for converting u-law samples to signed 32-bit PCM samples.
void drwav_mulaw_to_s32(drwav_int32* pOut, const drwav_uint8* pIn, size_t sampleCount);

#endif  //DR_WAV_NO_CONVERSION_API


//// High-Level Convenience Helpers ////

#ifndef DR_WAV_NO_STDIO

// Helper for initializing a wave file using stdio.
//
// This holds the internal FILE object until drwav_uninit() is called. Keep this in mind if you're caching drwav
// objects because the operating system may restrict the number of file handles an application can have open at
// any given time.
drwav_bool32 drwav_init_file(drwav* pWav, const char* filename);

// Helper for initializing a wave file for writing using stdio.
//
// This holds the internal FILE object until drwav_uninit() is called. Keep this in mind if you're caching drwav
// objects because the operating system may restrict the number of file handles an application can have open at
// any given time.
drwav_bool32 drwav_init_file_write(drwav* pWav, const char* filename, const drwav_data_format* pFormat);

// Helper for opening a wave file using stdio.
//
// This holds the internal FILE object until drwav_close() is called. Keep this in mind if you're caching drwav
// objects because the operating system may restrict the number of file handles an application can have open at
// any given time.
drwav* drwav_open_file(const char* filename);

// Helper for opening a wave file for writing using stdio.
//
// This holds the internal FILE object until drwav_close() is called. Keep this in mind if you're caching drwav
// objects because the operating system may restrict the number of file handles an application can have open at
// any given time.
drwav* drwav_open_file_write(const char* filename, const drwav_data_format* pFormat);

#endif  //DR_WAV_NO_STDIO

// Helper for initializing a loader from a pre-allocated memory buffer.
//
// This does not create a copy of the data. It is up to the application to ensure the buffer remains valid for
// the lifetime of the drwav object.
//
// The buffer should contain the contents of the entire wave file, not just the sample data.
drwav_bool32 drwav_init_memory(drwav* pWav, const void* data, size_t dataSize);

// Helper for initializing a writer which outputs data to a memory buffer.
//
// dr_wav will manage the memory allocations, however it is up to the caller to free the data with drwav_free().
//
// The buffer will remain allocated even after drwav_uninit() is called. Indeed, the buffer should not be
// considered valid until after drwav_uninit() has been called anyway.
drwav_bool32 drwav_init_memory_write(drwav* pWav, void** ppData, size_t* pDataSize, const drwav_data_format* pFormat);

// Helper for opening a loader from a pre-allocated memory buffer.
//
// This does not create a copy of the data. It is up to the application to ensure the buffer remains valid for
// the lifetime of the drwav object.
//
// The buffer should contain the contents of the entire wave file, not just the sample data.
drwav* drwav_open_memory(const void* data, size_t dataSize);

// Helper for opening a writer which outputs data to a memory buffer.
//
// dr_wav will manage the memory allocations, however it is up to the caller to free the data with drwav_free().
//
// The buffer will remain allocated even after drwav_close() is called. Indeed, the buffer should not be
// considered valid until after drwav_close() has been called anyway.
drwav* drwav_open_memory_write(void** ppData, size_t* pDataSize, const drwav_data_format* pFormat);


#ifndef DR_WAV_NO_CONVERSION_API
// Opens and reads a wav file in a single operation.
drwav_int16* drwav_open_and_read_s16(drwav_read_proc onRead, drwav_seek_proc onSeek, void* pUserData, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount);
float* drwav_open_and_read_f32(drwav_read_proc onRead, drwav_seek_proc onSeek, void* pUserData, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount);
drwav_int32* drwav_open_and_read_s32(drwav_read_proc onRead, drwav_seek_proc onSeek, void* pUserData, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount);
#ifndef DR_WAV_NO_STDIO
// Opens an decodes a wav file in a single operation.
drwav_int16* drwav_open_and_read_file_s16(const char* filename, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount);
float* drwav_open_and_read_file_f32(const char* filename, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount);
drwav_int32* drwav_open_and_read_file_s32(const char* filename, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount);
#endif

// Opens an decodes a wav file from a block of memory in a single operation.
drwav_int16* drwav_open_and_read_memory_s16(const void* data, size_t dataSize, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount);
float* drwav_open_and_read_memory_f32(const void* data, size_t dataSize, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount);
drwav_int32* drwav_open_and_read_memory_s32(const void* data, size_t dataSize, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount);
#endif

// Frees data that was allocated internally by dr_wav.
void drwav_free(void* pDataReturnedByOpenAndRead);

#ifdef __cplusplus
}
#endif
#endif  // dr_wav_h


/////////////////////////////////////////////////////
//
// IMPLEMENTATION
//
/////////////////////////////////////////////////////

#ifdef DR_WAV_IMPLEMENTATION
#include <stdlib.h>
#include <string.h> // For memcpy(), memset()
#include <limits.h> // For INT_MAX

#ifndef DR_WAV_NO_STDIO
#include <stdio.h>
#endif

// Standard library stuff.
#ifndef DRWAV_ASSERT
#include <assert.h>
#define DRWAV_ASSERT(expression)           assert(expression)
#endif
#ifndef DRWAV_MALLOC
#define DRWAV_MALLOC(sz)                   malloc((sz))
#endif
#ifndef DRWAV_REALLOC
#define DRWAV_REALLOC(p, sz)               realloc((p), (sz))
#endif
#ifndef DRWAV_FREE
#define DRWAV_FREE(p)                      free((p))
#endif
#ifndef DRWAV_COPY_MEMORY
#define DRWAV_COPY_MEMORY(dst, src, sz)    memcpy((dst), (src), (sz))
#endif
#ifndef DRWAV_ZERO_MEMORY
#define DRWAV_ZERO_MEMORY(p, sz)           memset((p), 0, (sz))
#endif

#define drwav_countof(x)                   (sizeof(x) / sizeof(x[0]))
#define drwav_align(x, a)                  ((((x) + (a) - 1) / (a)) * (a))
#define drwav_min(a, b)                    (((a) < (b)) ? (a) : (b))
#define drwav_max(a, b)                    (((a) > (b)) ? (a) : (b))
#define drwav_clamp(x, lo, hi)             (drwav_max((lo), drwav_min((hi), (x))))

#define drwav_assert                       DRWAV_ASSERT
#define drwav_copy_memory                  DRWAV_COPY_MEMORY
#define drwav_zero_memory                  DRWAV_ZERO_MEMORY


#define DRWAV_MAX_SIMD_VECTOR_SIZE         64  // 64 for AVX-512 in the future.

#ifdef _MSC_VER
#define DRWAV_INLINE __forceinline
#else
#ifdef __GNUC__
#define DRWAV_INLINE inline __attribute__((always_inline))
#else
#define DRWAV_INLINE inline
#endif
#endif

// I couldn't figure out where SIZE_MAX was defined for VC6. If anybody knows, let me know.
#if defined(_MSC_VER) && _MSC_VER <= 1200
    #if defined(_WIN64)
        #define SIZE_MAX    ((drwav_uint64)0xFFFFFFFFFFFFFFFF)
    #else
        #define SIZE_MAX    0xFFFFFFFF
    #endif
#endif

static const drwav_uint8 drwavGUID_W64_RIFF[16] = {0x72,0x69,0x66,0x66, 0x2E,0x91, 0xCF,0x11, 0xA5,0xD6, 0x28,0xDB,0x04,0xC1,0x00,0x00};    // 66666972-912E-11CF-A5D6-28DB04C10000
static const drwav_uint8 drwavGUID_W64_WAVE[16] = {0x77,0x61,0x76,0x65, 0xF3,0xAC, 0xD3,0x11, 0x8C,0xD1, 0x00,0xC0,0x4F,0x8E,0xDB,0x8A};    // 65766177-ACF3-11D3-8CD1-00C04F8EDB8A
static const drwav_uint8 drwavGUID_W64_JUNK[16] = {0x6A,0x75,0x6E,0x6B, 0xF3,0xAC, 0xD3,0x11, 0x8C,0xD1, 0x00,0xC0,0x4F,0x8E,0xDB,0x8A};    // 6B6E756A-ACF3-11D3-8CD1-00C04F8EDB8A
static const drwav_uint8 drwavGUID_W64_FMT [16] = {0x66,0x6D,0x74,0x20, 0xF3,0xAC, 0xD3,0x11, 0x8C,0xD1, 0x00,0xC0,0x4F,0x8E,0xDB,0x8A};    // 20746D66-ACF3-11D3-8CD1-00C04F8EDB8A
static const drwav_uint8 drwavGUID_W64_FACT[16] = {0x66,0x61,0x63,0x74, 0xF3,0xAC, 0xD3,0x11, 0x8C,0xD1, 0x00,0xC0,0x4F,0x8E,0xDB,0x8A};    // 74636166-ACF3-11D3-8CD1-00C04F8EDB8A
static const drwav_uint8 drwavGUID_W64_DATA[16] = {0x64,0x61,0x74,0x61, 0xF3,0xAC, 0xD3,0x11, 0x8C,0xD1, 0x00,0xC0,0x4F,0x8E,0xDB,0x8A};    // 61746164-ACF3-11D3-8CD1-00C04F8EDB8A

static DRWAV_INLINE drwav_bool32 drwav__guid_equal(const drwav_uint8 a[16], const drwav_uint8 b[16])
{
    const drwav_uint32* a32 = (const drwav_uint32*)a;
    const drwav_uint32* b32 = (const drwav_uint32*)b;

    return
        a32[0] == b32[0] &&
        a32[1] == b32[1] &&
        a32[2] == b32[2] &&
        a32[3] == b32[3];
}

static DRWAV_INLINE drwav_bool32 drwav__fourcc_equal(const unsigned char* a, const char* b)
{
    return
        a[0] == b[0] &&
        a[1] == b[1] &&
        a[2] == b[2] &&
        a[3] == b[3];
}



static DRWAV_INLINE int drwav__is_little_endian()
{
    int n = 1;
    return (*(char*)&n) == 1;
}

static DRWAV_INLINE unsigned short drwav__bytes_to_u16(const unsigned char* data)
{
    if (drwav__is_little_endian()) {
        return (data[0] << 0) | (data[1] << 8);
    } else {
        return (data[1] << 0) | (data[0] << 8);
    }
}

static DRWAV_INLINE short drwav__bytes_to_s16(const unsigned char* data)
{
    return (short)drwav__bytes_to_u16(data);
}

static DRWAV_INLINE unsigned int drwav__bytes_to_u32(const unsigned char* data)
{
    if (drwav__is_little_endian()) {
        return (data[0] << 0) | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
    } else {
        return (data[3] << 0) | (data[2] << 8) | (data[1] << 16) | (data[0] << 24);
    }
}

static DRWAV_INLINE drwav_uint64 drwav__bytes_to_u64(const unsigned char* data)
{
    if (drwav__is_little_endian()) {
        return
            ((drwav_uint64)data[0] <<  0) | ((drwav_uint64)data[1] <<  8) | ((drwav_uint64)data[2] << 16) | ((drwav_uint64)data[3] << 24) |
            ((drwav_uint64)data[4] << 32) | ((drwav_uint64)data[5] << 40) | ((drwav_uint64)data[6] << 48) | ((drwav_uint64)data[7] << 56);
    } else {
        return
            ((drwav_uint64)data[7] <<  0) | ((drwav_uint64)data[6] <<  8) | ((drwav_uint64)data[5] << 16) | ((drwav_uint64)data[4] << 24) |
            ((drwav_uint64)data[3] << 32) | ((drwav_uint64)data[2] << 40) | ((drwav_uint64)data[1] << 48) | ((drwav_uint64)data[0] << 56);
    }
}

static DRWAV_INLINE void drwav__bytes_to_guid(const unsigned char* data, drwav_uint8* guid)
{
    int i;
    for (i = 0; i < 16; ++i) {
        guid[i] = data[i];
    }
}


static DRWAV_INLINE drwav_bool32 drwav__is_compressed_format_tag(drwav_uint16 formatTag)
{
    return
        formatTag == DR_WAVE_FORMAT_ADPCM ||
        formatTag == DR_WAVE_FORMAT_DVI_ADPCM;
}


typedef struct
{
    union
    {
        drwav_uint8 fourcc[4];
        drwav_uint8 guid[16];
    } id;

    // The size in bytes of the chunk.
    drwav_uint64 sizeInBytes;

    // RIFF = 2 byte alignment.
    // W64  = 8 byte alignment.
    unsigned int paddingSize;

} drwav__chunk_header;

static drwav_bool32 drwav__read_chunk_header(drwav_read_proc onRead, void* pUserData, drwav_container container, drwav_uint64* pRunningBytesReadOut, drwav__chunk_header* pHeaderOut)
{
    if (container == drwav_container_riff) {
        if (onRead(pUserData, pHeaderOut->id.fourcc, 4) != 4) {
            return DRWAV_FALSE;
        }

        unsigned char sizeInBytes[4];
        if (onRead(pUserData, sizeInBytes, 4) != 4) {
            return DRWAV_FALSE;
        }

        pHeaderOut->sizeInBytes = drwav__bytes_to_u32(sizeInBytes);
        pHeaderOut->paddingSize = (unsigned int)(pHeaderOut->sizeInBytes % 2);
        *pRunningBytesReadOut += 8;
    } else {
        if (onRead(pUserData, pHeaderOut->id.guid, 16) != 16) {
            return DRWAV_FALSE;
        }

        unsigned char sizeInBytes[8];
        if (onRead(pUserData, sizeInBytes, 8) != 8) {
            return DRWAV_FALSE;
        }

        pHeaderOut->sizeInBytes = drwav__bytes_to_u64(sizeInBytes) - 24;    // <-- Subtract 24 because w64 includes the size of the header.
        pHeaderOut->paddingSize = (unsigned int)(pHeaderOut->sizeInBytes % 8);
        pRunningBytesReadOut += 24;
    }

    return DRWAV_TRUE;
}

static drwav_bool32 drwav__seek_forward(drwav_seek_proc onSeek, drwav_uint64 offset, void* pUserData)
{
    drwav_uint64 bytesRemainingToSeek = offset;
    while (bytesRemainingToSeek > 0) {
        if (bytesRemainingToSeek > 0x7FFFFFFF) {
            if (!onSeek(pUserData, 0x7FFFFFFF, drwav_seek_origin_current)) {
                return DRWAV_FALSE;
            }
            bytesRemainingToSeek -= 0x7FFFFFFF;
        } else {
            if (!onSeek(pUserData, (int)bytesRemainingToSeek, drwav_seek_origin_current)) {
                return DRWAV_FALSE;
            }
            bytesRemainingToSeek = 0;
        }
    }

    return DRWAV_TRUE;
}


static drwav_bool32 drwav__read_fmt(drwav_read_proc onRead, drwav_seek_proc onSeek, void* pUserData, drwav_container container, drwav_uint64* pRunningBytesReadOut, drwav_fmt* fmtOut)
{
    drwav__chunk_header header;
    if (!drwav__read_chunk_header(onRead, pUserData, container, pRunningBytesReadOut, &header)) {
        return DRWAV_FALSE;
    }


    // Skip junk chunks.
    if ((container == drwav_container_riff && drwav__fourcc_equal(header.id.fourcc, "JUNK")) || (container == drwav_container_w64 && drwav__guid_equal(header.id.guid, drwavGUID_W64_JUNK))) {
        if (!drwav__seek_forward(onSeek, header.sizeInBytes + header.paddingSize, pUserData)) {
            return DRWAV_FALSE;
        }
        *pRunningBytesReadOut += header.sizeInBytes + header.paddingSize;

        return drwav__read_fmt(onRead, onSeek, pUserData, container, pRunningBytesReadOut, fmtOut);
    }


    // Validation.
    if (container == drwav_container_riff) {
        if (!drwav__fourcc_equal(header.id.fourcc, "fmt ")) {
            return DRWAV_FALSE;
        }
    } else {
        if (!drwav__guid_equal(header.id.guid, drwavGUID_W64_FMT)) {
            return DRWAV_FALSE;
        }
    }


    unsigned char fmt[16];
    if (onRead(pUserData, fmt, sizeof(fmt)) != sizeof(fmt)) {
        return DRWAV_FALSE;
    }
    *pRunningBytesReadOut += sizeof(fmt);

    fmtOut->formatTag      = drwav__bytes_to_u16(fmt + 0);
    fmtOut->channels       = drwav__bytes_to_u16(fmt + 2);
    fmtOut->sampleRate     = drwav__bytes_to_u32(fmt + 4);
    fmtOut->avgBytesPerSec = drwav__bytes_to_u32(fmt + 8);
    fmtOut->blockAlign     = drwav__bytes_to_u16(fmt + 12);
    fmtOut->bitsPerSample  = drwav__bytes_to_u16(fmt + 14);

    fmtOut->extendedSize       = 0;
    fmtOut->validBitsPerSample = 0;
    fmtOut->channelMask        = 0;
    memset(fmtOut->subFormat, 0, sizeof(fmtOut->subFormat));

    if (header.sizeInBytes > 16) {
        unsigned char fmt_cbSize[2];
        if (onRead(pUserData, fmt_cbSize, sizeof(fmt_cbSize)) != sizeof(fmt_cbSize)) {
            return DRWAV_FALSE;    // Expecting more data.
        }
        *pRunningBytesReadOut += sizeof(fmt_cbSize);

        int bytesReadSoFar = 18;

        fmtOut->extendedSize = drwav__bytes_to_u16(fmt_cbSize);
        if (fmtOut->extendedSize > 0) {
            // Simple validation.
            if (fmtOut->formatTag == DR_WAVE_FORMAT_EXTENSIBLE) {
                if (fmtOut->extendedSize != 22) {
                    return DRWAV_FALSE;
                }
            }

            if (fmtOut->formatTag == DR_WAVE_FORMAT_EXTENSIBLE) {
                unsigned char fmtext[22];
                if (onRead(pUserData, fmtext, fmtOut->extendedSize) != fmtOut->extendedSize) {
                    return DRWAV_FALSE;    // Expecting more data.
                }

                fmtOut->validBitsPerSample = drwav__bytes_to_u16(fmtext + 0);
                fmtOut->channelMask        = drwav__bytes_to_u32(fmtext + 2);
                drwav__bytes_to_guid(fmtext + 6, fmtOut->subFormat);
            } else {
                if (!onSeek(pUserData, fmtOut->extendedSize, drwav_seek_origin_current)) {
                    return DRWAV_FALSE;
                }
            }
            *pRunningBytesReadOut += fmtOut->extendedSize;

            bytesReadSoFar += fmtOut->extendedSize;
        }

        // Seek past any leftover bytes. For w64 the leftover will be defined based on the chunk size.
        if (!onSeek(pUserData, (int)(header.sizeInBytes - bytesReadSoFar), drwav_seek_origin_current)) {
            return DRWAV_FALSE;
        }
        *pRunningBytesReadOut += (header.sizeInBytes - bytesReadSoFar);
    }

    if (header.paddingSize > 0) {
        if (!onSeek(pUserData, header.paddingSize, drwav_seek_origin_current)) {
            return DRWAV_FALSE;
        }
        *pRunningBytesReadOut += header.paddingSize;
    }

    return DRWAV_TRUE;
}


#ifndef DR_WAV_NO_STDIO
static size_t drwav__on_read_stdio(void* pUserData, void* pBufferOut, size_t bytesToRead)
{
    return fread(pBufferOut, 1, bytesToRead, (FILE*)pUserData);
}

static size_t drwav__on_write_stdio(void* pUserData, const void* pData, size_t bytesToWrite)
{
    return fwrite(pData, 1, bytesToWrite, (FILE*)pUserData);
}

static drwav_bool32 drwav__on_seek_stdio(void* pUserData, int offset, drwav_seek_origin origin)
{
    return fseek((FILE*)pUserData, offset, (origin == drwav_seek_origin_current) ? SEEK_CUR : SEEK_SET) == 0;
}

drwav_bool32 drwav_init_file(drwav* pWav, const char* filename)
{
    FILE* pFile;
#if defined(_MSC_VER) && _MSC_VER >= 1400
    if (fopen_s(&pFile, filename, "rb") != 0) {
        return DRWAV_FALSE;
    }
#else
    pFile = fopen(filename, "rb");
    if (pFile == NULL) {
        return DRWAV_FALSE;
    }
#endif

    return drwav_init(pWav, drwav__on_read_stdio, drwav__on_seek_stdio, (void*)pFile);
}

drwav_bool32 drwav_init_file_write(drwav* pWav, const char* filename, const drwav_data_format* pFormat)
{
    FILE* pFile;
#if defined(_MSC_VER) && _MSC_VER >= 1400
    if (fopen_s(&pFile, filename, "wb") != 0) {
        return DRWAV_FALSE;
    }
#else
    pFile = fopen(filename, "wb");
    if (pFile == NULL) {
        return DRWAV_FALSE;
    }
#endif

    return drwav_init_write(pWav, pFormat, drwav__on_write_stdio, drwav__on_seek_stdio, (void*)pFile);
}

drwav* drwav_open_file(const char* filename)
{
    FILE* pFile;
#if defined(_MSC_VER) && _MSC_VER >= 1400
    if (fopen_s(&pFile, filename, "rb") != 0) {
        return NULL;
    }
#else
    pFile = fopen(filename, "rb");
    if (pFile == NULL) {
        return NULL;
    }
#endif

    drwav* pWav = drwav_open(drwav__on_read_stdio, drwav__on_seek_stdio, (void*)pFile);
    if (pWav == NULL) {
        fclose(pFile);
        return NULL;
    }

    return pWav;
}

drwav* drwav_open_file_write(const char* filename, const drwav_data_format* pFormat)
{
    FILE* pFile;
#if defined(_MSC_VER) && _MSC_VER >= 1400
    if (fopen_s(&pFile, filename, "wb") != 0) {
        return NULL;
    }
#else
    pFile = fopen(filename, "wb");
    if (pFile == NULL) {
        return NULL;
    }
#endif

    drwav* pWav = drwav_open_write(pFormat, drwav__on_write_stdio, drwav__on_seek_stdio, (void*)pFile);
    if (pWav == NULL) {
        fclose(pFile);
        return NULL;
    }

    return pWav;
}
#endif  //DR_WAV_NO_STDIO


static size_t drwav__on_read_memory(void* pUserData, void* pBufferOut, size_t bytesToRead)
{
    drwav__memory_stream* memory = (drwav__memory_stream*)pUserData;
    drwav_assert(memory != NULL);
    drwav_assert(memory->dataSize >= memory->currentReadPos);

    size_t bytesRemaining = memory->dataSize - memory->currentReadPos;
    if (bytesToRead > bytesRemaining) {
        bytesToRead = bytesRemaining;
    }

    if (bytesToRead > 0) {
        DRWAV_COPY_MEMORY(pBufferOut, memory->data + memory->currentReadPos, bytesToRead);
        memory->currentReadPos += bytesToRead;
    }

    return bytesToRead;
}

static drwav_bool32 drwav__on_seek_memory(void* pUserData, int offset, drwav_seek_origin origin)
{
    drwav__memory_stream* memory = (drwav__memory_stream*)pUserData;
    drwav_assert(memory != NULL);

    if (origin == drwav_seek_origin_current) {
        if (offset > 0) {
            if (memory->currentReadPos + offset > memory->dataSize) {
                offset = (int)(memory->dataSize - memory->currentReadPos);  // Trying to seek too far forward.
            }
        } else {
            if (memory->currentReadPos < (size_t)-offset) {
                offset = -(int)memory->currentReadPos;  // Trying to seek too far backwards.
            }
        }

        // This will never underflow thanks to the clamps above.
        memory->currentReadPos += offset;
    } else {
        if ((drwav_uint32)offset <= memory->dataSize) {
            memory->currentReadPos = offset;
        } else {
            memory->currentReadPos = memory->dataSize;  // Trying to seek too far forward.
        }
    }
    
    return DRWAV_TRUE;
}

static size_t drwav__on_write_memory(void* pUserData, const void* pDataIn, size_t bytesToWrite)
{
    drwav__memory_stream_write* memory = (drwav__memory_stream_write*)pUserData;
    drwav_assert(memory != NULL);
    drwav_assert(memory->dataCapacity >= memory->currentWritePos);

    size_t bytesRemaining = memory->dataCapacity - memory->currentWritePos;
    if (bytesRemaining < bytesToWrite) {
        // Need to reallocate.
        size_t newDataCapacity = (memory->dataCapacity == 0) ? 256 : memory->dataCapacity * 2;

        // If doubling wasn't enough, just make it the minimum required size to write the data.
        if ((newDataCapacity - memory->currentWritePos) < bytesToWrite) {
            newDataCapacity = memory->currentWritePos + bytesToWrite;
        }

        void* pNewData = DRWAV_REALLOC(*memory->ppData, newDataCapacity);
        if (pNewData == NULL) {
            return 0;
        }

        *memory->ppData = pNewData;
        memory->dataCapacity = newDataCapacity;
    }

    drwav_uint8* pDataOut = (drwav_uint8*)(*memory->ppData);
    DRWAV_COPY_MEMORY(pDataOut + memory->currentWritePos, pDataIn, bytesToWrite);

    memory->currentWritePos += bytesToWrite;
    if (memory->dataSize < memory->currentWritePos) {
        memory->dataSize = memory->currentWritePos;
    }

    *memory->pDataSize = memory->dataSize;

    return bytesToWrite;
}

static drwav_bool32 drwav__on_seek_memory_write(void* pUserData, int offset, drwav_seek_origin origin)
{
    drwav__memory_stream_write* memory = (drwav__memory_stream_write*)pUserData;
    drwav_assert(memory != NULL);

    if (origin == drwav_seek_origin_current) {
        if (offset > 0) {
            if (memory->currentWritePos + offset > memory->dataSize) {
                offset = (int)(memory->dataSize - memory->currentWritePos);  // Trying to seek too far forward.
            }
        } else {
            if (memory->currentWritePos < (size_t)-offset) {
                offset = -(int)memory->currentWritePos;  // Trying to seek too far backwards.
            }
        }

        // This will never underflow thanks to the clamps above.
        memory->currentWritePos += offset;
    } else {
        if ((drwav_uint32)offset <= memory->dataSize) {
            memory->currentWritePos = offset;
        } else {
            memory->currentWritePos = memory->dataSize;  // Trying to seek too far forward.
        }
    }
    
    return DRWAV_TRUE;
}

drwav_bool32 drwav_init_memory(drwav* pWav, const void* data, size_t dataSize)
{
    if (data == NULL || dataSize == 0) {
        return DRWAV_FALSE;
    }

    drwav__memory_stream memoryStream;
    drwav_zero_memory(&memoryStream, sizeof(memoryStream));
    memoryStream.data = (const unsigned char*)data;
    memoryStream.dataSize = dataSize;
    memoryStream.currentReadPos = 0;

    if (!drwav_init(pWav, drwav__on_read_memory, drwav__on_seek_memory, (void*)&memoryStream)) {
        return DRWAV_FALSE;
    }

    pWav->memoryStream = memoryStream;
    pWav->pUserData = &pWav->memoryStream;
    return DRWAV_TRUE;
}

drwav_bool32 drwav_init_memory_write(drwav* pWav, void** ppData, size_t* pDataSize, const drwav_data_format* pFormat)
{
    if (ppData == NULL) {
        return DRWAV_FALSE;
    }

    *ppData = NULL; // Important because we're using realloc()!
    *pDataSize = 0;

    drwav__memory_stream_write memoryStreamWrite;
    drwav_zero_memory(&memoryStreamWrite, sizeof(memoryStreamWrite));
    memoryStreamWrite.ppData = ppData;
    memoryStreamWrite.pDataSize = pDataSize;
    memoryStreamWrite.dataSize = 0;
    memoryStreamWrite.dataCapacity = 0;
    memoryStreamWrite.currentWritePos = 0;

    if (!drwav_init_write(pWav, pFormat, drwav__on_write_memory, drwav__on_seek_memory_write, (void*)&memoryStreamWrite)) {
        return DRWAV_FALSE;
    }

    pWav->memoryStreamWrite = memoryStreamWrite;
    pWav->pUserData = &pWav->memoryStreamWrite;
    return DRWAV_TRUE;
}

drwav* drwav_open_memory(const void* data, size_t dataSize)
{
    if (data == NULL || dataSize == 0) {
        return NULL;
    }

    drwav__memory_stream memoryStream;
    drwav_zero_memory(&memoryStream, sizeof(memoryStream));
    memoryStream.data = (const unsigned char*)data;
    memoryStream.dataSize = dataSize;
    memoryStream.currentReadPos = 0;

    drwav* pWav = drwav_open(drwav__on_read_memory, drwav__on_seek_memory, (void*)&memoryStream);
    if (pWav == NULL) {
        return NULL;
    }

    pWav->memoryStream = memoryStream;
    pWav->pUserData = &pWav->memoryStream;
    return pWav;
}

drwav* drwav_open_memory_write(void** ppData, size_t* pDataSize, const drwav_data_format* pFormat)
{
    if (ppData == NULL) {
        return NULL;
    }

    *ppData = NULL; // Important because we're using realloc()!
    *pDataSize = 0;

    drwav__memory_stream_write memoryStreamWrite;
    drwav_zero_memory(&memoryStreamWrite, sizeof(memoryStreamWrite));
    memoryStreamWrite.ppData = ppData;
    memoryStreamWrite.pDataSize = pDataSize;
    memoryStreamWrite.dataSize = 0;
    memoryStreamWrite.dataCapacity = 0;
    memoryStreamWrite.currentWritePos = 0;

    drwav* pWav = drwav_open_write(pFormat, drwav__on_write_memory, drwav__on_seek_memory_write, (void*)&memoryStreamWrite);
    if (pWav == NULL) {
        return NULL;
    }

    pWav->memoryStreamWrite = memoryStreamWrite;
    pWav->pUserData = &pWav->memoryStreamWrite;
    return pWav;
}


drwav_bool32 drwav_init(drwav* pWav, drwav_read_proc onRead, drwav_seek_proc onSeek, void* pUserData)
{
    int i;
    if (onRead == NULL || onSeek == NULL) {
        return DRWAV_FALSE;
    }

    drwav_zero_memory(pWav, sizeof(*pWav));


    // The first 4 bytes should be the RIFF identifier.
    unsigned char riff[4];
    if (onRead(pUserData, riff, sizeof(riff)) != sizeof(riff)) {
        return DRWAV_FALSE;    // Failed to read data.
    }

    // The first 4 bytes can be used to identify the container. For RIFF files it will start with "RIFF" and for
    // w64 it will start with "riff".
    if (drwav__fourcc_equal(riff, "RIFF")) {
        pWav->container = drwav_container_riff;
    } else if (drwav__fourcc_equal(riff, "riff")) {
        pWav->container = drwav_container_w64;

        // Check the rest of the GUID for validity.
        drwav_uint8 riff2[12];
        if (onRead(pUserData, riff2, sizeof(riff2)) != sizeof(riff2)) {
            return DRWAV_FALSE;
        }

        for (i = 0; i < 12; ++i) {
            if (riff2[i] != drwavGUID_W64_RIFF[i+4]) {
                return DRWAV_FALSE;
            }
        }
    } else {
        return DRWAV_FALSE;   // Unknown or unsupported container.
    }


    if (pWav->container == drwav_container_riff) {
        // RIFF/WAVE
        unsigned char chunkSizeBytes[4];
        if (onRead(pUserData, chunkSizeBytes, sizeof(chunkSizeBytes)) != sizeof(chunkSizeBytes)) {
            return DRWAV_FALSE;
        }

        unsigned int chunkSize = drwav__bytes_to_u32(chunkSizeBytes);
        if (chunkSize < 36) {
            return DRWAV_FALSE;    // Chunk size should always be at least 36 bytes.
        }

        unsigned char wave[4];
        if (onRead(pUserData, wave, sizeof(wave)) != sizeof(wave)) {
            return DRWAV_FALSE;
        }

        if (!drwav__fourcc_equal(wave, "WAVE")) {
            return DRWAV_FALSE;    // Expecting "WAVE".
        }

        pWav->dataChunkDataPos = 4 + sizeof(chunkSizeBytes) + sizeof(wave);
    } else {
        // W64
        unsigned char chunkSize[8];
        if (onRead(pUserData, chunkSize, sizeof(chunkSize)) != sizeof(chunkSize)) {
            return DRWAV_FALSE;
        }

        if (drwav__bytes_to_u64(chunkSize) < 80) {
            return DRWAV_FALSE;
        }

        drwav_uint8 wave[16];
        if (onRead(pUserData, wave, sizeof(wave)) != sizeof(wave)) {
            return DRWAV_FALSE;
        }

        if (!drwav__guid_equal(wave, drwavGUID_W64_WAVE)) {
            return DRWAV_FALSE;
        }

        pWav->dataChunkDataPos = 16 + sizeof(chunkSize) + sizeof(wave);
    }


    // The next 24 bytes should be the "fmt " chunk.
    drwav_fmt fmt;
    if (!drwav__read_fmt(onRead, onSeek, pUserData, pWav->container, &pWav->dataChunkDataPos, &fmt)) {
        return DRWAV_FALSE;    // Failed to read the "fmt " chunk.
    }


    // Translate the internal format.
    unsigned short translatedFormatTag = fmt.formatTag;
    if (translatedFormatTag == DR_WAVE_FORMAT_EXTENSIBLE) {
        translatedFormatTag = drwav__bytes_to_u16(fmt.subFormat + 0);
    }


    drwav_uint64 sampleCountFromFactChunk = 0;

    // The next chunk we care about is the "data" chunk. This is not necessarily the next chunk so we'll need to loop.
    drwav_uint64 dataSize;
    for (;;)
    {
        drwav__chunk_header header;
        if (!drwav__read_chunk_header(onRead, pUserData, pWav->container, &pWav->dataChunkDataPos, &header)) {
            return DRWAV_FALSE;
        }

        dataSize = header.sizeInBytes;
        if (pWav->container == drwav_container_riff) {
            if (drwav__fourcc_equal(header.id.fourcc, "data")) {
                break;
            }
        } else {
            if (drwav__guid_equal(header.id.guid, drwavGUID_W64_DATA)) {
                break;
            }
        }

        // Optional. Get the total sample count from the FACT chunk. This is useful for compressed formats.
        if (pWav->container == drwav_container_riff) {
            if (drwav__fourcc_equal(header.id.fourcc, "fact")) {
                drwav_uint32 sampleCount;
                if (onRead(pUserData, &sampleCount, 4) != 4) {
                    return DRWAV_FALSE;
                }
                pWav->dataChunkDataPos += 4;
                dataSize -= 4;

                // The sample count in the "fact" chunk is either unreliable, or I'm not understanding it properly. For now I am only enabling this
                // for Microsoft ADPCM formats.
                if (pWav->translatedFormatTag == DR_WAVE_FORMAT_ADPCM) {
                    sampleCountFromFactChunk = sampleCount;
                } else {
                    sampleCountFromFactChunk = 0;
                }
            }
        } else {
            if (drwav__guid_equal(header.id.guid, drwavGUID_W64_FACT)) {
                if (onRead(pUserData, &sampleCountFromFactChunk, 8) != 8) {
                    return DRWAV_FALSE;
                }
                pWav->dataChunkDataPos += 4;
                dataSize -= 8;
            }
        }

        // If we get here it means we didn't find the "data" chunk. Seek past it.

        // Make sure we seek past the padding.
        dataSize += header.paddingSize;
        drwav__seek_forward(onSeek, dataSize, pUserData);
        pWav->dataChunkDataPos += dataSize;
    }

    // At this point we should be sitting on the first byte of the raw audio data.

    pWav->onRead              = onRead;
    pWav->onSeek              = onSeek;
    pWav->pUserData           = pUserData;
    pWav->fmt                 = fmt;
    pWav->sampleRate          = fmt.sampleRate;
    pWav->channels            = fmt.channels;
    pWav->bitsPerSample       = fmt.bitsPerSample;
    pWav->bytesPerSample      = (unsigned int)(fmt.blockAlign / fmt.channels);
    pWav->bytesRemaining      = dataSize;
    pWav->translatedFormatTag = translatedFormatTag;
    pWav->dataChunkDataSize   = dataSize;

    if (sampleCountFromFactChunk != 0) {
        pWav->totalSampleCount = sampleCountFromFactChunk * fmt.channels;
    } else {
        pWav->totalSampleCount = dataSize / pWav->bytesPerSample;

        if (pWav->translatedFormatTag == DR_WAVE_FORMAT_ADPCM) {
            drwav_uint64 blockCount = dataSize / fmt.blockAlign;
            pWav->totalSampleCount = (blockCount * (fmt.blockAlign - (6*pWav->channels))) * 2;  // x2 because two samples per byte.
        }
        if (pWav->translatedFormatTag == DR_WAVE_FORMAT_DVI_ADPCM) {
            drwav_uint64 blockCount = dataSize / fmt.blockAlign;
            pWav->totalSampleCount = ((blockCount * (fmt.blockAlign - (4*pWav->channels))) * 2) + (blockCount * pWav->channels);
        }
    }
    
    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_ADPCM) {
        pWav->bytesPerSample = 0;
    }

#ifdef DR_WAV_LIBSNDFILE_COMPAT
    // I use libsndfile as a benchmark for testing, however in the version I'm using (from the Windows installer on the libsndfile website),
    // it appears the total sample count libsndfile uses for MS-ADPCM is incorrect. It would seem they are computing the total sample count
    // from the number of blocks, however this results in the inclusion of the extra silent samples at the end of the last block. The correct
    // way to know the total sample count is to inspect the "fact" chunk which should always be present for compressed formats, and should
    // always include the sample count. This little block of code below is only used to emulate the libsndfile logic so I can properly run my
    // correctness tests against libsndfile and is disabled by default.
    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_ADPCM) {
        drwav_uint64 blockCount = dataSize / fmt.blockAlign;
        pWav->totalSampleCount = (blockCount * (fmt.blockAlign - (6*pWav->channels))) * 2;  // x2 because two samples per byte.
    }
    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_DVI_ADPCM) {
        drwav_uint64 blockCount = dataSize / fmt.blockAlign;
        pWav->totalSampleCount = ((blockCount * (fmt.blockAlign - (4*pWav->channels))) * 2) + (blockCount * pWav->channels);
    }
#endif

    return DRWAV_TRUE;
}

drwav_bool32 drwav_init_write(drwav* pWav, const drwav_data_format* pFormat, drwav_write_proc onWrite, drwav_seek_proc onSeek, void* pUserData)
{
    if (onWrite == NULL || onSeek == NULL) {
        return DRWAV_FALSE;
    }

    // Not currently supporting compressed formats. Will need to add support for the "fact" chunk before we enable this.
    if (pFormat->format == DR_WAVE_FORMAT_EXTENSIBLE) {
        return DRWAV_FALSE;
    }
    if (pFormat->format == DR_WAVE_FORMAT_ADPCM || pFormat->format == DR_WAVE_FORMAT_DVI_ADPCM) {
        return DRWAV_FALSE;
    }


    drwav_zero_memory(pWav, sizeof(*pWav));
    pWav->onWrite = onWrite;
    pWav->onSeek = onSeek;
    pWav->pUserData = pUserData;
    pWav->fmt.formatTag = (drwav_uint16)pFormat->format;
    pWav->fmt.channels = (drwav_uint16)pFormat->channels;
    pWav->fmt.sampleRate = pFormat->sampleRate;
    pWav->fmt.avgBytesPerSec = (drwav_uint32)((pFormat->bitsPerSample * pFormat->sampleRate * pFormat->channels) >> 3);
    pWav->fmt.blockAlign = (drwav_uint16)((pFormat->channels * pFormat->bitsPerSample) >> 3);
    pWav->fmt.bitsPerSample = (drwav_uint16)pFormat->bitsPerSample;
    pWav->fmt.extendedSize = 0;

    size_t runningPos = 0;

    // "RIFF" chunk.
    drwav_uint64 chunkSizeRIFF = 0;
    if (pFormat->container == drwav_container_riff) {
        runningPos += pWav->onWrite(pUserData, "RIFF", 4);
        runningPos += pWav->onWrite(pUserData, &chunkSizeRIFF, 4);
        runningPos += pWav->onWrite(pUserData, "WAVE", 4);
    } else {
        runningPos += pWav->onWrite(pUserData, drwavGUID_W64_RIFF, 16);
        runningPos += pWav->onWrite(pUserData, &chunkSizeRIFF, 8);
        runningPos += pWav->onWrite(pUserData, drwavGUID_W64_WAVE, 16);
    }

    // "fmt " chunk.
    drwav_uint64 chunkSizeFMT;
    if (pFormat->container == drwav_container_riff) {
        chunkSizeFMT = 16;
        runningPos += pWav->onWrite(pUserData, "fmt ", 4);
        runningPos += pWav->onWrite(pUserData, &chunkSizeFMT, 4);
    } else {
        chunkSizeFMT = 40;
        runningPos += pWav->onWrite(pUserData, drwavGUID_W64_FMT, 16);
        runningPos += pWav->onWrite(pUserData, &chunkSizeFMT, 8);
    }

    runningPos += pWav->onWrite(pUserData, &pWav->fmt.formatTag,      2);
    runningPos += pWav->onWrite(pUserData, &pWav->fmt.channels,       2);
    runningPos += pWav->onWrite(pUserData, &pWav->fmt.sampleRate,     4);
    runningPos += pWav->onWrite(pUserData, &pWav->fmt.avgBytesPerSec, 4);
    runningPos += pWav->onWrite(pUserData, &pWav->fmt.blockAlign,     2);
    runningPos += pWav->onWrite(pUserData, &pWav->fmt.bitsPerSample,  2);

    pWav->dataChunkDataPos = runningPos;
    pWav->dataChunkDataSize = 0;

    // "data" chunk.
    drwav_uint64 chunkSizeDATA = 0;
    if (pFormat->container == drwav_container_riff) {
        runningPos += pWav->onWrite(pUserData, "data", 4);
        runningPos += pWav->onWrite(pUserData, &chunkSizeDATA, 4);
    } else {
        runningPos += pWav->onWrite(pUserData, drwavGUID_W64_DATA, 16);
        runningPos += pWav->onWrite(pUserData, &chunkSizeDATA, 8);
    }


    // Simple validation.
    if (pFormat->container == drwav_container_riff) {
        if (runningPos != 20 + chunkSizeFMT + 8) {
            return DRWAV_FALSE;
        }
    } else {
        if (runningPos != 40 + chunkSizeFMT + 24) {
            return DRWAV_FALSE;
        }
    }
    


    // Set some properties for the client's convenience.
    pWav->container = pFormat->container;
    pWav->channels = (drwav_uint16)pFormat->channels;
    pWav->sampleRate = pFormat->sampleRate;
    pWav->bitsPerSample = (drwav_uint16)pFormat->bitsPerSample;
    pWav->bytesPerSample = (drwav_uint16)(pFormat->bitsPerSample >> 3);
    pWav->translatedFormatTag = (drwav_uint16)pFormat->format;

    return DRWAV_TRUE;
}

void drwav_uninit(drwav* pWav)
{
    if (pWav == NULL) {
        return;
    }

    // If the drwav object was opened in write mode we'll need to finialize a few things:
    //   - Make sure the "data" chunk is aligned to 16-bits
    //   - Set the size of the "data" chunk.
    if (pWav->onWrite != NULL) {
        // Padding. Do not adjust pWav->dataChunkDataSize - this should not include the padding.
        drwav_uint32 paddingSize = 0;
        if (pWav->container == drwav_container_riff) {
            paddingSize = (drwav_uint32)(pWav->dataChunkDataSize % 2);
        } else {
            paddingSize = (drwav_uint32)(pWav->dataChunkDataSize % 8);
        }
        
        if (paddingSize > 0) {
            drwav_uint64 paddingData = 0;
            pWav->onWrite(pWav->pUserData, &paddingData, paddingSize);
        }


        // Chunk sizes.
        if (pWav->onSeek) {
            if (pWav->container == drwav_container_riff) {
                // The "RIFF" chunk size.
                if (pWav->onSeek(pWav->pUserData, 4, drwav_seek_origin_start)) {
                    drwav_uint32 riffChunkSize = 36;
                    if (pWav->dataChunkDataSize <= (0xFFFFFFFF - 36)) {
                        riffChunkSize = 36 + (drwav_uint32)pWav->dataChunkDataSize;
                    } else {
                        riffChunkSize = 0xFFFFFFFF;
                    }

                    pWav->onWrite(pWav->pUserData, &riffChunkSize, 4);
                }

                // the "data" chunk size.
                if (pWav->onSeek(pWav->pUserData, (int)pWav->dataChunkDataPos + 4, drwav_seek_origin_start)) {
                    drwav_uint32 dataChunkSize = 0;
                    if (pWav->dataChunkDataSize <= 0xFFFFFFFF) {
                        dataChunkSize = (drwav_uint32)pWav->dataChunkDataSize;
                    } else {
                        dataChunkSize = 0xFFFFFFFF;
                    }
                    
                    pWav->onWrite(pWav->pUserData, &dataChunkSize, 4);
                }
            } else {
                // The "RIFF" chunk size.
                if (pWav->onSeek(pWav->pUserData, 16, drwav_seek_origin_start)) {
                    drwav_uint64 riffChunkSize = 80 + 24 + pWav->dataChunkDataSize;
                    pWav->onWrite(pWav->pUserData, &riffChunkSize, 8);
                }

                // The "data" chunk size.
                if (pWav->onSeek(pWav->pUserData, (int)pWav->dataChunkDataPos + 16, drwav_seek_origin_start)) {
                    drwav_uint64 dataChunkSize = 24 + pWav->dataChunkDataSize;  // +24 because W64 includes the size of the GUID and size fields.
                    pWav->onWrite(pWav->pUserData, &dataChunkSize, 8);
                }
            }
        }
    }

#ifndef DR_WAV_NO_STDIO
    // If we opened the file with drwav_open_file() we will want to close the file handle. We can know whether or not drwav_open_file()
    // was used by looking at the onRead and onSeek callbacks.
    if (pWav->onRead == drwav__on_read_stdio || pWav->onWrite == drwav__on_write_stdio) {
        fclose((FILE*)pWav->pUserData);
    }
#endif
}


drwav* drwav_open(drwav_read_proc onRead, drwav_seek_proc onSeek, void* pUserData)
{
    drwav* pWav = (drwav*)DRWAV_MALLOC(sizeof(*pWav));
    if (pWav == NULL) {
        return NULL;
    }

    if (!drwav_init(pWav, onRead, onSeek, pUserData)) {
        DRWAV_FREE(pWav);
        return NULL;
    }

    return pWav;
}

drwav* drwav_open_write(const drwav_data_format* pFormat, drwav_write_proc onWrite, drwav_seek_proc onSeek, void* pUserData)
{
    drwav* pWav = (drwav*)DRWAV_MALLOC(sizeof(*pWav));
    if (pWav == NULL) {
        return NULL;
    }

    if (!drwav_init_write(pWav, pFormat, onWrite, onSeek, pUserData)) {
        DRWAV_FREE(pWav);
        return NULL;
    }

    return pWav;
}

void drwav_close(drwav* pWav)
{
    drwav_uninit(pWav);
    DRWAV_FREE(pWav);
}


size_t drwav_read_raw(drwav* pWav, size_t bytesToRead, void* pBufferOut)
{
    if (pWav == NULL || bytesToRead == 0 || pBufferOut == NULL) {
        return 0;
    }

    if (bytesToRead > pWav->bytesRemaining) {
        bytesToRead = (size_t)pWav->bytesRemaining;
    }

    size_t bytesRead = pWav->onRead(pWav->pUserData, pBufferOut, bytesToRead);

    pWav->bytesRemaining -= bytesRead;
    return bytesRead;
}

drwav_uint64 drwav_read(drwav* pWav, drwav_uint64 samplesToRead, void* pBufferOut)
{
    if (pWav == NULL || samplesToRead == 0 || pBufferOut == NULL) {
        return 0;
    }

    // Cannot use this function for compressed formats.
    if (drwav__is_compressed_format_tag(pWav->translatedFormatTag)) {
        return 0;
    }

    // Don't try to read more samples than can potentially fit in the output buffer.
    if (samplesToRead * pWav->bytesPerSample > SIZE_MAX) {
        samplesToRead = SIZE_MAX / pWav->bytesPerSample;
    }

    size_t bytesRead = drwav_read_raw(pWav, (size_t)(samplesToRead * pWav->bytesPerSample), pBufferOut);
    return bytesRead / pWav->bytesPerSample;
}

drwav_bool32 drwav_seek_to_first_sample(drwav* pWav)
{
    if (!pWav->onSeek(pWav->pUserData, (int)pWav->dataChunkDataPos, drwav_seek_origin_start)) {
        return DRWAV_FALSE;
    }

    if (drwav__is_compressed_format_tag(pWav->translatedFormatTag)) {
        pWav->compressed.iCurrentSample = 0;
    }
    
    pWav->bytesRemaining = pWav->dataChunkDataSize;
    return DRWAV_TRUE;
}

drwav_bool32 drwav_seek_to_sample(drwav* pWav, drwav_uint64 sample)
{
    // Seeking should be compatible with wave files > 2GB.

    if (pWav == NULL || pWav->onSeek == NULL) {
        return DRWAV_FALSE;
    }

    // If there are no samples, just return DRWAV_TRUE without doing anything.
    if (pWav->totalSampleCount == 0) {
        return DRWAV_TRUE;
    }

    // Make sure the sample is clamped.
    if (sample >= pWav->totalSampleCount) {
        sample  = pWav->totalSampleCount - 1;
    }


    // For compressed formats we just use a slow generic seek. If we are seeking forward we just seek forward. If we are going backwards we need
    // to seek back to the start.
    if (drwav__is_compressed_format_tag(pWav->translatedFormatTag)) {
        // TODO: This can be optimized.
        if (sample > pWav->compressed.iCurrentSample) {
            // Seeking forward - just move from the current position.
            drwav_uint64 offset = sample - pWav->compressed.iCurrentSample;

            drwav_int16 devnull[2048];
            while (offset > 0) {
                drwav_uint64 samplesToRead = sample;
                if (samplesToRead > 2048) {
                    samplesToRead = 2048;
                }

                drwav_uint64 samplesRead = drwav_read_s16(pWav, samplesToRead, devnull);
                if (samplesRead != samplesToRead) {
                    return DRWAV_FALSE;
                }

                offset -= samplesRead;
            }
        } else {
            // Seeking backwards. Just use the fallback.
            goto fallback;
        }
    } else {
        drwav_uint64 totalSizeInBytes = pWav->totalSampleCount * pWav->bytesPerSample;
        drwav_assert(totalSizeInBytes >= pWav->bytesRemaining);

        drwav_uint64 currentBytePos = totalSizeInBytes - pWav->bytesRemaining;
        drwav_uint64 targetBytePos  = sample * pWav->bytesPerSample;

        drwav_uint64 offset;
        if (currentBytePos < targetBytePos) {
            // Offset forwards.
            offset = (targetBytePos - currentBytePos);
        } else {
            // Offset backwards.
            if (!drwav_seek_to_first_sample(pWav)) {
                return DRWAV_FALSE;
            }
            offset = targetBytePos;
        }

        while (offset > 0) {
            int offset32 = ((offset > INT_MAX) ? INT_MAX : (int)offset);
            if (!pWav->onSeek(pWav->pUserData, offset32, drwav_seek_origin_current)) {
                return DRWAV_FALSE;
            }

            pWav->bytesRemaining -= offset32;
            offset -= offset32;
        }
    }

    return DRWAV_TRUE;

fallback:
    // This is a generic seek implementation that just continuously reads samples into a temporary buffer. This should work for all supported
    // formats, but it is not efficient. This should be used as a fall back.
    if (!drwav_seek_to_first_sample(pWav)) {
        return DRWAV_FALSE;
    }

    drwav_int16 devnull[2048];
    while (sample > 0) {
        drwav_uint64 samplesToRead = sample;
        if (samplesToRead > 2048) {
            samplesToRead = 2048;
        }

        drwav_uint64 samplesRead = drwav_read_s16(pWav, samplesToRead, devnull);
        if (samplesRead != samplesToRead) {
            return DRWAV_FALSE;
        }

        sample -= samplesRead;
    }

    return DRWAV_TRUE;
}


size_t drwav_write_raw(drwav* pWav, size_t bytesToWrite, const void* pData)
{
    if (pWav == NULL || bytesToWrite == 0 || pData == NULL) {
        return 0;
    }

    size_t bytesWritten = pWav->onWrite(pWav->pUserData, pData, bytesToWrite);
    pWav->dataChunkDataSize += bytesWritten;

    return bytesWritten;
}

drwav_uint64 drwav_write(drwav* pWav, drwav_uint64 samplesToWrite, const void* pData)
{
    if (pWav == NULL || samplesToWrite == 0 || pData == NULL) {
        return 0;
    }

    drwav_uint64 bytesToWrite = ((samplesToWrite * pWav->bitsPerSample) / 8);
    if (bytesToWrite > SIZE_MAX) {
        return 0;
    }

    size_t bytesWritten = drwav_write_raw(pWav, (size_t)bytesToWrite, pData);
    return ((drwav_uint64)bytesWritten * 8) / pWav->bitsPerSample;
}


#ifndef DR_WAV_NO_CONVERSION_API
static unsigned short g_drwavAlawTable[256] = {
    0xEA80, 0xEB80, 0xE880, 0xE980, 0xEE80, 0xEF80, 0xEC80, 0xED80, 0xE280, 0xE380, 0xE080, 0xE180, 0xE680, 0xE780, 0xE480, 0xE580, 
    0xF540, 0xF5C0, 0xF440, 0xF4C0, 0xF740, 0xF7C0, 0xF640, 0xF6C0, 0xF140, 0xF1C0, 0xF040, 0xF0C0, 0xF340, 0xF3C0, 0xF240, 0xF2C0, 
    0xAA00, 0xAE00, 0xA200, 0xA600, 0xBA00, 0xBE00, 0xB200, 0xB600, 0x8A00, 0x8E00, 0x8200, 0x8600, 0x9A00, 0x9E00, 0x9200, 0x9600, 
    0xD500, 0xD700, 0xD100, 0xD300, 0xDD00, 0xDF00, 0xD900, 0xDB00, 0xC500, 0xC700, 0xC100, 0xC300, 0xCD00, 0xCF00, 0xC900, 0xCB00, 
    0xFEA8, 0xFEB8, 0xFE88, 0xFE98, 0xFEE8, 0xFEF8, 0xFEC8, 0xFED8, 0xFE28, 0xFE38, 0xFE08, 0xFE18, 0xFE68, 0xFE78, 0xFE48, 0xFE58, 
    0xFFA8, 0xFFB8, 0xFF88, 0xFF98, 0xFFE8, 0xFFF8, 0xFFC8, 0xFFD8, 0xFF28, 0xFF38, 0xFF08, 0xFF18, 0xFF68, 0xFF78, 0xFF48, 0xFF58, 
    0xFAA0, 0xFAE0, 0xFA20, 0xFA60, 0xFBA0, 0xFBE0, 0xFB20, 0xFB60, 0xF8A0, 0xF8E0, 0xF820, 0xF860, 0xF9A0, 0xF9E0, 0xF920, 0xF960, 
    0xFD50, 0xFD70, 0xFD10, 0xFD30, 0xFDD0, 0xFDF0, 0xFD90, 0xFDB0, 0xFC50, 0xFC70, 0xFC10, 0xFC30, 0xFCD0, 0xFCF0, 0xFC90, 0xFCB0, 
    0x1580, 0x1480, 0x1780, 0x1680, 0x1180, 0x1080, 0x1380, 0x1280, 0x1D80, 0x1C80, 0x1F80, 0x1E80, 0x1980, 0x1880, 0x1B80, 0x1A80, 
    0x0AC0, 0x0A40, 0x0BC0, 0x0B40, 0x08C0, 0x0840, 0x09C0, 0x0940, 0x0EC0, 0x0E40, 0x0FC0, 0x0F40, 0x0CC0, 0x0C40, 0x0DC0, 0x0D40, 
    0x5600, 0x5200, 0x5E00, 0x5A00, 0x4600, 0x4200, 0x4E00, 0x4A00, 0x7600, 0x7200, 0x7E00, 0x7A00, 0x6600, 0x6200, 0x6E00, 0x6A00, 
    0x2B00, 0x2900, 0x2F00, 0x2D00, 0x2300, 0x2100, 0x2700, 0x2500, 0x3B00, 0x3900, 0x3F00, 0x3D00, 0x3300, 0x3100, 0x3700, 0x3500, 
    0x0158, 0x0148, 0x0178, 0x0168, 0x0118, 0x0108, 0x0138, 0x0128, 0x01D8, 0x01C8, 0x01F8, 0x01E8, 0x0198, 0x0188, 0x01B8, 0x01A8, 
    0x0058, 0x0048, 0x0078, 0x0068, 0x0018, 0x0008, 0x0038, 0x0028, 0x00D8, 0x00C8, 0x00F8, 0x00E8, 0x0098, 0x0088, 0x00B8, 0x00A8, 
    0x0560, 0x0520, 0x05E0, 0x05A0, 0x0460, 0x0420, 0x04E0, 0x04A0, 0x0760, 0x0720, 0x07E0, 0x07A0, 0x0660, 0x0620, 0x06E0, 0x06A0, 
    0x02B0, 0x0290, 0x02F0, 0x02D0, 0x0230, 0x0210, 0x0270, 0x0250, 0x03B0, 0x0390, 0x03F0, 0x03D0, 0x0330, 0x0310, 0x0370, 0x0350
};

static unsigned short g_drwavMulawTable[256] = {
    0x8284, 0x8684, 0x8A84, 0x8E84, 0x9284, 0x9684, 0x9A84, 0x9E84, 0xA284, 0xA684, 0xAA84, 0xAE84, 0xB284, 0xB684, 0xBA84, 0xBE84, 
    0xC184, 0xC384, 0xC584, 0xC784, 0xC984, 0xCB84, 0xCD84, 0xCF84, 0xD184, 0xD384, 0xD584, 0xD784, 0xD984, 0xDB84, 0xDD84, 0xDF84, 
    0xE104, 0xE204, 0xE304, 0xE404, 0xE504, 0xE604, 0xE704, 0xE804, 0xE904, 0xEA04, 0xEB04, 0xEC04, 0xED04, 0xEE04, 0xEF04, 0xF004, 
    0xF0C4, 0xF144, 0xF1C4, 0xF244, 0xF2C4, 0xF344, 0xF3C4, 0xF444, 0xF4C4, 0xF544, 0xF5C4, 0xF644, 0xF6C4, 0xF744, 0xF7C4, 0xF844, 
    0xF8A4, 0xF8E4, 0xF924, 0xF964, 0xF9A4, 0xF9E4, 0xFA24, 0xFA64, 0xFAA4, 0xFAE4, 0xFB24, 0xFB64, 0xFBA4, 0xFBE4, 0xFC24, 0xFC64, 
    0xFC94, 0xFCB4, 0xFCD4, 0xFCF4, 0xFD14, 0xFD34, 0xFD54, 0xFD74, 0xFD94, 0xFDB4, 0xFDD4, 0xFDF4, 0xFE14, 0xFE34, 0xFE54, 0xFE74, 
    0xFE8C, 0xFE9C, 0xFEAC, 0xFEBC, 0xFECC, 0xFEDC, 0xFEEC, 0xFEFC, 0xFF0C, 0xFF1C, 0xFF2C, 0xFF3C, 0xFF4C, 0xFF5C, 0xFF6C, 0xFF7C, 
    0xFF88, 0xFF90, 0xFF98, 0xFFA0, 0xFFA8, 0xFFB0, 0xFFB8, 0xFFC0, 0xFFC8, 0xFFD0, 0xFFD8, 0xFFE0, 0xFFE8, 0xFFF0, 0xFFF8, 0x0000, 
    0x7D7C, 0x797C, 0x757C, 0x717C, 0x6D7C, 0x697C, 0x657C, 0x617C, 0x5D7C, 0x597C, 0x557C, 0x517C, 0x4D7C, 0x497C, 0x457C, 0x417C, 
    0x3E7C, 0x3C7C, 0x3A7C, 0x387C, 0x367C, 0x347C, 0x327C, 0x307C, 0x2E7C, 0x2C7C, 0x2A7C, 0x287C, 0x267C, 0x247C, 0x227C, 0x207C, 
    0x1EFC, 0x1DFC, 0x1CFC, 0x1BFC, 0x1AFC, 0x19FC, 0x18FC, 0x17FC, 0x16FC, 0x15FC, 0x14FC, 0x13FC, 0x12FC, 0x11FC, 0x10FC, 0x0FFC, 
    0x0F3C, 0x0EBC, 0x0E3C, 0x0DBC, 0x0D3C, 0x0CBC, 0x0C3C, 0x0BBC, 0x0B3C, 0x0ABC, 0x0A3C, 0x09BC, 0x093C, 0x08BC, 0x083C, 0x07BC, 
    0x075C, 0x071C, 0x06DC, 0x069C, 0x065C, 0x061C, 0x05DC, 0x059C, 0x055C, 0x051C, 0x04DC, 0x049C, 0x045C, 0x041C, 0x03DC, 0x039C, 
    0x036C, 0x034C, 0x032C, 0x030C, 0x02EC, 0x02CC, 0x02AC, 0x028C, 0x026C, 0x024C, 0x022C, 0x020C, 0x01EC, 0x01CC, 0x01AC, 0x018C, 
    0x0174, 0x0164, 0x0154, 0x0144, 0x0134, 0x0124, 0x0114, 0x0104, 0x00F4, 0x00E4, 0x00D4, 0x00C4, 0x00B4, 0x00A4, 0x0094, 0x0084, 
    0x0078, 0x0070, 0x0068, 0x0060, 0x0058, 0x0050, 0x0048, 0x0040, 0x0038, 0x0030, 0x0028, 0x0020, 0x0018, 0x0010, 0x0008, 0x0000
};

static DRWAV_INLINE drwav_int16 drwav__alaw_to_s16(drwav_uint8 sampleIn)
{
    return (short)g_drwavAlawTable[sampleIn];
}

static DRWAV_INLINE drwav_int16 drwav__mulaw_to_s16(drwav_uint8 sampleIn)
{
    return (short)g_drwavMulawTable[sampleIn];
}



static void drwav__pcm_to_s16(drwav_int16* pOut, const unsigned char* pIn, size_t totalSampleCount, unsigned short bytesPerSample)
{
    unsigned int i;
    unsigned short j;
    // Special case for 8-bit sample data because it's treated as unsigned.
    if (bytesPerSample == 1) {
        drwav_u8_to_s16(pOut, pIn, totalSampleCount);
        return;
    }


    // Slightly more optimal implementation for common formats.
    if (bytesPerSample == 2) {
        for (i = 0; i < totalSampleCount; ++i) {
           *pOut++ = ((drwav_int16*)pIn)[i];
        }
        return;
    }
    if (bytesPerSample == 3) {
        drwav_s24_to_s16(pOut, pIn, totalSampleCount);
        return;
    }
    if (bytesPerSample == 4) {
        drwav_s32_to_s16(pOut, (const drwav_int32*)pIn, totalSampleCount);
        return;
    }


    // Generic, slow converter.
    for (i = 0; i < totalSampleCount; ++i) {
        unsigned short sample = 0;
        unsigned short shift  = (8 - bytesPerSample) * 8;
        for (j = 0; j < bytesPerSample && j < 2; ++j) {
            sample |= (unsigned short)(pIn[j]) << shift;
            shift  += 8;
        }

        pIn += bytesPerSample;
        *pOut++ = sample;
    }
}

static void drwav__ieee_to_s16(drwav_int16* pOut, const unsigned char* pIn, size_t totalSampleCount, unsigned short bytesPerSample)
{
    if (bytesPerSample == 4) {
        drwav_f32_to_s16(pOut, (float*)pIn, totalSampleCount);
        return;
    } else {
        drwav_f64_to_s16(pOut, (double*)pIn, totalSampleCount);
        return;
    }
}

drwav_uint64 drwav_read_s16__pcm(drwav* pWav, drwav_uint64 samplesToRead, drwav_int16* pBufferOut)
{
    // Fast path.
    if (pWav->bytesPerSample == 2) {
        return drwav_read(pWav, samplesToRead, pBufferOut);
    }

    drwav_uint64 totalSamplesRead = 0;
    unsigned char sampleData[4096];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read(pWav, drwav_min(samplesToRead, sizeof(sampleData)/pWav->bytesPerSample), sampleData);
        if (samplesRead == 0) {
            break;
        }

        drwav__pcm_to_s16(pBufferOut, sampleData, (size_t)samplesRead, pWav->bytesPerSample);

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_s16__msadpcm(drwav* pWav, drwav_uint64 samplesToRead, drwav_int16* pBufferOut)
{
    drwav_assert(pWav != NULL);
    drwav_assert(samplesToRead > 0);
    drwav_assert(pBufferOut != NULL);

    // TODO: Lots of room for optimization here.

    drwav_uint64 totalSamplesRead = 0;

    while (samplesToRead > 0 && pWav->compressed.iCurrentSample < pWav->totalSampleCount) {
        // If there are no cached samples we need to load a new block.
        if (pWav->msadpcm.cachedSampleCount == 0 && pWav->msadpcm.bytesRemainingInBlock == 0) {
            if (pWav->channels == 1) {
                // Mono.
                drwav_uint8 header[7];
                if (pWav->onRead(pWav->pUserData, header, sizeof(header)) != sizeof(header)) {
                    return totalSamplesRead;
                }
                pWav->msadpcm.bytesRemainingInBlock = pWav->fmt.blockAlign - sizeof(header);

                pWav->msadpcm.predictor[0] = header[0];
                pWav->msadpcm.delta[0] = drwav__bytes_to_s16(header + 1);
                pWav->msadpcm.prevSamples[0][1] = (drwav_int32)drwav__bytes_to_s16(header + 3);
                pWav->msadpcm.prevSamples[0][0] = (drwav_int32)drwav__bytes_to_s16(header + 5);
                pWav->msadpcm.cachedSamples[2] = pWav->msadpcm.prevSamples[0][0];
                pWav->msadpcm.cachedSamples[3] = pWav->msadpcm.prevSamples[0][1];
                pWav->msadpcm.cachedSampleCount = 2;
            } else {
                // Stereo.
                drwav_uint8 header[14];
                if (pWav->onRead(pWav->pUserData, header, sizeof(header)) != sizeof(header)) {
                    return totalSamplesRead;
                }
                pWav->msadpcm.bytesRemainingInBlock = pWav->fmt.blockAlign - sizeof(header);

                pWav->msadpcm.predictor[0] = header[0];
                pWav->msadpcm.predictor[1] = header[1];
                pWav->msadpcm.delta[0] = drwav__bytes_to_s16(header + 2);
                pWav->msadpcm.delta[1] = drwav__bytes_to_s16(header + 4);
                pWav->msadpcm.prevSamples[0][1] = (drwav_int32)drwav__bytes_to_s16(header + 6);
                pWav->msadpcm.prevSamples[1][1] = (drwav_int32)drwav__bytes_to_s16(header + 8);
                pWav->msadpcm.prevSamples[0][0] = (drwav_int32)drwav__bytes_to_s16(header + 10);
                pWav->msadpcm.prevSamples[1][0] = (drwav_int32)drwav__bytes_to_s16(header + 12);

                pWav->msadpcm.cachedSamples[0] = pWav->msadpcm.prevSamples[0][0];
                pWav->msadpcm.cachedSamples[1] = pWav->msadpcm.prevSamples[1][0];
                pWav->msadpcm.cachedSamples[2] = pWav->msadpcm.prevSamples[0][1];
                pWav->msadpcm.cachedSamples[3] = pWav->msadpcm.prevSamples[1][1];
                pWav->msadpcm.cachedSampleCount = 4;
            }
        }

        // Output anything that's cached.
        while (samplesToRead > 0 && pWav->msadpcm.cachedSampleCount > 0 && pWav->compressed.iCurrentSample < pWav->totalSampleCount) {
            pBufferOut[0] = (drwav_int16)pWav->msadpcm.cachedSamples[drwav_countof(pWav->msadpcm.cachedSamples) - pWav->msadpcm.cachedSampleCount];
            pWav->msadpcm.cachedSampleCount -= 1;

            pBufferOut += 1;
            samplesToRead -= 1;
            totalSamplesRead += 1;
            pWav->compressed.iCurrentSample += 1;
        }

        if (samplesToRead == 0) {
            return totalSamplesRead;
        }


        // If there's nothing left in the cache, just go ahead and load more. If there's nothing left to load in the current block we just continue to the next
        // loop iteration which will trigger the loading of a new block.
        if (pWav->msadpcm.cachedSampleCount == 0) {
            if (pWav->msadpcm.bytesRemainingInBlock == 0) {
                continue;
            } else {
                drwav_uint8 nibbles;
                if (pWav->onRead(pWav->pUserData, &nibbles, 1) != 1) {
                    return totalSamplesRead;
                }
                pWav->msadpcm.bytesRemainingInBlock -= 1;

                // TODO: Optimize away these if statements.
                drwav_int32 nibble0 = ((nibbles & 0xF0) >> 4); if ((nibbles & 0x80)) { nibble0 |= 0xFFFFFFF0UL; }
                drwav_int32 nibble1 = ((nibbles & 0x0F) >> 0); if ((nibbles & 0x08)) { nibble1 |= 0xFFFFFFF0UL; }

                static drwav_int32 adaptationTable[] = { 
                    230, 230, 230, 230, 307, 409, 512, 614, 
                    768, 614, 512, 409, 307, 230, 230, 230 
                };
                static drwav_int32 coeff1Table[] = { 256, 512, 0, 192, 240, 460,  392 };
                static drwav_int32 coeff2Table[] = { 0,  -256, 0, 64,  0,  -208, -232 };

                if (pWav->channels == 1) {
                    // Mono.
                    drwav_int32 newSample0;
                    newSample0  = ((pWav->msadpcm.prevSamples[0][1] * coeff1Table[pWav->msadpcm.predictor[0]]) + (pWav->msadpcm.prevSamples[0][0] * coeff2Table[pWav->msadpcm.predictor[0]])) >> 8;
                    newSample0 += nibble0 * pWav->msadpcm.delta[0];
                    newSample0  = drwav_clamp(newSample0, -32768, 32767);

                    pWav->msadpcm.delta[0] = (adaptationTable[((nibbles & 0xF0) >> 4)] * pWav->msadpcm.delta[0]) >> 8;
                    if (pWav->msadpcm.delta[0] < 16) {
                        pWav->msadpcm.delta[0] = 16;
                    }

                    pWav->msadpcm.prevSamples[0][0] = pWav->msadpcm.prevSamples[0][1];
                    pWav->msadpcm.prevSamples[0][1] = newSample0;


                    drwav_int32 newSample1;
                    newSample1  = ((pWav->msadpcm.prevSamples[0][1] * coeff1Table[pWav->msadpcm.predictor[0]]) + (pWav->msadpcm.prevSamples[0][0] * coeff2Table[pWav->msadpcm.predictor[0]])) >> 8;
                    newSample1 += nibble1 * pWav->msadpcm.delta[0];
                    newSample1  = drwav_clamp(newSample1, -32768, 32767);

                    pWav->msadpcm.delta[0] = (adaptationTable[((nibbles & 0x0F) >> 0)] * pWav->msadpcm.delta[0]) >> 8;
                    if (pWav->msadpcm.delta[0] < 16) {
                        pWav->msadpcm.delta[0] = 16;
                    }

                    pWav->msadpcm.prevSamples[0][0] = pWav->msadpcm.prevSamples[0][1];
                    pWav->msadpcm.prevSamples[0][1] = newSample1;


                    pWav->msadpcm.cachedSamples[2] = newSample0;
                    pWav->msadpcm.cachedSamples[3] = newSample1;
                    pWav->msadpcm.cachedSampleCount = 2;
                } else {
                    // Stereo.

                    // Left.
                    drwav_int32 newSample0;
                    newSample0  = ((pWav->msadpcm.prevSamples[0][1] * coeff1Table[pWav->msadpcm.predictor[0]]) + (pWav->msadpcm.prevSamples[0][0] * coeff2Table[pWav->msadpcm.predictor[0]])) >> 8;
                    newSample0 += nibble0 * pWav->msadpcm.delta[0];
                    newSample0  = drwav_clamp(newSample0, -32768, 32767);

                    pWav->msadpcm.delta[0] = (adaptationTable[((nibbles & 0xF0) >> 4)] * pWav->msadpcm.delta[0]) >> 8;
                    if (pWav->msadpcm.delta[0] < 16) {
                        pWav->msadpcm.delta[0] = 16;
                    }

                    pWav->msadpcm.prevSamples[0][0] = pWav->msadpcm.prevSamples[0][1];
                    pWav->msadpcm.prevSamples[0][1] = newSample0;


                    // Right.
                    drwav_int32 newSample1;
                    newSample1  = ((pWav->msadpcm.prevSamples[1][1] * coeff1Table[pWav->msadpcm.predictor[1]]) + (pWav->msadpcm.prevSamples[1][0] * coeff2Table[pWav->msadpcm.predictor[1]])) >> 8;
                    newSample1 += nibble1 * pWav->msadpcm.delta[1];
                    newSample1  = drwav_clamp(newSample1, -32768, 32767);

                    pWav->msadpcm.delta[1] = (adaptationTable[((nibbles & 0x0F) >> 0)] * pWav->msadpcm.delta[1]) >> 8;
                    if (pWav->msadpcm.delta[1] < 16) {
                        pWav->msadpcm.delta[1] = 16;
                    }

                    pWav->msadpcm.prevSamples[1][0] = pWav->msadpcm.prevSamples[1][1];
                    pWav->msadpcm.prevSamples[1][1] = newSample1;

                    pWav->msadpcm.cachedSamples[2] = newSample0;
                    pWav->msadpcm.cachedSamples[3] = newSample1;
                    pWav->msadpcm.cachedSampleCount = 2;
                }
            }
        }
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_s16__ima(drwav* pWav, drwav_uint64 samplesToRead, drwav_int16* pBufferOut)
{
    drwav_uint32 iChannel;
    drwav_uint32 iByte;
    drwav_assert(pWav != NULL);
    drwav_assert(samplesToRead > 0);
    drwav_assert(pBufferOut != NULL);

    // TODO: Lots of room for optimization here.

    drwav_uint64 totalSamplesRead = 0;

    while (samplesToRead > 0 && pWav->compressed.iCurrentSample < pWav->totalSampleCount) {
        // If there are no cached samples we need to load a new block.
        if (pWav->ima.cachedSampleCount == 0 && pWav->ima.bytesRemainingInBlock == 0) {
            if (pWav->channels == 1) {
                // Mono.
                drwav_uint8 header[4];
                if (pWav->onRead(pWav->pUserData, header, sizeof(header)) != sizeof(header)) {
                    return totalSamplesRead;
                }
                pWav->ima.bytesRemainingInBlock = pWav->fmt.blockAlign - sizeof(header);

                pWav->ima.predictor[0] = drwav__bytes_to_s16(header + 0);
                pWav->ima.stepIndex[0] = header[2];
                pWav->ima.cachedSamples[drwav_countof(pWav->ima.cachedSamples) - 1] = pWav->ima.predictor[0];
                pWav->ima.cachedSampleCount = 1;
            } else {
                // Stereo.
                drwav_uint8 header[8];
                if (pWav->onRead(pWav->pUserData, header, sizeof(header)) != sizeof(header)) {
                    return totalSamplesRead;
                }
                pWav->ima.bytesRemainingInBlock = pWav->fmt.blockAlign - sizeof(header);

                pWav->ima.predictor[0] = drwav__bytes_to_s16(header + 0);
                pWav->ima.stepIndex[0] = header[2];
                pWav->ima.predictor[1] = drwav__bytes_to_s16(header + 4);
                pWav->ima.stepIndex[1] = header[6];

                pWav->ima.cachedSamples[drwav_countof(pWav->ima.cachedSamples) - 2] = pWav->ima.predictor[0];
                pWav->ima.cachedSamples[drwav_countof(pWav->ima.cachedSamples) - 1] = pWav->ima.predictor[1];
                pWav->ima.cachedSampleCount = 2;
            }
        }

        // Output anything that's cached.
        while (samplesToRead > 0 && pWav->ima.cachedSampleCount > 0 && pWav->compressed.iCurrentSample < pWav->totalSampleCount) {
            pBufferOut[0] = (drwav_int16)pWav->ima.cachedSamples[drwav_countof(pWav->ima.cachedSamples) - pWav->ima.cachedSampleCount];
            pWav->ima.cachedSampleCount -= 1;

            pBufferOut += 1;
            samplesToRead -= 1;
            totalSamplesRead += 1;
            pWav->compressed.iCurrentSample += 1;
        }

        if (samplesToRead == 0) {
            return totalSamplesRead;
        }

        // If there's nothing left in the cache, just go ahead and load more. If there's nothing left to load in the current block we just continue to the next
        // loop iteration which will trigger the loading of a new block.
        if (pWav->ima.cachedSampleCount == 0) {
            if (pWav->ima.bytesRemainingInBlock == 0) {
                continue;
            } else {
                static drwav_int32 indexTable[16] = {
                    -1, -1, -1, -1, 2, 4, 6, 8,
                    -1, -1, -1, -1, 2, 4, 6, 8
                };

                static drwav_int32 stepTable[89] = { 
                    7,     8,     9,     10,    11,    12,    13,    14,    16,    17, 
                    19,    21,    23,    25,    28,    31,    34,    37,    41,    45, 
                    50,    55,    60,    66,    73,    80,    88,    97,    107,   118, 
                    130,   143,   157,   173,   190,   209,   230,   253,   279,   307,
                    337,   371,   408,   449,   494,   544,   598,   658,   724,   796,
                    876,   963,   1060,  1166,  1282,  1411,  1552,  1707,  1878,  2066, 
                    2272,  2499,  2749,  3024,  3327,  3660,  4026,  4428,  4871,  5358,
                    5894,  6484,  7132,  7845,  8630,  9493,  10442, 11487, 12635, 13899, 
                    15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767 
                };

                // From what I can tell with stereo streams, it looks like every 4 bytes (8 samples) is for one channel. So it goes 4 bytes for the
                // left channel, 4 bytes for the right channel.
                pWav->ima.cachedSampleCount = 8 * pWav->channels;
                for (iChannel = 0; iChannel < pWav->channels; ++iChannel) {
                    drwav_uint8 nibbles[4];
                    if (pWav->onRead(pWav->pUserData, &nibbles, 4) != 4) {
                        return totalSamplesRead;
                    }
                    pWav->ima.bytesRemainingInBlock -= 4;

                    for (iByte = 0; iByte < 4; ++iByte) {
                        drwav_uint8 nibble0 = ((nibbles[iByte] & 0x0F) >> 0);
                        drwav_uint8 nibble1 = ((nibbles[iByte] & 0xF0) >> 4);

                        drwav_int32 step      = stepTable[pWav->ima.stepIndex[iChannel]];
                        drwav_int32 predictor = pWav->ima.predictor[iChannel];

                        drwav_int32      diff  = step >> 3;
                        if (nibble0 & 1) diff += step >> 2;
                        if (nibble0 & 2) diff += step >> 1;
                        if (nibble0 & 4) diff += step;
                        if (nibble0 & 8) diff  = -diff;

                        predictor = drwav_clamp(predictor + diff, -32768, 32767);
                        pWav->ima.predictor[iChannel] = predictor;
                        pWav->ima.stepIndex[iChannel] = drwav_clamp(pWav->ima.stepIndex[iChannel] + indexTable[nibble0], 0, (drwav_int32)drwav_countof(stepTable)-1);
                        pWav->ima.cachedSamples[(drwav_countof(pWav->ima.cachedSamples) - pWav->ima.cachedSampleCount) + (iByte*2+0)*pWav->channels + iChannel] = predictor;


                        step      = stepTable[pWav->ima.stepIndex[iChannel]];
                        predictor = pWav->ima.predictor[iChannel];

                                         diff  = step >> 3;
                        if (nibble1 & 1) diff += step >> 2;
                        if (nibble1 & 2) diff += step >> 1;
                        if (nibble1 & 4) diff += step;
                        if (nibble1 & 8) diff  = -diff;

                        predictor = drwav_clamp(predictor + diff, -32768, 32767);
                        pWav->ima.predictor[iChannel] = predictor;
                        pWav->ima.stepIndex[iChannel] = drwav_clamp(pWav->ima.stepIndex[iChannel] + indexTable[nibble1], 0, (drwav_int32)drwav_countof(stepTable)-1);
                        pWav->ima.cachedSamples[(drwav_countof(pWav->ima.cachedSamples) - pWav->ima.cachedSampleCount) + (iByte*2+1)*pWav->channels + iChannel] = predictor;
                    }
                }
            }
        }
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_s16__ieee(drwav* pWav, drwav_uint64 samplesToRead, drwav_int16* pBufferOut)
{
    drwav_uint64 totalSamplesRead = 0;
    unsigned char sampleData[4096];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read(pWav, drwav_min(samplesToRead, sizeof(sampleData)/pWav->bytesPerSample), sampleData);
        if (samplesRead == 0) {
            break;
        }

        drwav__ieee_to_s16(pBufferOut, sampleData, (size_t)samplesRead, pWav->bytesPerSample);

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_s16__alaw(drwav* pWav, drwav_uint64 samplesToRead, drwav_int16* pBufferOut)
{
    drwav_uint64 totalSamplesRead = 0;
    unsigned char sampleData[4096];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read(pWav, drwav_min(samplesToRead, sizeof(sampleData)/pWav->bytesPerSample), sampleData);
        if (samplesRead == 0) {
            break;
        }

        drwav_alaw_to_s16(pBufferOut, sampleData, (size_t)samplesRead);

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_s16__mulaw(drwav* pWav, drwav_uint64 samplesToRead, drwav_int16* pBufferOut)
{
    drwav_uint64 totalSamplesRead = 0;
    unsigned char sampleData[4096];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read(pWav, drwav_min(samplesToRead, sizeof(sampleData)/pWav->bytesPerSample), sampleData);
        if (samplesRead == 0) {
            break;
        }

        drwav_mulaw_to_s16(pBufferOut, sampleData, (size_t)samplesRead);

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_s16(drwav* pWav, drwav_uint64 samplesToRead, drwav_int16* pBufferOut)
{
    if (pWav == NULL || samplesToRead == 0 || pBufferOut == NULL) {
        return 0;
    }

    // Don't try to read more samples than can potentially fit in the output buffer.
    if (samplesToRead * sizeof(drwav_int16) > SIZE_MAX) {
        samplesToRead = SIZE_MAX / sizeof(drwav_int16);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_PCM) {
        return drwav_read_s16__pcm(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_ADPCM) {
        return drwav_read_s16__msadpcm(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_IEEE_FLOAT) {
        return drwav_read_s16__ieee(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_ALAW) {
        return drwav_read_s16__alaw(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_MULAW) {
        return drwav_read_s16__mulaw(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_DVI_ADPCM) {
        return drwav_read_s16__ima(pWav, samplesToRead, pBufferOut);
    }

    return 0;
}

void drwav_u8_to_s16(drwav_int16* pOut, const drwav_uint8* pIn, size_t sampleCount)
{
    int r;
    size_t i;
    for (i = 0; i < sampleCount; ++i) {
        int x = pIn[i];
        r = x - 128;
        r = r << 8;
        pOut[i] = (short)r;
    }
}

void drwav_s24_to_s16(drwav_int16* pOut, const drwav_uint8* pIn, size_t sampleCount)
{
    int r;
    size_t i;
    for (i = 0; i < sampleCount; ++i) {
        int x = ((int)(((unsigned int)(((unsigned char*)pIn)[i*3+0]) << 8) | ((unsigned int)(((unsigned char*)pIn)[i*3+1]) << 16) | ((unsigned int)(((unsigned char*)pIn)[i*3+2])) << 24)) >> 8;
        r = x >> 8;
        pOut[i] = (short)r;
    }
}

void drwav_s32_to_s16(drwav_int16* pOut, const drwav_int32* pIn, size_t sampleCount)
{
    int r;
    size_t i;
    for (i = 0; i < sampleCount; ++i) {
        int x = pIn[i];
        r = x >> 16;
        pOut[i] = (short)r;
    }
}

void drwav_f32_to_s16(drwav_int16* pOut, const float* pIn, size_t sampleCount)
{
/*
    int r;
    for (size_t i = 0; i < sampleCount; ++i) {
        float x = pIn[i];
        float c;
        int s;
        c = ((x < -1) ? -1 : ((x > 1) ? 1 : x));
        s = ((*((int*)&x)) & 0x80000000) >> 31;
        s = s + 32767;
        r = (int)(c * s);
        pOut[i] = (short)r;
    }
*/
    fprintf(stderr, "Warning: drwav_f32_to_s16 has been deactivated!\n");
}

void drwav_f64_to_s16(drwav_int16* pOut, const double* pIn, size_t sampleCount)
{
/*
    int r;
    for (size_t i = 0; i < sampleCount; ++i) {
        double x = pIn[i];
        double c;
        int s;
        c = ((x < -1) ? -1 : ((x > 1) ? 1 : x));
        s = (int)(((*((drwav_uint64*)&x)) & (drwav_uint64)0x8000000000000000) >> 63);
        s = s + 32767;
        r = (int)(c * s);
        pOut[i] = (short)r;
    }
*/
    fprintf(stderr, "Warning: drwav_f64_to_s16 has been deactivated!\n");
}

void drwav_alaw_to_s16(drwav_int16* pOut, const drwav_uint8* pIn, size_t sampleCount)
{
    size_t i;
    for (i = 0; i < sampleCount; ++i) {
        pOut[i] = drwav__alaw_to_s16(pIn[i]);
    }
}

void drwav_mulaw_to_s16(drwav_int16* pOut, const drwav_uint8* pIn, size_t sampleCount)
{
    size_t i;
    for (i = 0; i < sampleCount; ++i) {
        pOut[i] = drwav__mulaw_to_s16(pIn[i]);
    }
}



static void drwav__pcm_to_f32(float* pOut, const unsigned char* pIn, size_t sampleCount, unsigned short bytesPerSample)
{
    unsigned int i;
    unsigned short j;
    // Special case for 8-bit sample data because it's treated as unsigned.
    if (bytesPerSample == 1) {
        drwav_u8_to_f32(pOut, pIn, sampleCount);
        return;
    }

    // Slightly more optimal implementation for common formats.
    if (bytesPerSample == 2) {
        drwav_s16_to_f32(pOut, (const drwav_int16*)pIn, sampleCount);
        return;
    }
    if (bytesPerSample == 3) {
        drwav_s24_to_f32(pOut, pIn, sampleCount);
        return;
    }
    if (bytesPerSample == 4) {
        drwav_s32_to_f32(pOut, (const drwav_int32*)pIn, sampleCount);
        return;
    }

    // Generic, slow converter.
    for (i = 0; i < sampleCount; ++i) {
        unsigned int sample = 0;
        unsigned int shift  = (8 - bytesPerSample) * 8;
        for (j = 0; j < bytesPerSample && j < 4; ++j) {
            sample |= (unsigned int)(pIn[j]) << shift;
            shift  += 8;
        }

        pIn += bytesPerSample;
        *pOut++ = (float)((int)sample / 2147483648.0);
    }
}

static void drwav__ieee_to_f32(float* pOut, const unsigned char* pIn, size_t sampleCount, unsigned short bytesPerSample)
{
    unsigned int i;
    if (bytesPerSample == 4) {
        for (i = 0; i < sampleCount; ++i) {
            *pOut++ = ((float*)pIn)[i];
        }
        return;
    } else {
        drwav_f64_to_f32(pOut, (double*)pIn, sampleCount);
        return;
    }
}


drwav_uint64 drwav_read_f32__pcm(drwav* pWav, drwav_uint64 samplesToRead, float* pBufferOut)
{
    drwav_uint64 totalSamplesRead = 0;
    unsigned char sampleData[4096];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read(pWav, drwav_min(samplesToRead, sizeof(sampleData)/pWav->bytesPerSample), sampleData);
        if (samplesRead == 0) {
            break;
        }

        drwav__pcm_to_f32(pBufferOut, sampleData, (size_t)samplesRead, pWav->bytesPerSample);
        pBufferOut += samplesRead;

        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_f32__msadpcm(drwav* pWav, drwav_uint64 samplesToRead, float* pBufferOut)
{
    // We're just going to borrow the implementation from the drwav_read_s16() since ADPCM is a little bit more complicated than other formats and I don't
    // want to duplicate that code.
    drwav_uint64 totalSamplesRead = 0;
    drwav_int16 samples16[2048];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read_s16(pWav, drwav_min(samplesToRead, 2048), samples16);
        if (samplesRead == 0) {
            break;
        }

        drwav_s16_to_f32(pBufferOut, samples16, (size_t)samplesRead);   // <-- Safe cast because we're clamping to 2048.

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_f32__ima(drwav* pWav, drwav_uint64 samplesToRead, float* pBufferOut)
{
    // We're just going to borrow the implementation from the drwav_read_s16() since IMA-ADPCM is a little bit more complicated than other formats and I don't
    // want to duplicate that code.
    drwav_uint64 totalSamplesRead = 0;
    drwav_int16 samples16[2048];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read_s16(pWav, drwav_min(samplesToRead, 2048), samples16);
        if (samplesRead == 0) {
            break;
        }

        drwav_s16_to_f32(pBufferOut, samples16, (size_t)samplesRead);   // <-- Safe cast because we're clamping to 2048.

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_f32__ieee(drwav* pWav, drwav_uint64 samplesToRead, float* pBufferOut)
{
    // Fast path.
    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_IEEE_FLOAT && pWav->bytesPerSample == 4) {
        return drwav_read(pWav, samplesToRead, pBufferOut);
    }

    drwav_uint64 totalSamplesRead = 0;
    unsigned char sampleData[4096];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read(pWav, drwav_min(samplesToRead, sizeof(sampleData)/pWav->bytesPerSample), sampleData);
        if (samplesRead == 0) {
            break;
        }

        drwav__ieee_to_f32(pBufferOut, sampleData, (size_t)samplesRead, pWav->bytesPerSample);

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_f32__alaw(drwav* pWav, drwav_uint64 samplesToRead, float* pBufferOut)
{
    drwav_uint64 totalSamplesRead = 0;
    unsigned char sampleData[4096];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read(pWav, drwav_min(samplesToRead, sizeof(sampleData)/pWav->bytesPerSample), sampleData);
        if (samplesRead == 0) {
            break;
        }

        drwav_alaw_to_f32(pBufferOut, sampleData, (size_t)samplesRead);

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_f32__mulaw(drwav* pWav, drwav_uint64 samplesToRead, float* pBufferOut)
{
    drwav_uint64 totalSamplesRead = 0;
    unsigned char sampleData[4096];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read(pWav, drwav_min(samplesToRead, sizeof(sampleData)/pWav->bytesPerSample), sampleData);
        if (samplesRead == 0) {
            break;
        }

        drwav_mulaw_to_f32(pBufferOut, sampleData, (size_t)samplesRead);

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_f32(drwav* pWav, drwav_uint64 samplesToRead, float* pBufferOut)
{
    if (pWav == NULL || samplesToRead == 0 || pBufferOut == NULL) {
        return 0;
    }

    // Don't try to read more samples than can potentially fit in the output buffer.
    if (samplesToRead * sizeof(float) > SIZE_MAX) {
        samplesToRead = SIZE_MAX / sizeof(float);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_PCM) {
        return drwav_read_f32__pcm(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_ADPCM) {
        return drwav_read_f32__msadpcm(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_IEEE_FLOAT) {
        return drwav_read_f32__ieee(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_ALAW) {
        return drwav_read_f32__alaw(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_MULAW) {
        return drwav_read_f32__mulaw(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_DVI_ADPCM) {
        return drwav_read_f32__ima(pWav, samplesToRead, pBufferOut);
    }

    return 0;
}

void drwav_u8_to_f32(float* pOut, const drwav_uint8* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

#ifdef DR_WAV_LIBSNDFILE_COMPAT
    // It appears libsndfile uses slightly different logic for the u8 -> f32 conversion to dr_wav, which in my opinion is incorrect. It appears
    // libsndfile performs the conversion something like "f32 = (u8 / 256) * 2 - 1", however I think it should be "f32 = (u8 / 255) * 2 - 1" (note
    // the divisor of 256 vs 255). I use libsndfile as a benchmark for testing, so I'm therefore leaving this block here just for my automated
    // correctness testing. This is disabled by default.
    for (i = 0; i < sampleCount; ++i) {
        *pOut++ = (pIn[i] / 256.0f) * 2 - 1;
    }
#else
    for (i = 0; i < sampleCount; ++i) {
        *pOut++ = (pIn[i] / 255.0f) * 2 - 1;
    }
#endif
}

void drwav_s16_to_f32(float* pOut, const drwav_int16* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i = 0; i < sampleCount; ++i) {
        *pOut++ = pIn[i] / 32768.0f;
    }
}

void drwav_s24_to_f32(float* pOut, const drwav_uint8* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i = 0; i < sampleCount; ++i) {
        unsigned int s0 = pIn[i*3 + 0];
        unsigned int s1 = pIn[i*3 + 1];
        unsigned int s2 = pIn[i*3 + 2];

        int sample32 = (int)((s0 << 8) | (s1 << 16) | (s2 << 24));
        *pOut++ = (float)(sample32 / 2147483648.0);
    }
}

void drwav_s32_to_f32(float* pOut, const drwav_int32* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i = 0; i < sampleCount; ++i) {
        *pOut++ = (float)(pIn[i] / 2147483648.0);
    }
}

void drwav_f64_to_f32(float* pOut, const double* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i = 0; i < sampleCount; ++i) {
        *pOut++ = (float)pIn[i];
    }
}

void drwav_alaw_to_f32(float* pOut, const drwav_uint8* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i = 0; i < sampleCount; ++i) {
        *pOut++ = drwav__alaw_to_s16(pIn[i]) / 32768.0f;
    }
}

void drwav_mulaw_to_f32(float* pOut, const drwav_uint8* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i = 0; i < sampleCount; ++i) {
        *pOut++ = drwav__mulaw_to_s16(pIn[i]) / 32768.0f;
    }
}



static void drwav__pcm_to_s32(drwav_int32* pOut, const unsigned char* pIn, size_t totalSampleCount, unsigned short bytesPerSample)
{
    unsigned int i;
    unsigned short j;
    // Special case for 8-bit sample data because it's treated as unsigned.
    if (bytesPerSample == 1) {
        drwav_u8_to_s32(pOut, pIn, totalSampleCount);
        return;
    }

    // Slightly more optimal implementation for common formats.
    if (bytesPerSample == 2) {
        drwav_s16_to_s32(pOut, (const drwav_int16*)pIn, totalSampleCount);
        return;
    }
    if (bytesPerSample == 3) {
        drwav_s24_to_s32(pOut, pIn, totalSampleCount);
        return;
    }
    if (bytesPerSample == 4) {
        for (i = 0; i < totalSampleCount; ++i) {
           *pOut++ = ((drwav_int32*)pIn)[i];
        }
        return;
    }

    // Generic, slow converter.
    for (i = 0; i < totalSampleCount; ++i) {
        unsigned int sample = 0;
        unsigned int shift  = (8 - bytesPerSample) * 8;
        for (j = 0; j < bytesPerSample && j < 4; ++j) {
            sample |= (unsigned int)(pIn[j]) << shift;
            shift  += 8;
        }

        pIn += bytesPerSample;
        *pOut++ = sample;
    }
}

static void drwav__ieee_to_s32(drwav_int32* pOut, const unsigned char* pIn, size_t totalSampleCount, unsigned short bytesPerSample)
{
    if (bytesPerSample == 4) {
        drwav_f32_to_s32(pOut, (float*)pIn, totalSampleCount);
        return;
    } else {
        drwav_f64_to_s32(pOut, (double*)pIn, totalSampleCount);
        return;
    }
}


drwav_uint64 drwav_read_s32__pcm(drwav* pWav, drwav_uint64 samplesToRead, drwav_int32* pBufferOut)
{
    // Fast path.
    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_PCM && pWav->bytesPerSample == 4) {
        return drwav_read(pWav, samplesToRead, pBufferOut);
    }

    drwav_uint64 totalSamplesRead = 0;
    unsigned char sampleData[4096];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read(pWav, drwav_min(samplesToRead, sizeof(sampleData)/pWav->bytesPerSample), sampleData);
        if (samplesRead == 0) {
            break;
        }

        drwav__pcm_to_s32(pBufferOut, sampleData, (size_t)samplesRead, pWav->bytesPerSample);

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_s32__msadpcm(drwav* pWav, drwav_uint64 samplesToRead, drwav_int32* pBufferOut)
{
    // We're just going to borrow the implementation from the drwav_read_s16() since ADPCM is a little bit more complicated than other formats and I don't
    // want to duplicate that code.
    drwav_uint64 totalSamplesRead = 0;
    drwav_int16 samples16[2048];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read_s16(pWav, drwav_min(samplesToRead, 2048), samples16);
        if (samplesRead == 0) {
            break;
        }

        drwav_s16_to_s32(pBufferOut, samples16, (size_t)samplesRead);   // <-- Safe cast because we're clamping to 2048.

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_s32__ima(drwav* pWav, drwav_uint64 samplesToRead, drwav_int32* pBufferOut)
{
    // We're just going to borrow the implementation from the drwav_read_s16() since IMA-ADPCM is a little bit more complicated than other formats and I don't
    // want to duplicate that code.
    drwav_uint64 totalSamplesRead = 0;
    drwav_int16 samples16[2048];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read_s16(pWav, drwav_min(samplesToRead, 2048), samples16);
        if (samplesRead == 0) {
            break;
        }

        drwav_s16_to_s32(pBufferOut, samples16, (size_t)samplesRead);   // <-- Safe cast because we're clamping to 2048.

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_s32__ieee(drwav* pWav, drwav_uint64 samplesToRead, drwav_int32* pBufferOut)
{
    drwav_uint64 totalSamplesRead = 0;
    unsigned char sampleData[4096];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read(pWav, drwav_min(samplesToRead, sizeof(sampleData)/pWav->bytesPerSample), sampleData);
        if (samplesRead == 0) {
            break;
        }

        drwav__ieee_to_s32(pBufferOut, sampleData, (size_t)samplesRead, pWav->bytesPerSample);

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_s32__alaw(drwav* pWav, drwav_uint64 samplesToRead, drwav_int32* pBufferOut)
{
    drwav_uint64 totalSamplesRead = 0;
    unsigned char sampleData[4096];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read(pWav, drwav_min(samplesToRead, sizeof(sampleData)/pWav->bytesPerSample), sampleData);
        if (samplesRead == 0) {
            break;
        }

        drwav_alaw_to_s32(pBufferOut, sampleData, (size_t)samplesRead);

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_s32__mulaw(drwav* pWav, drwav_uint64 samplesToRead, drwav_int32* pBufferOut)
{
    drwav_uint64 totalSamplesRead = 0;
    unsigned char sampleData[4096];
    while (samplesToRead > 0) {
        drwav_uint64 samplesRead = drwav_read(pWav, drwav_min(samplesToRead, sizeof(sampleData)/pWav->bytesPerSample), sampleData);
        if (samplesRead == 0) {
            break;
        }

        drwav_mulaw_to_s32(pBufferOut, sampleData, (size_t)samplesRead);

        pBufferOut       += samplesRead;
        samplesToRead    -= samplesRead;
        totalSamplesRead += samplesRead;
    }

    return totalSamplesRead;
}

drwav_uint64 drwav_read_s32(drwav* pWav, drwav_uint64 samplesToRead, drwav_int32* pBufferOut)
{
    if (pWav == NULL || samplesToRead == 0 || pBufferOut == NULL) {
        return 0;
    }

    // Don't try to read more samples than can potentially fit in the output buffer.
    if (samplesToRead * sizeof(drwav_int32) > SIZE_MAX) {
        samplesToRead = SIZE_MAX / sizeof(drwav_int32);
    }


    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_PCM) {
        return drwav_read_s32__pcm(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_ADPCM) {
        return drwav_read_s32__msadpcm(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_IEEE_FLOAT) {
        return drwav_read_s32__ieee(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_ALAW) {
        return drwav_read_s32__alaw(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_MULAW) {
        return drwav_read_s32__mulaw(pWav, samplesToRead, pBufferOut);
    }

    if (pWav->translatedFormatTag == DR_WAVE_FORMAT_DVI_ADPCM) {
        return drwav_read_s32__ima(pWav, samplesToRead, pBufferOut);
    }

    return 0;
}

void drwav_u8_to_s32(drwav_int32* pOut, const drwav_uint8* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i = 0; i < sampleCount; ++i) {
        *pOut++ = ((int)pIn[i] - 128) << 24;
    }
}

void drwav_s16_to_s32(drwav_int32* pOut, const drwav_int16* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i = 0; i < sampleCount; ++i) {
        *pOut++ = pIn[i] << 16;
    }
}

void drwav_s24_to_s32(drwav_int32* pOut, const drwav_uint8* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i = 0; i < sampleCount; ++i) {
        unsigned int s0 = pIn[i*3 + 0];
        unsigned int s1 = pIn[i*3 + 1];
        unsigned int s2 = pIn[i*3 + 2];

        drwav_int32 sample32 = (drwav_int32)((s0 << 8) | (s1 << 16) | (s2 << 24));
        *pOut++ = sample32;
    }
}

void drwav_f32_to_s32(drwav_int32* pOut, const float* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i = 0; i < sampleCount; ++i) {
        *pOut++ = (drwav_int32)(2147483648.0 * pIn[i]);
    }
}

void drwav_f64_to_s32(drwav_int32* pOut, const double* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i = 0; i < sampleCount; ++i) {
        *pOut++ = (drwav_int32)(2147483648.0 * pIn[i]);
    }
}

void drwav_alaw_to_s32(drwav_int32* pOut, const drwav_uint8* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i = 0; i < sampleCount; ++i) {
        *pOut++ = ((drwav_int32)drwav__alaw_to_s16(pIn[i])) << 16;
    }
}

void drwav_mulaw_to_s32(drwav_int32* pOut, const drwav_uint8* pIn, size_t sampleCount)
{
    size_t i;
    if (pOut == NULL || pIn == NULL) {
        return;
    }

    for (i= 0; i < sampleCount; ++i) {
        *pOut++ = ((drwav_int32)drwav__mulaw_to_s16(pIn[i])) << 16;
    }
}



drwav_int16* drwav__read_and_close_s16(drwav* pWav, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount)
{
    drwav_assert(pWav != NULL);

    drwav_uint64 sampleDataSize = pWav->totalSampleCount * sizeof(drwav_int16);
    if (sampleDataSize > SIZE_MAX) {
        drwav_uninit(pWav);
        return NULL;    // File's too big.
    }

    drwav_int16* pSampleData = (drwav_int16*)DRWAV_MALLOC((size_t)sampleDataSize);    // <-- Safe cast due to the check above.
    if (pSampleData == NULL) {
        drwav_uninit(pWav);
        return NULL;    // Failed to allocate memory.
    }

    drwav_uint64 samplesRead = drwav_read_s16(pWav, (size_t)pWav->totalSampleCount, pSampleData);
    if (samplesRead != pWav->totalSampleCount) {
        DRWAV_FREE(pSampleData);
        drwav_uninit(pWav);
        return NULL;    // There was an error reading the samples.
    }

    drwav_uninit(pWav);

    if (sampleRate) *sampleRate = pWav->sampleRate;
    if (channels) *channels = pWav->channels;
    if (totalSampleCount) *totalSampleCount = pWav->totalSampleCount;
    return pSampleData;
}

float* drwav__read_and_close_f32(drwav* pWav, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount)
{
    drwav_assert(pWav != NULL);

    drwav_uint64 sampleDataSize = pWav->totalSampleCount * sizeof(float);
    if (sampleDataSize > SIZE_MAX) {
        drwav_uninit(pWav);
        return NULL;    // File's too big.
    }

    float* pSampleData = (float*)DRWAV_MALLOC((size_t)sampleDataSize);    // <-- Safe cast due to the check above.
    if (pSampleData == NULL) {
        drwav_uninit(pWav);
        return NULL;    // Failed to allocate memory.
    }

    drwav_uint64 samplesRead = drwav_read_f32(pWav, (size_t)pWav->totalSampleCount, pSampleData);
    if (samplesRead != pWav->totalSampleCount) {
        DRWAV_FREE(pSampleData);
        drwav_uninit(pWav);
        return NULL;    // There was an error reading the samples.
    }

    drwav_uninit(pWav);

    if (sampleRate) *sampleRate = pWav->sampleRate;
    if (channels) *channels = pWav->channels;
    if (totalSampleCount) *totalSampleCount = pWav->totalSampleCount;
    return pSampleData;
}

drwav_int32* drwav__read_and_close_s32(drwav* pWav, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount)
{
    drwav_assert(pWav != NULL);

    drwav_uint64 sampleDataSize = pWav->totalSampleCount * sizeof(drwav_int32);
    if (sampleDataSize > SIZE_MAX) {
        drwav_uninit(pWav);
        return NULL;    // File's too big.
    }

    drwav_int32* pSampleData = (drwav_int32*)DRWAV_MALLOC((size_t)sampleDataSize);    // <-- Safe cast due to the check above.
    if (pSampleData == NULL) {
        drwav_uninit(pWav);
        return NULL;    // Failed to allocate memory.
    }

    drwav_uint64 samplesRead = drwav_read_s32(pWav, (size_t)pWav->totalSampleCount, pSampleData);
    if (samplesRead != pWav->totalSampleCount) {
        DRWAV_FREE(pSampleData);
        drwav_uninit(pWav);
        return NULL;    // There was an error reading the samples.
    }

    drwav_uninit(pWav);

    if (sampleRate) *sampleRate = pWav->sampleRate;
    if (channels) *channels = pWav->channels;
    if (totalSampleCount) *totalSampleCount = pWav->totalSampleCount;
    return pSampleData;
}


drwav_int16* drwav_open_and_read_s16(drwav_read_proc onRead, drwav_seek_proc onSeek, void* pUserData, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount)
{
    if (sampleRate) *sampleRate = 0;
    if (channels) *channels = 0;
    if (totalSampleCount) *totalSampleCount = 0;

    drwav wav;
    if (!drwav_init(&wav, onRead, onSeek, pUserData)) {
        return NULL;
    }

    return drwav__read_and_close_s16(&wav, channels, sampleRate, totalSampleCount);
}

float* drwav_open_and_read_f32(drwav_read_proc onRead, drwav_seek_proc onSeek, void* pUserData, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount)
{
    if (sampleRate) *sampleRate = 0;
    if (channels) *channels = 0;
    if (totalSampleCount) *totalSampleCount = 0;

    drwav wav;
    if (!drwav_init(&wav, onRead, onSeek, pUserData)) {
        return NULL;
    }

    return drwav__read_and_close_f32(&wav, channels, sampleRate, totalSampleCount);
}

drwav_int32* drwav_open_and_read_s32(drwav_read_proc onRead, drwav_seek_proc onSeek, void* pUserData, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount)
{
    if (sampleRate) *sampleRate = 0;
    if (channels) *channels = 0;
    if (totalSampleCount) *totalSampleCount = 0;

    drwav wav;
    if (!drwav_init(&wav, onRead, onSeek, pUserData)) {
        return NULL;
    }

    return drwav__read_and_close_s32(&wav, channels, sampleRate, totalSampleCount);
}

#ifndef DR_WAV_NO_STDIO
drwav_int16* drwav_open_and_read_file_s16(const char* filename, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount)
{
    if (sampleRate) *sampleRate = 0;
    if (channels) *channels = 0;
    if (totalSampleCount) *totalSampleCount = 0;

    drwav wav;
    if (!drwav_init_file(&wav, filename)) {
        return NULL;
    }

    return drwav__read_and_close_s16(&wav, channels, sampleRate, totalSampleCount);
}

float* drwav_open_and_read_file_f32(const char* filename, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount)
{
    if (sampleRate) *sampleRate = 0;
    if (channels) *channels = 0;
    if (totalSampleCount) *totalSampleCount = 0;

    drwav wav;
    if (!drwav_init_file(&wav, filename)) {
        return NULL;
    }

    return drwav__read_and_close_f32(&wav, channels, sampleRate, totalSampleCount);
}

drwav_int32* drwav_open_and_read_file_s32(const char* filename, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount)
{
    if (sampleRate) *sampleRate = 0;
    if (channels) *channels = 0;
    if (totalSampleCount) *totalSampleCount = 0;

    drwav wav;
    if (!drwav_init_file(&wav, filename)) {
        return NULL;
    }

    return drwav__read_and_close_s32(&wav, channels, sampleRate, totalSampleCount);
}
#endif

drwav_int16* drwav_open_and_read_memory_s16(const void* data, size_t dataSize, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount)
{
    if (sampleRate) *sampleRate = 0;
    if (channels) *channels = 0;
    if (totalSampleCount) *totalSampleCount = 0;

    drwav wav;
    if (!drwav_init_memory(&wav, data, dataSize)) {
        return NULL;
    }

    return drwav__read_and_close_s16(&wav, channels, sampleRate, totalSampleCount);
}

float* drwav_open_and_read_memory_f32(const void* data, size_t dataSize, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount)
{
    if (sampleRate) *sampleRate = 0;
    if (channels) *channels = 0;
    if (totalSampleCount) *totalSampleCount = 0;

    drwav wav;
    if (!drwav_init_memory(&wav, data, dataSize)) {
        return NULL;
    }

    return drwav__read_and_close_f32(&wav, channels, sampleRate, totalSampleCount);
}

drwav_int32* drwav_open_and_read_memory_s32(const void* data, size_t dataSize, unsigned int* channels, unsigned int* sampleRate, drwav_uint64* totalSampleCount)
{
    if (sampleRate) *sampleRate = 0;
    if (channels) *channels = 0;
    if (totalSampleCount) *totalSampleCount = 0;

    drwav wav;
    if (!drwav_init_memory(&wav, data, dataSize)) {
        return NULL;
    }

    return drwav__read_and_close_s32(&wav, channels, sampleRate, totalSampleCount);
}
#endif  //DR_WAV_NO_CONVERSION_API


void drwav_free(void* pDataReturnedByOpenAndRead)
{
    DRWAV_FREE(pDataReturnedByOpenAndRead);
}

#endif  //DR_WAV_IMPLEMENTATION


// REVISION HISTORY
//
// v0.7 - 2017-11-04
//   - Add writing APIs.
//
// v0.6 - 2017-08-16
//   - API CHANGE: Rename dr_* types to drwav_*.
//   - Add support for custom implementations of malloc(), realloc(), etc.
//   - Add support for Microsoft ADPCM.
//   - Add support for IMA ADPCM (DVI, format code 0x11).
//   - Optimizations to drwav_read_s16().
//   - Bug fixes.
//
// v0.5g - 2017-07-16
//   - Change underlying type for booleans to unsigned.
//
// v0.5f - 2017-04-04
//   - Fix a minor bug with drwav_open_and_read_s16() and family.
//
// v0.5e - 2016-12-29
//   - Added support for reading samples as signed 16-bit integers. Use the _s16() family of APIs for this.
//   - Minor fixes to documentation.
//
// v0.5d - 2016-12-28
//   - Use drwav_int*/drwav_uint* sized types to improve compiler support.
//
// v0.5c - 2016-11-11
//   - Properly handle JUNK chunks that come before the FMT chunk.
//
// v0.5b - 2016-10-23
//   - A minor change to drwav_bool8 and drwav_bool32 types.
//
// v0.5a - 2016-10-11
//   - Fixed a bug with drwav_open_and_read() and family due to incorrect argument ordering.
//   - Improve A-law and mu-law efficiency.
//
// v0.5 - 2016-09-29
//   - API CHANGE. Swap the order of "channels" and "sampleRate" parameters in drwav_open_and_read*(). Rationale for this is to
//     keep it consistent with dr_audio and drwav_flac.
//
// v0.4b - 2016-09-18
//   - Fixed a typo in documentation.
//
// v0.4a - 2016-09-18
//   - Fixed a typo.
//   - Change date format to ISO 8601 (YYYY-MM-DD)
//
// v0.4 - 2016-07-13
//   - API CHANGE. Make onSeek consistent with drwav_flac.
//   - API CHANGE. Rename drwav_seek() to drwav_seek_to_sample() for clarity and consistency with drwav_flac.
//   - Added support for Sony Wave64.
//
// v0.3a - 2016-05-28
//   - API CHANGE. Return drwav_bool32 instead of int in onSeek callback.
//   - Fixed a memory leak.
//
// v0.3 - 2016-05-22
//   - Lots of API changes for consistency.
//
// v0.2a - 2016-05-16
//   - Fixed Linux/GCC build.
//
// v0.2 - 2016-05-11
//   - Added support for reading data as signed 32-bit PCM for consistency with drwav_flac.
//
// v0.1a - 2016-05-07
//   - Fixed a bug in drwav_open_file() where the file handle would not be closed if the loader failed to initialize.
//
// v0.1 - 2016-05-04
//   - Initial versioned release.


/*
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
*/
