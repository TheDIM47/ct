{.$DEFINE USE_VARIANT}  // not so slow, but...
{$DEFINE D2D_DEFAULTS} // remove for DJ defaults

{$DEFINE IBX6XX} // Define for Ibx 6.X

{$IFDEF WIN32}
{$DEFINE D2D_OCX} // Enable for D2D ActiveX edition compile
{$ENDIF}
