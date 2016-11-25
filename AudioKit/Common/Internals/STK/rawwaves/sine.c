//    Utility to make a rawwave sine table (assumes big-endian machine).

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define LENGTH 1024
#define PI 3.14159265358979323846

void main()
{
  int i,j;
  double temp;
  short data[LENGTH + 2];
  FILE *fd;

  fd = fopen("sinewave.raw","wb");
  for (i=0; i<LENGTH; i++)
    data[i] = 32767 * sin(i * 2 * PI / (double) LENGTH);
  fwrite(&data,2,LENGTH,fd);
  fclose(fd);
}
