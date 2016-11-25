/**********************************************/
/**    Utility to make various flavors of    **/
/**    sine wave (rectified, etc), and       **/
/**    other commonly needed waveforms, like **/
/**    triangles, ramps, etc.                **/
/**    The files generated are all 16 bit    **/
/**    linear signed integer, of length      **/
/**    as defined by LENGTH below            **/
/**********************************************/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define LENGTH 256
#define PI 3.14159265358979323846

void main()
{
  int i,j;
  double temp;
  short data[LENGTH + 2];
  FILE *fd;

  ///////////  Yer Basic TX81Z Waves, Including Sine ///////////  
  fd = fopen("halfwave.raw","wb");
  for (i=0;i<LENGTH/2;i++)
    data[i] = 32767 * sin(i * 2 * PI / (double) LENGTH);
  for (i=LENGTH/2;i<LENGTH;i++) 
    data[i] = 0;
  fwrite(&data,2,LENGTH,fd);
  fclose(fd);
    
  fd = fopen("sinewave.raw","wb");
  for (i=LENGTH/2;i<LENGTH;i++)
    data[i] = 32767 * sin(i * 2 * PI / (double) LENGTH);
  fwrite(&data,2,LENGTH,fd);
  fclose(fd);
    
  fd = fopen("sineblnk.raw","wb");
  for (i=0;i<LENGTH/2;i++)
    data[i] = data[2*i];
  for (i=LENGTH/2;i<LENGTH;i++) 
    data[i] = 0;
  fwrite(&data,2,LENGTH,fd);
  fclose(fd);
    
  fd = fopen("fwavblnk.raw","wb");
  for (i=0;i<LENGTH/4;i++)
    data[i+LENGTH/4] = data[i];
  fwrite(&data,2,LENGTH,fd);
  fclose(fd);
    
  fd = fopen("snglpeak.raw","wb");
  for (i=0;i<=LENGTH/4;i++)
    data[i] = 32767 * (1.0 - cos(i * 2 * PI / (double) LENGTH));
  for (i=0;i<=LENGTH/4;i++)
    data[LENGTH/2-i] = data[i];
  for (i=LENGTH/2;i<LENGTH;i++) 
    data[i] = 0;
  fwrite(&data,2,LENGTH,fd);
  fclose(fd);
    
  fd = fopen("twopeaks.raw","wb");
  for (i=0;i<=LENGTH/2;i++)    {
    data[LENGTH/2+i] = -data[i];
  }
  fwrite(&data,2,LENGTH,fd);
  fclose(fd);
    
  fd = fopen("peksblnk.raw","wb");
  for (i=0;i<=LENGTH/2;i++)
    data[i] = data[i*2];
  for (i=LENGTH/2;i<LENGTH;i++) 
    data[i] = 0;
  fwrite(&data,2,LENGTH,fd);
  fclose(fd);
    
  fd = fopen("ppksblnk.raw","wb");
  for (i=0;i<=LENGTH/4;i++)
    data[i+LENGTH/4] = data[i]; 
  fwrite(&data,2,LENGTH,fd);
  fclose(fd);

  ///////////  Impulses of various bandwidth  ///////////  
  fd = fopen("impuls10.raw","wb");
  for (i=0;i<LENGTH;i++)      {
    temp = 0.0;
    for (j=1;j<=10;j++)
      temp += cos(i * j * 2 * PI / (double) LENGTH);
    data[i] = 32767 / 10.0 * temp;
  }
  fwrite(&data,2,LENGTH,fd);
  fclose(fd);
    
  fd = fopen("impuls20.raw","wb");
  for (i=0;i<LENGTH;i++)      {
    temp = 0.0;
    for (j=1;j<=20;j++)
      temp += cos(i * j * 2 * PI / (double) LENGTH);
    data[i] = 32767 / 20.0 * temp;
  }
  fwrite(&data,2,LENGTH,fd);
  fclose(fd);
    
  fd = fopen("impuls40.raw","wb");
  for (i=0;i<LENGTH;i++)      {
    temp = 0.0;
    for (j=1;j<=40;j++)
      temp += cos(i * j * 2 * PI / (double) LENGTH);
    data[i] = 32767 / 40.0 * temp;
  }
  fwrite(&data,2,LENGTH,fd);
  fclose(fd);

}
