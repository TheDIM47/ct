Program test;

uses iconvt;
	       
Var 
  cd : pvoid;
  b, p : pchar;
  x, y : longint;
Const  
  a : pchar = 'Хелло, ворлд!'; 
begin
  cd := iconv_open('KOI8-R', 'CP866');
  
  GetMem(b, 20); p := b;
  
  x := strlen(a); y := x;

  writeln('before: a=',a,' x=',x,' b=',b,' y=',y);

  iconv(cd, a, x, p, y);
  
  writeln('after:  a=',a,' x=',x,' b=',b,' y=',y);  
  
  FreeMem(b);  
  
  writeln('iconv_close return=', iconv_close(cd));
end.
