/*****************************************************************************

        FFTRealFixLenParam.h
        By Laurent de Soras

--- Legal stuff ---

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

*Tab=3***********************************************************************/

#if !defined(ffft_FFTRealFixLenParam_HEADER_INCLUDED)
#define ffft_FFTRealFixLenParam_HEADER_INCLUDED

#if defined(_MSC_VER)
#pragma once
#pragma warning(4 : 4250) // "Inherits via dominance."
#endif



namespace ffft {

class FFTRealFixLenParam {

public:
  // Over this bit depth, we use direct calculation for sin/cos
  enum { TRIGO_BD_LIMIT = 12 };

  typedef float DataType;

private:
  FFTRealFixLenParam();
  FFTRealFixLenParam(const FFTRealFixLenParam &other);
  FFTRealFixLenParam &operator=(const FFTRealFixLenParam &other);
  bool operator==(const FFTRealFixLenParam &other);
  bool operator!=(const FFTRealFixLenParam &other);

};

}

//#include	"ffft/FFTRealFixLenParam.hpp"

#endif


