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
#ifndef CSOUNDFILE_H
#define CSOUNDFILE_H

#if 0
#undef MYFLT
#ifdef USE_DOUBLE
#define MYFLT double
#else
#define MYFLT float
#endif
#endif

#if defined(_MSC_VER) && !defined(__GNUC__)
#pragma warning(disable: 4786)
#endif
#ifdef SWIG
%module csnd6
%include "std_string.i"
%include "std_vector.i"
#if !defined(SWIGLUA)
%include "std_map.i"
%template(IntToStringMap) std::map<int, std::string>;
#endif
%{
#include <string>
#include <vector>
%}
#else
#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <fstream>
#include <sstream>
#include <stdlib.h>

#ifndef PUBLIC
#if (defined(WIN32) || defined(_WIN32)) && !defined(SWIG)
#  define PUBLIC        __declspec(dllexport)
#elif defined(__GNUC__) && (__GNUC__ >= 4) /* && !defined(__MACH__) */
#  define PUBLIC        __attribute__ ( (visibility("default")) )
#else
#  define PUBLIC
#endif
#endif

#if defined(WIN32)
#include <io.h>
#endif
#endif

void PUBLIC gatherArgs(int argc, const char **argv, std::string &commandLine);

void PUBLIC scatterArgs(const std::string commandLine, std::vector<std::string> &args, std::vector<char *> &argv);

std::string PUBLIC &trim(std::string &value);

std::string PUBLIC &trimQuotes(std::string &value);

/**
 *       Returns true if definition is a valid Csound instrument definition block.
 *       Also returns the part before the instr number, the instr number,
 *       the name (all text after the first comment on the same line as the instr number),
 *       and the part after the instr number, all by reference.
 */
bool PUBLIC parseInstrument(const std::string &definition, std::string &preNumber, std::string &id, std::string &name, std::string &postNumber);

/**
 * Manages a Csound Structured Data (CSD) file with facilities
 * for creating an arrangement of selected instruments in the orchestra,
 * and for programmatically building score files.
 */
class PUBLIC CsoundFile
{
protected:
  /**
   *       What are we storing, anyway?
   */
  std::string filename;
  /**
   *       CsOptions
   */
  std::string command;
  std::vector<std::string> args;
  std::vector<char *> argv;
  /**
   *       CsInstruments
   */
  std::string orchestra;
  /**
   *       CsScore
   */
  std::string score;
  /**
   *       CsMidi
   */
  std::vector<unsigned char> midifile;
public:
  /**
   *       Patch library and arrangement.
   */
  std::string libraryFilename;
  std::vector<std::string> arrangement;
  CsoundFile();
  virtual ~CsoundFile(){};
  virtual std::string generateFilename();
  virtual std::string getFilename() const;
  virtual void setFilename(std::string name);
  /**
   * Clears all contents of this,
   * then imports the indicated file,
   * which can be a Csound unified file (.csd),
   * Csound orchestra (.orc), Csound score (.sco),
   * standard MIDI file (.mid), or MusicXML v2 (.xml)
   * file.
   *
   * The MusicXML notes become instrument number + 1,
   * time in seconds, duration in seconds, MIDI key
   * number, and MIDI velocity number.
   */
  virtual int load(std::string filename);
  virtual int load(std::istream &stream);
  virtual int save(std::string filename) const;
  virtual int save(std::ostream &stream) const;
  /**
   * Imports the indicated file,
   * which can be a Csound unified file (.csd),
   * Csound orchestra (.orc), Csound score (.sco),
   * standard MIDI file (.mid), or MusicXML v2 (.xml)
   * file. The data that is read replaces existing
   * data of that type, but leaves other types of data
   * untouched.
   *
   * The MusicXML notes become instrument number + 1,
   * time in seconds, duration in seconds, MIDI key
   * number, and MIDI velocity number.
   */
  virtual int importFile(std::string filename);
  virtual int importFile(std::istream &stream);
  virtual int importCommand(std::istream &stream);
  virtual int exportCommand(std::ostream &stream) const;
  virtual int importOrchestra(std::istream &stream);
  virtual int exportOrchestra(std::ostream &stream) const;
  virtual int importScore(std::istream &stream);
  virtual int exportScore(std::ostream &stream) const;
  virtual int importArrangement(std::istream &stream);
  virtual int exportArrangement(std::ostream &stream) const;
  virtual int exportArrangementForPerformance(std::string filename) const;
  virtual int exportArrangementForPerformance(std::ostream &stream) const;
  virtual int importMidifile(std::istream &stream);
  virtual int exportMidifile(std::ostream &stream) const;
  virtual std::string getCommand() const;
  virtual void setCommand(std::string commandLine);
  virtual std::string getOrcFilename() const;
  virtual std::string getScoFilename() const;
  virtual std::string getMidiFilename() const;
  virtual std::string getOutputSoundfileName() const;
  virtual std::string getOrchestra() const;
  virtual void setOrchestra(std::string orchestra);
  virtual int getInstrumentCount() const;
  virtual std::string getOrchestraHeader() const;
  virtual bool getInstrument(int number, std::string &definition) const;
  //virtual bool getInstrumentNumber(int index, std::string &definition) const;
  virtual bool getInstrument(std::string name, std::string &definition) const;
  virtual std::string getInstrument(std::string name) const;
  virtual std::string getInstrument(int number) const;
  virtual std::string getInstrumentBody(std::string name) const;
  virtual std::string getInstrumentBody(int number) const;
  virtual std::map<int, std::string> getInstrumentNames() const;
  virtual double getInstrumentNumber(std::string name) const;
  virtual std::string getScore() const;
  virtual void setScore(std::string score);
  virtual int getArrangementCount() const;
  virtual std::string getArrangement(int index) const;
  virtual void addArrangement(std::string instrument);
  virtual void setArrangement(int index, std::string instrument);
  virtual void insertArrangement(int index, std::string instrument);
  virtual void removeArrangement(int index);
  virtual void setCSD(std::string xml);
  virtual std::string getCSD() const;
  virtual void addScoreLine(const std::string line);
  virtual void addNote(double p1, double p2, double p3, double p4, double p5, double p6, double p7, double p8, double p9, double p10, double p11);
  virtual void addNote(double p1, double p2, double p3, double p4, double p5, double p6, double p7, double p8, double p9, double p10);
  virtual void addNote(double p1, double p2, double p3, double p4, double p5, double p6, double p7, double p8, double p9);
  virtual void addNote(double p1, double p2, double p3, double p4, double p5, double p6, double p7, double p8);
  virtual void addNote(double p1, double p2, double p3, double p4, double p5, double p6, double p7);
  virtual void addNote(double p1, double p2, double p3, double p4, double p5, double p6);
  virtual void addNote(double p1, double p2, double p3, double p4, double p5);
  virtual void addNote(double p1, double p2, double p3, double p4);
  virtual void addNote(double p1, double p2, double p3);
  virtual bool exportForPerformance() const;
  virtual void removeAll();
  virtual void removeCommand();
  virtual void removeOrchestra();
  virtual void removeScore();
  virtual void removeArrangement();
  virtual void removeMidifile();
  //virtual void getInstrumentNames(std::vector<std::string> &names) const;
  virtual bool loadOrcLibrary(const char *filename = 0);
};

#endif   //     CSOUND_FILE_H

