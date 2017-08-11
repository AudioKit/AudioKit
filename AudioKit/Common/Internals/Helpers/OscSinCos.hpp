/*****************************************************************************

        OscSinCos.hpp
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if defined (ffft_OscSinCos_CURRENT_CODEHEADER)
	#error Recursive inclusion of OscSinCos code header.
#endif
#define	ffft_OscSinCos_CURRENT_CODEHEADER

#if ! defined (ffft_OscSinCos_CODEHEADER_INCLUDED)
#define	ffft_OscSinCos_CODEHEADER_INCLUDED



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	<cmath>

namespace std { }



namespace ffft
{



/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



template <class T>
OscSinCos <T>::OscSinCos ()
:	_pos_cos (1)
,	_pos_sin (0)
,	_step_cos (1)
,	_step_sin (0)
{
	// Nothing
}



template <class T>
void	OscSinCos <T>::set_step (double angle_rad)
{
	using namespace std;

	_step_cos = static_cast <DataType> (cos (angle_rad));
	_step_sin = static_cast <DataType> (sin (angle_rad));
}



template <class T>
typename OscSinCos <T>::DataType	OscSinCos <T>::get_cos () const
{
	return (_pos_cos);
}



template <class T>
typename OscSinCos <T>::DataType	OscSinCos <T>::get_sin () const
{
	return (_pos_sin);
}



template <class T>
void	OscSinCos <T>::step ()
{
	const DataType	old_cos = _pos_cos;
	const DataType	old_sin = _pos_sin;

	_pos_cos = old_cos * _step_cos - old_sin * _step_sin;
	_pos_sin = old_cos * _step_sin + old_sin * _step_cos;
}



template <class T>
void	OscSinCos <T>::clear_buffers ()
{
	_pos_cos = static_cast <DataType> (1);
	_pos_sin = static_cast <DataType> (0);
}



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



}	// namespace ffft



#endif	// ffft_OscSinCos_CODEHEADER_INCLUDED

#undef ffft_OscSinCos_CURRENT_CODEHEADER



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
