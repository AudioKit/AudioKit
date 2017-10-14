/*****************************************************************************

        FFTRealPassDirect.hpp
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if defined (ffft_FFTRealPassDirect_CURRENT_CODEHEADER)
	#error Recursive inclusion of FFTRealPassDirect code header.
#endif
#define	ffft_FFTRealPassDirect_CURRENT_CODEHEADER

#if ! defined (ffft_FFTRealPassDirect_CODEHEADER_INCLUDED)
#define	ffft_FFTRealPassDirect_CODEHEADER_INCLUDED



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	"ffft/FFTRealUseTrigo.h"



namespace ffft
{



/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



template <>
inline void	FFTRealPassDirect <1>::process (long len, DataType dest_ptr [], DataType src_ptr [], const DataType x_ptr [], const DataType cos_ptr [], long cos_len, const long br_ptr [], OscType osc_list [])
{
	// First and second pass at once
	const long		qlen = len >> 2;

	long				coef_index = 0;
	do
	{
		// To do: unroll the loop (2x).
		const long		ri_0 = br_ptr [coef_index >> 2];
		const long		ri_1 = ri_0 + 2 * qlen;	// bit_rev_lut_ptr [coef_index + 1];
		const long		ri_2 = ri_0 + 1 * qlen;	// bit_rev_lut_ptr [coef_index + 2];
		const long		ri_3 = ri_0 + 3 * qlen;	// bit_rev_lut_ptr [coef_index + 3];

		DataType	* const	df2 = dest_ptr + coef_index;
		df2 [1] = x_ptr [ri_0] - x_ptr [ri_1];
		df2 [3] = x_ptr [ri_2] - x_ptr [ri_3];

		const DataType	sf_0 = x_ptr [ri_0] + x_ptr [ri_1];
		const DataType	sf_2 = x_ptr [ri_2] + x_ptr [ri_3];

		df2 [0] = sf_0 + sf_2;
		df2 [2] = sf_0 - sf_2;

		coef_index += 4;
	}
	while (coef_index < len);
}

template <>
inline void	FFTRealPassDirect <2>::process (long len, DataType dest_ptr [], DataType src_ptr [], const DataType x_ptr [], const DataType cos_ptr [], long cos_len, const long br_ptr [], OscType osc_list [])
{
	// Executes "previous" passes first. Inverts source and destination buffers
	FFTRealPassDirect <1>::process (
		len,
		src_ptr,
		dest_ptr,
		x_ptr,
		cos_ptr,
		cos_len,
		br_ptr,
		osc_list
	);

	// Third pass
	const DataType	sqrt2_2 = DataType (SQRT2 * 0.5);

	long				coef_index = 0;
	do
	{
		dest_ptr [coef_index    ] = src_ptr [coef_index] + src_ptr [coef_index + 4];
		dest_ptr [coef_index + 4] = src_ptr [coef_index] - src_ptr [coef_index + 4];
		dest_ptr [coef_index + 2] = src_ptr [coef_index + 2];
		dest_ptr [coef_index + 6] = src_ptr [coef_index + 6];

		DataType			v;

		v = (src_ptr [coef_index + 5] - src_ptr [coef_index + 7]) * sqrt2_2;
		dest_ptr [coef_index + 1] = src_ptr [coef_index + 1] + v;
		dest_ptr [coef_index + 3] = src_ptr [coef_index + 1] - v;

		v = (src_ptr [coef_index + 5] + src_ptr [coef_index + 7]) * sqrt2_2;
		dest_ptr [coef_index + 5] = v + src_ptr [coef_index + 3];
		dest_ptr [coef_index + 7] = v - src_ptr [coef_index + 3];

		coef_index += 8;
	}
	while (coef_index < len);
}

template <int PASS>
void	FFTRealPassDirect <PASS>::process (long len, DataType dest_ptr [], DataType src_ptr [], const DataType x_ptr [], const DataType cos_ptr [], long cos_len, const long br_ptr [], OscType osc_list [])
{
	// Executes "previous" passes first. Inverts source and destination buffers
	FFTRealPassDirect <PASS - 1>::process (
		len,
		src_ptr,
		dest_ptr,
		x_ptr,
		cos_ptr,
		cos_len,
		br_ptr,
		osc_list
	);

	const long		dist = 1L << (PASS - 1);
	const long		c1_r = 0;
	const long		c1_i = dist;
	const long		c2_r = dist * 2;
	const long		c2_i = dist * 3;
	const long		cend = dist * 4;
	const long		table_step = cos_len >> (PASS - 1);

   enum {	TRIGO_OSC		= PASS - FFTRealFixLenParam::TRIGO_BD_LIMIT	};
	enum {	TRIGO_DIRECT	= (TRIGO_OSC >= 0) ? 1 : 0	};

	long				coef_index = 0;
	do
	{
		const DataType	* const	sf = src_ptr + coef_index;
		DataType			* const	df = dest_ptr + coef_index;

		// Extreme coefficients are always real
		df [c1_r] = sf [c1_r] + sf [c2_r];
		df [c2_r] = sf [c1_r] - sf [c2_r];
		df [c1_i] = sf [c1_i];
		df [c2_i] = sf [c2_i];

		FFTRealUseTrigo <TRIGO_DIRECT>::prepare (osc_list [TRIGO_OSC]);

		// Others are conjugate complex numbers
		for (long i = 1; i < dist; ++ i)
		{
			DataType			c;
			DataType			s;
			FFTRealUseTrigo <TRIGO_DIRECT>::iterate (
				osc_list [TRIGO_OSC],
				c,
				s,
				cos_ptr,
				i * table_step,
				(dist - i) * table_step
			);

			const DataType	sf_r_i = sf [c1_r + i];
			const DataType	sf_i_i = sf [c1_i + i];

			const DataType	v1 = sf [c2_r + i] * c - sf [c2_i + i] * s;
			df [c1_r + i] = sf_r_i + v1;
			df [c2_r - i] = sf_r_i - v1;

			const DataType	v2 = sf [c2_r + i] * s + sf [c2_i + i] * c;
			df [c2_r + i] = v2 + sf_i_i;
			df [cend - i] = v2 - sf_i_i;
		}

		coef_index += cend;
	}
	while (coef_index < len);
}



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



}	// namespace ffft



#endif	// ffft_FFTRealPassDirect_CODEHEADER_INCLUDED

#undef ffft_FFTRealPassDirect_CURRENT_CODEHEADER



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
