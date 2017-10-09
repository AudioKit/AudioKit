//
//  Filter.h
//
//  Created by Mike Gazzaruso on 05/02/14.
//
//

#ifndef __SilenceDetectionEffect__Filter__
#define __SilenceDetectionEffect__Filter__


class MikeFilter
{
public:
    MikeFilter();
    void calc_filter_coeffs(double const frequency,double const sample_rate);
    
    float filter(float in0);

private:
    
	// filter coeffs
	float b0a0,b1a0,b2a0,a1a0,a2a0;
    
	// in/out history
	float ou1,ou2,in1,in2;
};

#endif
