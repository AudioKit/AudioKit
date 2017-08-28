/*****************************************************************************

        FFTRealFixLen.hpp
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if defined (ffft_FFTRealFixLen_CURRENT_CODEHEADER)
	#error Recursive inclusion of FFTRealFixLen code header.
#endif
#define	ffft_FFTRealFixLen_CURRENT_CODEHEADER

#if ! defined (ffft_FFTRealFixLen_CODEHEADER_INCLUDED)
#define	ffft_FFTRealFixLen_CODEHEADER_INCLUDED



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	"ffft/def.h"
#include	"ffft/FFTRealPassDirect.h"
#include	"ffft/FFTRealPassInverse.h"
#include	"ffft/FFTRealSelect.h"

#include	<cassert>
#include	<cmath>

namespace std { }



namespace ffft
{



/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



template <int LL2>
FFTRealFixLen <LL2>::FFTRealFixLen ()
:	_buffer (FFT_LEN)
,	_br_data (BR_ARR_SIZE)
,	_trigo_data (TRIGO_TABLE_ARR_SIZE)
,	_trigo_osc ()
{
	build_br_lut ();
	build_trigo_lut ();
	build_trigo_osc ();
}



template <int LL2>
long	FFTRealFixLen <LL2>::get_length () const
{
	return (FFT_LEN);
}



// General case
template <int LL2>
void	FFTRealFixLen <LL2>::do_fft (DataType f [], const DataType x [])
{
	assert (f != 0);
	assert (x != 0);
	assert (x != f);
	assert (FFT_LEN_L2 >= 3);

	// Do the transform in several passes
	const DataType	*	cos_ptr = &_trigo_data [0];
	const long *	br_ptr = &_br_data [0];

	FFTRealPassDirect <FFT_LEN_L2 - 1>::process (
		FFT_LEN,
		f,
		&_buffer [0],
		x,
		cos_ptr,
		TRIGO_TABLE_ARR_SIZE,
		br_ptr,
		&_trigo_osc [0]
	);
}

// 4-point FFT
template <>
inline void	FFTRealFixLen <2>::do_fft (DataType f [], const DataType x [])
{
	assert (f != 0);
	assert (x != 0);
	assert (x != f);

	f [1] = x [0] - x [2];
	f [3] = x [1] - x [3];

	const DataType	b_0 = x [0] + x [2];
	const DataType	b_2 = x [1] + x [3];
	
	f [0] = b_0 + b_2;
	f [2] = b_0 - b_2;
}

// 2-point FFT
template <>
inline void	FFTRealFixLen <1>::do_fft (DataType f [], const DataType x [])
{
	assert (f != 0);
	assert (x != 0);
	assert (x != f);

	f [0] = x [0] + x [1];
	f [1] = x [0] - x [1];
}

// 1-point FFT
template <>
inline void	FFTRealFixLen <0>::do_fft (DataType f [], const DataType x [])
{
	assert (f != 0);
	assert (x != 0);

	f [0] = x [0];
}



// General case
template <int LL2>
void	FFTRealFixLen <LL2>::do_ifft (const DataType f [], DataType x [])
{
	assert (f != 0);
	assert (x != 0);
	assert (x != f);
	assert (FFT_LEN_L2 >= 3);

	// Do the transform in several passes
	DataType *		s_ptr =
		FFTRealSelect <FFT_LEN_L2 & 1>::sel_bin (&_buffer [0], x);
	DataType *		d_ptr =
		FFTRealSelect <FFT_LEN_L2 & 1>::sel_bin (x, &_buffer [0]);
	const DataType	*	cos_ptr = &_trigo_data [0];
	const long *	br_ptr = &_br_data [0];

	FFTRealPassInverse <FFT_LEN_L2 - 1>::process (
		FFT_LEN,
		d_ptr,
		s_ptr,
		f,
		cos_ptr,
		TRIGO_TABLE_ARR_SIZE,
		br_ptr,
		&_trigo_osc [0]
	);
}

// 4-point IFFT
template <>
inline void	FFTRealFixLen <2>::do_ifft (const DataType f [], DataType x [])
{
	assert (f != 0);
	assert (x != 0);
	assert (x != f);

	const DataType	b_0 = f [0] + f [2];
	const DataType	b_2 = f [0] - f [2];

	x [0] = b_0 + f [1] * 2;
	x [2] = b_0 - f [1] * 2;
	x [1] = b_2 + f [3] * 2;
	x [3] = b_2 - f [3] * 2;
}

// 2-point IFFT
template <>
inline void	FFTRealFixLen <1>::do_ifft (const DataType f [], DataType x [])
{
	assert (f != 0);
	assert (x != 0);
	assert (x != f);

	x [0] = f [0] + f [1];
	x [1] = f [0] - f [1];
}

// 1-point IFFT
template <>
inline void	FFTRealFixLen <0>::do_ifft (const DataType f [], DataType x [])
{
	assert (f != 0);
	assert (x != 0);
	assert (x != f);

	x [0] = f [0];
}




template <int LL2>
void	FFTRealFixLen <LL2>::rescale (DataType x []) const
{
	assert (x != 0);

	const DataType	mul = DataType (1.0 / FFT_LEN);

	if (FFT_LEN < 4)
	{
		long				i = FFT_LEN - 1;
		do
		{
			x [i] *= mul;
			--i;
		}
		while (i >= 0);
	}

	else
	{
		assert ((FFT_LEN & 3) == 0);

		// Could be optimized with SIMD instruction sets (needs alignment check)
		long				i = FFT_LEN - 4;
		do
		{
			x [i + 0] *= mul;
			x [i + 1] *= mul;
			x [i + 2] *= mul;
			x [i + 3] *= mul;
			i -= 4;
		}
		while (i >= 0);
	}
}



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



template <int LL2>
void	FFTRealFixLen <LL2>::build_br_lut ()
{
	_br_data [0] = 0;
	for (long cnt = 1; cnt < BR_ARR_SIZE; ++cnt)
	{
		long				index = cnt << 2;
		long				br_index = 0;

		int				bit_cnt = FFT_LEN_L2;
		do
		{
			br_index <<= 1;
			br_index += (index & 1);
			index >>= 1;

			-- bit_cnt;
		}
		while (bit_cnt > 0);

		_br_data [cnt] = br_index;
	}
}



template <int LL2>
void	FFTRealFixLen <LL2>::build_trigo_lut ()
{
	const double	mul = (0.5 * PI) / TRIGO_TABLE_ARR_SIZE;
	for (long i = 0; i < TRIGO_TABLE_ARR_SIZE; ++ i)
	{
		using namespace std;

		_trigo_data [i] = DataType (cos (i * mul));
	}
}



template <int LL2>
void	FFTRealFixLen <LL2>::build_trigo_osc ()
{
	for (int i = 0; i < NBR_TRIGO_OSC; ++i)
	{
		OscType &		osc = _trigo_osc [i];

		const long		len = static_cast <long> (TRIGO_TABLE_ARR_SIZE) << (i + 1);
		const double	mul = (0.5 * PI) / len;
		osc.set_step (mul);
	}
}



}	// namespace ffft



#endif	// ffft_FFTRealFixLen_CODEHEADER_INCLUDED

#undef ffft_FFTRealFixLen_CURRENT_CODEHEADER



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
