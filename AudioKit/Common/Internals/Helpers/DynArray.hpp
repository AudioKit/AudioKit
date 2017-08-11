/*****************************************************************************

        DynArray.hpp
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/



#if defined (ffft_DynArray_CURRENT_CODEHEADER)
	#error Recursive inclusion of DynArray code header.
#endif
#define	ffft_DynArray_CURRENT_CODEHEADER

#if ! defined (ffft_DynArray_CODEHEADER_INCLUDED)
#define	ffft_DynArray_CODEHEADER_INCLUDED



/*\\\ INCLUDE FILES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

#include	<cassert>



namespace ffft
{



/*\\\ PUBLIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



template <class T>
DynArray <T>::DynArray ()
:	_data_ptr (0)
,	_len (0)
{
	// Nothing
}



template <class T>
DynArray <T>::DynArray (long size)
:	_data_ptr (0)
,	_len (0)
{
	assert (size >= 0);
	if (size > 0)
	{
		_data_ptr = new DataType [size];
		_len = size;
	}
}



template <class T>
DynArray <T>::~DynArray ()
{
	delete [] _data_ptr;
	_data_ptr = 0;
	_len = 0;
}



template <class T>
long	DynArray <T>::size () const
{
	return (_len);
}



template <class T>
void	DynArray <T>::resize (long size)
{
	assert (size >= 0);
	if (size > 0)
	{
		DataType *		old_data_ptr = _data_ptr;
		DataType *		tmp_data_ptr = new DataType [size];

		_data_ptr = tmp_data_ptr;
		_len = size;

		delete [] old_data_ptr;
	}
}



template <class T>
const typename DynArray <T>::DataType &	DynArray <T>::operator [] (long pos) const
{
	assert (pos >= 0);
	assert (pos < _len);

	return (_data_ptr [pos]);
}



template <class T>
typename DynArray <T>::DataType &	DynArray <T>::operator [] (long pos)
{
	assert (pos >= 0);
	assert (pos < _len);

	return (_data_ptr [pos]);
}



/*\\\ PROTECTED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



/*\\\ PRIVATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



}	// namespace ffft



#endif	// ffft_DynArray_CODEHEADER_INCLUDED

#undef ffft_DynArray_CURRENT_CODEHEADER



/*\\\ EOF \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
