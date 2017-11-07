/*****************************************************************************

        FFTRealUseTrigo.h
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if ! defined (ffft_FFTRealUseTrigo_HEADER_INCLUDED)
#define	ffft_FFTRealUseTrigo_HEADER_INCLUDED

#if defined (_MSC_VER)
	#pragma once
	#pragma warning (4 : 4250) // "Inherits via dominance."
#endif



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	"ffft/def.h"
#include	"ffft/FFTRealFixLenParam.h"
#include	"ffft/OscSinCos.h"



namespace ffft
{



template <int ALGO>
class FFTRealUseTrigo
{

/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

public:

   typedef	FFTRealFixLenParam::DataType	DataType;
	typedef	OscSinCos <DataType>	OscType;

	ffft_FORCEINLINE static void
						prepare (OscType &osc);
	ffft_FORCEINLINE	static void
						iterate (OscType &osc, DataType &c, DataType &s, const DataType cos_ptr [], long index_c, long index_s);



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

protected:



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

private:



/*\\\ FORBIDDEN MEMBER FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

private:

						FFTRealUseTrigo ();
						~FFTRealUseTrigo ();
						FFTRealUseTrigo (const FFTRealUseTrigo &other);
	FFTRealUseTrigo &
						operator = (const FFTRealUseTrigo &other);
	bool				operator == (const FFTRealUseTrigo &other);
	bool				operator != (const FFTRealUseTrigo &other);

};	// class FFTRealUseTrigo



}	// namespace ffft



#include	"ffft/FFTRealUseTrigo.hpp"



#endif	// ffft_FFTRealUseTrigo_HEADER_INCLUDED



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
