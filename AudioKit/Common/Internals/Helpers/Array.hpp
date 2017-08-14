/*****************************************************************************

        Array.hpp
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if defined (ffft_Array_CURRENT_CODEHEADER)
	#error Recursive inclusion of Array code header.
#endif
#define	ffft_Array_CURRENT_CODEHEADER

#if ! defined (ffft_Array_CODEHEADER_INCLUDED)
#define	ffft_Array_CODEHEADER_INCLUDED



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	<cassert>



namespace ffft
{



/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



template <class T, long LEN>
Array <T, LEN>::Array ()
{
	// Nothing
}



template <class T, long LEN>
const typename Array <T, LEN>::DataType &	Array <T, LEN>::operator [] (long pos) const
{
	assert (pos >= 0);
	assert (pos < LEN);

	return (_data_arr [pos]);
}



template <class T, long LEN>
typename Array <T, LEN>::DataType &	Array <T, LEN>::operator [] (long pos)
{
	assert (pos >= 0);
	assert (pos < LEN);

	return (_data_arr [pos]);
}



template <class T, long LEN>
long	Array <T, LEN>::size ()
{
	return (LEN);
}



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



}	// namespace ffft



#endif	// ffft_Array_CODEHEADER_INCLUDED

#undef ffft_Array_CURRENT_CODEHEADER



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
