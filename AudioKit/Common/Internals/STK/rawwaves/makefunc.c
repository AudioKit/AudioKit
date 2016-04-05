/**********************************************/
/**  Utility to make various functions       **/
/**  like exponential and log gain curves.   **/
/**                                          **/
/**  Included here:                          **/
/**  Yamaha TX81Z curves for master gain,    **/
/**  Envelope Rates (in normalized units),   **/
/**  envelope sustain level, and more....    **/
/**********************************************/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

void main()
{
  int i,j;
  double temp;
  double data[128];

  /*************** TX81Z Master Gain *************/    
  for (i=0;i<100;i++)   {
    data[i] = pow(2.0,-(99-i)/10.0);
  }
  data[0] = 0.0;
  printf("double __FM4Op_gains[99] = {");
  for (i=0;i<100;i++)  {
    if (i%8 == 0) printf("\n");
    printf("%lf,",data[i]);
  }
  printf("};\n");
  /*************** TX81Z Sustain Level ***********/    
  for (i=0;i<16;i++)   {
    data[i] = pow(2.0,-(15-i)/2.0);
  }
  data[0] = 0.0;
  printf("double __FM4Op_susLevels[16] = {");
  for (i=0;i<16;i++)  {
    if (i%8 == 0) printf("\n");
    printf("%lf,",data[i]);
  }
  printf("};\n");
  /******************  Attack Rate ***************/    
  for (i=0;i<32;i++)   {
    data[i] = 6.0 * pow(5.7,-(i-1)/5.0);
  }
  printf("double __FM4Op_attTimes[16] = {");
  for (i=0;i<32;i++)  {
    if (i%8 == 0) printf("\n");
    printf("%lf,",data[i]);
  }
  printf("};\n");
  exit(1);
}

