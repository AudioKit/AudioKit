/*****************************************************************************

        FFTRealUseTrigo.hpp
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if defined (ffft_FFTRealUseTrigo_CURRENT_CODEHEADER)
	#error Recursive inclusion of FFTRealUseTrigo code header.
#endif
#define	ffft_FFTRealUseTrigo_CURRENT_CODEHEADER

#if ! defined (ffft_FFTRealUseTrigo_CODEHEADER_INCLUDED)
#define	ffft_FFTRealUseTrigo_CODEHEADER_INCLUDED



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	"ffft/OscSinCos.h"



namespace ffft
{



/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



template <int ALGO>
void	FFTRealUseTrigo <ALGO>::prepare (OscType &osc)
{
	osc.clear_buffers ();
}

template <>
inline void	FFTRealUseTrigo <0>::prepare (OscType &osc)
{
	// Nothing
}



template <int ALGO>
void	FFTRealUseTrigo <ALGO>::iterate (OscType &osc, DataType &c, DataType &s, const DataType cos_ptr [], long index_c, long index_s)
{
	osc.step ();
	c = osc.get_cos ();
	s = osc.get_sin ();
}

template <>
inline void	FFTRealUseTrigo <0>::iterate (OscType &osc, DataType &c, DataType &s, const DataType cos_ptr [], long index_c, long index_s)
{
	c = cos_ptr [index_c];
	s = cos_ptr [index_s];
}



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



}	// namespace ffft



#endif	// ffft_FFTRealUseTrigo_CODEHEADER_INCLUDED

#undef ffft_FFTRealUseTrigo_CURRENT_CODEHEADER



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
