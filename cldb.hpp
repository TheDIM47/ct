// Borland C++ Builder
// Copyright (c) 1995, 2002 by Borland Software Corporation
// All rights reserved

// (DO NOT EDIT: machine generated header) 'cldb.pas' rev: 6.00

#ifndef cldbHPP
#define cldbHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Cldb
{
//-- type declarations -------------------------------------------------------
typedef char Char256[256];

typedef char Char16[16];

typedef char Char12[12];

typedef char Char3[3];

struct THeader;
typedef THeader *PHeader;

#pragma pack(push, 1)
struct THeader
{
	Word FileSIG;
	Word SFAtr;
	Byte NumKeys;
	int NumRecs;
	int NumDels;
	Word NumFlds;
	Word NumPics;
	Word NumArrs;
	Word RecLen;
	int Offset;
	int LogEOF;
	int LogBOF;
	int FreeRec;
	char RecName[12];
	char MemName[12];
	char FilPrefx[3];
	char RecPrefx[3];
	Word MemoLen;
	Word MemoWid;
	int LockCont;
	int ChgTime;
	int ChgDate;
	Word CheckSum;
} ;
#pragma pack(pop)

struct TFieldRecord;
typedef TFieldRecord *PFieldRecord;

#pragma pack(push, 1)
struct TFieldRecord
{
	Byte FldType;
	char FldName[16];
	Word FOffset;
	Word Length;
	Byte DecSig;
	Byte DecDec;
	Word ArrNum;
	Word PicNum;
} ;
#pragma pack(pop)

struct TKeyRecord;
typedef TKeyRecord *PKeyRecord;

#pragma pack(push, 1)
struct TKeyRecord
{
	Byte NumComps;
	char KeyNams[16];
	Byte CompType;
	Byte CompLen;
} ;
#pragma pack(pop)

struct TKeyItem;
typedef TKeyItem *PKeyItem;

#pragma pack(push, 1)
struct TKeyItem
{
	Byte FldType;
	Word FldNum;
	Word ElmOff;
	Byte ElmLen;
} ;
#pragma pack(pop)

struct TPictureRecord;
typedef TPictureRecord *PPictureRecord;

#pragma pack(push, 1)
struct TPictureRecord
{
	Word PicLen;
	char PicStr[256];
} ;
#pragma pack(pop)

struct TArrayRecord;
typedef TArrayRecord *PArrayRecord;

#pragma pack(push, 1)
struct TArrayRecord
{
	Word NumDim;
	Word TotDim;
	Word ElmSiz;
} ;
#pragma pack(pop)

struct TArrayItem;
typedef TArrayItem *PArrayItem;

#pragma pack(push, 1)
struct TArrayItem
{
	Word MaxDim;
	Word LenDim;
} ;
#pragma pack(pop)

struct TDataHeader;
typedef TDataHeader *PDataHeader;

#pragma pack(push, 1)
struct TDataHeader
{
	Byte RHd;
	int RPtr;
} ;
#pragma pack(pop)

//-- var, const, procedure ---------------------------------------------------
static const Shortint SIGN_LOCKED = 0x1;
static const Shortint SIGN_OWNED = 0x2;
static const Shortint SIGN_ENCRYPTED = 0x4;
static const Shortint SIGN_MEMO = 0x8;
static const Shortint SIGN_COMPRESSED = 0x10;
static const Shortint SIGN_RECLAIM = 0x20;
static const Shortint SIGN_READONLY = 0x40;
static const Byte SIGN_CREATED = 0x80;
static const Word VERSION_21_SIG = 0x3343;
static const Shortint FLD_LONG = 0x1;
static const Shortint FLD_REAL = 0x2;
static const Shortint FLD_STRING = 0x3;
static const Shortint FLD_PICTURE = 0x4;
static const Shortint FLD_BYTE = 0x5;
static const Shortint FLD_SHORT = 0x6;
static const Shortint FLD_GROUP = 0x7;
static const Shortint FLD_DECIMAL = 0x8;
static const Shortint DATA_NEW = 0x1;
static const Shortint DATA_OLD = 0x2;
static const Shortint DATA_REV = 0x4;
static const Shortint DATA_DEL = 0x10;
static const Shortint DATA_HLD = 0x40;

}	/* namespace Cldb */
using namespace Cldb;
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// cldb
