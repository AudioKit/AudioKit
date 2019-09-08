//
//  AKParameterRamper.hpp
//  AudioKit
//
//  Created by Ryan Francesconi on 4/27/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//
//  Fade code inspired by SoX's fade.c:
//  https://github.com/chirlu/sox/blob/master/src/fade.c

#pragma once

#import "AKParameterRampBase.hpp" // have to put this here to get it included in umbrella header

#ifdef __cplusplus

// Variable Ramp Type Ramper
struct AKParameterRamp : AKParameterRampBase {
    // See AKSettings.RampType. Same values.
    enum RampType {
        linearRamp      = 0,
        exponentialRamp = 1,
        logarithmicRamp = 2,
        sCurveRamp      = 3
    };

    enum FadeCurve {
        // Linear Slope
        linearCurve,
        // Quarter of sine wave, 0 to pi/2
        quarterCurve,
        // Half of sine wave, pi/2 to 1.5 * pi, scaled so that -1 means no output
        // and 1 means 0 db attenuation.
        halfCurve,
        // Logarithmic curve.
        exponentialCurve,
        // Inverted parabola
        parabolicCurve,
        logOutCurve,
        halfSineCurve
    };

    float computeValueAt(int64_t atSample) override
    {
        int64_t index = atSample - _startSample;
        bool fadeIn = getTarget() > getStartValue();
        int curveType = linearCurve;

        switch (getRampType()) {
            case exponentialRamp:
                curveType = fadeIn ? exponentialCurve : quarterCurve;
                break;
            case logarithmicRamp:
                curveType = fadeIn ? quarterCurve : exponentialCurve;
                break;
            case sCurveRamp:
                curveType = halfCurve;
                break;
            default:
                break;
        }

        double gain = calculateGain(index, getDurationInSamples(), curveType);
        double difference = getTarget() - getStartValue();
        double result = getStartValue() + (difference * gain);

//        printf( "fade type: %d, startValue: %6.4lf, target: %6.4lf, duration: %6.4lf, index: %lld, gain: %6.4lf, RESULT: %6.4lf\n",
//               curveType, getStartValue(), getTarget(), getDurationInSamples(), index, gain, result);

        _value = result;
        return result;
    }

    // Function returns gain value 0.0 - 1.0 according index / range ratio
    // and -1.0 if type is invalid
    // See enum above for explanation of each, not currently using all of these but they might be useful later
    double calculateGain(uint64_t index, uint64_t range, int type)
    {
        double result = 0.0;

        // does it really have to be constrained to [0.0, 1.0]?
        //findex = fmax(0.0, fmin(1.0, 1.0 * index / range));
        double findex = (double)index / range;

        switch (type) {
            case linearCurve:
                result = findex;
                break;

            case quarterCurve:
                result = sin(findex * M_PI_2);
                break;

            case halfCurve:
                result = (1 - cos(findex * M_PI)) / 2;
                break;

            case exponentialCurve:
                result = pow(0.1, (1 - findex) * 2);
                break;

            case parabolicCurve:
                result = (1 - (1 - findex) * (1 - findex));
                break;

            case logOutCurve:
                result = log(1 + (findex * (M_E - 1)));
                break;

            case halfSineCurve:
                result = sin(M_PI_2 * findex);

            // ERROR, unknown type
            default:
                result = -1.0;
                break;
        }
        return result;
    }

    // currently unused
    double computeExponential(int64_t atSample)
    {
        // position
        double minp = _startSample;
        double maxp = _startSample + getDurationInSamples();

        // values
        double minv = log(getStartValue());
        double maxv = log(getTarget());

        // calculate adjustment factor
        double scale = (maxv - minv) / (maxp - minp);
        double result = exp(minv + scale * (atSample - minp));

        //printf( "From: %6.4lf, To: %6.4lf, Start: %lld, Total: S%6.4lld, Current Sample: %lld, Value: %6.4lf\n", getStartValue(), getTarget(), _startSample, getDurationInSamples(), atSample, _value );
        return result;
    }

    // currently unused
    float computeLinear(int64_t atSample)
    {
        float fract = (float)(atSample - _startSample) / getDurationInSamples();
        return _value = getStartValue() + (getTarget() - getStartValue()) * fract;
    }
};

#endif
