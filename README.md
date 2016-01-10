CLARION TOOLKIT VERSION 1.16
----------------------------
Copyright (C) by Dmitry Koudryavtsev
GNU Public License v2

  Clarion 2.X Toolkit - Delphi components and demo-applications
                        for Clarion v.2.X tables read-only access.
                        Full source code included.

  Initially, "Toolkit" was developed for Delphi 5, but
  I think It will work on other Delphi or C++Builder
  versions with/without minimal changes.

  Features:
  - Encrypted tables support ( with Password Recovery )
  - Clarion Arrays support
  - Application-level transactions support
  - Fast and smart cache-cursor

  Installation:
    Open datkitXX.dpk in Delphi/Kylix "File"->"Open" dialog,
    (where XX is your Delphi/Kylix version software)
    click on "Install" button. Components will appear on
    "Data Acces" components page.

    Note: if you will try to open dfm and receive error message
          "Error reading XXXX. Invalid property value....."
          - ignore it (press "Ignore all"). 

  You can find precompiled Win32 binaries in "binaries" folder.

  Packaging:

  d2d         - Demo - Clarion to dBASE DBF converter (D2D) console
  d2d_gui     - Demo - D2D GUI edition
  d2d_ocx     - Demo - D2D ActiveX edition (only for WIN32)
  dat2gdb     - Demo - Clarion to Interbase/Firebird converter
  dv          - Demo - Clarion table viewer
  iconvt      - iconvt unit for Kylix (linux)
  iconvt-pp   - iconvt unit for Free Pascal (linux)
  unsupported - dbf to dat converter and TClarionDataSet

   clarion.pas  - Classes definition
   cldb.pas     - Internal Clarion structures
   d2dx.pas     - Core D2D code shared with d2d, d2d-gui and d2d-ocx
   d2dx.inc     - Common defines
   datkit.res   - Common resource file
   datkitXX.dpk - Packages ( where XX: d6 - Delphi 6; k2 - Kylix 2;
                  c6 - C++Builder 6 and so on... )
   gpl.txt      - License file
   gpl.rus.html - License file ( russian )
   readme.1st   - This file

  News for 1.16 (Feb-2003)
  ! New decryption algorythms  
  * Minor bugfix. Minor changes in exception handling 
  ! Now, default value for Repeatable option is FALSE (!) (d2dx)
  + New Dat2Gdb key DeleteOld (see dat2gdb/readme.1st for details)
    (useful for empty gdb (with metadata only, for example))

  News for 1.15.4 (Oct-2002)
  * Minor bugfix 
  + New D2D key -E{O|C|-} OemToChar|CharToOem|None conversion
    for international users
  ! OemConvert option changed from Boolean to TOemCvtType 
  + datkitd7.dpk - Delphi 7 package

  News for 1.15.3 (Aug-2002)
  * dat2gdb bugfix (fix problem with BYTE fields)

  News for 1.15.2 (Aug-2002)
  * dat2gdb bugfix 

  News for 1.15 (Jul-2002)
  ! Juliasoft's homepage has been moved !!!
    Our new location is http://juliasoft.nm.ru
  * more linux compatibility, minor optimization, minor code changes
  ! if you want to built D2D ActiveX, enable D2D_OCX option in d2d.inc 
  * Hint: you can enable TIME_SLICE in dat2gdb\dat2gdb.inc for use dat2gdb 
    on non-NT based OS.
  ! use dat2gdb\threaded_timer\ThreadedTimer.pas and "IBX without QT Timer"
    edition (See Jeff Overcash submission on Borland Code Central) for 
    compile dat2gdb without Qt (linux compile).

  News for 1.14 (Aug-2001 - Jul-2002)
  + Clarion Toolkit ported to Linux !
  + Delphi 6 support
  + Kylix support (possible lastest libqtintf.so required)
  + D2D ActiveX Edition (OCX)
  + D2D GUI Edition
  * Major bugfix 
  * Minor optimization
  * D2D feature: if Dat file contains empty field names,
    those field names in Dbf will contains time in 'nnsszzz' format
  + New D2D keys: DateStarted and DateContains
  + New Dat2Gdb keys (see dat2gdb/readme.1st and options.txt for details)
  + Date resolving algorythm was changed !!!
  ! Dat2Gdb works with Firebird/Interbase 6.X 
  + New "Select Font" menu item in DV

  1.13 ? Oh, no! :-))

  News for 1.12a-1.12e Internal release (Apr-May-2001)
  * Major performance optimization in Dat2Gdb
  * Minor bugfix in Dat2Gdb

  News for 1.12
  ! New key /Y[+|-] in D2D support for array conversion
    Smart array conversion routine
  * Minor bugfix in core Toolkit files and Demos
  * Minor optimization
  ! DBF to DAT converter (Dbf2Dat) was upgraded for:
    - Encryption support
    - Clarion arrays support
    You can find Dbf2Dat in DBF2DAT (ex-ALPHA) dir.
    See DBF2DAT\readme.1st for more information
  * Smart array conversion routine in Dat2Gdb - will works faster
    for array conversion mode
  + Borland project group CtGroup.Bpg for all projects in "CT" 
    has been added
  ! All Demos full functional. Compiled Demo examples available 
    from http://juliasoft.chat.ru (Clarion Toolkit page)

  News for 1.11
  * Performance optimization continues
     Minor optimization in Clarion.pas
     Major optimization in D2D (~30-40% faster)
  + New function TctCursor.GetRawDataPointer(Fld : TctField) : Pointer
    returns raw field data address
  * Extended Error information in Dat2Gdb (since v1.10)

  News for 1.10
  ! Homepage has been moved to www.chat.ru/~juliasoft
  * Minor performance optimization, code improvements, bugfix
  * Function GetDecimalX has been added to TctCursor class.
    I've use it for LONGINT field, which contains DECIMAL value.
  * ALPHA\Dbf2Dat code changed. Old code was wrong. Sorry.
    This utility requires modified version of ClDb.Pas and Clarion.Pas,
    which placed in ALPHA directory.
  + New key /W<Msec> in D2D. Waiting for the next try to open source file.
    Default: INFINITE
  + New keyword "WaitFor=<Msec>" in Dat2Gdb. Same as above.
  * "WaitFor" and /W key is workaround of problem infinite waiting 
    for table unlocking on NT
  ! FIB+ code has been removed from Dat2Gdb
  * Dat2Gdb has been tested with FireBird 0.9.4 ( Interbase 6 )

  News for 1.08
  * Fix in SetPassword (D3 version) (by Dennis Chertkov)
  + Package DatKitD3.dpk for Delphi 3 added (by Dennis Chertkov)
  * Bugfix in GetFilePrefix (by Andrey Baramzin bugreport)
  + New keyword 'ArrayAsStr' added in Dat2Gdb, see dat2gdb.cnf
    (example configuration) and \DAT2GDB\readme.1st for details,
  * Bugfix in Dat2Gdb Sparser.pas with empty line in Cnf file
    (by Alex Kopnin bugreport)
  ! FIBPlus (by Sergey Buzazhy www.geocities.com/buzz_ss) support added.
    See Dat2Gdb.Inc for details.
    Now, you can try to use Dat2Gdb with Interbase 6. 
  ! ALPHA code of DBF to DAT converter added in \ALPHA directory
    It works, but encryption and arrays not supported. BDE requierd.
    BE CAREFUL !!!

  News for 1.07
  * Decimal separator bugfix in D2D (by Alex Kopnin)
  * Small changes in this Readme
  ! Delphi package file renamed in DatKitD5.dpk [ for Delphi 5 ]
  ! Package DatKitC5.bpk for C++Builder 5 added

    *** You must uninstall old version of 'Toolkit'
    *** before v1.07 installation

  News for 1.06
  * Bugfix in DatView export to CVS procedure (by Igor Zakhrebetkov)
  * D3 compatible fix in Clarion.Pas          (by Igor Zakhrebetkov)

  News for 1.05
  ! First, Great thanks for all who helped me in Clarion Toolkit
    development
  ! Second, I've changed my e-mail address :-)
    New address: juliasoft@mail.ru
  ! BCD conversion routines rewrited for speed
  * Known bugs fixed
  * Bugs in TctCursor.Is... functions fixed
  + Export to CSV added in Dat Viewer (by Final Filer software)
  + New key -U (Undelete support) in Dat to Dbf converter

  News since 1.01
  ! First, I'll still Clarion Toolkit development :-)
  * Micro-bugfix in TCtCursor.GotoRecord
  + New Demo - Clarion to Interbase converter
  * Dat to DBF converter improved. New keys added.

Any comments and suggestions
----------------------------
Dmitry Koudryavtsev
RUSSIA, Volgograd, 1999-2001
Web:    http://juliasoft.chat.ru
E-Mail: juliasoft@mail.ru
FIDO:   2:5055/24
