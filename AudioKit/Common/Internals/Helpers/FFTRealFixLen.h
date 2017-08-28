/*****************************************************************************

        FFTRealFixLen.h
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if ! defined (ffft_FFTRealFixLen_HEADER_INCLUDED)
#define	ffft_FFTRealFixLen_HEADER_INCLUDED

#if defined (_MSC_VER)
	#pragma once
	#pragma warning (4 : 4250) // "Inherits via dominance."
#endif



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	"ffft/Array.h"
#include	"ffft/DynArray.h"
#include	"ffft/FFTRealFixLenParam.h"
#include	"ffft/OscSinCos.h"



namespace ffft
{



template <int LL2>
class FFTRealFixLen
{
	typedef	int	CompileTimeCheck1 [(LL2 >=  0) ? 1 : -1];
	typedef	int	CompileTimeCheck2 [(LL2 <= 30) ? 1 : -1];

/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

public:

   typedef	FFTRealFixLenParam::DataType   DataType;
	typedef	OscSinCos <DataType>	OscType;

	enum {			FFT_LEN_L2	= LL2	};
	enum {			FFT_LEN		= 1 << FFT_LEN_L2	};

						FFTRealFixLen ();

	inline long		get_length () const;
	void				do_fft (DataType f [], const DataType x []);
	void				do_ifft (const DataType f [], DataType x []);
	void				rescale (DataType x []) const;



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

protected:



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

private:

	enum {			TRIGO_BD_LIMIT	= FFTRealFixLenParam::TRIGO_BD_LIMIT	};

	enum {			BR_ARR_SIZE_L2	= ((FFT_LEN_L2 - 3) < 0) ? 0 : (FFT_LEN_L2 - 2)	};
	enum {			BR_ARR_SIZE		= 1 << BR_ARR_SIZE_L2	};

   enum {			TRIGO_BD			=   ((FFT_LEN_L2 - TRIGO_BD_LIMIT) < 0)
											  ? (int)FFT_LEN_L2
											  : (int)TRIGO_BD_LIMIT };
	enum {			TRIGO_TABLE_ARR_SIZE_L2	= (LL2 < 4) ? 0 : (TRIGO_BD - 2)	};
	enum {			TRIGO_TABLE_ARR_SIZE	= 1 << TRIGO_TABLE_ARR_SIZE_L2	};

	enum {			NBR_TRIGO_OSC			= FFT_LEN_L2 - TRIGO_BD	};
	enum {			TRIGO_OSC_ARR_SIZE	=	(NBR_TRIGO_OSC > 0) ? NBR_TRIGO_OSC : 1	};

	void				build_br_lut ();
	void				build_trigo_lut ();
	void				build_trigo_osc ();

	DynArray <DataType>
						_buffer;
	DynArray <long>
						_br_data;
	DynArray <DataType>
						_trigo_data;
   Array <OscType, TRIGO_OSC_ARR_SIZE>
						_trigo_osc;



/*\\\ FORBIDDEN MEMBER FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

private:

						FFTRealFixLen (const FFTRealFixLen &other);
	FFTRealFixLen&	operator = (const FFTRealFixLen &other);
	bool				operator == (const FFTRealFixLen &other);
	bool				operator != (const FFTRealFixLen &other);

};	// class FFTRealFixLen



}	// namespace ffft



#include	"ffft/FFTRealFixLen.hpp"



#endif	// ffft_FFTRealFixLen_HEADER_INCLUDED



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
