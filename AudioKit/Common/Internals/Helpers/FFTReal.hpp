/*****************************************************************************

        FFTReal.hpp
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if defined (ffft_FFTReal_CURRENT_CODEHEADER)
	#error Recursive inclusion of FFTReal code header.
#endif
#define	ffft_FFTReal_CURRENT_CODEHEADER

#if ! defined (ffft_FFTReal_CODEHEADER_INCLUDED)
#define	ffft_FFTReal_CODEHEADER_INCLUDED



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	<cassert>
#include	<cmath>



namespace ffft
{



static inline bool	FFTReal_is_pow2 (long x)
{
	assert (x > 0);

	return  ((x & -x) == x);
}



static inline int	FFTReal_get_next_pow2 (long x)
{
	--x;

	int				p = 0;
	while ((x & ~0xFFFFL) != 0)
	{
		p += 16;
		x >>= 16;
	}
	while ((x & ~0xFL) != 0)
	{
		p += 4;
		x >>= 4;
	}
	while (x > 0)
	{
		++p;
		x >>= 1;
	}

	return (p);
}



/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



/*
==============================================================================
Name: ctor
Input parameters:
	- length: length of the array on which we want to do a FFT. Range: power of
		2 only, > 0.
Throws: std::bad_alloc
==============================================================================
*/

template <class DT>
FFTReal <DT>::FFTReal (long length)
:	_length (length)
,	_nbr_bits (FFTReal_get_next_pow2 (length))
,	_br_lut ()
,	_trigo_lut ()
,	_buffer (length)
,	_trigo_osc ()
{
	assert (FFTReal_is_pow2 (length));
	assert (_nbr_bits <= MAX_BIT_DEPTH);

	init_br_lut ();
	init_trigo_lut ();
	init_trigo_osc ();
}



/*
==============================================================================
Name: get_length
Description:
	Returns the number of points processed by this FFT object.
Returns: The number of points, power of 2, > 0.
Throws: Nothing
==============================================================================
*/

template <class DT>
long	FFTReal <DT>::get_length () const
{
	return (_length);
}



/*
==============================================================================
Name: do_fft
Description:
	Compute the FFT of the array.
Input parameters:
	- x: pointer on the source array (time).
Output parameters:
	- f: pointer on the destination array (frequencies).
		f [0...length(x)/2] = real values,
		f [length(x)/2+1...length(x)-1] = negative imaginary values of
		coefficents 1...length(x)/2-1.
Throws: Nothing
==============================================================================
*/

template <class DT>
void	FFTReal <DT>::do_fft (DataType f [], const DataType x []) const
{
	assert (f != 0);
	assert (f != use_buffer ());
	assert (x != 0);
	assert (x != use_buffer ());
	assert (x != f);

	// General case
	if (_nbr_bits > 2)
	{
		compute_fft_general (f, x);
	}

	// 4-point FFT
	else if (_nbr_bits == 2)
	{
		f [1] = x [0] - x [2];
		f [3] = x [1] - x [3];

		const DataType	b_0 = x [0] + x [2];
		const DataType	b_2 = x [1] + x [3];
		
		f [0] = b_0 + b_2;
		f [2] = b_0 - b_2;
	}

	// 2-point FFT
	else if (_nbr_bits == 1)
	{
		f [0] = x [0] + x [1];
		f [1] = x [0] - x [1];
	}

	// 1-point FFT
	else
	{
		f [0] = x [0];
	}
}



/*
==============================================================================
Name: do_ifft
Description:
	Compute the inverse FFT of the array. Note that data must be post-scaled:
	IFFT (FFT (x)) = x * length (x).
Input parameters:
	- f: pointer on the source array (frequencies).
		f [0...length(x)/2] = real values
		f [length(x)/2+1...length(x)-1] = negative imaginary values of
		coefficents 1...length(x)/2-1.
Output parameters:
	- x: pointer on the destination array (time).
Throws: Nothing
==============================================================================
*/

template <class DT>
void	FFTReal <DT>::do_ifft (const DataType f [], DataType x []) const
{
	assert (f != 0);
	assert (f != use_buffer ());
	assert (x != 0);
	assert (x != use_buffer ());
	assert (x != f);

	// General case
	if (_nbr_bits > 2)
	{
		compute_ifft_general (f, x);
	}

	// 4-point IFFT
	else if (_nbr_bits == 2)
	{
		const DataType	b_0 = f [0] + f [2];
		const DataType	b_2 = f [0] - f [2];

		x [0] = b_0 + f [1] * 2;
		x [2] = b_0 - f [1] * 2;
		x [1] = b_2 + f [3] * 2;
		x [3] = b_2 - f [3] * 2;
	}

	// 2-point IFFT
	else if (_nbr_bits == 1)
	{
		x [0] = f [0] + f [1];
		x [1] = f [0] - f [1];
	}

	// 1-point IFFT
	else
	{
		x [0] = f [0];
	}
}



/*
==============================================================================
Name: rescale
Description:
	Scale an array by divide each element by its length. This function should
	be called after FFT + IFFT.
Input parameters:
	- x: pointer on array to rescale (time or frequency).
Throws: Nothing
==============================================================================
*/

template <class DT>
void	FFTReal <DT>::rescale (DataType x []) const
{
	const DataType	mul = DataType (1.0 / _length);

	if (_length < 4)
	{
		long				i = _length - 1;
		do
		{
			x [i] *= mul;
			--i;
		}
		while (i >= 0);
	}

	else
	{
		assert ((_length & 3) == 0);

		// Could be optimized with SIMD instruction sets (needs alignment check)
		long				i = _length - 4;
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



/*
==============================================================================
Name: use_buffer
Description:
	Access the internal buffer, whose length is the FFT one.
	Buffer content will be erased at each do_fft() / do_ifft() call!
	This buffer cannot be used as:
		- source for FFT or IFFT done with this object
		- destination for FFT or IFFT done with this object
Returns:
	Buffer start address
Throws: Nothing
==============================================================================
*/

template <class DT>
typename FFTReal <DT>::DataType *	FFTReal <DT>::use_buffer () const
{
	return (&_buffer [0]);
}



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



template <class DT>
void	FFTReal <DT>::init_br_lut ()
{
	const long		length = 1L << _nbr_bits;
	_br_lut.resize (length);

	_br_lut [0] = 0;
	long				br_index = 0;
	for (long cnt = 1; cnt < length; ++cnt)
	{
		// ++br_index (bit reversed)
		long				bit = length >> 1;
		while (((br_index ^= bit) & bit) == 0)
		{
			bit >>= 1;
		}

		_br_lut [cnt] = br_index;
	}
}



template <class DT>
void	FFTReal <DT>::init_trigo_lut ()
{
	using namespace std;

	if (_nbr_bits > 3)
	{
		const long		total_len = (1L << (_nbr_bits - 1)) - 4;
		_trigo_lut.resize (total_len);

		for (int level = 3; level < _nbr_bits; ++level)
		{
			const long		level_len = 1L << (level - 1);
			DataType	* const	level_ptr =
				&_trigo_lut [get_trigo_level_index (level)];
			const double	mul = PI / (level_len << 1);

			for (long i = 0; i < level_len; ++ i)
			{
				level_ptr [i] = static_cast <DataType> (cos (i * mul));
			}
		}
	}
}



template <class DT>
void	FFTReal <DT>::init_trigo_osc ()
{
	const int		nbr_osc = _nbr_bits - TRIGO_BD_LIMIT;
	if (nbr_osc > 0)
	{
		_trigo_osc.resize (nbr_osc);

		for (int osc_cnt = 0; osc_cnt < nbr_osc; ++osc_cnt)
		{
			OscType &		osc = _trigo_osc [osc_cnt];

			const long		len = 1L << (TRIGO_BD_LIMIT + osc_cnt);
			const double	mul = (0.5 * PI) / len;
			osc.set_step (mul);
		}
	}
}



template <class DT>
const long *	FFTReal <DT>::get_br_ptr () const
{
	return (&_br_lut [0]);
}



template <class DT>
const typename FFTReal <DT>::DataType *	FFTReal <DT>::get_trigo_ptr (int level) const
{
	assert (level >= 3);

	return (&_trigo_lut [get_trigo_level_index (level)]);
}



template <class DT>
long	FFTReal <DT>::get_trigo_level_index (int level) const
{
	assert (level >= 3);

	return ((1L << (level - 1)) - 4);
}



// Transform in several passes
template <class DT>
void	FFTReal <DT>::compute_fft_general (DataType f [], const DataType x []) const
{
	assert (f != 0);
	assert (f != use_buffer ());
	assert (x != 0);
	assert (x != use_buffer ());
	assert (x != f);

	DataType *		sf;
	DataType *		df;

	if ((_nbr_bits & 1) != 0)
	{
		df = use_buffer ();
		sf = f;
	}
	else
	{
		df = f;
		sf = use_buffer ();
	}

	compute_direct_pass_1_2 (df, x);
	compute_direct_pass_3 (sf, df);

	for (int pass = 3; pass < _nbr_bits; ++ pass)
	{
		compute_direct_pass_n (df, sf, pass);

		DataType * const	temp_ptr = df;
		df = sf;
		sf = temp_ptr;
	}
}



template <class DT>
void	FFTReal <DT>::compute_direct_pass_1_2 (DataType df [], const DataType x []) const
{
	assert (df != 0);
	assert (x != 0);
	assert (df != x);

	const long * const	bit_rev_lut_ptr = get_br_ptr ();
	long				coef_index = 0;
	do
	{
		const long		rev_index_0 = bit_rev_lut_ptr [coef_index];
		const long		rev_index_1 = bit_rev_lut_ptr [coef_index + 1];
		const long		rev_index_2 = bit_rev_lut_ptr [coef_index + 2];
		const long		rev_index_3 = bit_rev_lut_ptr [coef_index + 3];

		DataType	* const	df2 = df + coef_index;
		df2 [1] = x [rev_index_0] - x [rev_index_1];
		df2 [3] = x [rev_index_2] - x [rev_index_3];

		const DataType	sf_0 = x [rev_index_0] + x [rev_index_1];
		const DataType	sf_2 = x [rev_index_2] + x [rev_index_3];

		df2 [0] = sf_0 + sf_2;
		df2 [2] = sf_0 - sf_2;
		
		coef_index += 4;
	}
	while (coef_index < _length);
}



template <class DT>
void	FFTReal <DT>::compute_direct_pass_3 (DataType df [], const DataType sf []) const
{
	assert (df != 0);
	assert (sf != 0);
	assert (df != sf);

	const DataType	sqrt2_2 = DataType (SQRT2 * 0.5);
	long				coef_index = 0;
	do
	{
		DataType			v;

		df [coef_index] = sf [coef_index] + sf [coef_index + 4];
		df [coef_index + 4] = sf [coef_index] - sf [coef_index + 4];
		df [coef_index + 2] = sf [coef_index + 2];
		df [coef_index + 6] = sf [coef_index + 6];

		v = (sf [coef_index + 5] - sf [coef_index + 7]) * sqrt2_2;
		df [coef_index + 1] = sf [coef_index + 1] + v;
		df [coef_index + 3] = sf [coef_index + 1] - v;

		v = (sf [coef_index + 5] + sf [coef_index + 7]) * sqrt2_2;
		df [coef_index + 5] = v + sf [coef_index + 3];
		df [coef_index + 7] = v - sf [coef_index + 3];

		coef_index += 8;
	}
	while (coef_index < _length);
}



template <class DT>
void	FFTReal <DT>::compute_direct_pass_n (DataType df [], const DataType sf [], int pass) const
{
	assert (df != 0);
	assert (sf != 0);
	assert (df != sf);
	assert (pass >= 3);
	assert (pass < _nbr_bits);

	if (pass <= TRIGO_BD_LIMIT)
	{
		compute_direct_pass_n_lut (df, sf, pass);
	}
	else
	{
		compute_direct_pass_n_osc (df, sf, pass);
	}
}



template <class DT>
void	FFTReal <DT>::compute_direct_pass_n_lut (DataType df [], const DataType sf [], int pass) const
{
	assert (df != 0);
	assert (sf != 0);
	assert (df != sf);
	assert (pass >= 3);
	assert (pass < _nbr_bits);

	const long		nbr_coef = 1 << pass;
	const long		h_nbr_coef = nbr_coef >> 1;
	const long		d_nbr_coef = nbr_coef << 1;
	long				coef_index = 0;
	const DataType	* const	cos_ptr = get_trigo_ptr (pass);
	do
	{
		const DataType	* const	sf1r = sf + coef_index;
		const DataType	* const	sf2r = sf1r + nbr_coef;
		DataType			* const	dfr = df + coef_index;
		DataType			* const	dfi = dfr + nbr_coef;

		// Extreme coefficients are always real
		dfr [0] = sf1r [0] + sf2r [0];
		dfi [0] = sf1r [0] - sf2r [0];	// dfr [nbr_coef] =
		dfr [h_nbr_coef] = sf1r [h_nbr_coef];
		dfi [h_nbr_coef] = sf2r [h_nbr_coef];

		// Others are conjugate complex numbers
		const DataType * const	sf1i = sf1r + h_nbr_coef;
		const DataType * const	sf2i = sf1i + nbr_coef;
		for (long i = 1; i < h_nbr_coef; ++ i)
		{
			const DataType	c = cos_ptr [i];					// cos (i*PI/nbr_coef);
			const DataType	s = cos_ptr [h_nbr_coef - i];	// sin (i*PI/nbr_coef);
			DataType	 		v;

			v = sf2r [i] * c - sf2i [i] * s;
			dfr [i] = sf1r [i] + v;
			dfi [-i] = sf1r [i] - v;	// dfr [nbr_coef - i] =

			v = sf2r [i] * s + sf2i [i] * c;
			dfi [i] = v + sf1i [i];
			dfi [nbr_coef - i] = v - sf1i [i];
		}

		coef_index += d_nbr_coef;
	}
	while (coef_index < _length);
}



template <class DT>
void	FFTReal <DT>::compute_direct_pass_n_osc (DataType df [], const DataType sf [], int pass) const
{
	assert (df != 0);
	assert (sf != 0);
	assert (df != sf);
	assert (pass > TRIGO_BD_LIMIT);
	assert (pass < _nbr_bits);

	const long		nbr_coef = 1 << pass;
	const long		h_nbr_coef = nbr_coef >> 1;
	const long		d_nbr_coef = nbr_coef << 1;
	long				coef_index = 0;
	OscType &		osc = _trigo_osc [pass - (TRIGO_BD_LIMIT + 1)];
	do
	{
		const DataType	* const	sf1r = sf + coef_index;
		const DataType	* const	sf2r = sf1r + nbr_coef;
		DataType			* const	dfr = df + coef_index;
		DataType			* const	dfi = dfr + nbr_coef;

		osc.clear_buffers ();

		// Extreme coefficients are always real
		dfr [0] = sf1r [0] + sf2r [0];
		dfi [0] = sf1r [0] - sf2r [0];	// dfr [nbr_coef] =
		dfr [h_nbr_coef] = sf1r [h_nbr_coef];
		dfi [h_nbr_coef] = sf2r [h_nbr_coef];

		// Others are conjugate complex numbers
		const DataType * const	sf1i = sf1r + h_nbr_coef;
		const DataType * const	sf2i = sf1i + nbr_coef;
		for (long i = 1; i < h_nbr_coef; ++ i)
		{
			osc.step ();
			const DataType	c = osc.get_cos ();
			const DataType	s = osc.get_sin ();
			DataType	 		v;

			v = sf2r [i] * c - sf2i [i] * s;
			dfr [i] = sf1r [i] + v;
			dfi [-i] = sf1r [i] - v;	// dfr [nbr_coef - i] =

			v = sf2r [i] * s + sf2i [i] * c;
			dfi [i] = v + sf1i [i];
			dfi [nbr_coef - i] = v - sf1i [i];
		}

		coef_index += d_nbr_coef;
	}
	while (coef_index < _length);
}



// Transform in several pass
template <class DT>
void	FFTReal <DT>::compute_ifft_general (const DataType f [], DataType x []) const
{
	assert (f != 0);
	assert (f != use_buffer ());
	assert (x != 0);
	assert (x != use_buffer ());
	assert (x != f);

	DataType *		sf = const_cast <DataType *> (f);
	DataType *		df;
	DataType *		df_temp;

	if (_nbr_bits & 1)
	{
		df = use_buffer ();
		df_temp = x;
	}
	else
	{
		df = x;
		df_temp = use_buffer ();
	}

	for (int pass = _nbr_bits - 1; pass >= 3; -- pass)
	{
		compute_inverse_pass_n (df, sf, pass);

		if (pass < _nbr_bits - 1)
		{
			DataType	* const	temp_ptr = df;
			df = sf;
			sf = temp_ptr;
		}
		else
		{
			sf = df;
			df = df_temp;
		}
	}

	compute_inverse_pass_3 (df, sf);
	compute_inverse_pass_1_2 (x, df);
}



template <class DT>
void	FFTReal <DT>::compute_inverse_pass_n (DataType df [], const DataType sf [], int pass) const
{
	assert (df != 0);
	assert (sf != 0);
	assert (df != sf);
	assert (pass >= 3);
	assert (pass < _nbr_bits);

	if (pass <= TRIGO_BD_LIMIT)
	{
		compute_inverse_pass_n_lut (df, sf, pass);
	}
	else
	{
		compute_inverse_pass_n_osc (df, sf, pass);
	}
}



template <class DT>
void	FFTReal <DT>::compute_inverse_pass_n_lut (DataType df [], const DataType sf [], int pass) const
{
	assert (df != 0);
	assert (sf != 0);
	assert (df != sf);
	assert (pass >= 3);
	assert (pass < _nbr_bits);

	const long		nbr_coef = 1 << pass;
	const long		h_nbr_coef = nbr_coef >> 1;
	const long		d_nbr_coef = nbr_coef << 1;
	long				coef_index = 0;
	const DataType * const	cos_ptr = get_trigo_ptr (pass);
	do
	{
		const DataType	* const	sfr = sf + coef_index;
		const DataType	* const	sfi = sfr + nbr_coef;
		DataType			* const	df1r = df + coef_index;
		DataType			* const	df2r = df1r + nbr_coef;

		// Extreme coefficients are always real
		df1r [0] = sfr [0] + sfi [0];		// + sfr [nbr_coef]
		df2r [0] = sfr [0] - sfi [0];		// - sfr [nbr_coef]
		df1r [h_nbr_coef] = sfr [h_nbr_coef] * 2;
		df2r [h_nbr_coef] = sfi [h_nbr_coef] * 2;

		// Others are conjugate complex numbers
		DataType * const	df1i = df1r + h_nbr_coef;
		DataType * const	df2i = df1i + nbr_coef;
		for (long i = 1; i < h_nbr_coef; ++ i)
		{
			df1r [i] = sfr [i] + sfi [-i];		// + sfr [nbr_coef - i]
			df1i [i] = sfi [i] - sfi [nbr_coef - i];

			const DataType	c = cos_ptr [i];					// cos (i*PI/nbr_coef);
			const DataType	s = cos_ptr [h_nbr_coef - i];	// sin (i*PI/nbr_coef);
			const DataType	vr = sfr [i] - sfi [-i];		// - sfr [nbr_coef - i]
			const DataType	vi = sfi [i] + sfi [nbr_coef - i];

			df2r [i] = vr * c + vi * s;
			df2i [i] = vi * c - vr * s;
		}

		coef_index += d_nbr_coef;
	}
	while (coef_index < _length);
}



template <class DT>
void	FFTReal <DT>::compute_inverse_pass_n_osc (DataType df [], const DataType sf [], int pass) const
{
	assert (df != 0);
	assert (sf != 0);
	assert (df != sf);
	assert (pass > TRIGO_BD_LIMIT);
	assert (pass < _nbr_bits);

	const long		nbr_coef = 1 << pass;
	const long		h_nbr_coef = nbr_coef >> 1;
	const long		d_nbr_coef = nbr_coef << 1;
	long				coef_index = 0;
	OscType &		osc = _trigo_osc [pass - (TRIGO_BD_LIMIT + 1)];
	do
	{
		const DataType	* const	sfr = sf + coef_index;
		const DataType	* const	sfi = sfr + nbr_coef;
		DataType			* const	df1r = df + coef_index;
		DataType			* const	df2r = df1r + nbr_coef;

		osc.clear_buffers ();

		// Extreme coefficients are always real
		df1r [0] = sfr [0] + sfi [0];		// + sfr [nbr_coef]
		df2r [0] = sfr [0] - sfi [0];		// - sfr [nbr_coef]
		df1r [h_nbr_coef] = sfr [h_nbr_coef] * 2;
		df2r [h_nbr_coef] = sfi [h_nbr_coef] * 2;

		// Others are conjugate complex numbers
		DataType * const	df1i = df1r + h_nbr_coef;
		DataType * const	df2i = df1i + nbr_coef;
		for (long i = 1; i < h_nbr_coef; ++ i)
		{
			df1r [i] = sfr [i] + sfi [-i];		// + sfr [nbr_coef - i]
			df1i [i] = sfi [i] - sfi [nbr_coef - i];

			osc.step ();
			const DataType	c = osc.get_cos ();
			const DataType	s = osc.get_sin ();
			const DataType	vr = sfr [i] - sfi [-i];		// - sfr [nbr_coef - i]
			const DataType	vi = sfi [i] + sfi [nbr_coef - i];

			df2r [i] = vr * c + vi * s;
			df2i [i] = vi * c - vr * s;
		}

		coef_index += d_nbr_coef;
	}
	while (coef_index < _length);
}



template <class DT>
void	FFTReal <DT>::compute_inverse_pass_3 (DataType df [], const DataType sf []) const
{
	assert (df != 0);
	assert (sf != 0);
	assert (df != sf);

	const DataType	sqrt2_2 = DataType (SQRT2 * 0.5);
	long				coef_index = 0;
	do
	{
		df [coef_index] = sf [coef_index] + sf [coef_index + 4];
		df [coef_index + 4] = sf [coef_index] - sf [coef_index + 4];
		df [coef_index + 2] = sf [coef_index + 2] * 2;
		df [coef_index + 6] = sf [coef_index + 6] * 2;

		df [coef_index + 1] = sf [coef_index + 1] + sf [coef_index + 3];
		df [coef_index + 3] = sf [coef_index + 5] - sf [coef_index + 7];

		const DataType	vr = sf [coef_index + 1] - sf [coef_index + 3];
		const DataType	vi = sf [coef_index + 5] + sf [coef_index + 7];

		df [coef_index + 5] = (vr + vi) * sqrt2_2;
		df [coef_index + 7] = (vi - vr) * sqrt2_2;

		coef_index += 8;
	}
	while (coef_index < _length);
}



template <class DT>
void	FFTReal <DT>::compute_inverse_pass_1_2 (DataType x [], const DataType sf []) const
{
	assert (x != 0);
	assert (sf != 0);
	assert (x != sf);

	const long *	bit_rev_lut_ptr = get_br_ptr ();
	const DataType *	sf2 = sf;
	long				coef_index = 0;
	do
	{
		{
			const DataType	b_0 = sf2 [0] + sf2 [2];
			const DataType	b_2 = sf2 [0] - sf2 [2];
			const DataType	b_1 = sf2 [1] * 2;
			const DataType	b_3 = sf2 [3] * 2;

			x [bit_rev_lut_ptr [0]] = b_0 + b_1;
			x [bit_rev_lut_ptr [1]] = b_0 - b_1;
			x [bit_rev_lut_ptr [2]] = b_2 + b_3;
			x [bit_rev_lut_ptr [3]] = b_2 - b_3;
		}
		{
			const DataType	b_0 = sf2 [4] + sf2 [6];
			const DataType	b_2 = sf2 [4] - sf2 [6];
			const DataType	b_1 = sf2 [5] * 2;
			const DataType	b_3 = sf2 [7] * 2;

			x [bit_rev_lut_ptr [4]] = b_0 + b_1;
			x [bit_rev_lut_ptr [5]] = b_0 - b_1;
			x [bit_rev_lut_ptr [6]] = b_2 + b_3;
			x [bit_rev_lut_ptr [7]] = b_2 - b_3;
		}

		sf2 += 8;
		coef_index += 8;
		bit_rev_lut_ptr += 8;
	}
	while (coef_index < _length);
}



}	// namespace ffft



#endif	// ffft_FFTReal_CODEHEADER_INCLUDED

#undef ffft_FFTReal_CURRENT_CODEHEADER



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
