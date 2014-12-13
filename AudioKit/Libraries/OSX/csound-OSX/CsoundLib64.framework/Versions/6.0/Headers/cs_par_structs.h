/*
    cs_par_structs.h:

    Copyright (C) 2011 John ffitch and Chris Wilson
                  2013 John ffitch and Martin Brain

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

#ifndef __CS_PAR_DISPATCH_H
#define __CS_PAR_DISPATCH_H

/* global variables lock support */
struct global_var_lock_t;

struct instr_semantics_t;

/* New model */

typedef int taskID;

/* Each task has a status */
enum state { WAITING = 3,          /* Dependencies have not been finished */
             AVAILABLE = 2,        /* Dependencies met, ready to be run */
             INPROGRESS = 1,       /* Has been started */
             DONE = 0 };           /* Has been completed */

/* Sets of prerequiste tasks for each task */
typedef struct _watchList {
  taskID id;
  struct _watchList *next;
} watchList;

#endif
