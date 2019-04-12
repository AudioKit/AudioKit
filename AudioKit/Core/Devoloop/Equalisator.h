//
//  Equalisator.h
//  Rhino
//
//  Created by Mike Gazzaruso, revision history on Githbub.
//
//

#pragma once

class Equalisator {
public:
    Equalisator();
    void calc_filter_coeffs(int const type, double const frequency,
                            double const sample_rate, double const q,
                            double const db_gain, bool q_is_bandwidth);
    float filter(float in0);

private:
    // filter coeffs
    float b0a0, b1a0, b2a0, a1a0, a2a0;

    // in/out history
    float ou1, ou2, in1, in2;
};

