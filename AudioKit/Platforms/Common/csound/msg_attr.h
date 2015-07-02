/*
    msg_attr.h:

    Copyright (C) 2005 Istvan Varga

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

#ifndef CSOUND_MSG_ATTR_H
#define CSOUND_MSG_ATTR_H

/* message types (only one can be specified) */

/* standard message */
#define CSOUNDMSG_DEFAULT       (0x0000)
/* error message (initerror, perferror, etc.) */
#define CSOUNDMSG_ERROR         (0x1000)
/* orchestra opcodes (e.g. printks) */
#define CSOUNDMSG_ORCH          (0x2000)
/* for progress display and heartbeat characters */
#define CSOUNDMSG_REALTIME      (0x3000)
/* warning messages */
#define CSOUNDMSG_WARNING       (0x4000)
/* API response messages, intended to be parsed by code */
#define CSOUNDMSG_API_RESP      (0x5000)

/* format attributes (colors etc.), use the bitwise OR of any of these: */

#define CSOUNDMSG_FG_BLACK      (0x0100)
#define CSOUNDMSG_FG_RED        (0x0101)
#define CSOUNDMSG_FG_GREEN      (0x0102)
#define CSOUNDMSG_FG_YELLOW     (0x0103)
#define CSOUNDMSG_FG_BLUE       (0x0104)
#define CSOUNDMSG_FG_MAGENTA    (0x0105)
#define CSOUNDMSG_FG_CYAN       (0x0106)
#define CSOUNDMSG_FG_WHITE      (0x0107)

#define CSOUNDMSG_FG_BOLD       (0x0008)
#define CSOUNDMSG_FG_UNDERLINE  (0x0080)

#define CSOUNDMSG_BG_BLACK      (0x0200)
#define CSOUNDMSG_BG_RED        (0x0210)
#define CSOUNDMSG_BG_GREEN      (0x0220)
#define CSOUNDMSG_BG_ORANGE     (0x0230)
#define CSOUNDMSG_BG_BLUE       (0x0240)
#define CSOUNDMSG_BG_MAGENTA    (0x0250)
#define CSOUNDMSG_BG_CYAN       (0x0260)
#define CSOUNDMSG_BG_GREY       (0x0270)

 /* ------------------------------------------------------------------------ */

#define CSOUNDMSG_TYPE_MASK     (0x7000)
#define CSOUNDMSG_FG_COLOR_MASK (0x0107)
#define CSOUNDMSG_FG_ATTR_MASK  (0x0088)
#define CSOUNDMSG_BG_COLOR_MASK (0x0270)

#endif      /* CSOUND_MSG_ATTR_H */

