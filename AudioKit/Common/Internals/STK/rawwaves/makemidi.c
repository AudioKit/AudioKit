/**********************************************/
/**  Utility to make various functions       **/
/**  like exponential and log gain curves.   **/
/**  Specifically for direct MIDI parameter  **/           
/**  conversions.                            **/
/**  Included here:                          **/
/**  A440 Referenced Equal Tempered Pitches  **/
/**  as a function of MIDI note number.      **/
/**                                          **/
/**********************************************/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

void main()
{
  int i,j;
  double temp;
  double data[128];

  /********* Pitch as fn. of MIDI Note **********/    
    
  printf("double __MIDI_To_Pitch[128] = {");
  for (i=0;i<128;i++)  {
    if (i%8 == 0) printf("\n");
    temp = 220.0 * pow(2.0,((double) i - 57) / 12.0);
    printf("%.2lf,",temp);
  }
  printf("};\n");
  exit(1);
}

