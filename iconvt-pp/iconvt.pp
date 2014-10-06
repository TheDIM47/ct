{
  iconvt for Free Pascal
}

unit iconvt;

interface

type
  pvoid = ^pointer;

function iconv_open(const to_code : pchar; const from_code : pchar) : pvoid; cdecl; external;
function iconv(const cd : pvoid; var src; var src_cnt : longint; var dst; var dst_cnt : longint) : longint; cdecl; external;
function iconv_close(cd : pvoid) : longint; cdecl; external;

implementation
{$linklib c}
end.	       
