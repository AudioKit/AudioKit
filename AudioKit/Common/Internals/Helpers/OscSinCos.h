/*****************************************************************************

        OscSinCos.h
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if ! defined (ffft_OscSinCos_HEADER_INCLUDED)
#define	ffft_OscSinCos_HEADER_INCLUDED

#if defined (_MSC_VER)
	#pragma once
	#pragma warning (4 : 4250) // "Inherits via dominance."
#endif



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	"def.h"



namespace ffft
{



template <class T>
class OscSinCos
{

/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

public:

	typedef	T	DataType;

						OscSinCos ();

	ffft_FORCEINLINE void
						set_step (double angle_rad);

	ffft_FORCEINLINE DataType
						get_cos () const;
	ffft_FORCEINLINE DataType
						get_sin () const;
	ffft_FORCEINLINE void
						step ();
	ffft_FORCEINLINE void
						clear_buffers ();



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

protected:



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

private:

	DataType			_pos_cos;		// Current phase expressed with sin and cos. [-1 ; 1]
	DataType			_pos_sin;		// -
	DataType			_step_cos;		// Phase increment per step, [-1 ; 1]
	DataType			_step_sin;		// -



/*\\\ FORBIDDEN MEMBER FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

private:

						OscSinCos (const OscSinCos &other);
	OscSinCos &		operator = (const OscSinCos &other);
	bool				operator == (const OscSinCos &other);
	bool				operator != (const OscSinCos &other);

};	// class OscSinCos



}	// namespace ffft



#include	"OscSinCos.hpp"



#endif	// ffft_OscSinCos_HEADER_INCLUDED



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
