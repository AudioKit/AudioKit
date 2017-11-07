/***************************************************/
/*! \class LentPitShift
    \brief Pitch shifter effect class based on the Lent algorithm.

    This class implements a pitch shifter using pitch 
    tracking and sample windowing and shifting.

    by Francois Germain, 2009.
*/
/***************************************************/

#include "LentPitShift.h"

namespace stk {

LentPitShift::LentPitShift( StkFloat periodRatio, int tMax )
  : inputFrames(0.,tMax,1), outputFrames(0.,tMax,1), ptrFrames(0), inputPtr(0), outputPtr(0.), tMax_(tMax), periodRatio_(periodRatio), zeroFrame(0., tMax, 1)
{
	window = new StkFloat[2*tMax_]; // Allocation of the array for the hamming window
	threshold_ = 0.1;               // Default threshold for pitch tracking

	dt = new StkFloat[tMax+1]; // Allocation of the euclidian distance coefficient array.  The first one is never used.
	cumDt = new StkFloat[tMax+1];  // Allocation of the cumulative sum array
	cumDt[0] = 0.;                 // Initialization of the first coefficient of the cumulative sum
	dpt = new StkFloat[tMax+1];    // Allocation of the pitch tracking function coefficient array
	dpt[0]   = 1.;                 // Initialization of the first coefficient of dpt which is always the same

	// Initialisation of the input and output delay lines
	inputLine_.setMaximumDelay( 3 * tMax_ );
	// The delay is choosed such as the coefficients are not read before being finalised.
	outputLine_.setMaximumDelay( 3 * tMax_ );
	outputLine_.setDelay( 3 * tMax_ );

	//Initialization of the delay line of pitch tracking coefficients
	//coeffLine_ = new Delay[512];
	//for(int i=0;i<tMax_;i++)
	//	coeffLine_[i] = new Delay( tMax_, tMax_ );
}

void LentPitShift :: clear()
{
	inputLine_.clear();
	outputLine_.clear();
}

void LentPitShift :: setShift( StkFloat shift )
{
  if ( shift <= 0.0 ) periodRatio_ = 1.0;
  periodRatio_ = 1.0 / shift; 
}

} // stk namespace
