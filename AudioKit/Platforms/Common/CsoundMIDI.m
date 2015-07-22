/* 
 
 CsoundMIDI.m:
 
 Copyright (C) 2011 Steven Yi, Victor Lazzarini
 
 This file is part of Csound for iOS.
 
 The Csound for iOS Library is free software; you can redistribute it
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

#import "CsoundMIDI.h"
#include <stdio.h>
#include <CoreMidi/CoreMidi.h>
#include <time.h>
#include <stdlib.h>

void ReadProc(const MIDIPacketList *pktlist, void *refcon, void *srcConnRefCon);

@implementation CsoundMIDI

/*=============================================*/
/* start coremidi - csound code                */

/* MIDI message queue size */
#define DSIZE 1024


/* MIDI data struct */
typedef struct {
    Byte status;
    Byte data1;
    Byte data2;
    Byte flag;
} MIDIdata;

/* user data for MIDI callbacks */
typedef struct _cdata {
    MIDIdata *mdata;
    int p, q, pnot, pchn;
    MIDIClientRef mclient;
} cdata;

/* coremidi callback, called when MIDI data is available */
void ReadProc(const MIDIPacketList *pktlist, void *refcon, void *srcConnRefCon){
    cdata *data = (cdata *)refcon;  
	MIDIdata *mdata = data->mdata; 
	int *p = &data->p, i, j;
	MIDIPacket *packet = &((MIDIPacketList *)pktlist)->packet[0];
	Byte *curpack;
	
	for (i = 0; i < pktlist->numPackets; i++) {
		//printf("len %d \n", packet->length);
		for(j=0; j < packet->length; j+=3){
			while(mdata[*p].flag);  /* in case data was not read, spin */
			curpack = packet->data+j;
			memcpy(&mdata[*p], curpack, 3);
			mdata[*p].flag = 1;
			(*p)++;
			if(*p == DSIZE) *p = 0;
		}
		packet = MIDIPacketNext(packet);
	} 

}

/* csound MIDI input open callback, sets the device for input */ 
static int MidiInDeviceOpen(CSOUND *csound, void **userData, const char *dev)
{
    int k;
    ItemCount endpoints;
        
    CFStringRef name = NULL, cname = NULL, pname = NULL;
    CFStringEncoding defaultEncoding = CFStringGetSystemEncoding();
    MIDIClientRef mclient = 0;
    MIDIPortRef mport = 0;
    MIDIEndpointRef endpoint;
    MIDIdata *mdata = (MIDIdata *) malloc(DSIZE*sizeof(MIDIdata));
    OSStatus ret;
    cdata *refcon = (cdata *) malloc(sizeof(cdata));
    memset(mdata, 0, sizeof(MIDIdata)*DSIZE);
    refcon->mdata = mdata;
    refcon->p = 0;
    refcon->q = 0;
	refcon->pnot = refcon->pchn = 0;
	
    /* MIDI client */
    cname = CFStringCreateWithCString(NULL, "my client", defaultEncoding);
    ret = MIDIClientCreate(cname, NULL, NULL, &mclient);
    if(!ret){
        /* MIDI output port */
        pname = CFStringCreateWithCString(NULL, "outport", defaultEncoding);
        ret = MIDIInputPortCreate(mclient, pname, ReadProc, refcon, &mport);
        if(!ret){
            /* sources, we connect to all available input sources */
            endpoints = MIDIGetNumberOfSources();
			csoundMessage(csound, "midi srcs %lu\n", endpoints); 
            for(k=0; k < endpoints; k++){
                endpoint = MIDIGetSource(k);
                MIDIPortConnectSource(mport, endpoint, NULL);
                
            }
        }
    }
    refcon->mclient = mclient;
    *userData = (void*) refcon;
    if(name) CFRelease(name);
    if(pname) CFRelease(pname);
    if(cname) CFRelease(cname); 
    /* report success */
    return 0;
}

/* used to distinguish between 1 and 2-byte messages */
static  const   int     datbyts[8] = { 2, 2, 2, 2, 1, 1, 2, 0 };

/* csound MIDI read callback, called every k-cycle */
static int MidiDataRead(CSOUND *csound, void *userData,
                        unsigned char *mbuf, int nbytes)
{
    cdata * data = (cdata *)userData;
    if(data == NULL) return 0;
    
    MIDIdata *mdata = data->mdata;
    int *q = &data->q, st, d1, d2, n = 0;
    
    /* check if there is new data on circular queue */
    while (mdata[*q].flag) {
        st = (int) mdata[*q].status;
        d1 = (int) mdata[*q].data1;
        d2 = (int) mdata[*q].data2;
        
        if (st < 0x80)
            goto next;
        
        if (st >= 0xF0 &&
            !(st == 0xF8 || st == 0xFA || st == 0xFB ||
              st == 0xFC || st == 0xFF))
            goto next;
        nbytes -= (datbyts[(st - 0x80) >> 4] + 1);
        if (nbytes < 0) break;
        
        /* write to csound midi buffer */
        n += (datbyts[(st - 0x80) >> 4] + 1);
        switch (datbyts[(st - 0x80) >> 4]) {
            case 0:
                *mbuf++ = (unsigned char) st;
                break;
            case 1:
                *mbuf++ = (unsigned char) st;
                *mbuf++ = (unsigned char) d1;
                break;
            case 2:
                *mbuf++ = (unsigned char) st;
                *mbuf++ = (unsigned char) d1;
                *mbuf++ = (unsigned char) d2;
                break;
        } 
	next:
        mdata[*q].flag = 0;
        (*q)++;
        if(*q==DSIZE) *q = 0;
    }
    
    /* return the number of bytes read */
    return n;
}

/* csound close device callback */
static int MidiInDeviceClose(CSOUND *csound, void *userData)
{
    cdata * data = (cdata *)userData;
    if (data != NULL) {
        MIDIClientDispose(data->mclient);
        free(data->mdata);
        free(data);
    }
    return 0;
}

/* callback setting code */
+(void)setMidiInCallbacks:(CSOUND *)csound {
    csoundSetHostImplementedMIDIIO(csound, 1);
    csoundSetExternalMidiInOpenCallback(csound, MidiInDeviceOpen);
    csoundSetExternalMidiReadCallback(csound, MidiDataRead);
    csoundSetExternalMidiInCloseCallback(csound, MidiInDeviceClose);
}

@end
