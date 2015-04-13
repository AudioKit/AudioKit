/*
 * C S O U N D
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
#ifndef CSND_CPPSOUND_H
#define CSND_CPPSOUND_H

#include "float-version.h"
#ifndef __MYFLT_DEF
#define __MYFLT_DEF
#ifdef USE_DOUBLE
#define MYFLT double
#else
#define MYFLT float
#endif
#endif

#ifdef SWIG
%module csnd6
%include "std_string.i"
%include "std_vector.i"
%apply std::vector<double> *INPUT { std::vector<double> const & };
%{
#include "csound.hpp"
#include "CsoundFile.hpp"
#include <string>
#include <vector>
  %}
%template(MyfltVector) std::vector<MYFLT>;
#else
#include "csound.hpp"
#include "CsoundFile.hpp"
#include <string>
#include <vector>
#endif

class PUBLIC CppSound : public Csound, public CsoundFile
{
  bool go;
  bool isCompiled;
  bool isPerforming;
  size_t spoutSize;
  std::string renderedSoundfile;
public:
  CppSound() : Csound(),
                       go(false),
                       isCompiled(false),
                       isPerforming(false),
                       spoutSize(0)
{

  //SetHostData((CSOUND *)0);

}

  virtual ~CppSound();
  virtual CSOUND *getCsound();
  virtual long getThis();
  virtual CsoundFile *getCsoundFile();
  virtual int compile(int argc, char **argv);
  virtual int compile();
  virtual size_t getSpoutSize() const;
  virtual std::string getOutputSoundfileName() const;
  virtual int perform(int argc, char **argv);
  virtual int perform();
  virtual int performKsmps();
  virtual void cleanup();
  virtual void inputMessage(const char *istatement);
  virtual void write(const char *text);
  virtual bool getIsCompiled() const;
  virtual void setIsPerforming(bool isPerforming);
  virtual bool getIsPerforming() const;
  virtual bool getIsGo();
  virtual void stop();
};

#endif

