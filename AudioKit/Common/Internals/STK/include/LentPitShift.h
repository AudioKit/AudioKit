#ifndef STK_LENTPITSHIFT_H
#define STK_LENTPITSHIFT_H

#include "Effect.h"
#include "Delay.h"

namespace stk {

/***************************************************/
/*! \class LentPitShift
    \brief Pitch shifter effect class based on the Lent algorithm.

    This class implements a pitch shifter using pitch 
    tracking and sample windowing and shifting.

    by Francois Germain, 2009.
*/
/***************************************************/

class LentPitShift : public Effect
{
 public:
  //! Class constructor.
  LentPitShift( StkFloat periodRatio = 1.0, int tMax = RT_BUFFER_SIZE );

  ~LentPitShift( void ) {
    delete window;
    delete dt;
    delete dpt;
    delete cumDt;
  }

  //! Reset and clear all internal state.
  void clear( void );

  //! Set the pitch shift factor (1.0 produces no shift).
  void setShift( StkFloat shift );

  //! Input one sample to the filter and return one output.
  StkFloat tick( StkFloat input );

  //! Take a channel of the StkFrames object as inputs to the filter and replace with corresponding outputs.
  /*!
    The StkFrames argument reference is returned.  The \c channel
    argument must be less than the number of channels in the
    StkFrames argument (the first channel is specified by 0).
    However, range checking is only performed if _STK_DEBUG_ is
    defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  //! Take a channel of the \c iFrames object as inputs to the filter and write outputs to the \c oFrames object.
  /*!
    The \c iFrames object reference is returned.  Each channel
    argument must be less than the number of channels in the
    corresponding StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& iFrames, StkFrames &oFrames, unsigned int iChannel = 0, unsigned int oChannel = 0 );

 protected:

  //! Apply the effect on the input samples and store it.
  /*!
    The samples stored in the input frame vector are processed
    and the delayed result are stored in the output frame vector.
  */
  void process( );

  // Frame storage vectors for process function
  StkFrames inputFrames;
  StkFrames outputFrames;
  int ptrFrames;          // writing pointer

  // Input delay line
  Delay inputLine_;
  int inputPtr;

  // Output delay line
  Delay outputLine_;
  double outputPtr;

  // Pitch tracker variables
  unsigned long tMax_;    // Maximal period measurable by the pitch tracker.
  // It is also the size of the window used by the pitch tracker and
  // the size of the frames that can be computed by the tick function

  StkFloat threshold_; // Threshold of detection for the pitch tracker
  unsigned long lastPeriod_;    // Result of the last pitch tracking loop
  StkFloat* dt;        // Array containing the euclidian distance coefficients
  StkFloat* cumDt;     // Array containing the cumulative sum of the coefficients in dt
  StkFloat* dpt;       // Array containing the pitch tracking function coefficients

  // Pitch shifter variables
  StkFloat env[2];     // Coefficients for the linear interpolation when modifying the output samples
  StkFloat* window;    // Hamming window used for the input portion extraction
  double periodRatio_; // Ratio of modification of the signal period
  StkFrames zeroFrame; // Frame of tMax_ zero samples


  // Coefficient delay line that could be used for a dynamic calculation of the pitch
  //Delay* coeffLine_;

};

inline void LentPitShift::process()
{
  StkFloat x_t;    // input coefficient
  StkFloat x_t_T;  // previous input coefficient at T samples
  StkFloat coeff;  // new coefficient for the difference function

  unsigned long alternativePitch = tMax_;  // Global minimum storage
  lastPeriod_ = tMax_+1;         // Storage of the lowest local minimum under the threshold

  // Loop variables
  unsigned long delay_;
  unsigned int n;

  // Initialization of the dt coefficients.  Since the
  // frames are of tMax_ length, there is no overlapping
  // between the successive windows where pitch tracking
  // is performed.
  for ( delay_=1; delay_<=tMax_; delay_++ )
    dt[delay_] = 0.;

  // Calculation of the dt coefficients and update of the input delay line.
  for ( n=0; n<inputFrames.size(); n++ ) {
    x_t = inputLine_.tick( inputFrames[ n ] );
    for ( delay_=1; delay_<= tMax_; delay_++ ) {
      x_t_T = inputLine_.tapOut( delay_ );
      coeff = x_t - x_t_T;
      dt[delay_] += coeff * coeff;
    }
  }

  // Calculation of the pitch tracking function and test for the minima.
  for ( delay_=1; delay_<=tMax_; delay_++ ) {
    cumDt[delay_] = dt[delay_] + cumDt[delay_-1];
    dpt[delay_] = dt[delay_] * delay_ / cumDt[delay_];

    // Look for a minimum
    if ( dpt[delay_-1]-dpt[delay_-2] < 0 && dpt[delay_]-dpt[delay_-1] > 0 ) {
      // Check if the minimum is under the threshold
      if ( dpt[delay_-1] < threshold_ ){
        lastPeriod_ = delay_-1;
        // If a minimum is found, we can stop the loop
        break;
      }
      else if ( dpt[alternativePitch] > dpt[delay_-1] )
        // Otherwise we store it if it is the current global minimum
        alternativePitch = delay_-1;
    }
  }

  // Test for the last period length.
  if ( dpt[delay_]-dpt[delay_-1] < 0 ) {
    if ( dpt[delay_] < threshold_ )
      lastPeriod_ = delay_;
    else if ( dpt[alternativePitch] > dpt[delay_] )
      alternativePitch = delay_;
  }

  if ( lastPeriod_ == tMax_+1 )
    // No period has been under the threshold so we used the global minimum
    lastPeriod_ = alternativePitch;

  // We put the new zero output coefficients in the output delay line and 
  // we get the previous calculated coefficients
  outputLine_.tick( zeroFrame, outputFrames );

  // Initialization of the Hamming window used in the algorithm
  for ( int n=-(int)lastPeriod_; n<(int)lastPeriod_; n++ )
    window[n+lastPeriod_] = (1 + cos(PI*n/lastPeriod_)) / 2	;

  long M;  // Index of reading in the input delay line
  long N;  // Index of writing in the output delay line
  double sample;  // Temporary storage for the new coefficient

  // We loop for all the frames of length lastPeriod_ presents between inputPtr and tMax_
  for ( ; inputPtr<(int)(tMax_-lastPeriod_); inputPtr+=lastPeriod_ ) {
    // Test for the decision of compression/expansion
    while ( outputPtr < inputPtr ) {
      // Coefficients for the linear interpolation
      env[1] = fmod( outputPtr + tMax_, 1.0 );
      env[0] = 1.0 - env[1];
      M = tMax_ - inputPtr + lastPeriod_ - 1; // New reading pointer
      N = 2*tMax_ - (unsigned long)floor(outputPtr + tMax_) + lastPeriod_ - 1; // New writing pointer
      for ( unsigned int j=0; j<2*lastPeriod_; j++,M--,N-- ) {
        sample = inputLine_.tapOut(M) * window[j] / 2.;
        // Linear interpolation
        outputLine_.addTo(env[0] * sample, N);
        outputLine_.addTo(env[1] * sample, N-1);
      }
      outputPtr = outputPtr + lastPeriod_ * periodRatio_; // new output pointer
    }
  }
  // Shifting of the pointers waiting for the new frame of length tMax_.
  outputPtr -= tMax_;
  inputPtr  -= tMax_;
}


inline StkFloat LentPitShift :: tick( StkFloat input )
{
  StkFloat sample;

  inputFrames[ptrFrames] = input;

  sample = outputFrames[ptrFrames++];

  // Check for end condition
  if ( ptrFrames == (int) inputFrames.size() ){
    ptrFrames = 0;
    process( );
  }

  return sample;
}

inline StkFrames& LentPitShift :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "LentPitShift::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    *samples = tick( *samples );
  }

  return frames;
}

inline StkFrames& LentPitShift :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "LentPitShift::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    *oSamples = tick( *iSamples );
  }

  return iFrames;
}

} // stk namespace

#endif

