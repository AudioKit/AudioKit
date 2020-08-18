////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//                Copyright (c) 1998 - 2016 David Bryant.                 //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// open_legacy.c

// This code provides an interface between the new reader callback mechanism that
// WavPack uses internally and the old reader callback functions that did not
// provide large file support.

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"

typedef struct {
    WavpackStreamReader *reader;
    void *id;
} WavpackReaderTranslator;

static int32_t trans_read_bytes (void *id, void *data, int32_t bcount)
{
    WavpackReaderTranslator *trans = id;
    return trans->reader->read_bytes (trans->id, data, bcount);
}

static int32_t trans_write_bytes (void *id, void *data, int32_t bcount)
{
    WavpackReaderTranslator *trans = id;
    return trans->reader->write_bytes (trans->id, data, bcount);
}

static int64_t trans_get_pos (void *id)
{
    WavpackReaderTranslator *trans = id;
    return trans->reader->get_pos (trans->id);
}

static int trans_set_pos_abs (void *id, int64_t pos)
{
    WavpackReaderTranslator *trans = id;
    return trans->reader->set_pos_abs (trans->id, (uint32_t) pos);
}

static int trans_set_pos_rel (void *id, int64_t delta, int mode)
{
    WavpackReaderTranslator *trans = id;
    return trans->reader->set_pos_rel (trans->id, (int32_t) delta, mode);
}

static int trans_push_back_byte (void *id, int c)
{
    WavpackReaderTranslator *trans = id;
    return trans->reader->push_back_byte (trans->id, c);
}

static int64_t trans_get_length (void *id)
{
    WavpackReaderTranslator *trans = id;
    return trans->reader->get_length (trans->id);
}

static int trans_can_seek (void *id)
{
    WavpackReaderTranslator *trans = id;
    return trans->reader->can_seek (trans->id);
}

static int trans_close_stream (void *id)
{
    free (id);
    return 0;
}

static WavpackStreamReader64 trans_reader = {
    trans_read_bytes, trans_write_bytes, trans_get_pos, trans_set_pos_abs, trans_set_pos_rel,
    trans_push_back_byte, trans_get_length, trans_can_seek, NULL, trans_close_stream
};

// This function is identical to WavpackOpenFileInput64() except that instead
// of providing the new 64-bit reader callbacks, the old reader callbacks are
// utilized and a translation layer is employed. It is provided as a compatibility
// function for existing applications. To ensure that streaming applications using
// this function continue to work, the OPEN_NO_CHECKSUM flag is forced on when
// the OPEN_STREAMING flag is set.

WavpackContext *WavpackOpenFileInputEx (WavpackStreamReader *reader, void *wv_id, void *wvc_id, char *error, int flags, int norm_offset)
{
    WavpackReaderTranslator *trans_wv = NULL, *trans_wvc = NULL;

    // this prevents existing streaming applications from failing if they try to pass
    // in blocks that have been modified from the original (e.g., Matroska blocks)

    if (flags & OPEN_STREAMING)
        flags |= OPEN_NO_CHECKSUM;

    if (wv_id) {
        trans_wv = malloc (sizeof (WavpackReaderTranslator));
        trans_wv->reader = reader;
        trans_wv->id = wv_id;
    }

    if (wvc_id) {
        trans_wvc = malloc (sizeof (WavpackReaderTranslator));
        trans_wvc->reader = reader;
        trans_wvc->id = wvc_id;
    }

    return WavpackOpenFileInputEx64 (&trans_reader, trans_wv, trans_wvc, error, flags, norm_offset);
}
