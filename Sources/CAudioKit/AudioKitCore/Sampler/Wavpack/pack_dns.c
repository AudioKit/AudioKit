////////////////////////////////////////////////////////////////////////////
//                           **** WAVPACK ****                            //
//                  Hybrid Lossless Wavefile Compressor                   //
//              Copyright (c) 1998 - 2013 Conifer Software.               //
//                          All Rights Reserved.                          //
//      Distributed under the BSD Software License (see license.txt)      //
////////////////////////////////////////////////////////////////////////////

// pack_dns.c

// This module handles the implementation of "dynamic noise shaping" which is
// designed to move the spectrum of the quantization noise introduced by lossy
// compression up or down in frequency so that it is more likely to be masked
// by the source material.

#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "wavpack_local.h"

static void best_floating_line (short *values, int num_values, double *initial_y, double *final_y, short *max_error);

void dynamic_noise_shaping (WavpackContext *wpc, int32_t *buffer, int shortening_allowed)
{
    WavpackStream *wps = wpc->streams [wpc->current_stream];
    int32_t sample_count = wps->wphdr.block_samples;
    struct decorr_pass *ap = &wps->analysis_pass;
    uint32_t flags = wps->wphdr.flags;
    int32_t *bptr, temp, sam;
    short *swptr;
    int sc;

    if (!wps->num_terms && sample_count > 8) {
        if (flags & MONO_DATA)
            for (bptr = buffer + sample_count - 3, sc = sample_count - 2; sc--;) {
                sam = (3 * bptr [1] - bptr [2]) >> 1;
                temp = *bptr-- - apply_weight (ap->weight_A, sam);
                update_weight (ap->weight_A, 2, sam, temp);
            }
        else
            for (bptr = buffer + (sample_count - 3) * 2 + 1, sc = sample_count - 2; sc--;) {
                sam = (3 * bptr [2] - bptr [4]) >> 1;
                temp = *bptr-- - apply_weight (ap->weight_B, sam);
                update_weight (ap->weight_B, 2, sam, temp);
                sam = (3 * bptr [2] - bptr [4]) >> 1;
                temp = *bptr-- - apply_weight (ap->weight_A, sam);
                update_weight (ap->weight_A, 2, sam, temp);
            }
    }

    if (sample_count > wps->dc.shaping_samples) {
        sc = sample_count - wps->dc.shaping_samples;
        swptr = wps->dc.shaping_data + wps->dc.shaping_samples;
        bptr = buffer + wps->dc.shaping_samples * ((flags & MONO_DATA) ? 1 : 2);

        if (flags & MONO_DATA)
            while (sc--) {
                sam = (3 * ap->samples_A [0] - ap->samples_A [1]) >> 1;
                temp = *bptr - apply_weight (ap->weight_A, sam);
                update_weight (ap->weight_A, 2, sam, temp);
                ap->samples_A [1] = ap->samples_A [0];
                ap->samples_A [0] = *bptr++;
                *swptr++ = (ap->weight_A < 256) ? 1024 : 1536 - ap->weight_A * 2;
            }
        else
            while (sc--) {
                sam = (3 * ap->samples_A [0] - ap->samples_A [1]) >> 1;
                temp = *bptr - apply_weight (ap->weight_A, sam);
                update_weight (ap->weight_A, 2, sam, temp);
                ap->samples_A [1] = ap->samples_A [0];
                ap->samples_A [0] = *bptr++;

                sam = (3 * ap->samples_B [0] - ap->samples_B [1]) >> 1;
                temp = *bptr - apply_weight (ap->weight_B, sam);
                update_weight (ap->weight_B, 2, sam, temp);
                ap->samples_B [1] = ap->samples_B [0];
                ap->samples_B [0] = *bptr++;

                *swptr++ = (ap->weight_A + ap->weight_B < 512) ? 1024 : 1536 - ap->weight_A - ap->weight_B;
            }

        wps->dc.shaping_samples = sample_count;
    }

    if (wpc->wvc_flag) {
        int max_allowed_error = 1000000 / wpc->ave_block_samples;
        short max_error, trial_max_error;
        double initial_y, final_y;

        if (max_allowed_error < 128)
            max_allowed_error = 128;

        best_floating_line (wps->dc.shaping_data, sample_count, &initial_y, &final_y, &max_error);

        if (shortening_allowed && max_error > max_allowed_error) {
            int min_samples = 0, max_samples = sample_count, trial_count;
            double trial_initial_y, trial_final_y;

            while (1) {
                trial_count = (min_samples + max_samples) / 2;

                best_floating_line (wps->dc.shaping_data, trial_count, &trial_initial_y,
                    &trial_final_y, &trial_max_error);

                if (trial_max_error < max_allowed_error) {
                    max_error = trial_max_error;
                    min_samples = trial_count;
                    initial_y = trial_initial_y;
                    final_y = trial_final_y;
                }
                else
                    max_samples = trial_count;

                if (min_samples > 10000 || max_samples - min_samples < 2)
                    break;
            }

            sample_count = min_samples;
        }

        if (initial_y < -512) initial_y = -512;
        else if (initial_y > 1024) initial_y = 1024;

        if (final_y < -512) final_y = -512;
        else if (final_y > 1024) final_y = 1024;
#if 0
        error_line ("%.2f sec, sample count = %5d, max error = %3d, range = %5d, %5d, actual = %5d, %5d",
            (double) wps->sample_index / wpc->config.sample_rate, sample_count, max_error,
            (int) floor (initial_y), (int) floor (final_y),
            wps->dc.shaping_data [0], wps->dc.shaping_data [sample_count-1]);
#endif
        if (sample_count != wps->wphdr.block_samples)
            wps->wphdr.block_samples = sample_count;

        if (wpc->wvc_flag) {
            wps->dc.shaping_acc [0] = wps->dc.shaping_acc [1] = (int32_t) floor (initial_y * 65536.0 + 0.5);

            wps->dc.shaping_delta [0] = wps->dc.shaping_delta [1] =
                (int32_t) floor ((final_y - initial_y) / (sample_count - 1) * 65536.0 + 0.5);

            wps->dc.shaping_array = NULL;
        }
        else
            wps->dc.shaping_array = wps->dc.shaping_data;
    }
    else
        wps->dc.shaping_array = wps->dc.shaping_data;
}

// Given an array of integer data (in shorts), find the linear function that most closely
// represents it (based on minimum sum of absolute errors). This is returned as the double
// precision initial & final Y values of the best-fit line. The function can also optionally
// compute and return a maximum error value (as a short). Note that the ends of the resulting
// line may fall way outside the range of input values, so some sort of clipping may be
// needed.

static void best_floating_line (short *values, int num_values, double *initial_y, double *final_y, short *max_error)
{
    double left_sum = 0.0, right_sum = 0.0, center_x = (num_values - 1) / 2.0, center_y, m;
    int i;

    for (i = 0; i < num_values >> 1; ++i) {
        right_sum += values [num_values - i - 1];
        left_sum += values [i];
    }

    if (num_values & 1) {
        right_sum += values [num_values >> 1] * 0.5;
        left_sum += values [num_values >> 1] * 0.5;
    }

    center_y = (right_sum + left_sum) / num_values;
    m = (right_sum - left_sum) / ((double) num_values * num_values) * 4.0;

    if (initial_y)
        *initial_y = center_y - m * center_x;

    if (final_y)
        *final_y = center_y + m * center_x;

    if (max_error) {
        double max = 0.0;

        for (i = 0; i < num_values; ++i)
            if (fabs (values [i] - (center_y + (i - center_x) * m)) > max)
                max = fabs (values [i] - (center_y + (i - center_x) * m));

        *max_error = (short) floor (max + 0.5);
    }
}
