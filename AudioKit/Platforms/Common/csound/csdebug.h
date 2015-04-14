/*
    csdebug.h:

    Copyright (C) 2014 Andres Cabrera

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

#ifndef CSDEBUG_H
#define CSDEBUG_H

/**
* \file csdebug.h
*
* This header provides the debugger API which is part of libcsound.
*
* Basic usage of the debugger is this:
*
* \code
    CSOUND* csound = csoundCreate(NULL);
    csoundCompileOrc(csound, " ");
    csoundStart(csound);
    csoundDebuggerInit(csound);
    csoundSetBreakpointCallback(csound, brkpt_cb, &userdata);
    csoundSetInstrumentBreakpoint(csound, 1, 5);

    // Run Csound Performance here
    // The breakpoint callback will be called when instrument 1 has been
    // instantiated and 5 control blocks have been processed.

    csoundDebuggerClean(csound);
    csoundDestroy(csound);
* \endcode
*
*/

#ifdef __BUILDING_LIBCSOUND
#include "csoundCore.h"
#else
#include "csound.h"
#endif

#include "csound_type_system.h"


/** @defgroup DEBUGGER Debugger
 *
 *  @{ */

typedef struct debug_instr_s {
    CS_VARIABLE *varPoolHead;
    MYFLT *lclbas;
    void *instrptr;
    MYFLT p1, p2, p3;
    int kcounter;
    int line;
    struct debug_instr_s *next;
} debug_instr_t;

typedef struct debug_opcode_s {
    char opname[16];
    int line;
    // TODO: Fill opcode linked list
    struct debug_opcode_s *next;
    struct debug_opcode_s *prev;
} debug_opcode_t;

typedef struct debug_variable_s {
    const char *name;
    const char *typeName;
    void *data;
    struct debug_variable_s *next;
} debug_variable_t;

typedef struct {
    debug_instr_t *breakpointInstr;
    debug_variable_t *instrVarList;
    debug_instr_t *instrListHead;
    debug_opcode_t *currentOpcode;
} debug_bkpt_info_t;


/** \cond DOXYGEN_HIDDEN
 * These types should not appear in the Doxygen docs */


typedef enum {
    CSDEBUG_BKPT_LINE,
    CSDEBUG_BKPT_INSTR,
    CSDEBUG_BKPT_DELETE,
    CSDEBUG_BKPT_CLEAR_ALL
} bkpt_mode_t;

typedef enum {
    CSDEBUG_STATUS_RUNNING,
    CSDEBUG_STATUS_STOPPED,
    CSDEBUG_STATUS_NEXT
} debug_status_t;

typedef struct bkpt_node_s {
    int line; /* if line is < 0 breakpoint is for instrument instances */
    MYFLT instr; /* instrument number (including fractional part */
    int skip; /* number of times to skip when arriving at the breakpoint */
    int count; /* current backwards count for skip, when 0 break */
    bkpt_mode_t mode;
    struct bkpt_node_s *next;
} bkpt_node_t;

typedef enum {
    CSDEBUG_CMD_NONE,
    CSDEBUG_CMD_STEPOVER,
    CSDEBUG_CMD_STEPINTO,
    CSDEBUG_CMD_NEXT,
    CSDEBUG_CMD_CONTINUE,
    CSDEBUG_CMD_STOP
} debug_command_t;

typedef enum {
    CSDEBUG_OFF = 0x0,
    CSDEBUG_K = 0x01,
    CSDEBUG_INIT = 0x02
} debug_mode_t;

#ifdef __BUILD_LIBCSOUND

void csoundDebuggerBreakpointReached(CSOUND *csound);

#endif

/** @endcond */

#ifdef __cplusplus
extern "C" {
#endif


/** Breakpoint callback function type
 *
 * When a breakpoint is reached, the debugger will call a function of this type
 * see csoundSetBreakpointCallback() */
typedef void (*breakpoint_cb_t) (CSOUND *, debug_bkpt_info_t *, void *userdata);

typedef struct csdebug_data_s {
    void *bkpt_buffer; /* for passing breakpoints to the running engine */
    void *cmd_buffer;     /* for passing commands to the running engine */
    debug_status_t status;
    bkpt_node_t *bkpt_anchor;            /* linked list for breakpoints */
    bkpt_node_t *cur_bkpt;   /* current breakpoint where we are stopped */
    breakpoint_cb_t bkpt_cb;
    void *cb_data;
    void *debug_instr_ptr;      /* != NULL when stopped at a breakpoint.
                                   Holds INSDS * */
    void *debug_opcode_ptr; /* != NULL when stopped at a line breakpoint.
                               Holds OPDS * */
} csdebug_data_t;

/** Intialize debugger facilities
 *
 * This function allocates debugger structures, and enables its usage.
 * There is a small performance penalty when using the debugger, so
 * be sure to call csoundDebuggerClean() after use.
 *
 * This call is not thread safe and must be called before performance starts.
 *
 * @param csound A Csound instance
*/
PUBLIC void csoundDebuggerInit(CSOUND *csound);

/** Cleanup debugger facilities
 *
 * @param csound A Csound instance
*/
PUBLIC void csoundDebuggerClean(CSOUND *csound);

/** Set a breakpoint on a particular line
 *
 * @param csound A Csound instance @param line The line on which to
 * set a breakpoint
 * @param instr When set to 0, the line number refers
 * to the line number in the score. When a number is given, it should
 * refer to an instrument that has been compiled on the fly using
 * csoundParseOrc().
 * @param skip number of control blocks to skip
 *
*/
PUBLIC void csoundSetBreakpoint(CSOUND *csound, int line, int instr, int skip);

/** Remove a previously set line breakpoint
 *
*/
PUBLIC void csoundRemoveBreakpoint(CSOUND *csound, int line, int instr);

/** Set a breakpoint for an instrument number
 *
 * Sets a breakpoint for an instrument number with optional number of skip
 * control blocks. You can specify a fractional instrument number to identify
 * particular instances. Specifying a value greater than 1 will result in that
 * number of control blocks being skipped before this breakpoint is called
 * again. A value of 0 and 1 has the same effect.
 *
 * This call is thread safe, as the breakpoint will be put in a lock free queue
 * that is processed as soon as possible in the kperf function.
 *
 * @param csound a Csound instance
 * @param instr instrument number
 * @param skip number of control blocks to skip
 */
PUBLIC void csoundSetInstrumentBreakpoint(CSOUND *csound, MYFLT instr, int skip);

/** Remove instrument breakpoint
 *
 * Removes an instrument breakpoint from the breakpoint list. Csound will no
 * longer break at that instrument
 *
 * This call is thread safe, as the breakpoint will be put in a lock free queue
 * that is processed as soon as possible in the kperf function.
 */
PUBLIC void csoundRemoveInstrumentBreakpoint(CSOUND *csound, MYFLT instr);

/** Clear all breakpoints
 *
 * Removes all breakpoints. This call is thread safe, as it will be processed
 *  as soon as possible in the kperf function.
 */
PUBLIC void csoundClearBreakpoints(CSOUND *csound);

/** Sets the breakpoint callback function
 *
 * Sets the function that will be called when a breakpoint is reached.
 *
 * @param csound Csound instance pointer
 * @param bkpt_cb pointer to breakpoint callback function
 * @param userdata pointer to user data that will be passed to the callback
 * function
 */
PUBLIC void csoundSetBreakpointCallback(CSOUND *csound,
                                        breakpoint_cb_t bkpt_cb, void *userdata);

/* Not implemented yet, so not exposed in the API
PUBLIC void csoundDebugStepOver(CSOUND *csound);
PUBLIC void csoundDebugStepInto(CSOUND *csound);
*/

/** Continue execution and break at next instrument instance
 *
 * Call this function to continue execution but automatically stop at
 * next instrument instance.
 */
PUBLIC void csoundDebugNext(CSOUND *csound);

/** Continue execution from breakpoint
 *
 * Call this function to continue execution of a Csound instance which is
 * stopped because a breakpoint has been reached. This function will continue
 * traversing the instrument chain from the instrument instance that
 * triggered the break.
 */
PUBLIC void csoundDebugContinue(CSOUND *csound);

/** Stop Csound rendering and enter the debugger
 *
 * Calling this function will enter the debugger at the soonest possible point
 * as if a breakpoint had been reached.
 */
PUBLIC void csoundDebugStop(CSOUND *csound);

/** Get a list of active instrument instances
 * Returns a linked list of allocated instrument instances
 * csoundDebugFreeInstrInstances() must be called on the list once it is no
 * longer needed.
 * This function is not thread safe and should only be called while the csound
 * engine is stopped at a breakpoint.
 */
PUBLIC debug_instr_t *csoundDebugGetInstrInstances(CSOUND *csound);

/** Free list created by csoundDebugGetCurrentInstrInstance() or
 * csoundDebugGetInstrInstances()
 */
PUBLIC void csoundDebugFreeInstrInstances(CSOUND *csound, debug_instr_t *instr);

/** Get list of variables for instrument */
PUBLIC debug_variable_t *csoundDebugGetVariables(CSOUND *csound,
                                                 debug_instr_t *instr);

/** Free variable list generated by csoundDebugGetVariables() */
PUBLIC void csoundDebugFreeVariables(CSOUND *csound,
                                     debug_variable_t *varHead);


/**  @} */

#ifdef __cplusplus
}
#endif

#endif
