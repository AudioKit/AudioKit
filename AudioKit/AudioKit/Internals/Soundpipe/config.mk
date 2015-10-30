# Modules that don't require external libraries go here
MODULES=base \
        fold \
        ftbl \
        randmt \
        allpass \
        atone \
        butbr butbp buthp butlp \
        clip \
        comb \
        dcblock \
        decimator\
        delay \
        dist \
        eqfil \
        fofilt \
        fosc \
        jcrev \
        lpf18 \
        mode \
        moogladder \
        noise \
        osc \
        pareq \
        phasor \
        revsc \
        rms \
        scale \
        streson \
        tbvcf \
        tone \
        vdelay

# ini parser needed for nsmp module
include lib/inih/Makefile

# Header files needed for modules generated with FAUST
CFLAGS += -I lib/faust

# JACK module
#
#MODULES += jack
#CFLAGS += -ljack

# RPi Module
#
#MODULES += rpi
#CFLAGS += -lasound

# Padsynth module
#
#MODULES += fftwrapper
#MODULES += padsynth
#CFLAGS += -lfftw3

# If you are on OSX, you may need this
CFLAGS += -I /usr/local/include -L /usr/local/include  -I. -O3
