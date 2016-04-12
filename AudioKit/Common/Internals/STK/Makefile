RM = /bin/rm
OBJECT_PATH = Release
LIBDIR = ${exec_prefix}/lib
INCLUDEDIR = ${prefix}/include
#vpath %.o $(OBJECT_PATH)

#OBJECTS	=	Stk.o Generator.o Noise.o Blit.o BlitSaw.o BlitSquare.o Granulate.o \
#					Envelope.o ADSR.o Asymp.o Modulate.o SineWave.o FileLoop.o SingWave.o \
#					FileRead.o FileWrite.o WvIn.o FileWvIn.o WvOut.o FileWvOut.o \
#					Filter.o Fir.o Iir.o OneZero.o OnePole.o PoleZero.o TwoZero.o TwoPole.o \
#					BiQuad.o FormSwep.o Delay.o DelayL.o DelayA.o \
#					\
#					Effect.o PRCRev.o JCRev.o NRev.o FreeVerb.o \
#					Chorus.o Echo.o PitShift.o LentPitShift.o \
#					Function.o ReedTable.o JetTable.o BowTable.o Cubic.o \
#					Voicer.o Vector3D.o Sphere.o Twang.o Guitar.o \
#					\
#					Instrmnt.o Clarinet.o BlowHole.o Saxofony.o Flute.o Brass.o BlowBotl.o \
#					Bowed.o Plucked.o StifKarp.o Sitar.o Mandolin.o Mesh2D.o \
#					FM.o Rhodey.o Wurley.o TubeBell.o HevyMetl.o PercFlut.o BeeThree.o FMVoices.o \
#					Sampler.o Moog.o Simple.o Drummer.o Shakers.o \
#					Modal.o ModalBar.o BandedWG.o Resonate.o VoicForm.o Phonemes.o Whistle.o \
#					\
#					Messager.o Skini.o MidiFileIn.o

OBJECTS	=	Stk.o Noise.o Blit.o BlitSaw.o BlitSquare.o Granulate.o \
					Envelope.o ADSR.o Asymp.o Modulate.o SineWave.o FileLoop.o SingWave.o \
					FileRead.o FileWrite.o FileWvIn.o FileWvOut.o \
					Fir.o Iir.o OneZero.o OnePole.o PoleZero.o TwoZero.o TwoPole.o \
					BiQuad.o FormSwep.o Delay.o DelayL.o DelayA.o \
					\
					PRCRev.o JCRev.o NRev.o FreeVerb.o \
					Chorus.o Echo.o PitShift.o LentPitShift.o \
					Voicer.o Sphere.o Twang.o Guitar.o \
					\
					Clarinet.o BlowHole.o Saxofony.o Flute.o Brass.o BlowBotl.o \
					Bowed.o Plucked.o StifKarp.o Sitar.o Mandolin.o Mesh2D.o \
					FM.o Rhodey.o Wurley.o TubeBell.o HevyMetl.o PercFlut.o BeeThree.o FMVoices.o \
					Sampler.o Moog.o Simple.o Drummer.o Shakers.o \
					Modal.o ModalBar.o BandedWG.o Resonate.o VoicForm.o Phonemes.o Whistle.o \
					\
					Messager.o Skini.o MidiFileIn.o

INCLUDE = -Iinclude

CC       = g++
DEFS     =  
DEFS    += -D__LITTLE_ENDIAN__
CFLAGS   = -O3 -Wall
CFLAGS  += $(INCLUDE) -fPIC
LIBS     = -lm 


RAWWAVES = rawwaves/
DEFS    += -DRAWWAVE_PATH=\"$(RAWWAVES)\"

%.o : %.cpp 
	$(CC) $(CFLAGS) $(DEFS) -c $(<) -o $@

all : $(OBJECTS)

$(OBJECT_PATH)/.placeholder:
	mkdir -vp $(OBJECT_PATH)
	touch $(OBJECT_PATH)/.placeholder


$(OBJECTS) : include/Stk.h 

sp_mandol: sp_mandol.cpp $(OBJECTS)
	g++ -o $@ $(CFLAGS) sp_mandol.cpp -lsoundpipe -lsndfile $(OBJECTS)

sp_modalbar: sp_modalbar.cpp $(OBJECTS)
	g++ -o $@ $(CFLAGS) sp_modalbar.cpp -lsoundpipe -lsndfile $(OBJECTS)

clean : 
	$(RM) -f $(OBJECT_PATH)/*.o
	$(RM) -f *~
	$(RM) -fR *.dSYM
	$(RM) -rf *.o
	$(RM) -rf sp_mandol sp_modalbar
