/*
 * C S O U N D
 *
 * An auto-extensible system for making music on computers
 * by means of software alone.
 *
 * Copyright (C) 2001-2005 Michael Gogins, Matt Ingalls, John D. Ramsdell,
 *                         John P. ffitch, Istvan Varga
 *
 * L I C E N S E
 *
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
#ifndef CSOUND_FILEBUILDING_H
#define CSOUND_FILEBUILDING_H

#include "csound.h"
/** \file
 * \brief Csound API functions to create, build up, and save CSD files.
 * \author Michael Gogins
 *
 * \b Purpose
 *
 * The purpose of these functions is to make it easier for clients
 * of the Csound API to programmatically build up CSD files,
 * including set instrument definitions, set options,
 * and especially append score statements.
 *
 * There are also convenience functions to compile and perform
 * the saved CSD file.
 */
#ifndef PUBLIC
#if (defined(WIN32) || defined(_WIN32)) && !defined(SWIG)
#  define PUBLIC        __declspec(dllexport)
#elif defined(__GNUC__) && !defined(__MACH__)
#  define PUBLIC        __attribute__ ( (visibility("default")) )
#else
#  define PUBLIC
#endif
#endif

  /**
   * Enables Python interface.
   */

#ifdef SWIG
#define CS_PRINTF2
#define CS_PRINTF3
#include "float-version.h"
#ifndef __MYFLT_DEF
#define __MYFLT_DEF
#ifndef USE_DOUBLE
#define MYFLT float
#else
#define MYFLT double
#endif
#endif
%module filebuilding
%{
#  include "sysdep.h"
#  include "text.h"
#  include "csound.h"
#  include <stdarg.h>
%}
#else
#  include "sysdep.h"
#  include "text.h"
#  include "csound.h"
#  include <stdarg.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif



/**
 * Initialize an internal CSD file.
 */
  PUBLIC void csoundCsdCreate(CSOUND *csound);

/**
 * Set the CsOptions element of the internal CSD file.
 */
PUBLIC void csoundCsdSetOptions(CSOUND *csound, char *options);

/**
 * Return the CsOptions element of the internal CSD file.
 */
PUBLIC const char* csoundCsdGetOptions(CSOUND *csound);

/**
 * Set the CsInstruments element of the internal CSD file.
 */
PUBLIC void csoundCsdSetOrchestra(CSOUND *csound, char *orchestra);

/**
 * Return the CsInstruments element of the internal CSD file.
 */
PUBLIC const char* csoundCsdGetOrchestra(CSOUND *csound);

/**
 * Append a line of text to the CsScore element of the internal CSD file.
 */
PUBLIC void csoundCsdAddScoreLine(CSOUND *csound, char *line);

/**
 * Append an 'i' event to the CsScore element of the internal CSD file.
 */
PUBLIC void csoundCsdAddEvent11(CSOUND *csound, double p1, double p2, double p3,
                                double p4, double p5, double p6, double p7,
                                double p8, double p9, double p10, double p11);

/**
 * Append an 'i' event to the CsScore element of the internal CSD file.
 */
PUBLIC void csoundCsdAddEvent10(CSOUND *csound, double p1, double p2, double p3,
                                double p4, double p5, double p6, double p7,
                                double p8, double p9, double p10);

/**
 * Append an 'i' event to the CsScore element of the internal CSD file.
 */
PUBLIC void csoundCsdAddEvent9(CSOUND *csound, double p1, double p2, double p3,
                               double p4, double p5, double p6, double p7,
                               double p8, double p9);

/**
 * Append an 'i' event to the CsScore element of the internal CSD file.
 */
PUBLIC void csoundCsdAddEvent8(CSOUND *csound, double p1, double p2, double p3,
                               double p4, double p5, double p6, double p7,
                               double p8);

/**
 * Append an 'i' event to the CsScore element of the internal CSD file.
 */
PUBLIC void csoundCsdAddEvent7(CSOUND *csound, double p1, double p2, double p3,
                               double p4, double p5, double p6, double p7);

/**
 * Append an 'i' event to the CsScore element of the internal CSD file.
 */
PUBLIC void csoundCsdAddEvent6(CSOUND *csound, double p1, double p2, double p3,
                               double p4, double p5, double p6);

/**
 * Append an 'i' event to the CsScore element of the internal CSD file.
 */
PUBLIC void csoundCsdAddEvent5(CSOUND *csound, double p1, double p2, double p3,
                               double p4, double p5);

/**
 * Append an 'i' event to the CsScore element of the internal CSD file.
 */
PUBLIC void csoundCsdAddEvent4(CSOUND *csound, double p1, double p2, double p3,
                               double p4);

/**
 * Append an 'i' event to the CsScore element of the internal CSD file.
 */
PUBLIC void csoundCsdAddEvent3(CSOUND *csound, double p1, double p2, double p3);

/**
 * Save the internal CSD file to the indicated filename, which must end in '.csd'.
 */
PUBLIC int csoundCsdSave(CSOUND *csound, char *filename);

/**
 * Convenience function that saves the internal CSD file to the indicated filename,
 * which must end in '.csd, then performs the file.
 */
PUBLIC int csoundCsdCompile(CSOUND *csound, char *filename);

/**
 * Convenience function that saves the internal CSD file to the indicated filename,
 * which must end in '.csd, then compiles the file for later performance.
 */
PUBLIC int csoundCsdPerform(CSOUND *csound, char *filename);


 /* VL: a new, more complete, version of this function has been added to the main
     Csound library.
  PUBLIC int csoundCompileCsd(CSOUND *, char *csdFilename);
 */

/**
 * Compiles and renders a Csound performance,
 * as directed by the supplied CSD file,
 * in one pass. Returns 0 for success.
 */
PUBLIC int csoundPerformCsd(CSOUND *, char *csdFilename);

#ifdef __cplusplus
}
#endif

#endif
