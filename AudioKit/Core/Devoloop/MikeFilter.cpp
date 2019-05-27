//
//  MikeFilter.cpp
//
//  Created by Mike Gazzaruso, revision history on Githbub.
//
//

#include "MikeFilter.h"
#include <cmath>

MikeFilter::MikeFilter() {
    // reset filter coeffs
    b0a0 = b1a0 = b2a0 = a1a0 = a2a0 = 0.0f;

    // reset in/out history
    ou1 = ou2 = in1 = in2 = 0.0f;
}

float MikeFilter::filter(float in0) {
    // filter
    float const yn =
    b0a0 * in0 + b1a0 * in1 + b2a0 * in2 - a1a0 * ou1 - a2a0 * ou2;

    // push in/out buffers
    in2 = in1;
    in1 = in0;
    ou2 = ou1;
    ou1 = yn;

    // return output
    return yn;
}

void MikeFilter::calc_filter_coeffs(double const frequency,
                                    double const sample_rate) {
    // temp pi
    double const temp_pi = 3.1415926535897932384626433832795;

    // temp coef vars
    double alpha, a0, a1, a2, b0, b1, b2;

    double const omega = 2.0 * temp_pi * frequency / sample_rate;
    double const tsin = sin(omega);
    double const tcos = cos(omega);

    alpha = tsin / (2.0 * 0.5);

    b0 = (1.0 - tcos) / 2.0;
    b1 = 1.0 - tcos;
    b2 = (1.0 - tcos) / 2.0;
    a0 = 1.0 + alpha;
    a1 = -2.0 * tcos;
    a2 = 1.0 - alpha;

    // set filter coeffs
    b0a0 = float(b0 / a0);
    b1a0 = float(b1 / a0);
    b2a0 = float(b2 / a0);
    a1a0 = float(a1 / a0);
    a2a0 = float(a2 / a0);
}
