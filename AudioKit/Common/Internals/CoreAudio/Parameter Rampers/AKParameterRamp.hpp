//
//  AKParameterRamper.hpp
//  AudioKit
//
//  Created by Ryan Francesconi on 4/27/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//
//  Fade code inspired by SoX's fade.c:
//  https://github.com/chirlu/sox/blob/master/src/fade.c
//
//  Ari Moisio <armoi@sci.fi> Aug 29 2000, based on skeleton effect
//  Written by Chris Bagwell (cbagwell@sprynet.com) - March 16, 1999
//  Copyright 1999 Chris Bagwell And Sundry Contributors
//  This source code is freely redistributable and may be used for
//  any purpose.  This copyright notice must be maintained.
//  Chris Bagwell And Sundry Contributors are not responsible for
//  the consequences of using this software.

#pragma once

#import "AKParameterRampBase.hpp" // have to put this here to get it included in umbrella header

#ifdef __cplusplus

// Variable Ramp Type Ramper
struct AKParameterRamp : AKParameterRampBase {
    // See AKSettings.RampType. Same values.
    enum RampType {
        linearRamp = 0,
        exponentialRamp = 1,
        logarithmicRamp = 2,
        sCurveRamp = 3
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
        logarithmicCurve,
        // Inverted parabola
        parabolicCurve
    };

    float computeValueAt(int64_t atSample) override {
        // These ramp types are essentially curve pair presets
        switch (getRampType()) {
            case logarithmicRamp:
                return _value = computeFade(atSample, quarterCurve, logarithmicCurve);
                break;
            case exponentialRamp:
                return _value = computeFade(atSample, logarithmicCurve, quarterCurve);

                // return _value = computeExponential(atSample);
                break;
            case sCurveRamp:
                return _value = computeFade(atSample, halfCurve, halfCurve);
                break;
            // or 0
            default:
                return _value = computeFade(atSample, linearCurve, linearCurve);
//                float fract = (float)(atSample - _startSample) / getDurationInSamples();
//                return _value = getStartValue() + (getTarget() - getStartValue()) * fract;

                break;
        }
    }

    double computeFade(int64_t atSample, int inType, int outType) {
        int64_t index = atSample - _startSample;
        bool fadeIn = getTarget() > getStartValue();
        double result = 1.0, gain = 1.0;

        // FADE IN
        if (fadeIn) {
            gain = calculateGain(index, getDurationInSamples(), inType);
            double difference = getTarget() - getStartValue();
            result = getStartValue() + (difference * gain);

//            double difference = getTarget() - getStartValue();
//            result = (difference * gain);

        // FADE OUT
        } else {
            gain = calculateGain(index, getDurationInSamples(), outType);
            gain = 1.0 - gain;
            result = (getStartValue() * gain) + getTarget();

//            double difference = getTarget() - getStartValue();
//            result = getStartValue() + (difference * gain);
        }

//        double difference = getTarget() - getStartValue();
//        result = getStartValue() + (difference * gain);

        printf( "fade in: %d, fade out: %d, startValue: %6.4lf, target: %6.4lf, duration: %6.4lf, index: %lld, gain: %6.4lf, RESULT: %6.4lf\n",
               inType, outType, getStartValue(), getTarget(), getDurationInSamples(), index, gain, result);
        return result;
    }

    // Function returns gain value 0.0 - 1.0 according index / range ratio
    // and -1.0 if  type is invalid
    // See enum above for explanation of each
    double calculateGain(uint64_t index, uint64_t range, int type) {
        double result = 0.0, findex = 0.0;

        // does it really have to be constrained to [0.0, 1.0]?
        findex = fmax(0.0, fmin(1.0, 1.0 * index / range));
        //findex = (double)index / range;

        switch (type) {
            case linearCurve :
                result = findex;
                break;

            case quarterCurve :
                result = sin(findex * M_PI / 2);
                break;

            case halfCurve :
                result = (1 - cos(findex * M_PI )) / 2 ;
                break;

            case logarithmicCurve :
                result = pow(0.1, (1 - findex) * 2);
                break;

            case parabolicCurve :
                result = (1 - (1 - findex) * (1 - findex));
                break;

            // ERROR, unknown type
            default :
                result = -1.0;
                break;
        }

        // sanity check
        // result = fmax(0.0, fmin(1.0, result));
        return result;
    }

    double computeExponential(int64_t atSample) {
        // position
        double minp = _startSample;
        double maxp = _startSample + getDurationInSamples();

        // values
        double minv = log(getStartValue());
        double maxv = log(getTarget());

        // calculate adjustment factor
        double scale = (maxv-minv) / (maxp-minp);
        double result = exp(minv + scale * (atSample-minp));

        //printf( "From: %6.4lf, To: %6.4lf, Start: %lld, Total: S%6.4lld, Current Sample: %lld, Value: %6.4lf\n", getStartValue(), getTarget(), _startSample, getDurationInSamples(), atSample, _value );
        return result;
    }

    float computeLinear(int64_t atSample) {
        float fract = (float)(atSample - _startSample) / getDurationInSamples();
        return _value = getStartValue() + (getTarget() - getStartValue()) * fract;
    }


    //
//    float computeLinear(int64_t atSample) {
//        _value = computeFade(atSample, linearCurve, linearCurve);
//        return _value;
//    }
//
//    // FADE_QUARTER out is nice exp curve
//    // FADE_LOG IN is nice exp curve
//    float computeExponential(int64_t atSample) {
//        _value = computeFade(atSample, parabolicCurve, logarithmicCurve);
//        return _value;
//    }
//
//    float computeLogarithmic(int64_t atSample) {
//        //return computeFade(atSample, FADE_QUARTER, FADE_PAR);
//        _value = computeFade(atSample, logarithmicCurve, parabolicCurve);
//        return _value;
//    }
//
//    float computeSCurve(int64_t atSample) {
//        _value = computeFade(atSample, halfCurve, halfCurve);
//        return _value;
//    }



    float computeLogarithmic2(int64_t atSample) {
        double sampleNumber = atSample - _startSample;
        double percent = sampleNumber / getDurationInSamples();
        double target = getStartValue() + (getTarget() - getStartValue());

        double multiplier = log(1 + percent * (M_E - 1));
        double result = target * multiplier;

        // printf( "target: %6.4lf, multiplier: %6.4lf, sample_number: %6.4lf, _value: %6.4lf\n", target, multiplier, sampleNumber, _value);
        return result;
    }

};

#endif


/*

y=\left(\log_bx\ \cdot\ 2\right)

 case LOG_IN:
 return log(1 + (((float) sample_number / fade_length) * (M_E - 1)));

 case LOG_OUT:
 return 1.0 - (log(1 + (((float) sample_number / fade_length) * (M_E - 1))));

 case LINEAR_OUT:
 return 1.0 - ((float) sample_number / fade_length);
 case HALF_SINE_OUT:
 return 1.0 - (sin(M_PI / 2 * sample_number / fade_length));


 // Compute the per-sample multiplier.
 float multiplier = powf(value2 / value1, 1 / numSampleFrames);

 // Set the starting value of the exponential ramp. This is the same as multiplier ^
 // AudioUtilities::timeToSampleFrame(currentTime - time1, sampleRate), but is more
 // accurate, especially if multiplier is close to 1.
 value = value1 * powf(value2 / value1,
 AudioUtilities::timeToSampleFrame(currentTime - time1, sampleRate) / numSampleFrames);
 */
