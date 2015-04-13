/*
 csound_standard_types.h:

 Copyright (C) 2012, 2013 Steven Yi

 This file is part of Csound.

 The Csound Library is free software; you can redistribute it
 and/or modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.

 Csound is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public
 License along with Csound; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 02111-1307 USA
 */

#ifndef CSOUND_STANDARD_TYPES_H
#define CSOUND_STANDARD_TYPES_H

#include "csound_type_system.h"
#include "csound.h"

#ifdef  __cplusplus
extern "C" {
#endif

    PUBLIC void csoundAddStandardTypes(CSOUND* csound, TYPE_POOL* pool);

    PUBLIC_DATA extern const CS_TYPE CS_VAR_TYPE_A;
    PUBLIC_DATA extern const CS_TYPE CS_VAR_TYPE_K;
    PUBLIC_DATA extern const CS_TYPE CS_VAR_TYPE_I;
    PUBLIC_DATA extern const CS_TYPE CS_VAR_TYPE_S;
    PUBLIC_DATA extern const CS_TYPE CS_VAR_TYPE_P;
    PUBLIC_DATA extern const CS_TYPE CS_VAR_TYPE_R;
    PUBLIC_DATA extern const CS_TYPE CS_VAR_TYPE_C;
    PUBLIC_DATA extern const CS_TYPE CS_VAR_TYPE_W;
    PUBLIC_DATA extern const CS_TYPE CS_VAR_TYPE_F;
    PUBLIC_DATA extern const CS_TYPE CS_VAR_TYPE_B;
    PUBLIC_DATA extern const CS_TYPE CS_VAR_TYPE_b;
    PUBLIC_DATA extern const CS_TYPE CS_VAR_TYPE_ARRAY;

    typedef struct arrayVarInit {
        int dimensions;
        CS_TYPE* type;
    } ARRAY_VAR_INIT;


    /* Type maps for poly, optional, and var arg types
     * format is in pairs of specified type and types it can resolve into,
     * termintated by a NULL */
    extern const char* POLY_IN_TYPES[];
    extern const char* OPTIONAL_IN_TYPES[];
    extern const char* VAR_ARG_IN_TYPES[];
    extern const char* POLY_OUT_TYPES[];
    extern const char* VAR_ARG_OUT_TYPES[];



#ifdef  __cplusplus
}
#endif

#endif  /* CSOUND_STANDARD_TYPES_H */
