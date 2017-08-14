/*****************************************************************************

        FFTRealPassInverse.hpp
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if defined (ffft_FFTRealPassInverse_CURRENT_CODEHEADER)
	#error Recursive inclusion of FFTRealPassInverse code header.
#endif
#define	ffft_FFTRealPassInverse_CURRENT_CODEHEADER

#if ! defined (ffft_FFTRealPassInverse_CODEHEADER_INCLUDED)
#define	ffft_FFTRealPassInverse_CODEHEADER_INCLUDED



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	"ffft/FFTRealUseTrigo.h"



namespace ffft
{



/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



template <int PASS>
void	FFTRealPassInverse <PASS>::process (long len, DataType dest_ptr [], DataType src_ptr [], const DataType f_ptr [], const DataType cos_ptr [], long cos_len, const long br_ptr [], OscType osc_list [])
{
	process_internal (
		len,
		dest_ptr,
		f_ptr,
		cos_ptr,
		cos_len,
		br_ptr,
		osc_list
	);
	FFTRealPassInverse <PASS - 1>::process_rec (
		len,
		src_ptr,
		dest_ptr,
		cos_ptr,
		cos_len,
		br_ptr,
		osc_list
	);
}



template <int PASS>
void	FFTRealPassInverse <PASS>::process_rec (long len, DataType dest_ptr [], DataType src_ptr [], const DataType cos_ptr [], long cos_len, const long br_ptr [], OscType osc_list [])
{
	process_internal (
		len,
		dest_ptr,
		src_ptr,
		cos_ptr,
		cos_len,
		br_ptr,
		osc_list
	);
	FFTRealPassInverse <PASS - 1>::process_rec (
		len,
		src_ptr,
		dest_ptr,
		cos_ptr,
		cos_len,
		br_ptr,
		osc_list
	);
}

template <>
inline void	FFTRealPassInverse <0>::process_rec (long len, DataType dest_ptr [], DataType src_ptr [], const DataType cos_ptr [], long cos_len, const long br_ptr [], OscType osc_list [])
{
	// Stops recursion
}



template <int PASS>
void	FFTRealPassInverse <PASS>::process_internal (long len, DataType dest_ptr [], const DataType src_ptr [], const DataType cos_ptr [], long cos_len, const long br_ptr [], OscType osc_list [])
{
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
		df [c1_i] = sf [c1_i] * 2;
		df [c2_i] = sf [c2_i] * 2;

		FFTRealUseTrigo <TRIGO_DIRECT>::prepare (osc_list [TRIGO_OSC]);

		// Others are conjugate complex numbers
		for (long i = 1; i < dist; ++ i)
		{
			df [c1_r + i] = sf [c1_r + i] + sf [c2_r - i];
			df [c1_i + i] = sf [c2_r + i] - sf [cend - i];

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

			const DataType	vr = sf [c1_r + i] - sf [c2_r - i];
			const DataType	vi = sf [c2_r + i] + sf [cend - i];

			df [c2_r + i] = vr * c + vi * s;
			df [c2_i + i] = vi * c - vr * s;
		}

		coef_index += cend;
	}
	while (coef_index < len);
}

template <>
inline void	FFTRealPassInverse <2>::process_internal (long len, DataType dest_ptr [], const DataType src_ptr [], const DataType cos_ptr [], long cos_len, const long br_ptr [], OscType osc_list [])
{
	// Antepenultimate pass
	const DataType	sqrt2_2 = DataType (SQRT2 * 0.5);

	long				coef_index = 0;
	do
	{
		dest_ptr [coef_index    ] = src_ptr [coef_index] + src_ptr [coef_index + 4];
		dest_ptr [coef_index + 4] = src_ptr [coef_index] - src_ptr [coef_index + 4];
		dest_ptr [coef_index + 2] = src_ptr [coef_index + 2] * 2;
		dest_ptr [coef_index + 6] = src_ptr [coef_index + 6] * 2;

		dest_ptr [coef_index + 1] = src_ptr [coef_index + 1] + src_ptr [coef_index + 3];
		dest_ptr [coef_index + 3] = src_ptr [coef_index + 5] - src_ptr [coef_index + 7];

		const DataType	vr = src_ptr [coef_index + 1] - src_ptr [coef_index + 3];
		const DataType	vi = src_ptr [coef_index + 5] + src_ptr [coef_index + 7];

		dest_ptr [coef_index + 5] = (vr + vi) * sqrt2_2;
		dest_ptr [coef_index + 7] = (vi - vr) * sqrt2_2;

		coef_index += 8;
	}
	while (coef_index < len);
}

template <>
inline void	FFTRealPassInverse <1>::process_internal (long len, DataType dest_ptr [], const DataType src_ptr [], const DataType cos_ptr [], long cos_len, const long br_ptr [], OscType osc_list [])
{
	// Penultimate and last pass at once
	const long		qlen = len >> 2;

	long				coef_index = 0;
	do
	{
		const long		ri_0 = br_ptr [coef_index >> 2];

		const DataType	b_0 = src_ptr [coef_index    ] + src_ptr [coef_index + 2];
		const DataType	b_2 = src_ptr [coef_index    ] - src_ptr [coef_index + 2];
		const DataType	b_1 = src_ptr [coef_index + 1] * 2;
		const DataType	b_3 = src_ptr [coef_index + 3] * 2;

		dest_ptr [ri_0           ] = b_0 + b_1;
		dest_ptr [ri_0 + 2 * qlen] = b_0 - b_1;
		dest_ptr [ri_0 + 1 * qlen] = b_2 + b_3;
		dest_ptr [ri_0 + 3 * qlen] = b_2 - b_3;

		coef_index += 4;
	}
	while (coef_index < len);
}



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



}	// namespace ffft



#endif	// ffft_FFTRealPassInverse_CODEHEADER_INCLUDED

#undef ffft_FFTRealPassInverse_CURRENT_CODEHEADER



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
