{
  Iconvt for Kylix
}
{$APPTYPE CONSOLE}
Program test;

uses Libc, SysUtils;

Var
  cd : pointer;
  a, pa : pchar;
  b, pb : pointer;

  x, y : cardinal;
  n : integer;
begin
  a := strdup('•…‹‹Ž!'); pa := a;
  b := a; pb :=b;
  cd := iconv_open('KOI8-R', 'CP866');
  x := strlen(a); y := x;
  writeln('before: a=',pa,' x=',x,' b=', pchar(pb),' y=',y);
  n := iconv(cd, a, x, b, y);
  writeln('n := ', n);
  writeln('after:  a=',pa,' x=',x,' b=', pchar(pb),' y=',y);
  writeln('iconv_close return=', iconv_close(cd));
end.
