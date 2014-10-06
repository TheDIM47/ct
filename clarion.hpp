// Borland C++ Builder
// Copyright (c) 1995, 2002 by Borland Software Corporation
// All rights reserved

// (DO NOT EDIT: machine generated header) 'clarion.pas' rev: 6.00

#ifndef clarionHPP
#define clarionHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <cldb.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysUtils.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Clarion
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TCacheBalance { coFastBack, coBackward, coNormal, coForward, coFastForw };
#pragma option pop

typedef Word *PWord;

class DELPHICLASS TctTransaction;
typedef TctTransaction* *PctTransaction;

class PASCALIMPLEMENTATION TctTransaction : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	System::ShortString FPath;
	System::ShortString FName;
	bool FActive;
	int FFile;
	System::ShortString __fastcall MakeTrnName();
	System::ShortString __fastcall GetPath();
	void __fastcall SetPath( System::ShortString &S);
	
public:
	__fastcall virtual TctTransaction(Classes::TComponent* AOwner);
	__fastcall virtual ~TctTransaction(void);
	bool __fastcall InTransaction(void);
	bool __fastcall BeginTransaction(void);
	bool __fastcall EndTransaction(void);
	void __fastcall WaitTransaction(int WaitMs);
	
__published:
	__property System::ShortString AppName = {read=FName, write=FName};
	__property System::ShortString AppPath = {read=GetPath, write=SetPath};
};


class DELPHICLASS TctClarion;
typedef TctClarion* *PctClarion;

class DELPHICLASS TctField;
class DELPHICLASS TctArray;
class PASCALIMPLEMENTATION TctClarion : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	System::ShortString FFileName;
	System::ShortString FPassword;
	int FFile;
	int FMode;
	bool FRead_Only;
	bool FExclusive;
	bool FActive;
	Word FId;
	#pragma pack(push, 1)
	Cldb::THeader FHeader;
	#pragma pack(pop)
	
	Classes::TList* FFields;
	Classes::TList* FKeys;
	Classes::TList* FPictures;
	Classes::TList* FArrays;
	void __fastcall SetFileName( System::ShortString &Name);
	Word __fastcall CalcCheckSum(void);
	void __fastcall DecodeHeader(Word ID);
	bool __fastcall CheckHeader(Word ID);
	void __fastcall SetPassword( System::ShortString &APwd);
	
protected:
	void __fastcall ReadHeader(void);
	void __fastcall ReadFields(void);
	void __fastcall ReadKeys(void);
	void __fastcall ReadPictures(void);
	void __fastcall ReadArrays(void);
	
public:
	__fastcall virtual TctClarion(Classes::TComponent* AOWner);
	__fastcall virtual ~TctClarion(void);
	virtual void __fastcall Close(void);
	virtual void __fastcall Open(void);
	bool __fastcall IsLocked(void);
	bool __fastcall IsEncrypted(void);
	bool __fastcall IsMemoExist(void);
	TctField* __fastcall GetField(int Index);
	TctArray* __fastcall GetArray(int Index);
	TctField* __fastcall FieldByName( System::ShortString &AFName);
	int __fastcall GetFieldCount(void);
	int __fastcall GetRecordCount(void);
	System::ShortString __fastcall GetFilePrefix();
	__property TctField* Fields[int Index] = {read=GetField};
	__property TctArray* Arrays[int Index] = {read=GetArray};
	
__published:
	__property bool Active = {read=FActive, nodefault};
	__property System::ShortString FileName = {read=FFileName, write=SetFileName};
	__property System::ShortString Password = {read=FPassword, write=SetPassword};
	__property bool Read_Only = {read=FRead_Only, write=FRead_Only, default=1};
	__property bool Exclusive = {read=FExclusive, write=FExclusive, default=0};
};


typedef TctField* *PctField;

class PASCALIMPLEMENTATION TctField : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	TctClarion* FOwner;
	#pragma pack(push, 1)
	Cldb::TFieldRecord FFieldRecord;
	#pragma pack(pop)
	
	
public:
	__fastcall TctField(TctClarion* AOwner);
	Word __fastcall GetFieldSize(void);
	Word __fastcall GetFieldOffs(void);
	Byte __fastcall GetFieldType(void);
	System::ShortString __fastcall GetFieldName();
	Word __fastcall GetArrayNumber(void);
	Word __fastcall GetPictureNumber(void);
	Byte __fastcall GetDecSig(void);
	Byte __fastcall GetDecDec(void);
	bool __fastcall IsArray(void);
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~TctField(void) { }
	#pragma option pop
	
};


class DELPHICLASS TctKey;
typedef TctKey* *PctKey;

class PASCALIMPLEMENTATION TctKey : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	TctClarion* FOwner;
	#pragma pack(push, 1)
	Cldb::TKeyRecord FKeyRecord;
	#pragma pack(pop)
	
	Classes::TList* FKeyItems;
	__fastcall TctKey(TctClarion* AOwner);
	__fastcall virtual ~TctKey(void);
};


class DELPHICLASS TctPicture;
typedef TctPicture* *PctPicture;

class PASCALIMPLEMENTATION TctPicture : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	TctClarion* FOwner;
	#pragma pack(push, 1)
	Cldb::TPictureRecord FPictureRecord;
	#pragma pack(pop)
	
	__fastcall TctPicture(TctClarion* AOwner);
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~TctPicture(void) { }
	#pragma option pop
	
};


typedef TctArray* *PctArray;

class PASCALIMPLEMENTATION TctArray : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	TctClarion* FOwner;
	#pragma pack(push, 1)
	Cldb::TArrayRecord FArrayRecord;
	#pragma pack(pop)
	
	Classes::TList* FArrayItems;
	__fastcall TctArray(TctClarion* AOwner);
	__fastcall virtual ~TctArray(void);
	int __fastcall GetBufLen(void);
	int __fastcall GetDim(Byte Index);
	int __fastcall GetDimLen(Byte Index);
};


class DELPHICLASS TctCursor;
typedef TctCursor* *PctCursor;

class PASCALIMPLEMENTATION TctCursor : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	TctClarion* FOwner;
	int FFile;
	char *FCacheBuffer;
	Word FCacheSize;
	TCacheBalance FCacheBalance;
	int FCMaxRecsInCache;
	int FCRecsInCache;
	int FCMinRecNo;
	int FCMaxRecNo;
	int FCurrRecNo;
	bool __fastcall CheckInCache(void);
	void __fastcall ReadCache(void);
	
public:
	__fastcall TctCursor(TctClarion* AOwner, Word ACSize, TCacheBalance ACBalance);
	__fastcall virtual ~TctCursor(void);
	void __fastcall GotoFirst(void);
	void __fastcall GotoLast(void);
	void __fastcall GotoNext(void);
	void __fastcall GotoPrev(void);
	void __fastcall GotoRecord(int RecNo);
	bool __fastcall EOF(void);
	bool __fastcall BOF(void);
	System::TDateTime __fastcall GetDate(TctField* Fld);
	System::TDateTime __fastcall GetTime(TctField* Fld);
	System::ShortString __fastcall GetString(TctField* Fld);
	Byte __fastcall GetByte(TctField* Fld);
	short __fastcall GetShort(TctField* Fld);
	double __fastcall GetDouble(TctField* Fld);
	int __fastcall GetInteger(TctField* Fld);
	double __fastcall GetDecimal(TctField* Fld);
	double __fastcall GetDecimalX(TctField* Fld, int DS, int DD);
	AnsiString __fastcall GetArrayAsString(TctField* Fld);
	void * __fastcall GetRawDataPointer(TctField* Fld);
	bool __fastcall IsNew(void);
	bool __fastcall IsOld(void);
	bool __fastcall IsRevised(void);
	bool __fastcall IsDeleted(void);
	bool __fastcall IsHeld(void);
	void __fastcall SetBalance(TCacheBalance ACBalance);
	TCacheBalance __fastcall GetBalance(void);
	int __fastcall GetCurrRecNo(void);
};


struct TBcd;
typedef TBcd *PBcd;

#pragma pack(push, 1)
struct TBcd
{
	Byte Precision;
	Byte SignSpecialPlaces;
	Byte Fraction[32];
} ;
#pragma pack(pop)

//-- var, const, procedure ---------------------------------------------------
static const int DAT_HEADER_SIZE = 0x55;
static const int REC_HEADER_SIZE = 0x5;
static const Word DELTA_DAYS = 0x8d41;
#define TOOLKIT_VERSION "\x041.14lt"
#define ERR_TRN_WAIT "\x1dTry to wait owned transactionde\x06"
#define ERR_TRN_DIR "\x1dInvalid Transaction Directory"
#define ERR_CT_CANT_OPEN_FILE " Can`t open file or access denied"
#define ERR_CT_INVALID_FLDNAME "\x12Invalid Field Name"
#define ERR_CT_INVALID_VERSION "\x14Invalid file version"
#define ERR_CT_STRANGE_ENCRYPT "#Strange header encryption algorythm\x12"
extern PACKAGE void __fastcall Register(void);
extern PACKAGE System::ShortString __fastcall CheckExt( System::ShortString &S);
extern PACKAGE System::ShortString __fastcall RemoveExt( System::ShortString &S);
extern PACKAGE System::ShortString __fastcall CheckSlash( System::SmallString<255>  &S, const int S_Size);
extern PACKAGE System::ShortString __fastcall PatchName( System::ShortString &S);
extern PACKAGE void __fastcall DecodeBuffer(void *Buf, Word BufSize, Word Id);
extern PACKAGE System::ShortString __fastcall OemToChar(const System::ShortString &S);
extern PACKAGE System::ShortString __fastcall CharToOem(const System::ShortString &S);
extern PACKAGE bool __fastcall BCDToCurr(const TBcd &BCD, System::Currency &Curr);

}	/* namespace Clarion */
using namespace Clarion;
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// clarion
