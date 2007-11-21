/*
  image.c

  convert xpm image to linux_logo.h format

*/

#include <stdio.h>

#include XPM_IMAGE".xpm"


#define  MAX_COLORS  214
#define  EOS         '\0'


int main( void )
{
   
   int width;
   int height;
   int chars_per_pixel;
   int num_colors;

   char   * current_line;
   int      loop;
   int      vertical;
   int      horizontal;
   int      carriage_return;
   char     red[ MAX_COLORS ][ 3 ];
   char     green[ MAX_COLORS ][ 3 ];
   char     blue[ MAX_COLORS ][ 3 ];


   sscanf( XPM_NAME[ 0 ], "%d %d %d %d", 
           &width, &height, &num_colors, &chars_per_pixel );

   if( num_colors > MAX_COLORS )
   {
      printf( "Only %d colors are supported -- exit\n", MAX_COLORS );
      exit( -1 );
   }
   else
   {
      /* the color maps are assigned */
      for( loop=0; loop<num_colors; loop++ )
      {
          current_line = XPM_NAME[ 1 + loop ];
          current_line = current_line + 4 + chars_per_pixel;
          red[ loop ][ 0 ] = current_line[ 0 ];
          red[ loop ][ 1 ] = current_line[ 1 ];
          red[ loop ][ 2 ] = EOS;
          green[ loop ][ 0 ] = current_line[ 2 ];
          green[ loop ][ 1 ] = current_line[ 3 ];
          green[ loop ][ 2 ] = EOS;
          blue[ loop ][ 0 ] = current_line[ 4 ];
          blue[ loop ][ 1 ] = current_line[ 5 ];
          blue[ loop ][ 2 ] = EOS;
      }
      for( ; loop<MAX_COLORS; loop++ )
      {
          red[ loop ][ 0 ] = 'F';
          red[ loop ][ 1 ] = 'F';
          red[ loop ][ 2 ] = EOS;
          green[ loop ][ 0 ] = 'F';
          green[ loop ][ 1 ] = 'F';
          green[ loop ][ 2 ] = EOS;
          blue[ loop ][ 0 ] = 'F';
          blue[ loop ][ 1 ] = 'F';
          blue[ loop ][ 2 ] = EOS;
      }

      printf( "unsigned char linux_logo_red[] __initdata = {\n   " );
      for( loop=0; loop<MAX_COLORS-1; loop++ )
      {
         printf( "0x%s, ", red[ loop ] );
         if( ( loop % 8 ) == 7 ) printf( "\n   " );
      }
      printf( "0x%s\n};\n\n", red[ loop ] );

      printf( "unsigned char linux_logo_green[] __initdata = {\n   " );
      for( loop=0; loop<MAX_COLORS-1; loop++ )
      {
         printf( "0x%s, ", green[ loop ] );
         if( ( loop % 8 ) == 7 ) printf( "\n   " );
      }
      printf( "0x%s\n};\n\n", green[ loop ] );

      printf( "unsigned char linux_logo_blue[] __initdata = {\n   " );
      for( loop=0; loop<MAX_COLORS-1; loop++ )
      {
         printf( "0x%s, ", blue[ loop ] );
         if( ( loop % 8 ) == 7 ) printf( "\n   " );
      }
      printf( "0x%s\n};\n\n", blue[ loop ] );



      /* and now the image is defined */
      printf( "unsigned char linux_logo[] __initdata = {\n   " );
      carriage_return = 0;
      for( vertical=0; vertical<height; vertical++ )
      {
          current_line = XPM_NAME[ 1 + num_colors + vertical ];
          
          for( horizontal=0; horizontal<width; horizontal++ )
          {
              for( loop=0; loop<num_colors; loop++ )
              {
                  if( strncmp( current_line, XPM_NAME[ 1 + loop ], 2 ) == 0 )
                  {
                      printf( "0x%2x", loop + 32 );
                      if( ( vertical == height-1 ) && ( horizontal == width-1 ) )
                      {
                          printf( "\n};\n\n" );    /* end of definition */
                      }
                      else
                      {
                          carriage_return++;
                          if( carriage_return == 8 )
                          {
                              printf( ",\n   " );
                              carriage_return = 0;
                          }
                          else
                          {
                              printf( ", " );
                          }

                      }
                      break;
                  }
              }
              if( loop == num_colors )
              {
                  printf( "Format error, Line %d, Col %d -- exit.\n\n", vertical, horizontal );
                  exit( -1 );
              }
              current_line += chars_per_pixel;
          }
      }
   }

   return 0;
}

