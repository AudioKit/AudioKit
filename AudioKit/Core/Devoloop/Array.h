/*****************************************************************************

        Array.h
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/

#if !defined(ffft_Array_HEADER_INCLUDED)
#define ffft_Array_HEADER_INCLUDED

#if defined(_MSC_VER)
#pragma once
#pragma warning(4 : 4250) // "Inherits via dominance."
#endif



namespace ffft {

template <class T, long LEN> class Array {

public:
  typedef T DataType;

  Array();

  inline const DataType &operator[](long pos) const;
  inline DataType &operator[](long pos);

  static inline long size();
private:
  DataType _data_arr[LEN];

  Array(const Array &other);
  Array &operator=(const Array &other);
  bool operator==(const Array &other);
  bool operator!=(const Array &other);

};

}

#include "ffft/Array.hpp"

#endif


