/*****************************************************************************

        FFTRealPassInverse.h
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if ! defined (ffft_FFTRealPassInverse_HEADER_INCLUDED)
#define	ffft_FFTRealPassInverse_HEADER_INCLUDED

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



template <int PASS>
class FFTRealPassInverse
{

/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

public:

   typedef	FFTRealFixLenParam::DataType	DataType;
	typedef	OscSinCos <DataType>	OscType;

	ffft_FORCEINLINE static void
						process (long len, DataType dest_ptr [], DataType src_ptr [], const DataType f_ptr [], const DataType cos_ptr [], long cos_len, const long br_ptr [], OscType osc_list []);
	ffft_FORCEINLINE static void
						process_rec (long len, DataType dest_ptr [], DataType src_ptr [], const DataType cos_ptr [], long cos_len, const long br_ptr [], OscType osc_list []);
	ffft_FORCEINLINE static void
						process_internal (long len, DataType dest_ptr [], const DataType src_ptr [], const DataType cos_ptr [], long cos_len, const long br_ptr [], OscType osc_list []);



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

protected:



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

private:



/*\\\ FORBIDDEN MEMBER FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

private:

						FFTRealPassInverse ();
						FFTRealPassInverse (const FFTRealPassInverse &other);
	FFTRealPassInverse &
						operator = (const FFTRealPassInverse &other);
	bool				operator == (const FFTRealPassInverse &other);
	bool				operator != (const FFTRealPassInverse &other);

};	// class FFTRealPassInverse



}	// namespace ffft



#include	"ffft/FFTRealPassInverse.hpp"



#endif	// ffft_FFTRealPassInverse_HEADER_INCLUDED



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
