/*
    cfgvar.h:

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

#ifndef CSOUND_CFGVAR_H
#define CSOUND_CFGVAR_H

#ifdef __cplusplus
extern "C" {
#endif

/* generic header structure */

typedef struct csCfgVariableHead_s {
    union csCfgVariable_u *nxt;       /* pointer to next structure in chain */
    unsigned char   *name;            /* name of the variable               */
    void            *p;               /* pointer to value                   */
    int             type;             /* type (e.g. CSOUNDCFG_INTEGER)      */
    int             flags;            /* bitwise OR of flags                */
    unsigned char   *shortDesc;       /* short description (NULL if none)   */
    unsigned char   *longDesc;        /* long description (NULL if none)    */
} csCfgVariableHead_t;

/* int type */

typedef struct csCfgVariableInt_s {
    union csCfgVariable_u *nxt;       /* pointer to next structure in chain */
    unsigned char   *name;            /* name of the variable               */
    int             *p;               /* pointer to value                   */
    int             type;             /* type (CSOUNDCFG_INTEGER)           */
    int             flags;            /* bitwise OR of flags                */
    unsigned char   *shortDesc;       /* short description (NULL if none)   */
    unsigned char   *longDesc;        /* long description (NULL if none)    */
    int             min;              /* minimum allowed value              */
    int             max;              /* maximum allowed value              */
} csCfgVariableInt_t;

/* boolean type (int with a value of 0 or 1) */

typedef struct csCfgVariableBoolean_s {
    union csCfgVariable_u *nxt;       /* pointer to next structure in chain */
    unsigned char   *name;            /* name of the variable               */
    int             *p;               /* pointer to value                   */
    int             type;             /* type (CSOUNDCFG_BOOLEAN)           */
    int             flags;            /* bitwise OR of flags                */
    unsigned char   *shortDesc;       /* short description (NULL if none)   */
    unsigned char   *longDesc;        /* long description (NULL if none)    */
} csCfgVariableBoolean_t;

/* float type */

typedef struct csCfgVariableFloat_s {
    union csCfgVariable_u *nxt;       /* pointer to next structure in chain */
    unsigned char   *name;            /* name of the variable               */
    float           *p;               /* pointer to value                   */
    int             type;             /* type (CSOUNDCFG_FLOAT)             */
    int             flags;            /* bitwise OR of flags                */
    unsigned char   *shortDesc;       /* short description (NULL if none)   */
    unsigned char   *longDesc;        /* long description (NULL if none)    */
    float           min;              /* minimum allowed value              */
    float           max;              /* maximum allowed value              */
} csCfgVariableFloat_t;

/* double type */

typedef struct csCfgVariableDouble_s {
    union csCfgVariable_u *nxt;       /* pointer to next structure in chain */
    unsigned char   *name;            /* name of the variable               */
    double          *p;               /* pointer to value                   */
    int             type;             /* type (CSOUNDCFG_DOUBLE)            */
    int             flags;            /* bitwise OR of flags                */
    unsigned char   *shortDesc;       /* short description (NULL if none)   */
    unsigned char   *longDesc;        /* long description (NULL if none)    */
    double          min;              /* minimum allowed value              */
    double          max;              /* maximum allowed value              */
} csCfgVariableDouble_t;

/* MYFLT (float or double) type */

typedef struct csCfgVariableMYFLT_s {
    union csCfgVariable_u *nxt;       /* pointer to next structure in chain */
    unsigned char   *name;            /* name of the variable               */
    MYFLT           *p;               /* pointer to value                   */
    int             type;             /* type (CSOUNDCFG_MYFLT)             */
    int             flags;            /* bitwise OR of flags                */
    unsigned char   *shortDesc;       /* short description (NULL if none)   */
    unsigned char   *longDesc;        /* long description (NULL if none)    */
    MYFLT           min;              /* minimum allowed value              */
    MYFLT           max;              /* maximum allowed value              */
} csCfgVariableMYFLT_t;

/* string type */

typedef struct csCfgVariableString_s {
    union csCfgVariable_u *nxt;       /* pointer to next structure in chain */
    unsigned char   *name;            /* name of the variable               */
    char            *p;               /* value: array of 'maxlen' chars     */
    int             type;             /* type (CSOUNDCFG_STRING)            */
    int             flags;            /* bitwise OR of flags                */
    unsigned char   *shortDesc;       /* short description (NULL if none)   */
    unsigned char   *longDesc;        /* long description (NULL if none)    */
    int             maxlen;           /* maximum length + 1                 */
} csCfgVariableString_t;

/* union of all variable types */

typedef union csCfgVariable_u {
  csCfgVariableHead_t       h;
  csCfgVariableInt_t        i;
  csCfgVariableBoolean_t    b;
  csCfgVariableFloat_t      f;
  csCfgVariableDouble_t     d;
  csCfgVariableMYFLT_t      m;
  csCfgVariableString_t     s;
} csCfgVariable_t;

/* types */

#define CSOUNDCFG_INTEGER   1
#define CSOUNDCFG_BOOLEAN   2
#define CSOUNDCFG_FLOAT     3
#define CSOUNDCFG_DOUBLE    4
#define CSOUNDCFG_MYFLT     5
#define CSOUNDCFG_STRING    6

/* flags */

#define CSOUNDCFG_POWOFTWO  0x00000001

/* error codes */

#define CSOUNDCFG_SUCCESS           0
#define CSOUNDCFG_INVALID_NAME      -1
#define CSOUNDCFG_INVALID_TYPE      -2
#define CSOUNDCFG_INVALID_FLAG      -3
#define CSOUNDCFG_NULL_POINTER      -4
#define CSOUNDCFG_TOO_HIGH          -5
#define CSOUNDCFG_TOO_LOW           -6
#define CSOUNDCFG_NOT_POWOFTWO      -7
#define CSOUNDCFG_INVALID_BOOLEAN   -8
#define CSOUNDCFG_MEMORY            -9
#define CSOUNDCFG_STRING_LENGTH     -10

#define CSOUNDCFG_LASTERROR         -10

/* -------- interface functions -------- */

/* This pragma must come before all public function declarations */
#if (defined(macintosh) && defined(__MWERKS__))
#  pragma export on
#endif

  /**
   * Create global configuration variable with the specified parameters.
   * This function should be called by the host application only.
   *   name:    name of the variable (may contain letters, digits, and _)
   *   p:       pointer to variable
   *   type:    type of variable, determines how 'p' is interpreted
   *              CSOUNDCFG_INTEGER:      int*
   *              CSOUNDCFG_BOOLEAN:      int* (value may be 0 or 1)
   *              CSOUNDCFG_FLOAT:        float*
   *              CSOUNDCFG_DOUBLE:       double*
   *              CSOUNDCFG_MYFLT:        MYFLT*
   *              CSOUNDCFG_STRING:       char* (should have enough space)
   *   flags:   bitwise OR of flag values, currently only CSOUNDCFG_POWOFTWO
   *            is available, which requests CSOUNDCFG_INTEGER values to be
   *            power of two
   *   min:     for CSOUNDCFG_INTEGER, CSOUNDCFG_FLOAT, CSOUNDCFG_DOUBLE, and
   *            CSOUNDCFG_MYFLT, a pointer to a variable of the type selected
   *            by 'type' that specifies the minimum allowed value.
   *            If 'min' is NULL, there is no minimum value.
   *   max:     similar to 'min', except it sets the maximum allowed value.
   *            For CSOUNDCFG_STRING, it is a pointer to an int variable
   *            that defines the maximum length of the string (including the
   *            null character at the end) in bytes. This value is limited
   *            to the range 8 to 16384, and if max is NULL, it defaults to 256.
   *   shortDesc: a short description of the variable (may be NULL or an empty
   *            string if a description is not available)
   *   longDesc: a long description of the variable (may be NULL or an empty
   *            string if a description is not available)
   * Return value is CSOUNDCFG_SUCCESS, or one of the following error codes:
   *   CSOUNDCFG_INVALID_NAME
   *            the specified name is invalid or is already in use
   *   CSOUNDCFG_MEMORY
   *            a memory allocation failure occured
   *   CSOUNDCFG_NULL_POINTER
   *            the 'p' pointer was NULL
   *   CSOUNDCFG_INVALID_TYPE
   *   CSOUNDCFG_INVALID_FLAG
   *            an invalid variable type was specified, or the flags value
   *            had unknown bits set
   */
#if 0
  PUBLIC int
    csoundCreateGlobalConfigurationVariable(const char *name,
                                            void *p, int type, int flags,
                                            void *min, void *max,
                                            const char *shortDesc,
                                            const char *longDesc);
#endif

  /**
   * This function is similar to csoundCreateGlobalConfigurationVariable(),
   * except it creates a configuration variable specific to Csound instance
   * 'csound', and is suitable for calling from the Csound library
   * (in csoundPreCompile()) or plugins (in csoundModuleCreate()).
   * The other parameters and return value are the same as in the case of
   * csoundCreateGlobalConfigurationVariable().
   */
  PUBLIC int
    csoundCreateConfigurationVariable(CSOUND *csound, const char *name,
                                      void *p, int type, int flags,
                                      void *min, void *max,
                                      const char *shortDesc,
                                      const char *longDesc);

  /**
   * Copy a global configuration variable to a Csound instance.
   * This function is experimental and may be subject to changes in
   * future releases of the Csound library.
   */
#if 0
  PUBLIC int csoundCopyGlobalConfigurationVariable(CSOUND *csound,
                                                   const char *name, void *p);
#endif

  /**
   * Copy all global configuration variables to the specified Csound instance.
   * This function is experimental and may be subject to changes in
   * future releases of the Csound library.
   */
#if 0
  PUBLIC int csoundCopyGlobalConfigurationVariables(CSOUND *csound);
#endif

  /**
   * Set the value of a global configuration variable; should be called by the
   * host application only.
   * 'value' is a pointer of the same type as the 'p' pointer that was passed
   * to csoundCreateGlobalConfigurationVariable(), depending on the type of
   * the variable (integer, float, etc.).
   * Return value is CSOUNDCFG_SUCCESS in case of success, or one of the
   * following error codes:
   *   CSOUNDCFG_INVALID_NAME
   *            no configuration variable was found with the specified name
   *   CSOUNDCFG_NULL_POINTER
   *            the 'value' pointer was NULL
   *   CSOUNDCFG_TOO_LOW
   *   CSOUNDCFG_TOO_HIGH
   *   CSOUNDCFG_NOT_POWOFTWO
   *   CSOUNDCFG_INVALID_BOOLEAN
   *   CSOUNDCFG_STRING_LENGTH
   *            the specified value was invalid in some way
   */
#if 0
  PUBLIC int csoundSetGlobalConfigurationVariable(const char *name,
                                                  void *value);
#endif

  /**
   * Set the value of a configuration variable of Csound instance 'csound'.
   * The 'name' and 'value' parameters, and return value are the same as
   * in the case of csoundSetGlobalConfigurationVariable().
   */
  PUBLIC int csoundSetConfigurationVariable(CSOUND *csound, const char *name,
                                                            void *value);

  /**
   * Set the value of a global configuration variable, by parsing a string;
   * should be called by the host application only.
   * For boolean variables, any of the strings "0", "no", "off", and "false"
   * will set the value to 0, and any of "1", "yes", "on", and "true" means a
   * value of 1.
   * Return value is CSOUNDCFG_SUCCESS in case of success, or one of the
   * following error codes:
   *   CSOUNDCFG_INVALID_NAME
   *            no configuration variable was found with the specified name
   *   CSOUNDCFG_NULL_POINTER
   *            the 'value' pointer was NULL
   *   CSOUNDCFG_TOO_LOW
   *   CSOUNDCFG_TOO_HIGH
   *   CSOUNDCFG_NOT_POWOFTWO
   *   CSOUNDCFG_INVALID_BOOLEAN
   *   CSOUNDCFG_STRING_LENGTH
   *            the specified value was invalid in some way
   */
#if 0
  PUBLIC int csoundParseGlobalConfigurationVariable(const char *name,
                                                    const char *value);
#endif

  /**
   * Set the value of a configuration variable of Csound instance 'csound',
   * by parsing a string.
   * The 'name' and 'value' parameters, and return value are the same as
   * in the case of csoundParseGlobalConfigurationVariable().
   */
  PUBLIC int csoundParseConfigurationVariable(CSOUND *csound, const char *name,
                                              const char *value);

  /**
   * Return pointer to the global configuration variable with the specified
   * name.
   * The return value may be NULL if the variable is not found in the database.
   */
#if 0
  PUBLIC csCfgVariable_t
    *csoundQueryGlobalConfigurationVariable(const char *name);
#endif

  /**
   * Return pointer to the configuration variable of Csound instace 'csound'
   * with the specified name.
   * The return value may be NULL if the variable is not found in the database.
   */
  PUBLIC csCfgVariable_t
    *csoundQueryConfigurationVariable(CSOUND *csound, const char *name);

  /**
   * Create an alphabetically sorted list of all global configuration variables.
   * Returns a pointer to a NULL terminated array of configuration variable
   * pointers, or NULL on error.
   * The caller is responsible for freeing the returned list with
   * csoundDeleteCfgVarList(), however, the variable pointers in the list
   * should not be freed.
   */
#if 0
  PUBLIC csCfgVariable_t **csoundListGlobalConfigurationVariables(void);
#endif

  /**
   * Create an alphabetically sorted list of all configuration variables
   * of Csound instance 'csound'.
   * Returns a pointer to a NULL terminated array of configuration variable
   * pointers, or NULL on error.
   * The caller is responsible for freeing the returned list with
   * csoundDeleteCfgVarList(), however, the variable pointers in the list
   * should not be freed.
   */
  PUBLIC csCfgVariable_t **csoundListConfigurationVariables(CSOUND *csound);

  /**
   * Release a configuration variable list previously returned
   * by csoundListGlobalConfigurationVariables() or
   * csoundListConfigurationVariables().
   */
  PUBLIC void csoundDeleteCfgVarList(csCfgVariable_t **lst);

  /**
   * Remove the global configuration variable with the specified name
   * from the database. Should be called by the host application only,
   * and never by the Csound library or plugins.
   * Return value is CSOUNDCFG_SUCCESS in case of success, or
   * CSOUNDCFG_INVALID_NAME if the variable was not found.
   */
#if 0
  PUBLIC int csoundDeleteGlobalConfigurationVariable(const char *name);
#endif

  /**
   * Remove the configuration variable of Csound instance 'csound' with the
   * specified name from the database. Plugins need not call this, as all
   * configuration variables are automatically deleted by csoundReset().
   * Return value is CSOUNDCFG_SUCCESS in case of success, or
   * CSOUNDCFG_INVALID_NAME if the variable was not found.
   */
  PUBLIC int csoundDeleteConfigurationVariable(CSOUND *csound,
                                               const char *name);

  /**
   * Remove all global configuration variables and free database.
   * Should be called by the host application only, and never by the
   * Csound library or plugins.
   * Return value is CSOUNDCFG_SUCCESS in case of success.
   */
#if 0
  PUBLIC int csoundDeleteAllGlobalConfigurationVariables(void);
#endif

  /**
   * Returns pointer to an error string constant for the specified
   * CSOUNDCFG error code. The string is not translated.
   */
  PUBLIC const char *csoundCfgErrorCodeToString(int errcode);

/* This pragma must come after all public function declarations */
#if (defined(macintosh) && defined(__MWERKS__))
#  pragma export off
#endif

#ifdef __cplusplus
}
#endif

#endif  /* CSOUND_CFGVAR_H */

