////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//                Copyright (c) 1998 - 2016 David Bryant.                 //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// wavpack.h

#ifndef WAVPACK_H
#define WAVPACK_H

// This header file contains all the definitions required to use the
// functions in "wputils.c" to read and write WavPack files and streams.

#include <sys/types.h>

#if defined(_MSC_VER) && _MSC_VER < 1600
typedef unsigned __int64 uint64_t;
typedef unsigned __int32 uint32_t;
typedef unsigned __int16 uint16_t;
typedef unsigned __int8 uint8_t;
typedef __int64 int64_t;
typedef __int32 int32_t;
typedef __int16 int16_t;
typedef __int8  int8_t;
#else
#include <stdint.h>
#endif

// RIFF / wav header formats (these occur at the beginning of both wav files
// and pre-4.0 WavPack files that are not in the "raw" mode). Generally, an
// application using the library to read or write WavPack files will not be
// concerned with any of these.

typedef struct {
    char ckID [4];
    uint32_t ckSize;
    char formType [4];
} RiffChunkHeader;

typedef struct {
    char ckID [4];
    uint32_t ckSize;
} ChunkHeader;

#define ChunkHeaderFormat "4L"

typedef struct {
    uint16_t FormatTag, NumChannels;
    uint32_t SampleRate, BytesPerSecond;
    uint16_t BlockAlign, BitsPerSample;
    uint16_t cbSize, ValidBitsPerSample;
    int32_t ChannelMask;
    uint16_t SubFormat;
    char GUID [14];
} WaveHeader;

#define WaveHeaderFormat "SSLLSSSSLS"

// This is the ONLY structure that occurs in WavPack files (as of version
// 4.0), and is the preamble to every block in both the .wv and .wvc
// files (in little-endian format). Normally, this structure has no use
// to an application using the library to read or write WavPack files,
// but if an application needs to manually parse WavPack files then this
// would be used (with appropriate endian correction).

typedef struct {
    char ckID [4];
    uint32_t ckSize;
    int16_t version;
    unsigned char block_index_u8;
    unsigned char total_samples_u8;
    uint32_t total_samples, block_index, block_samples, flags, crc;
} WavpackHeader;

#define WavpackHeaderFormat "4LS2LLLLL"

// Macros to access the 40-bit block_index field

#define GET_BLOCK_INDEX(hdr) ( (int64_t) (hdr).block_index + ((int64_t) (hdr).block_index_u8 << 32) )

#define SET_BLOCK_INDEX(hdr,value) do { \
    int64_t tmp = (value);              \
    (hdr).block_index = (uint32_t) tmp; \
    (hdr).block_index_u8 =              \
        (unsigned char) (tmp >> 32);    \
} while (0)

// Macros to access the 40-bit total_samples field, which is complicated by the fact that
// all 1's in the lower 32 bits indicates "unknown" (regardless of upper 8 bits)

#define GET_TOTAL_SAMPLES(hdr) ( ((hdr).total_samples == (uint32_t) -1) ? -1 : \
    (int64_t) (hdr).total_samples + ((int64_t) (hdr).total_samples_u8 << 32) - (hdr).total_samples_u8 )

#define SET_TOTAL_SAMPLES(hdr,value) do {       \
    int64_t tmp = (value);                      \
    if (tmp < 0)                                \
        (hdr).total_samples = (uint32_t) -1;    \
    else {                                      \
        tmp += (tmp / 0xffffffffLL);            \
        (hdr).total_samples = (uint32_t) tmp;   \
        (hdr).total_samples_u8 =                \
            (unsigned char) (tmp >> 32);        \
    }                                           \
} while (0)

// or-values for WavpackHeader.flags
#define BYTES_STORED    3       // 1-4 bytes/sample
#define MONO_FLAG       4       // not stereo
#define HYBRID_FLAG     8       // hybrid mode
#define JOINT_STEREO    0x10    // joint stereo
#define CROSS_DECORR    0x20    // no-delay cross decorrelation
#define HYBRID_SHAPE    0x40    // noise shape (hybrid mode only)
#define FLOAT_DATA      0x80    // ieee 32-bit floating point data

#define INT32_DATA      0x100   // special extended int handling
#define HYBRID_BITRATE  0x200   // bitrate noise (hybrid mode only)
#define HYBRID_BALANCE  0x400   // balance noise (hybrid stereo mode only)

#define INITIAL_BLOCK   0x800   // initial block of multichannel segment
#define FINAL_BLOCK     0x1000  // final block of multichannel segment

#define SHIFT_LSB       13
#define SHIFT_MASK      (0x1fL << SHIFT_LSB)

#define MAG_LSB         18
#define MAG_MASK        (0x1fL << MAG_LSB)

#define SRATE_LSB       23
#define SRATE_MASK      (0xfL << SRATE_LSB)

#define FALSE_STEREO    0x40000000      // block is stereo, but data is mono
#define NEW_SHAPING     0x20000000      // use IIR filter for negative shaping

#define MONO_DATA (MONO_FLAG | FALSE_STEREO)

// Introduced in WavPack 5.0:
#define HAS_CHECKSUM    0x10000000      // block contains a trailing checksum
#define DSD_FLAG        0x80000000      // block is encoded DSD (1-bit PCM)

#define IGNORED_FLAGS   0x08000000      // reserved, but ignore if encountered
#define UNKNOWN_FLAGS   0x00000000      // we no longer have any of these spares

#define MIN_STREAM_VERS     0x402       // lowest stream version we'll decode
#define MAX_STREAM_VERS     0x410       // highest stream version we'll decode or encode

// These are the mask bit definitions for the metadata chunk id byte (see format.txt)

#define ID_UNIQUE               0x3f
#define ID_OPTIONAL_DATA        0x20
#define ID_ODD_SIZE             0x40
#define ID_LARGE                0x80

#define ID_DUMMY                0x0
#define ID_ENCODER_INFO         0x1
#define ID_DECORR_TERMS         0x2
#define ID_DECORR_WEIGHTS       0x3
#define ID_DECORR_SAMPLES       0x4
#define ID_ENTROPY_VARS         0x5
#define ID_HYBRID_PROFILE       0x6
#define ID_SHAPING_WEIGHTS      0x7
#define ID_FLOAT_INFO           0x8
#define ID_INT32_INFO           0x9
#define ID_WV_BITSTREAM         0xa
#define ID_WVC_BITSTREAM        0xb
#define ID_WVX_BITSTREAM        0xc
#define ID_CHANNEL_INFO         0xd

#define ID_RIFF_HEADER          (ID_OPTIONAL_DATA | 0x1)
#define ID_RIFF_TRAILER         (ID_OPTIONAL_DATA | 0x2)
#define ID_ALT_HEADER           (ID_OPTIONAL_DATA | 0x3)
#define ID_ALT_TRAILER          (ID_OPTIONAL_DATA | 0x4)
#define ID_CONFIG_BLOCK         (ID_OPTIONAL_DATA | 0x5)
#define ID_MD5_CHECKSUM         (ID_OPTIONAL_DATA | 0x6)
#define ID_SAMPLE_RATE          (ID_OPTIONAL_DATA | 0x7)
#define ID_ALT_EXTENSION        (ID_OPTIONAL_DATA | 0x8)
#define ID_ALT_MD5_CHECKSUM     (ID_OPTIONAL_DATA | 0x9)
#define ID_NEW_CONFIG_BLOCK     (ID_OPTIONAL_DATA | 0xa)
#define ID_BLOCK_CHECKSUM       (ID_OPTIONAL_DATA | 0xf)

///////////////////////// WavPack Configuration ///////////////////////////////

// This external structure is used during encode to provide configuration to
// the encoding engine and during decoding to provide fle information back to
// the higher level functions. Not all fields are used in both modes.

typedef struct {
    float bitrate, shaping_weight;
    int bits_per_sample, bytes_per_sample;
    int qmode, flags, xmode, num_channels, float_norm_exp;
    int32_t block_samples, extra_flags, sample_rate, channel_mask;
    unsigned char md5_checksum [16], md5_read;
    int num_tag_strings;                // this field is not used
    char **tag_strings;                 // this field is not used
} WavpackConfig;

#define CONFIG_HYBRID_FLAG      8       // hybrid mode
#define CONFIG_JOINT_STEREO     0x10    // joint stereo
#define CONFIG_CROSS_DECORR     0x20    // no-delay cross decorrelation
#define CONFIG_HYBRID_SHAPE     0x40    // noise shape (hybrid mode only)
#define CONFIG_FAST_FLAG        0x200   // fast mode
#define CONFIG_HIGH_FLAG        0x800   // high quality mode
#define CONFIG_VERY_HIGH_FLAG   0x1000  // very high
#define CONFIG_BITRATE_KBPS     0x2000  // bitrate is kbps, not bits / sample
#define CONFIG_SHAPE_OVERRIDE   0x8000  // shaping mode specified
#define CONFIG_JOINT_OVERRIDE   0x10000 // joint-stereo mode specified
#define CONFIG_DYNAMIC_SHAPING  0x20000 // dynamic noise shaping
#define CONFIG_CREATE_EXE       0x40000 // create executable
#define CONFIG_CREATE_WVC       0x80000 // create correction file
#define CONFIG_OPTIMIZE_WVC     0x100000 // maximize bybrid compression
#define CONFIG_COMPATIBLE_WRITE 0x400000 // write files for decoders < 4.3
#define CONFIG_CALC_NOISE       0x800000 // calc noise in hybrid mode
#define CONFIG_EXTRA_MODE       0x2000000 // extra processing mode
#define CONFIG_SKIP_WVX         0x4000000 // no wvx stream w/ floats & big ints
#define CONFIG_MD5_CHECKSUM     0x8000000 // store MD5 signature
#define CONFIG_MERGE_BLOCKS     0x10000000 // merge blocks of equal redundancy (for lossyWAV)
#define CONFIG_PAIR_UNDEF_CHANS 0x20000000 // encode undefined channels in stereo pairs
#define CONFIG_OPTIMIZE_MONO    0x80000000 // optimize for mono streams posing as stereo

// The lower 8 bits of qmode indicate the use of new features in version 5 that (presently)
// only apply to Core Audio Files (CAF) and DSD files, but could apply to other things too.
// These flags are stored in the file and can be retrieved by a decoder that is aware of
// them, but the individual bits are meaningless to the library. If ANY of these bits are
// set then the MD5 sum is written with a new ID so that old decoders will not see it
// (because these features will cause the MD5 sum to be different and fail).

#define QMODE_BIG_ENDIAN        0x1     // big-endian data format (opposite of WAV format)
#define QMODE_SIGNED_BYTES      0x2     // 8-bit audio data is signed (opposite of WAV format)
#define QMODE_UNSIGNED_WORDS    0x4     // audio data (other than 8-bit) is unsigned (opposite of WAV format)
#define QMODE_REORDERED_CHANS   0x8     // source channels were not Microsoft order, so they were reordered
#define QMODE_DSD_LSB_FIRST     0x10    // DSD bytes, LSB first (most Sony .dsf files)
#define QMODE_DSD_MSB_FIRST     0x20    // DSD bytes, MSB first (Philips .dff files)
#define QMODE_DSD_IN_BLOCKS     0x40    // DSD data is blocked by channels (Sony .dsf only)
#define QMODE_DSD_AUDIO         (QMODE_DSD_LSB_FIRST | QMODE_DSD_MSB_FIRST)

// The rest of the qmode word is reserved for the private use of the command-line programs
// and are ignored by the library (and not stored either). They really should not be defined
// here, but I thought it would be a good idea to have all the definitions together.

#define QMODE_ADOBE_MODE        0x100   // user specified Adobe mode
#define QMODE_NO_STORE_WRAPPER  0x200   // user specified to not store audio file wrapper (RIFF, CAFF, etc.)
#define QMODE_CHANS_UNASSIGNED  0x400   // user specified "..." in --channel-order option
#define QMODE_IGNORE_LENGTH     0x800   // user specified to ignore length in file header
#define QMODE_RAW_PCM           0x1000  // user specified raw PCM format (no header present)

////////////// Callbacks used for reading & writing WavPack streams //////////

typedef struct {
    int32_t (*read_bytes)(void *id, void *data, int32_t bcount);
    uint32_t (*get_pos)(void *id);
    int (*set_pos_abs)(void *id, uint32_t pos);
    int (*set_pos_rel)(void *id, int32_t delta, int mode);
    int (*push_back_byte)(void *id, int c);
    uint32_t (*get_length)(void *id);
    int (*can_seek)(void *id);

    // this callback is for writing edited tags only
    int32_t (*write_bytes)(void *id, void *data, int32_t bcount);
} WavpackStreamReader;

// Extended version of structure for handling large files and added
// functionality for truncating and closing files

typedef struct {
    int32_t (*read_bytes)(void *id, void *data, int32_t bcount);
    int32_t (*write_bytes)(void *id, void *data, int32_t bcount);
    int64_t (*get_pos)(void *id);                               // new signature for large files
    int (*set_pos_abs)(void *id, int64_t pos);                  // new signature for large files
    int (*set_pos_rel)(void *id, int64_t delta, int mode);      // new signature for large files
    int (*push_back_byte)(void *id, int c);
    int64_t (*get_length)(void *id);                            // new signature for large files
    int (*can_seek)(void *id);
    int (*truncate_here)(void *id);                             // new function to truncate file at current position
    int (*close)(void *id);                                     // new function to close file
} WavpackStreamReader64;

typedef int (*WavpackBlockOutput)(void *id, void *data, int32_t bcount);

//////////////////////////// function prototypes /////////////////////////////

typedef void WavpackContext;

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_WAVPACK_SAMPLES ((1LL << 40) - 257)

WavpackContext *WavpackOpenRawDecoder (
    void *main_data, int32_t main_size,
    void *corr_data, int32_t corr_size,
    int16_t version, char *error, int flags, int norm_offset);

WavpackContext *WavpackOpenFileInputEx64 (WavpackStreamReader64 *reader, void *wv_id, void *wvc_id, char *error, int flags, int norm_offset);
WavpackContext *WavpackOpenFileInputEx (WavpackStreamReader *reader, void *wv_id, void *wvc_id, char *error, int flags, int norm_offset);
WavpackContext *WavpackOpenFileInput (const char *infilename, char *error, int flags, int norm_offset);

#define OPEN_WVC        0x1     // open/read "correction" file
#define OPEN_TAGS       0x2     // read ID3v1 / APEv2 tags (seekable file)
#define OPEN_WRAPPER    0x4     // make audio wrapper available (i.e. RIFF)
#define OPEN_2CH_MAX    0x8     // open multichannel as stereo (no downmix)
#define OPEN_NORMALIZE  0x10    // normalize floating point data to +/- 1.0
#define OPEN_STREAMING  0x20    // "streaming" mode blindly unpacks blocks
                                // w/o regard to header file position info
#define OPEN_EDIT_TAGS  0x40    // allow editing of tags
#define OPEN_FILE_UTF8  0x80    // assume filenames are UTF-8 encoded, not ANSI (Windows only)

// new for version 5

#define OPEN_DSD_NATIVE 0x100   // open DSD files as bitstreams
                                // (returned as 8-bit "samples" stored in 32-bit words)
#define OPEN_DSD_AS_PCM 0x200   // open DSD files as 24-bit PCM (decimated 8x)
#define OPEN_ALT_TYPES  0x400   // application is aware of alternate file types & qmode
                                // (just affects retrieving wrappers & MD5 checksums)
#define OPEN_NO_CHECKSUM 0x800  // don't verify block checksums before decoding

int WavpackGetMode (WavpackContext *wpc);

#define MODE_WVC        0x1
#define MODE_LOSSLESS   0x2
#define MODE_HYBRID     0x4
#define MODE_FLOAT      0x8
#define MODE_VALID_TAG  0x10
#define MODE_HIGH       0x20
#define MODE_FAST       0x40
#define MODE_EXTRA      0x80    // extra mode used, see MODE_XMODE for possible level
#define MODE_APETAG     0x100
#define MODE_SFX        0x200
#define MODE_VERY_HIGH  0x400
#define MODE_MD5        0x800
#define MODE_XMODE      0x7000  // mask for extra level (1-6, 0=unknown)
#define MODE_DNS        0x8000

int WavpackVerifySingleBlock (unsigned char *buffer, int verify_checksum);
int WavpackGetQualifyMode (WavpackContext *wpc);
char *WavpackGetErrorMessage (WavpackContext *wpc);
int WavpackGetVersion (WavpackContext *wpc);
char *WavpackGetFileExtension (WavpackContext *wpc);
unsigned char WavpackGetFileFormat (WavpackContext *wpc);
uint32_t WavpackUnpackSamples (WavpackContext *wpc, int32_t *buffer, uint32_t samples);
uint32_t WavpackGetNumSamples (WavpackContext *wpc);
int64_t WavpackGetNumSamples64 (WavpackContext *wpc);
uint32_t WavpackGetNumSamplesInFrame (WavpackContext *wpc);
uint32_t WavpackGetSampleIndex (WavpackContext *wpc);
int64_t WavpackGetSampleIndex64 (WavpackContext *wpc);
int WavpackGetNumErrors (WavpackContext *wpc);
int WavpackLossyBlocks (WavpackContext *wpc);
int WavpackSeekSample (WavpackContext *wpc, uint32_t sample);
int WavpackSeekSample64 (WavpackContext *wpc, int64_t sample);
WavpackContext *WavpackCloseFile (WavpackContext *wpc);
uint32_t WavpackGetSampleRate (WavpackContext *wpc);
uint32_t WavpackGetNativeSampleRate (WavpackContext *wpc);
int WavpackGetBitsPerSample (WavpackContext *wpc);
int WavpackGetBytesPerSample (WavpackContext *wpc);
int WavpackGetNumChannels (WavpackContext *wpc);
int WavpackGetChannelMask (WavpackContext *wpc);
int WavpackGetReducedChannels (WavpackContext *wpc);
int WavpackGetFloatNormExp (WavpackContext *wpc);
int WavpackGetMD5Sum (WavpackContext *wpc, unsigned char data [16]);
void WavpackGetChannelIdentities (WavpackContext *wpc, unsigned char *identities);
uint32_t WavpackGetChannelLayout (WavpackContext *wpc, unsigned char *reorder);
uint32_t WavpackGetWrapperBytes (WavpackContext *wpc);
unsigned char *WavpackGetWrapperData (WavpackContext *wpc);
void WavpackFreeWrapper (WavpackContext *wpc);
void WavpackSeekTrailingWrapper (WavpackContext *wpc);
double WavpackGetProgress (WavpackContext *wpc);
uint32_t WavpackGetFileSize (WavpackContext *wpc);
int64_t WavpackGetFileSize64 (WavpackContext *wpc);
double WavpackGetRatio (WavpackContext *wpc);
double WavpackGetAverageBitrate (WavpackContext *wpc, int count_wvc);
double WavpackGetInstantBitrate (WavpackContext *wpc);
int WavpackGetNumTagItems (WavpackContext *wpc);
int WavpackGetTagItem (WavpackContext *wpc, const char *item, char *value, int size);
int WavpackGetTagItemIndexed (WavpackContext *wpc, int index, char *item, int size);
int WavpackGetNumBinaryTagItems (WavpackContext *wpc);
int WavpackGetBinaryTagItem (WavpackContext *wpc, const char *item, char *value, int size);
int WavpackGetBinaryTagItemIndexed (WavpackContext *wpc, int index, char *item, int size);
int WavpackAppendTagItem (WavpackContext *wpc, const char *item, const char *value, int vsize);
int WavpackAppendBinaryTagItem (WavpackContext *wpc, const char *item, const char *value, int vsize);
int WavpackDeleteTagItem (WavpackContext *wpc, const char *item);
int WavpackWriteTag (WavpackContext *wpc);

WavpackContext *WavpackOpenFileOutput (WavpackBlockOutput blockout, void *wv_id, void *wvc_id);
void WavpackSetFileInformation (WavpackContext *wpc, char *file_extension, unsigned char file_format);

#define WP_FORMAT_WAV   0       // Microsoft RIFF, including BWF and RF64 varients
#define WP_FORMAT_W64   1       // Sony Wave64
#define WP_FORMAT_CAF   2       // Apple CoreAudio
#define WP_FORMAT_DFF   3       // Philips DSDIFF
#define WP_FORMAT_DSF   4       // Sony DSD Format

int WavpackSetConfiguration (WavpackContext *wpc, WavpackConfig *config, uint32_t total_samples);
int WavpackSetConfiguration64 (WavpackContext *wpc, WavpackConfig *config, int64_t total_samples, const unsigned char *chan_ids);
int WavpackSetChannelLayout (WavpackContext *wpc, uint32_t layout_tag, const unsigned char *reorder);
int WavpackAddWrapper (WavpackContext *wpc, void *data, uint32_t bcount);
int WavpackStoreMD5Sum (WavpackContext *wpc, unsigned char data [16]);
int WavpackPackInit (WavpackContext *wpc);
int WavpackPackSamples (WavpackContext *wpc, int32_t *sample_buffer, uint32_t sample_count);
int WavpackFlushSamples (WavpackContext *wpc);
void WavpackUpdateNumSamples (WavpackContext *wpc, void *first_block);
void *WavpackGetWrapperLocation (void *first_block, uint32_t *size);
double WavpackGetEncodedNoise (WavpackContext *wpc, double *peak);

void WavpackFloatNormalize (int32_t *values, int32_t num_values, int delta_exp);

void WavpackLittleEndianToNative (void *data, char *format);
void WavpackNativeToLittleEndian (void *data, char *format);
void WavpackBigEndianToNative (void *data, char *format);
void WavpackNativeToBigEndian (void *data, char *format);

uint32_t WavpackGetLibraryVersion (void);
const char *WavpackGetLibraryVersionString (void);

#ifdef __cplusplus
}
#endif

#endif
