////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// tags.c

// This module provides support for reading metadata tags (either ID3v1 or
// APEv2) from WavPack files. No actual creation or manipulation of the tags
// is done in this module; this is just internal code to load the tags into
// memory. The high-level API functions are in the tag_utils.c module.

#include <stdlib.h>
#include <string.h>

#include "wavpack_local.h"

// This function attempts to load an ID3v1 or APEv2 tag from the specified
// file into the specified M_Tag structure. The ID3 tag fits in completely,
// but an APEv2 tag is variable length and so space must be allocated here
// to accomodate the data, and this will need to be freed later. A return
// value of TRUE indicates a valid tag was found and loaded. Note that the
// file pointer is undefined when this function exits.

int load_tag (WavpackContext *wpc)
{
    int ape_tag_length, ape_tag_items;
    M_Tag *m_tag = &wpc->m_tag;

    CLEAR (*m_tag);

    // This is a loop because we can try up to three times to look for an APEv2 tag. In order, we look:
    //
    //  1. At the end of the file for a APEv2 footer (this is the preferred location)
    //  2. If there's instead an ID3v1 tag at the end of the file, try looking for an APEv2 footer right before that
    //  3. If all else fails, look for an APEv2 header the the beginning of the file (use is strongly discouraged)

    while (1) {

        // seek based on specific location that we are looking for tag (see above list)

        if (m_tag->tag_begins_file)                     // case #3
            wpc->reader->set_pos_abs (wpc->wv_in, 0);
        else if (m_tag->id3_tag.tag_id [0] == 'T')      // case #2
            wpc->reader->set_pos_rel (wpc->wv_in, -(int32_t)(sizeof (APE_Tag_Hdr) + sizeof (ID3_Tag)), SEEK_END);
        else                                            // case #1
            wpc->reader->set_pos_rel (wpc->wv_in, -(int32_t)sizeof (APE_Tag_Hdr), SEEK_END);

        // read a possible APEv2 tag header/footer and see if there's one there...

        if (wpc->reader->read_bytes (wpc->wv_in, &m_tag->ape_tag_hdr, sizeof (APE_Tag_Hdr)) == sizeof (APE_Tag_Hdr) &&
            !strncmp (m_tag->ape_tag_hdr.ID, "APETAGEX", 8)) {

                WavpackLittleEndianToNative (&m_tag->ape_tag_hdr, APE_Tag_Hdr_Format);

                if (m_tag->ape_tag_hdr.version == 2000 && m_tag->ape_tag_hdr.item_count &&
                    m_tag->ape_tag_hdr.length > sizeof (m_tag->ape_tag_hdr) &&
                    m_tag->ape_tag_hdr.length <= APE_TAG_MAX_LENGTH &&
                    (m_tag->ape_tag_data = malloc (m_tag->ape_tag_hdr.length)) != NULL) {

                        ape_tag_items = m_tag->ape_tag_hdr.item_count;
                        ape_tag_length = m_tag->ape_tag_hdr.length;

                        // If this is a APEv2 footer (which is normal if we are searching at the end of the file)...

                        if (!(m_tag->ape_tag_hdr.flags & APE_TAG_THIS_IS_HEADER)) {

                            if (m_tag->id3_tag.tag_id [0] == 'T')
                                m_tag->tag_file_pos = -(int32_t)sizeof (ID3_Tag);
                            else
                                m_tag->tag_file_pos = 0;

                            m_tag->tag_file_pos -= ape_tag_length;

                            // if the footer claims there is a header present also, we will read that and use it
                            // instead of the footer (after verifying it, of course) for enhanced robustness

                            if (m_tag->ape_tag_hdr.flags & APE_TAG_CONTAINS_HEADER)
                                m_tag->tag_file_pos -= sizeof (APE_Tag_Hdr);

                            wpc->reader->set_pos_rel (wpc->wv_in, m_tag->tag_file_pos, SEEK_END);

                            if (m_tag->ape_tag_hdr.flags & APE_TAG_CONTAINS_HEADER) {
                                if (wpc->reader->read_bytes (wpc->wv_in, &m_tag->ape_tag_hdr, sizeof (APE_Tag_Hdr)) !=
                                    sizeof (APE_Tag_Hdr) || strncmp (m_tag->ape_tag_hdr.ID, "APETAGEX", 8)) {
                                        free (m_tag->ape_tag_data);
                                        CLEAR (*m_tag);
                                        return FALSE;       // something's wrong...
                                }

                                WavpackLittleEndianToNative (&m_tag->ape_tag_hdr, APE_Tag_Hdr_Format);

                                if (m_tag->ape_tag_hdr.version != 2000 || m_tag->ape_tag_hdr.item_count != ape_tag_items ||
                                    m_tag->ape_tag_hdr.length != ape_tag_length) {
                                        free (m_tag->ape_tag_data);
                                        CLEAR (*m_tag);
                                        return FALSE;       // something's wrong...
                                }
                            }
                        }

                        if (wpc->reader->read_bytes (wpc->wv_in, m_tag->ape_tag_data,
                            ape_tag_length - sizeof (APE_Tag_Hdr)) != ape_tag_length - sizeof (APE_Tag_Hdr)) {
                                free (m_tag->ape_tag_data);
                                CLEAR (*m_tag);
                                return FALSE;       // something's wrong...
                        }
                        else {
                            CLEAR (m_tag->id3_tag); // ignore ID3v1 tag if we found APEv2 tag
                            return TRUE;
                        }
                }
        }

        // we come here if the search for the APEv2 tag failed (otherwise we would have returned with it)

        if (m_tag->id3_tag.tag_id [0] == 'T') {     // settle for the ID3v1 tag that we found
            CLEAR (m_tag->ape_tag_hdr);
            return TRUE;
        }

        // if this was the search for the APEv2 tag at the beginning of the file (which is our
        // last resort) then we have nothing, so return failure

        if (m_tag->tag_begins_file) {
            CLEAR (*m_tag);
            return FALSE;
        }

        // If we get here, then we have failed the first APEv2 tag search (at end of file) and so now we
        // look for an ID3v1 tag at the same position. If that succeeds, then we'll loop back and look for
        // an APEv2 tag immediately before the ID3v1 tag, otherwise our last resort is to look for an
        // APEv2 tag at the beginning of the file. These are strongly discouraged (and not editable) but
        // they have been seen in the wild so we attempt to handle them here (at least well enough to
        // allow a proper transcoding).

        m_tag->tag_file_pos = -(int32_t)sizeof (ID3_Tag);
        wpc->reader->set_pos_rel (wpc->wv_in, m_tag->tag_file_pos, SEEK_END);

        if (wpc->reader->read_bytes (wpc->wv_in, &m_tag->id3_tag, sizeof (ID3_Tag)) != sizeof (ID3_Tag) ||
            strncmp (m_tag->id3_tag.tag_id, "TAG", 3)) {
                m_tag->tag_begins_file = 1;     // failed ID3v1, so look for APEv2 at beginning of file
                CLEAR (m_tag->id3_tag);
            }
    }  
}

// Return TRUE is a valid ID3v1 or APEv2 tag has been loaded.

int valid_tag (M_Tag *m_tag)
{
    if (m_tag->ape_tag_hdr.ID [0] == 'A')
        return 'A';
    else if (m_tag->id3_tag.tag_id [0] == 'T')
        return 'T';
    else
        return 0;
}

// Return FALSE if a valid APEv2 tag was only found at the beginning of the file (these are read-only
// because they cannot be edited without possibly shifting the entire file)

int editable_tag (M_Tag *m_tag)
{
    return !m_tag->tag_begins_file;
}

// Free the data for any APEv2 tag that was allocated.

void free_tag (M_Tag *m_tag)
{
    if (m_tag->ape_tag_data) {
        free (m_tag->ape_tag_data);
        m_tag->ape_tag_data = NULL;
    }
}
