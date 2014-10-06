#include <errno.h>
#include <stdio.h>
#include <iconv.h>

int main()
{
  char* in_buf  = "Хелло, ворлд!\0";
  char* out_buf = (char*)malloc(20);
  char* q = out_buf;

  size_t x, m, n;

  iconv_t cd = iconv_open("KOI8-R", /* TO code   */
                          "CP866"); /* FROM code */
 
  n = 13; 
  m = 13; 
  x = 0;

  if ( ( in_buf == NULL) || (&in_buf == NULL) ) printf("in_buff is NULL");
  if ( ( out_buf == NULL) || (&out_buf == NULL) ) printf("out_buff is NULL");  
  
  printf("before: converted=%i n=%i m=%i %s %s\n", x, n, m, in_buf, out_buf);  
  x = iconv(cd, 
            &in_buf, &n, 
	    &q, &m);
  printf("after: errno=%i converted=%i n=%i m=%i\n", errno, x, n, m);
  printf("in_buf='%s' out_buf='%s' q-n='%s'\n", in_buf, out_buf, q - 13);

  free(out_buf);
  
  iconv_close(cd);
}

