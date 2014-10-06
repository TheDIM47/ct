{
  Iconvt for Kylix
}
unit iconvt;

interface

const
  libc = 'libc.so.6';

function _iconv_open(const to_code : pchar; const from_code : pchar) : integer; cdecl;
function _iconv(const cd : integer; var src; var src_cnt : longint; var dst; var dst_cnt : longint) : integer; cdecl;
function _iconv_close(cd : integer) : integer; cdecl;

implementation

function _iconv_open(const to_code : pchar; const from_code : pchar) : integer; cdecl;
  external libc name 'iconv_open';
function _iconv(const cd : integer; var src; var src_cnt : longint; var dst; var dst_cnt : longint) : integer; cdecl;
  external libc name 'iconv';
function _iconv_close(cd : integer) : integer; cdecl;
  external libc name 'iconv_close';

end.
