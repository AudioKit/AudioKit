////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// open_filename.c

// This module provides all the code required to open an existing WavPack
// file, by filename, for reading. It does not contain the actual code to
// unpack audio data and this was done so that programs that just want to
// query WavPack files for information (like, for example, taggers) don't
// need to link in a lot of unnecessary code.
//
// To allow opening files by filename, this code provides an interface
// between the reader callback mechanism that WavPack uses internally and
// the standard fstream C library. Note that in applications that do not
// require opening files by filename, this module can be omitted (which
// might make building easier).
//
// For Unicode support on Windows, a flag has been added (OPEN_FILE_UTF8)
// that forces the filename string to be assumed UTF-8 and converted to
// a widechar string suitable for _wfopen(). Without this flag we revert
// to the previous behavior of simply calling fopen() and hoping that the
// local character set works. This is ignored on non-Windows platforms
// (which is okay because they are probably UTF-8 anyway).

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <io.h>
#endif

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"

#include <fcntl.h>
#include <sys/stat.h>

#if (defined(__GNUC__) || defined(__sun)) && !defined(_WIN32)
#include <unistd.h>
#endif

#ifdef __OS2__
#include <io.h>
#endif

#ifdef _WIN32
#define fileno _fileno
static FILE *fopen_utf8 (const char *filename_utf8, const char *mode_utf8);
#if !defined(S_ISREG) && defined(S_IFMT) && defined(S_IFREG)
#define S_ISREG(m) (((m) & S_IFMT) == S_IFREG)
#endif
#endif

#ifdef HAVE_FSEEKO
#define fseek fseeko
#define ftell ftello
#endif

static int32_t read_bytes (void *id, void *data, int32_t bcount)
{
    return (int32_t) fread (data, 1, bcount, (FILE*) id);
}

static int64_t get_pos (void *id)
{
#ifdef _WIN32
    return _ftelli64 ((FILE*) id);
#else
    return ftell ((FILE*) id);
#endif
}

static int set_pos_abs (void *id, int64_t pos)
{
#ifdef _WIN32
    return _fseeki64 (id, pos, SEEK_SET);
#else
    return fseek (id, pos, SEEK_SET);
#endif
}

static int set_pos_rel (void *id, int64_t delta, int mode)
{
#ifdef _WIN32
    return _fseeki64 (id, delta, mode);
#else
    return fseek (id, delta, mode);
#endif
}

static int push_back_byte (void *id, int c)
{
    return ungetc (c, id);
}

#ifdef _WIN32

static int64_t get_length (void *id)
{
    LARGE_INTEGER Size;
    HANDLE        fHandle;

    if (id == NULL)
        return 0;

    fHandle = (HANDLE)_get_osfhandle(_fileno((FILE*) id));
    if (fHandle == INVALID_HANDLE_VALUE)
        return 0;

    Size.u.LowPart = GetFileSize(fHandle, &Size.u.HighPart);

    if (Size.u.LowPart == INVALID_FILE_SIZE && GetLastError() != NO_ERROR)
        return 0;

    return (int64_t)Size.QuadPart;
}

#else

static int64_t get_length (void *id)
{
    FILE *file = id;
    struct stat statbuf;

    if (!file || fstat (fileno (file), &statbuf) || !S_ISREG(statbuf.st_mode))
        return 0;

    return statbuf.st_size;
}

#endif

static int can_seek (void *id)
{
    FILE *file = id;
    struct stat statbuf;

    return file && !fstat (fileno (file), &statbuf) && S_ISREG(statbuf.st_mode);
}

static int32_t write_bytes (void *id, void *data, int32_t bcount)
{
    return (int32_t) fwrite (data, 1, bcount, (FILE*) id);
}

#ifdef _WIN32

static int truncate_here (void *id)
{
    FILE *file = id;
    int64_t curr_pos = _ftelli64 (file);

    return _chsize_s (fileno (file), curr_pos);
}

#else

static int truncate_here (void *id)
{
    FILE *file = id;
    off_t curr_pos = ftell (file);

    return ftruncate (fileno (file), curr_pos);
}

#endif

static int close_stream (void *id)
{
    return fclose ((FILE*) id);
}

//  int32_t (*read_bytes)(void *id, void *data, int32_t bcount);
//  int32_t (*write_bytes)(void *id, void *data, int32_t bcount);
//  int64_t (*get_pos)(void *id);                               // new signature for large files
//  int (*set_pos_abs)(void *id, int64_t pos);                  // new signature for large files
//  int (*set_pos_rel)(void *id, int64_t delta, int mode);      // new signature for large files
//  int (*push_back_byte)(void *id, int c);
//  int64_t (*get_length)(void *id);                            // new signature for large files
//  int (*can_seek)(void *id);
//  int (*truncate_here)(void *id);                             // new function to truncate file at current position
//  int (*close)(void *id);                                     // new function to close file

static WavpackStreamReader64 freader = {
    read_bytes, write_bytes, get_pos, set_pos_abs, set_pos_rel,
    push_back_byte, get_length, can_seek, truncate_here, close_stream
};

// This function attempts to open the specified WavPack file for reading. If
// this fails for any reason then an appropriate message is copied to "error"
// (which must accept 80 characters) and NULL is returned, otherwise a
// pointer to a WavpackContext structure is returned (which is used to call
// all other functions in this module). A filename beginning with "-" is
// assumed to be stdin. The "flags" argument has the following bit mask
// values to specify details of the open operation:

// OPEN_WVC:  attempt to open/read "correction" file
// OPEN_TAGS:  attempt to read ID3v1 / APEv2 tags (requires seekable file)
// OPEN_WRAPPER:  make audio wrapper available (i.e. RIFF) to caller
// OPEN_2CH_MAX:  open only first stream of multichannel file (usually L/R)
// OPEN_NORMALIZE:  normalize floating point data to +/- 1.0 (w/ offset exp)
// OPEN_STREAMING:  blindly unpacks blocks w/o regard to header file position
// OPEN_EDIT_TAGS:  allow editing of tags (file must be writable)
// OPEN_FILE_UTF8:  assume infilename is UTF-8 encoded (Windows only)

// Version 4.2 of the WavPack library adds the OPEN_STREAMING flag. This is
// essentially a "raw" mode where the library will simply decode any blocks
// fed it through the reader callback, regardless of where those blocks came
// from in a stream. The only requirement is that complete WavPack blocks are
// fed to the decoder (and this may require multiple blocks in multichannel
// mode) and that complete blocks are decoded (even if all samples are not
// actually required). All the blocks must contain the same number of channels
// and bit resolution, and the correction data must be either present or not.
// All other parameters may change from block to block (like lossy/lossless).
// Obviously, in this mode any seeking must be performed by the application
// (and again, decoding must start at the beginning of the block containing
// the seek sample).

WavpackContext *WavpackOpenFileInput (const char *infilename, char *error, int flags, int norm_offset)
{
    char *file_mode = (flags & OPEN_EDIT_TAGS) ? "r+b" : "rb";
    FILE *(*fopen_func)(const char *, const char *) = fopen;
    FILE *wv_id, *wvc_id;

#ifdef _WIN32
    if (flags & OPEN_FILE_UTF8)
        fopen_func = fopen_utf8;
#endif

    if (*infilename == '-') {
        wv_id = stdin;
#if defined(_WIN32)
        _setmode (fileno (stdin), O_BINARY);
#endif
#if defined(__OS2__)
        setmode (fileno (stdin), O_BINARY);
#endif
    }
    else if ((wv_id = fopen_func (infilename, file_mode)) == NULL) {
        if (error) strcpy (error, (flags & OPEN_EDIT_TAGS) ? "can't open file for editing" : "can't open file");
        return NULL;
    }

    if (wv_id != stdin && (flags & OPEN_WVC)) {
        char *in2filename = malloc (strlen (infilename) + 10);

        strcpy (in2filename, infilename);
        strcat (in2filename, "c");
        wvc_id = fopen_func (in2filename, "rb");
        free (in2filename);
    }
    else
        wvc_id = NULL;

    return WavpackOpenFileInputEx64 (&freader, wv_id, wvc_id, error, flags, norm_offset);
}

#ifdef _WIN32

// The following code Copyright (c) 2004-2012 LoRd_MuldeR <mulder2@gmx.de>
// (see cli/win32_unicode_support.c for full license)

static wchar_t *utf8_to_utf16(const char *input)
{
	wchar_t *Buffer;
	int BuffSize = 0, Result = 0;

	BuffSize = MultiByteToWideChar(CP_UTF8, 0, input, -1, NULL, 0);
	Buffer = (wchar_t*) malloc(sizeof(wchar_t) * BuffSize);
	if(Buffer)
	{
		Result = MultiByteToWideChar(CP_UTF8, 0, input, -1, Buffer, BuffSize);
	}

	return ((Result > 0) && (Result <= BuffSize)) ? Buffer : NULL;
}


static FILE *fopen_utf8(const char *filename_utf8, const char *mode_utf8)
{
	FILE *ret = NULL;
	wchar_t *filename_utf16 = utf8_to_utf16(filename_utf8);
	wchar_t *mode_utf16 = utf8_to_utf16(mode_utf8);
	
	if(filename_utf16 && mode_utf16)
	{
		ret = _wfopen(filename_utf16, mode_utf16);
	}

	if(filename_utf16) free(filename_utf16);
	if(mode_utf16) free(mode_utf16);

	return ret;
}

#endif


