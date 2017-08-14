/*****************************************************************************

        FFTReal.h
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if ! defined (ffft_FFTReal_HEADER_INCLUDED)
#define	ffft_FFTReal_HEADER_INCLUDED

#if defined (_MSC_VER)
	#pragma once
	#pragma warning (4 : 4250) // "Inherits via dominance."
#endif



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	"def.h"
#include	"DynArray.h"
#include	"OscSinCos.h"



namespace ffft
{



template <class DT>
class FFTReal
{

/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

public:

	enum {			MAX_BIT_DEPTH	= 30	};	// So length can be represented as long int

	typedef	DT	DataType;

	explicit			FFTReal (long length);
	virtual			~FFTReal () {}

	long				get_length () const;
	void				do_fft (DataType f [], const DataType x []) const;
	void				do_ifft (const DataType f [], DataType x []) const;
	void				rescale (DataType x []) const;
	DataType *		use_buffer () const;



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

protected:



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

private:

   // Over this bit depth, we use direct calculation for sin/cos
   enum {	      TRIGO_BD_LIMIT	= 12  };

	typedef	OscSinCos <DataType>	OscType;

	void				init_br_lut ();
	void				init_trigo_lut ();
	void				init_trigo_osc ();

	ffft_FORCEINLINE const long *
						get_br_ptr () const;
	ffft_FORCEINLINE const DataType	*
						get_trigo_ptr (int level) const;
	ffft_FORCEINLINE long
						get_trigo_level_index (int level) const;

	inline void		compute_fft_general (DataType f [], const DataType x []) const;
	inline void		compute_direct_pass_1_2 (DataType df [], const DataType x []) const;
	inline void		compute_direct_pass_3 (DataType df [], const DataType sf []) const;
	inline void		compute_direct_pass_n (DataType df [], const DataType sf [], int pass) const;
	inline void		compute_direct_pass_n_lut (DataType df [], const DataType sf [], int pass) const;
	inline void		compute_direct_pass_n_osc (DataType df [], const DataType sf [], int pass) const;

	inline void		compute_ifft_general (const DataType f [], DataType x []) const;
	inline void		compute_inverse_pass_n (DataType df [], const DataType sf [], int pass) const;
	inline void		compute_inverse_pass_n_osc (DataType df [], const DataType sf [], int pass) const;
	inline void		compute_inverse_pass_n_lut (DataType df [], const DataType sf [], int pass) const;
	inline void		compute_inverse_pass_3 (DataType df [], const DataType sf []) const;
	inline void		compute_inverse_pass_1_2 (DataType x [], const DataType sf []) const;

	const long		_length;
	const int		_nbr_bits;
	DynArray <long>
						_br_lut;
	DynArray <DataType>
						_trigo_lut;
	mutable DynArray <DataType>
						_buffer;
   mutable DynArray <OscType>
						_trigo_osc;



/*\\\ FORBIDDEN MEMBER FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

private:

						FFTReal ();
						FFTReal (const FFTReal &other);
	FFTReal &		operator = (const FFTReal &other);
	bool				operator == (const FFTReal &other);
	bool				operator != (const FFTReal &other);

};	// class FFTReal



}	// namespace ffft



#include	"FFTReal.hpp"



#endif	// ffft_FFTReal_HEADER_INCLUDED



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
