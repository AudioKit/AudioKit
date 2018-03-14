////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2004 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// wavpack.h

#include <sys/types.h>

// This header file contains all the definitions required by WavPack.

#ifdef __BORLANDC__
typedef unsigned long uint32_t;
typedef long int32_t;
#elif defined(_WIN32) && !defined(__MINGW32__)
#include <stdlib.h>
typedef unsigned __int64 uint64_t;
typedef unsigned __int32 uint32_t;
typedef __int64 int64_t;
typedef __int32 int32_t;
#else
#include <inttypes.h>
#endif

typedef unsigned char   uchar;

#if !defined(__GNUC__) || defined(WIN32)
typedef unsigned short  ushort;
typedef unsigned int    uint;
#endif

#include <stdio.h>

#define FALSE 0
#define TRUE 1

////////////////////////////// WavPack Header /////////////////////////////////

// Note that this is the ONLY structure that is written to (or read from)
// WavPack 4.0 files, and is the preamble to every block in both the .wv
// and .wvc files.

typedef struct {
    char ckID [4];
    uint32_t ckSize;
    short version;
    uchar track_no, index_no;
    uint32_t total_samples, block_index, block_samples, flags, crc;
} WavpackHeader;

#define WavpackHeaderFormat "4LS2LLLLL"

// or-values for "flags"

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

#define IGNORED_FLAGS   0x18000000      // reserved, but ignore if encountered
#define NEW_SHAPING     0x20000000      // use IIR filter for negative shaping
#define UNKNOWN_FLAGS   0x80000000      // also reserved, but refuse decode if
                                        //  encountered

#define MONO_DATA (MONO_FLAG | FALSE_STEREO)

#define MIN_STREAM_VERS     0x402       // lowest stream version we'll decode
#define MAX_STREAM_VERS     0x410       // highest stream version we'll decode

//////////////////////////// WavPack Metadata /////////////////////////////////

// This is an internal representation of metadata.

typedef struct {
    int32_t byte_length;
    void *data;
    uchar id;
} WavpackMetadata;

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
#define ID_REPLAY_GAIN          (ID_OPTIONAL_DATA | 0x3)
#define ID_CUESHEET             (ID_OPTIONAL_DATA | 0x4)
#define ID_CONFIG_BLOCK         (ID_OPTIONAL_DATA | 0x5)
#define ID_MD5_CHECKSUM         (ID_OPTIONAL_DATA | 0x6)

///////////////////////// WavPack Configuration ///////////////////////////////

// This internal structure is used during encode to provide configuration to
// the encoding engine and during decoding to provide fle information back to
// the higher level functions. Not all fields are used in both modes.

typedef struct {
    int bits_per_sample, bytes_per_sample;
    int num_channels, float_norm_exp;
    uint32_t flags, sample_rate, channel_mask;
} WavpackConfig;

#define CONFIG_BYTES_STORED     3       // 1-4 bytes/sample
#define CONFIG_MONO_FLAG        4       // not stereo
#define CONFIG_HYBRID_FLAG      8       // hybrid mode
#define CONFIG_JOINT_STEREO     0x10    // joint stereo
#define CONFIG_CROSS_DECORR     0x20    // no-delay cross decorrelation
#define CONFIG_HYBRID_SHAPE     0x40    // noise shape (hybrid mode only)
#define CONFIG_FLOAT_DATA       0x80    // ieee 32-bit floating point data

#define CONFIG_FAST_FLAG        0x200   // fast mode
#define CONFIG_HIGH_FLAG        0x800   // high quality mode
#define CONFIG_VERY_HIGH_FLAG   0x1000  // very high
#define CONFIG_BITRATE_KBPS     0x2000  // bitrate is kbps, not bits / sample
#define CONFIG_AUTO_SHAPING     0x4000  // automatic noise shaping
#define CONFIG_SHAPE_OVERRIDE   0x8000  // shaping mode specified
#define CONFIG_JOINT_OVERRIDE   0x10000 // joint-stereo mode specified
#define CONFIG_CREATE_EXE       0x40000 // create executable
#define CONFIG_CREATE_WVC       0x80000 // create correction file
#define CONFIG_OPTIMIZE_WVC     0x100000 // maximize bybrid compression
#define CONFIG_CALC_NOISE       0x800000 // calc noise in hybrid mode
#define CONFIG_LOSSY_MODE       0x1000000 // obsolete (for information)
#define CONFIG_EXTRA_MODE       0x2000000 // extra processing mode
#define CONFIG_SKIP_WVX         0x4000000 // no wvx stream w/ floats & big ints
#define CONFIG_MD5_CHECKSUM     0x8000000 // compute & store MD5 signature
#define CONFIG_OPTIMIZE_MONO    0x80000000 // optimize for mono streams posing as stereo

//////////////////////////////// WavPack Stream ///////////////////////////////

// This internal structure contains everything required to handle a WavPack
// "stream", which is defined as a stereo or mono stream of audio samples. For
// multichannel audio several of these would be required. Each stream contains
// pointers to hold a complete allocated block of WavPack data, although it's
// possible to decode WavPack blocks without buffering an entire block.

typedef int32_t (*read_stream)(void *, int32_t);

typedef struct bs {
    uchar *buf, *end, *ptr;
    void (*wrap)(struct bs *bs);
    uint32_t file_bytes, sr;
    int error, bc;
    read_stream file;
} Bitstream;

#define MAX_NTERMS 16
#define MAX_TERM 8

struct decorr_pass {
    short term, delta, weight_A, weight_B;
    int32_t samples_A [MAX_TERM], samples_B [MAX_TERM];
};

struct entropy_data {
    uint32_t median [3], slow_level, error_limit;
};

struct words_data {
    uint32_t bitrate_delta [2], bitrate_acc [2];
    uint32_t pend_data, holding_one, zeros_acc;
    int holding_zero, pend_count;
    struct entropy_data c [2];
};

typedef struct {
    WavpackHeader wphdr;
    Bitstream wvbits;

    struct words_data w;

    int num_terms, mute_error;
    uint32_t sample_index, crc;

    uchar int32_sent_bits, int32_zeros, int32_ones, int32_dups;
    uchar float_flags, float_shift, float_max_exp, float_norm_exp;
 
    struct decorr_pass decorr_passes [MAX_NTERMS];

} WavpackStream;

// flags for float_flags:

#define FLOAT_SHIFT_ONES 1      // bits left-shifted into float = '1'
#define FLOAT_SHIFT_SAME 2      // bits left-shifted into float are the same
#define FLOAT_SHIFT_SENT 4      // bits shifted into float are sent literally
#define FLOAT_ZEROS_SENT 8      // "zeros" are not all real zeros
#define FLOAT_NEG_ZEROS  0x10   // contains negative zeros
#define FLOAT_EXCEPTIONS 0x20   // contains exceptions (inf, nan, etc.)

/////////////////////////////// WavPack Context ///////////////////////////////

// This internal structure holds everything required to encode or decode WavPack
// files. It is recommended that direct access to this structure be minimized
// and the provided utilities used instead.

typedef struct {
    WavpackConfig config;
    WavpackStream stream;

    uchar read_buffer [1024];
    char error_message [80];

    read_stream infile;
    uint32_t total_samples, crc_errors, first_flags;
    int open_flags, norm_offset, reduced_channels, lossy_blocks;

} WavpackContext;

//////////////////////// function prototypes and macros //////////////////////

#define CLEAR(destin) memset (&destin, 0, sizeof (destin));

// bits.c

void bs_open_read (Bitstream *bs, uchar *buffer_start, uchar *buffer_end, read_stream file, uint32_t file_bytes);

#define bs_is_open(bs) ((bs)->ptr != NULL)

#define getbit(bs) ( \
    (((bs)->bc) ? \
        ((bs)->bc--, (bs)->sr & 1) : \
            (((++((bs)->ptr) != (bs)->end) ? (void) 0 : (bs)->wrap (bs)), (bs)->bc = 7, ((bs)->sr = *((bs)->ptr)) & 1) \
    ) ? \
        ((bs)->sr >>= 1, 1) : \
        ((bs)->sr >>= 1, 0) \
)

#define getbits(value, nbits, bs) { \
    while ((nbits) > (bs)->bc) { \
        if (++((bs)->ptr) == (bs)->end) (bs)->wrap (bs); \
        (bs)->sr |= (int32_t)*((bs)->ptr) << (bs)->bc; \
        (bs)->bc += 8; \
    } \
    *(value) = (bs)->sr; \
    if ((bs)->bc > 32) { \
        (bs)->bc -= (nbits); \
        (bs)->sr = *((bs)->ptr) >> (8 - (bs)->bc); \
    } \
    else { \
        (bs)->bc -= (nbits); \
        (bs)->sr >>= (nbits); \
    } \
}

void little_endian_to_native (void *data, char *format);
void native_to_little_endian (void *data, char *format);

// These macros implement the weight application and update operations
// that are at the heart of the decorrelation loops. Note that when there
// are several alternative versions of the same macro (marked with PERFCOND)
// then the versions are functionally equivalent with respect to WavPack
// decoding and the user should choose the one that provides the best
// performance. This may be easier to check when NOT using the assembly
// language optimizations.

#if 1   // PERFCOND
#define apply_weight_i(weight, sample) ((weight * sample + 512) >> 10)
#else
#define apply_weight_i(weight, sample) ((((weight * sample) >> 8) + 2) >> 2)
#endif

#define apply_weight_f(weight, sample) (((((sample & 0xffffL) * weight) >> 9) + \
    (((sample & ~0xffffL) >> 9) * weight) + 1) >> 1)

#if 1   // PERFCOND
#define apply_weight(weight, sample) (sample != (short) sample ? \
    apply_weight_f (weight, sample) : apply_weight_i (weight, sample))
#else
#define apply_weight(weight, sample) ((int32_t)((weight * (int64_t) sample + 512) >> 10))
#endif

#if 0   // PERFCOND
#define update_weight(weight, delta, source, result) \
    if (source && result) { int32_t s = (int32_t) (source ^ result) >> 31; weight = (delta ^ s) + (weight - s); }
#elif 1
#define update_weight(weight, delta, source, result) \
    if (source && result) weight += (((source ^ result) >> 30) | 1) * delta
#else
#define update_weight(weight, delta, source, result) \
    if (source && result) (source ^ result) < 0 ? (weight -= delta) : (weight += delta)
#endif

#define update_weight_clip(weight, delta, source, result) \
    if (source && result && ((source ^ result) < 0 ? (weight -= delta) < -1024 : (weight += delta) > 1024)) \
        weight = weight < 0 ? -1024 : 1024

// unpack.c

int unpack_init (WavpackContext *wpc);
int init_wv_bitstream (WavpackContext *wpc, WavpackMetadata *wpmd);
int read_decorr_terms (WavpackStream *wps, WavpackMetadata *wpmd);
int read_decorr_weights (WavpackStream *wps, WavpackMetadata *wpmd);
int read_decorr_samples (WavpackStream *wps, WavpackMetadata *wpmd);
int read_float_info (WavpackStream *wps, WavpackMetadata *wpmd);
int read_int32_info (WavpackStream *wps, WavpackMetadata *wpmd);
int read_channel_info (WavpackContext *wpc, WavpackMetadata *wpmd);
int read_config_info (WavpackContext *wpc, WavpackMetadata *wpmd);
int32_t unpack_samples (WavpackContext *wpc, int32_t *buffer, uint32_t sample_count);
int check_crc_error (WavpackContext *wpc);

// metadata.c stuff

int read_metadata_buff (WavpackContext *wpc, WavpackMetadata *wpmd);
int process_metadata (WavpackContext *wpc, WavpackMetadata *wpmd);

// words.c stuff

int read_entropy_vars (WavpackStream *wps, WavpackMetadata *wpmd);
int read_hybrid_profile (WavpackStream *wps, WavpackMetadata *wpmd);
int32_t get_words (int32_t *buffer, int nsamples, uint32_t flags,
                struct words_data *w, Bitstream *bs);
int32_t exp2s (int log);
int restore_weight (signed char weight);

#define WORD_EOF (1L << 31)

// float.c

int read_float_info (WavpackStream *wps, WavpackMetadata *wpmd);
void float_values (WavpackStream *wps, int32_t *values, int32_t num_values);

// wputils.c

WavpackContext *WavpackOpenFileInput (read_stream infile, char *error);

int WavpackGetMode (WavpackContext *wpc);

#define MODE_WVC        0x1
#define MODE_LOSSLESS   0x2
#define MODE_HYBRID     0x4
#define MODE_FLOAT      0x8
#define MODE_VALID_TAG  0x10
#define MODE_HIGH       0x20
#define MODE_FAST       0x40

uint32_t WavpackUnpackSamples (WavpackContext *wpc, int32_t *buffer, uint32_t samples);
uint32_t WavpackGetNumSamples (WavpackContext *wpc);
uint32_t WavpackGetSampleIndex (WavpackContext *wpc);
int WavpackGetNumErrors (WavpackContext *wpc);
int WavpackLossyBlocks (WavpackContext *wpc);
uint32_t WavpackGetSampleRate (WavpackContext *wpc);
int WavpackGetBitsPerSample (WavpackContext *wpc);
int WavpackGetBytesPerSample (WavpackContext *wpc);
int WavpackGetNumChannels (WavpackContext *wpc);
int WavpackGetReducedChannels (WavpackContext *wpc);
