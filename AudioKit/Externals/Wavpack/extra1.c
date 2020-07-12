////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// extra1.c

// This module handles the "extra" mode for mono files.

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "wavpack_local.h"

// This flag causes this module to take into account the size of the header
// (which grows with more decorrelation passes) when making decisions about
// adding additional passes (as opposed to just considering the resulting
// magnitude of the residuals). With really long blocks it seems to actually
// hurt compression (for reasons I cannot explain), but with short blocks it
// works okay, so we're enabling it for now.

#define USE_OVERHEAD

// If the log2 value of any sample in a buffer being scanned exceeds this value,
// we abandon that configuration. This prevents us from going down paths that
// are wildly unstable.

#define LOG_LIMIT 6912

//#define EXTRA_DUMP        // dump generated filter data  error_line()

#ifdef OPT_ASM_X86
    #define PACK_DECORR_MONO_PASS_CONT pack_decorr_mono_pass_cont_x86
#elif defined(OPT_ASM_X64) && (defined (_WIN64) || defined(__CYGWIN__) || defined(__MINGW64__))
    #define PACK_DECORR_MONO_PASS_CONT pack_decorr_mono_pass_cont_x64win
#elif defined(OPT_ASM_X64)
    #define PACK_DECORR_MONO_PASS_CONT pack_decorr_mono_pass_cont_x64
#endif

#ifdef PACK_DECORR_MONO_PASS_CONT
    void PACK_DECORR_MONO_PASS_CONT (int32_t *out_buffer, int32_t *in_buffer,  struct decorr_pass *dpp, int32_t sample_count);
#endif

typedef struct {
    int32_t *sampleptrs [MAX_NTERMS+2];
    struct decorr_pass dps [MAX_NTERMS];
    int nterms, log_limit;
    uint32_t best_bits;
} WavpackExtraInfo;

static void decorr_mono_pass (int32_t *in_samples, int32_t *out_samples, uint32_t num_samples, struct decorr_pass *dpp, int dir)
{
    int32_t cont_samples = 0;
    int m = 0, i;

#ifdef PACK_DECORR_MONO_PASS_CONT
    if (num_samples > 16 && dir > 0) {
        int32_t pre_samples = (dpp->term > MAX_TERM) ? 2 : dpp->term;
        cont_samples = num_samples - pre_samples;
        num_samples = pre_samples;
    }
#endif

    dpp->sum_A = 0;

    if (dir < 0) {
        out_samples += (num_samples + cont_samples - 1);
        in_samples += (num_samples + cont_samples - 1);
        dir = -1;
    }
    else
        dir = 1;

    dpp->weight_A = restore_weight (store_weight (dpp->weight_A));

    for (i = 0; i < 8; ++i)
        dpp->samples_A [i] = wp_exp2s (wp_log2s (dpp->samples_A [i]));

    if (dpp->term > MAX_TERM) {
        while (num_samples--) {
            int32_t left, sam_A;

            if (dpp->term & 1)
                sam_A = 2 * dpp->samples_A [0] - dpp->samples_A [1];
            else
                sam_A = (3 * dpp->samples_A [0] - dpp->samples_A [1]) >> 1;

            dpp->samples_A [1] = dpp->samples_A [0];
            dpp->samples_A [0] = left = in_samples [0];

            left -= apply_weight (dpp->weight_A, sam_A);
            update_weight (dpp->weight_A, dpp->delta, sam_A, left);
            dpp->sum_A += dpp->weight_A;
            out_samples [0] = left;
            in_samples += dir;
            out_samples += dir;
        }
    }
    else if (dpp->term > 0) {
        while (num_samples--) {
            int k = (m + dpp->term) & (MAX_TERM - 1);
            int32_t left, sam_A;

            sam_A = dpp->samples_A [m];
            dpp->samples_A [k] = left = in_samples [0];
            m = (m + 1) & (MAX_TERM - 1);

            left -= apply_weight (dpp->weight_A, sam_A);
            update_weight (dpp->weight_A, dpp->delta, sam_A, left);
            dpp->sum_A += dpp->weight_A;
            out_samples [0] = left;
            in_samples += dir;
            out_samples += dir;
        }
    }

    if (m && dpp->term > 0 && dpp->term <= MAX_TERM) {
        int32_t temp_A [MAX_TERM];
        int k;

        memcpy (temp_A, dpp->samples_A, sizeof (dpp->samples_A));

        for (k = 0; k < MAX_TERM; k++) {
            dpp->samples_A [k] = temp_A [m];
            m = (m + 1) & (MAX_TERM - 1);
        }
    }

#ifdef PACK_DECORR_MONO_PASS_CONT
    if (cont_samples)
        PACK_DECORR_MONO_PASS_CONT (out_samples, in_samples, dpp, cont_samples);
#endif
}

static void reverse_mono_decorr (struct decorr_pass *dpp)
{
    if (dpp->term > MAX_TERM) {
        int32_t sam_A;

        if (dpp->term & 1)
            sam_A = 2 * dpp->samples_A [0] - dpp->samples_A [1];
        else
            sam_A = (3 * dpp->samples_A [0] - dpp->samples_A [1]) >> 1;

        dpp->samples_A [1] = dpp->samples_A [0];
        dpp->samples_A [0] = sam_A;

        if (dpp->term & 1)
            sam_A = 2 * dpp->samples_A [0] - dpp->samples_A [1];
        else
            sam_A = (3 * dpp->samples_A [0] - dpp->samples_A [1]) >> 1;

        dpp->samples_A [1] = sam_A;
    }
    else if (dpp->term > 1) {
        int i = 0, j = dpp->term - 1, cnt = dpp->term / 2;

        while (cnt--) {
            i &= (MAX_TERM - 1);
            j &= (MAX_TERM - 1);
            dpp->samples_A [i] ^= dpp->samples_A [j];
            dpp->samples_A [j] ^= dpp->samples_A [i];
            dpp->samples_A [i++] ^= dpp->samples_A [j--];
        }

//      CLEAR (dpp->samples_A);
    }
}

static void decorr_mono_buffer (int32_t *samples, int32_t *outsamples, uint32_t num_samples, struct decorr_pass *dpp, int tindex)
{
    struct decorr_pass dp, *dppi = dpp + tindex;
    int delta = dppi->delta, pre_delta, term = dppi->term;

    if (delta == 7)
        pre_delta = 7;
    else if (delta < 2)
        pre_delta = 3;
    else
        pre_delta = delta + 1;

    CLEAR (dp);
    dp.term = term;
    dp.delta = pre_delta;
    decorr_mono_pass (samples, outsamples, num_samples > 2048 ? 2048 : num_samples, &dp, -1);
    dp.delta = delta;

    if (tindex == 0)
        reverse_mono_decorr (&dp);
    else
        CLEAR (dp.samples_A);

    memcpy (dppi->samples_A, dp.samples_A, sizeof (dp.samples_A));
    dppi->weight_A = dp.weight_A;

    if (delta == 0) {
        dp.delta = 1;
        decorr_mono_pass (samples, outsamples, num_samples, &dp, 1);
        dp.delta = 0;
        memcpy (dp.samples_A, dppi->samples_A, sizeof (dp.samples_A));
        dppi->weight_A = dp.weight_A = dp.sum_A / num_samples;
    }

//    if (memcmp (dppi, &dp, sizeof (dp)))
//      error_line ("decorr_passes don't match, delta = %d", delta);

    decorr_mono_pass (samples, outsamples, num_samples, &dp, 1);
}

static int log2overhead (int first_term, int num_terms)
{
#ifdef USE_OVERHEAD
    if (first_term > MAX_TERM)
        return (4 + num_terms * 2) << 11;
    else
        return (2 + num_terms * 2) << 11;
#else
    return 0;
#endif
}

static void recurse_mono (WavpackContext *wpc, WavpackExtraInfo *info, int depth, int delta, uint32_t input_bits)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    int term, branches = ((wpc->config.extra_flags & EXTRA_BRANCHES) >> 6) - depth;
    int32_t *samples, *outsamples;
    uint32_t term_bits [22], bits;

    if (branches < 1 || depth + 1 == info->nterms)
        branches = 1;

    CLEAR (term_bits);
    samples = info->sampleptrs [depth];
    outsamples = info->sampleptrs [depth + 1];

    for (term = 1; term <= 18; ++term) {
        if (term == 17 && branches == 1 && depth + 1 < info->nterms)
            continue;

        if (term > 8 && term < 17)
            continue;

        if ((wpc->config.flags & CONFIG_FAST_FLAG) && (term > 4 && term < 17))
            continue;

        info->dps [depth].term = term;
        info->dps [depth].delta = delta;
        decorr_mono_buffer (samples, outsamples, wps->wphdr.block_samples, info->dps, depth);
        bits = LOG2BUFFER (outsamples, wps->wphdr.block_samples, info->log_limit);

        if (bits != (uint32_t) -1)
            bits += log2overhead (info->dps [0].term, depth + 1);

        if (bits < info->best_bits) {
            info->best_bits = bits;
            CLEAR (wps->decorr_passes);
            memcpy (wps->decorr_passes, info->dps, sizeof (info->dps [0]) * (depth + 1));
            memcpy (info->sampleptrs [info->nterms + 1], info->sampleptrs [depth + 1], wps->wphdr.block_samples * 4);
        }

        term_bits [term + 3] = bits;
    }

    while (depth + 1 < info->nterms && branches--) {
        uint32_t local_best_bits = input_bits;
        int best_term = 0, i;

        for (i = 0; i < 22; ++i)
            if (term_bits [i] && term_bits [i] < local_best_bits) {
                local_best_bits = term_bits [i];
//              term_bits [i] = 0;
                best_term = i - 3;
            }

        if (!best_term)
            break;

        term_bits [best_term + 3] = 0;

        info->dps [depth].term = best_term;
        info->dps [depth].delta = delta;
        decorr_mono_buffer (samples, outsamples, wps->wphdr.block_samples, info->dps, depth);

//      if (log2buffer (outsamples, wps->wphdr.block_samples * 2, 0) != local_best_bits)
//          error_line ("data doesn't match!");

        recurse_mono (wpc, info, depth + 1, delta, local_best_bits);
    }
}

static void delta_mono (WavpackContext *wpc, WavpackExtraInfo *info)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    int lower = FALSE, delta, d;
    uint32_t bits;

    if (wps->decorr_passes [0].term)
        delta = wps->decorr_passes [0].delta;
    else
        return;

    for (d = delta - 1; d >= 0; --d) {
        int i;

        if (!d && (wps->wphdr.flags & HYBRID_FLAG))
            break;

        for (i = 0; i < info->nterms && wps->decorr_passes [i].term; ++i) {
            info->dps [i].term = wps->decorr_passes [i].term;
            info->dps [i].delta = d;
            decorr_mono_buffer (info->sampleptrs [i], info->sampleptrs [i+1], wps->wphdr.block_samples, info->dps, i);
        }

        bits = LOG2BUFFER (info->sampleptrs [i], wps->wphdr.block_samples, info->log_limit);

        if (bits != (uint32_t) -1)
            bits += log2overhead (wps->decorr_passes [0].term, i);

        if (bits < info->best_bits) {
            lower = TRUE;
            info->best_bits = bits;
            CLEAR (wps->decorr_passes);
            memcpy (wps->decorr_passes, info->dps, sizeof (info->dps [0]) * i);
            memcpy (info->sampleptrs [info->nterms + 1], info->sampleptrs [i], wps->wphdr.block_samples * 4);
        }
        else
            break;
    }

    for (d = delta + 1; !lower && d <= 7; ++d) {
        int i;

        for (i = 0; i < info->nterms && wps->decorr_passes [i].term; ++i) {
            info->dps [i].term = wps->decorr_passes [i].term;
            info->dps [i].delta = d;
            decorr_mono_buffer (info->sampleptrs [i], info->sampleptrs [i+1], wps->wphdr.block_samples, info->dps, i);
        }

        bits = LOG2BUFFER (info->sampleptrs [i], wps->wphdr.block_samples, info->log_limit);

        if (bits != (uint32_t) -1)
            bits += log2overhead (wps->decorr_passes [0].term, i);

        if (bits < info->best_bits) {
            info->best_bits = bits;
            CLEAR (wps->decorr_passes);
            memcpy (wps->decorr_passes, info->dps, sizeof (info->dps [0]) * i);
            memcpy (info->sampleptrs [info->nterms + 1], info->sampleptrs [i], wps->wphdr.block_samples * 4);
        }
        else
            break;
    }
}

static void sort_mono (WavpackContext *wpc, WavpackExtraInfo *info)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    int reversed = TRUE;
    uint32_t bits;

    while (reversed) {
        int ri, i;

        memcpy (info->dps, wps->decorr_passes, sizeof (wps->decorr_passes));
        reversed = FALSE;

        for (ri = 0; ri < info->nterms && wps->decorr_passes [ri].term; ++ri) {

            if (ri + 1 >= info->nterms || !wps->decorr_passes [ri+1].term)
                break;

            if (wps->decorr_passes [ri].term == wps->decorr_passes [ri+1].term) {
                decorr_mono_buffer (info->sampleptrs [ri], info->sampleptrs [ri+1], wps->wphdr.block_samples, info->dps, ri);
                continue;
            }

            info->dps [ri] = wps->decorr_passes [ri+1];
            info->dps [ri+1] = wps->decorr_passes [ri];

            for (i = ri; i < info->nterms && wps->decorr_passes [i].term; ++i)
                decorr_mono_buffer (info->sampleptrs [i], info->sampleptrs [i+1], wps->wphdr.block_samples, info->dps, i);

            bits = LOG2BUFFER (info->sampleptrs [i], wps->wphdr.block_samples, info->log_limit);

            if (bits != (uint32_t) -1)
                bits += log2overhead (wps->decorr_passes [0].term, i);

            if (bits < info->best_bits) {
                reversed = TRUE;
                info->best_bits = bits;
                CLEAR (wps->decorr_passes);
                memcpy (wps->decorr_passes, info->dps, sizeof (info->dps [0]) * i);
                memcpy (info->sampleptrs [info->nterms + 1], info->sampleptrs [i], wps->wphdr.block_samples * 4);
            }
            else {
                info->dps [ri] = wps->decorr_passes [ri];
                info->dps [ri+1] = wps->decorr_passes [ri+1];
                decorr_mono_buffer (info->sampleptrs [ri], info->sampleptrs [ri+1], wps->wphdr.block_samples, info->dps, ri);
            }
        }
    }
}

static const uint32_t xtable [] = { 91, 123, 187, 251 };

static void analyze_mono (WavpackContext *wpc, int32_t *samples, int do_samples)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    WavpackExtraInfo info;
    int i;

#ifdef LOG_LIMIT
    info.log_limit = (((wps->wphdr.flags & MAG_MASK) >> MAG_LSB) + 4) * 256;

    if (info.log_limit > LOG_LIMIT)
        info.log_limit = LOG_LIMIT;
#else
    info.log_limit = 0;
#endif

    if (wpc->config.flags & (CONFIG_HIGH_FLAG | CONFIG_VERY_HIGH_FLAG))
        wpc->config.extra_flags = xtable [wpc->config.xmode - 4];
    else
        wpc->config.extra_flags = xtable [wpc->config.xmode - 3];

    info.nterms = wps->num_terms;

    for (i = 0; i < info.nterms + 2; ++i)
        info.sampleptrs [i] = malloc (wps->wphdr.block_samples * 4);

    memcpy (info.dps, wps->decorr_passes, sizeof (info.dps));
    memcpy (info.sampleptrs [0], samples, wps->wphdr.block_samples * 4);

    for (i = 0; i < info.nterms && info.dps [i].term; ++i)
        decorr_mono_pass (info.sampleptrs [i], info.sampleptrs [i + 1], wps->wphdr.block_samples, info.dps + i, 1);

    info.best_bits = LOG2BUFFER (info.sampleptrs [info.nterms], wps->wphdr.block_samples, 0) * 1;
    info.best_bits += log2overhead (info.dps [0].term, i);
    memcpy (info.sampleptrs [info.nterms + 1], info.sampleptrs [i], wps->wphdr.block_samples * 4);

    if (wpc->config.extra_flags & EXTRA_BRANCHES)
        recurse_mono (wpc, &info, 0, (int) floor (wps->delta_decay + 0.5),
            LOG2BUFFER (info.sampleptrs [0], wps->wphdr.block_samples, 0));

    if (wpc->config.extra_flags & EXTRA_SORT_FIRST)
        sort_mono (wpc, &info);

    if (wpc->config.extra_flags & EXTRA_TRY_DELTAS) {
        delta_mono (wpc, &info);

        if ((wpc->config.extra_flags & EXTRA_ADJUST_DELTAS) && wps->decorr_passes [0].term)
            wps->delta_decay = (float)((wps->delta_decay * 2.0 + wps->decorr_passes [0].delta) / 3.0);
        else
            wps->delta_decay = 2.0;
    }

    if (wpc->config.extra_flags & EXTRA_SORT_LAST)
        sort_mono (wpc, &info);

    if (do_samples)
        memcpy (samples, info.sampleptrs [info.nterms + 1], wps->wphdr.block_samples * 4);

    for (i = 0; i < info.nterms; ++i)
        if (!wps->decorr_passes [i].term)
            break;

    wps->num_terms = i;

    for (i = 0; i < info.nterms + 2; ++i)
        free (info.sampleptrs [i]);
}

static void mono_add_noise (WavpackStream *wps, int32_t *lptr, int32_t *rptr)
{
    int shaping_weight, new = wps->wphdr.flags & NEW_SHAPING;
    short *shaping_array = wps->dc.shaping_array;
    int32_t error = 0, temp, cnt;

    scan_word (wps, rptr, wps->wphdr.block_samples, -1);
    cnt = wps->wphdr.block_samples;

    if (wps->wphdr.flags & HYBRID_SHAPE) {
        while (cnt--) {
            if (shaping_array)
                shaping_weight = *shaping_array++;
            else
                shaping_weight = (wps->dc.shaping_acc [0] += wps->dc.shaping_delta [0]) >> 16;

            temp = -apply_weight (shaping_weight, error);

            if (new && shaping_weight < 0 && temp) {
                if (temp == error)
                    temp = (temp < 0) ? temp + 1 : temp - 1;

                lptr [0] += (error = nosend_word (wps, rptr [0], 0) - rptr [0] + temp);
            }
            else
                lptr [0] += (error = nosend_word (wps, rptr [0], 0) - rptr [0]) + temp;

            lptr++;
            rptr++;
        }

        if (!shaping_array)
            wps->dc.shaping_acc [0] -= wps->dc.shaping_delta [0] * wps->wphdr.block_samples;
    }
    else
        while (cnt--) {
            lptr [0] += nosend_word (wps, rptr [0], 0) - rptr [0];
            lptr++;
            rptr++;
        }
}

void execute_mono (WavpackContext *wpc, int32_t *samples, int no_history, int do_samples)
{
    int32_t *temp_buffer [2], *best_buffer, *noisy_buffer = NULL;
    struct decorr_pass temp_decorr_pass, save_decorr_passes [MAX_NTERMS];
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    int32_t num_samples = wps->wphdr.block_samples;
    int32_t buf_size = sizeof (int32_t) * num_samples;
    uint32_t best_size = (uint32_t) -1, size;
    int log_limit, pi, i;

#ifdef SKIP_DECORRELATION
    CLEAR (wps->decorr_passes);
    wps->num_terms = 0;
    return;
#endif

    for (i = 0; i < num_samples; ++i)
        if (samples [i])
            break;

    if (i == num_samples) {
        CLEAR (wps->decorr_passes);
        wps->num_terms = 0;
        init_words (wps);
        return;
    }

#ifdef LOG_LIMIT
    log_limit = (((wps->wphdr.flags & MAG_MASK) >> MAG_LSB) + 4) * 256;

    if (log_limit > LOG_LIMIT)
        log_limit = LOG_LIMIT;
#else
    log_limit = 0;
#endif

    CLEAR (save_decorr_passes);
    temp_buffer [0] = malloc (buf_size);
    temp_buffer [1] = malloc (buf_size);
    best_buffer = malloc (buf_size);

    if (wps->num_passes > 1 && (wps->wphdr.flags & HYBRID_FLAG)) {
        CLEAR (temp_decorr_pass);
        temp_decorr_pass.delta = 2;
        temp_decorr_pass.term = 18;

        decorr_mono_pass (samples, temp_buffer [0],
            num_samples > 2048 ? 2048 : num_samples, &temp_decorr_pass, -1);

        reverse_mono_decorr (&temp_decorr_pass);
        decorr_mono_pass (samples, temp_buffer [0], num_samples, &temp_decorr_pass, 1);
        CLEAR (temp_decorr_pass);
        temp_decorr_pass.delta = 2;
        temp_decorr_pass.term = 17;

        decorr_mono_pass (temp_buffer [0], temp_buffer [1],
            num_samples > 2048 ? 2048 : num_samples, &temp_decorr_pass, -1);

        decorr_mono_pass (temp_buffer [0], temp_buffer [1], num_samples, &temp_decorr_pass, 1);
        noisy_buffer = malloc (buf_size);
        memcpy (noisy_buffer, samples, buf_size);
        mono_add_noise (wps, noisy_buffer, temp_buffer [1]);
        no_history = 1;
    }

    if (no_history || wps->num_passes >= 7)
        wps->best_decorr = wps->mask_decorr = 0;

    for (pi = 0; pi < wps->num_passes;) {
        const WavpackDecorrSpec *wpds;
        int nterms, c, j;

        if (!pi)
            c = wps->best_decorr;
        else {
            if (wps->mask_decorr == 0)
                c = 0;
            else
                c = (wps->best_decorr & (wps->mask_decorr - 1)) | wps->mask_decorr;

            if (c == wps->best_decorr) {
                wps->mask_decorr = wps->mask_decorr ? ((wps->mask_decorr << 1) & (wps->num_decorrs - 1)) : 1;
                continue;
            }
        }

        wpds = &wps->decorr_specs [c];
        nterms = (int) strlen ((char *) wpds->terms);

        while (1) {
        memcpy (temp_buffer [0], noisy_buffer ? noisy_buffer : samples, buf_size);
        CLEAR (save_decorr_passes);

        for (j = 0; j < nterms; ++j) {
            CLEAR (temp_decorr_pass);
            temp_decorr_pass.delta = wpds->delta;
            temp_decorr_pass.term = wpds->terms [j];

            if (temp_decorr_pass.term < 0)
                temp_decorr_pass.term = 1;

            decorr_mono_pass (temp_buffer [j&1], temp_buffer [~j&1],
                num_samples > 2048 ? 2048 : num_samples, &temp_decorr_pass, -1);

            if (j) {
                CLEAR (temp_decorr_pass.samples_A);
            }
            else
                reverse_mono_decorr (&temp_decorr_pass);

            memcpy (save_decorr_passes + j, &temp_decorr_pass, sizeof (struct decorr_pass));
            decorr_mono_pass (temp_buffer [j&1], temp_buffer [~j&1], num_samples, &temp_decorr_pass, 1);
        }

        size = LOG2BUFFER (temp_buffer [j&1], num_samples, log_limit);

        if (size == (uint32_t) -1 && nterms)
            nterms >>= 1;
        else
            break;
        }

        size += log2overhead (wpds->terms [0], nterms);

        if (size < best_size) {
            memcpy (best_buffer, temp_buffer [j&1], buf_size);
            memcpy (wps->decorr_passes, save_decorr_passes, sizeof (struct decorr_pass) * MAX_NTERMS);
            wps->num_terms = nterms;
            wps->best_decorr = c;
            best_size = size;
        }

        if (pi++)
            wps->mask_decorr = wps->mask_decorr ? ((wps->mask_decorr << 1) & (wps->num_decorrs - 1)) : 1;
    }

    if (wpc->config.xmode > 3) {
        if (noisy_buffer) {
            analyze_mono (wpc, noisy_buffer, do_samples);

            if (do_samples)
                memcpy (samples, noisy_buffer, buf_size);
        }
        else
            analyze_mono (wpc, samples, do_samples);
    }
    else if (do_samples)
        memcpy (samples, best_buffer, buf_size);

    if (no_history || wpc->config.xmode > 3)
        scan_word (wps, best_buffer, num_samples, -1);

    if (noisy_buffer)
        free (noisy_buffer);

    free (temp_buffer [1]);
    free (temp_buffer [0]);
    free (best_buffer);

#ifdef EXTRA_DUMP
    if (1) {
        char string [256], substring [20];
        int i;

        sprintf (string, "M: terms =");

        for (i = 0; i < wps->num_terms; ++i) {
            if (wps->decorr_passes [i].term) {
                if (i && wps->decorr_passes [i-1].delta == wps->decorr_passes [i].delta)
                    sprintf (substring, " %d", wps->decorr_passes [i].term);
                else
                    sprintf (substring, " %d->%d", wps->decorr_passes [i].term,
                        wps->decorr_passes [i].delta);
            }
            else
                sprintf (substring, " *");

            strcat (string, substring);
        }

        error_line (string);
    }
#endif
}

