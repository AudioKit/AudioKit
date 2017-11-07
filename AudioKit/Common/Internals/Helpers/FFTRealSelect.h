/*****************************************************************************

        FFTRealSelect.h
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if ! defined (ffft_FFTRealSelect_HEADER_INCLUDED)
#define	ffft_FFTRealSelect_HEADER_INCLUDED

#if defined (_MSC_VER)
	#pragma once
#endif



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	"ffft/def.h"



namespace ffft
{



template <int P>
class FFTRealSelect
{

/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

public:

	ffft_FORCEINLINE static float *
						sel_bin (float *e_ptr, float *o_ptr);



/*\\\ FORBIDDEN MEMBER FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

private:

						FFTRealSelect ();
						~FFTRealSelect ();
						FFTRealSelect (const FFTRealSelect &other);
	FFTRealSelect&	operator = (const FFTRealSelect &other);
	bool				operator == (const FFTRealSelect &other);
	bool				operator != (const FFTRealSelect &other);

};	// class FFTRealSelect



}	// namespace ffft



#include	"ffft/FFTRealSelect.hpp"



#endif	// ffft_FFTRealSelect_HEADER_INCLUDED



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
