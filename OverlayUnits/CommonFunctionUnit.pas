unit CommonFunctionUnit;

interface
  uses System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, System.StrUtils, System.math;
  function storeSessionSettings(myIp: string): string;
  function updateSessionSettings(myIp: string): string;
  function generateSessionId(): string;
  function generateTimestamp(offset: integer = 0): string;
  function generateTimestampMonthOld: string;
  function binPower(value, exponent: integer): integer;
  function fillLeft(myNumber, size: integer): string;
  function Left(myString: string; getPart: integer): string;
  function getCurrentNumber(itemName: string): string;
  function CountOccurences( const SubText: string; const Text: string): Integer;
  function readEntireFile(fileName: String): String;

implementation
  uses FormUnit1, dialogs, CommonProcedureUnit, IOUtils;

  const
    netVoltage = 230;
    frequency = 50;
    fluxDensity = 1;

  function storeSessionSettings(myIp: string): string;
    var
    thisQuery: tAdoQuery;
    newTimeStamp: string;
  begin
    thisQuery := tAdoQuery.Create(nil);
    thisQuery.Connection := form1.adoVoorThuisCustomerSales;
    newTimestamp := generateTimestamp;
    with thisQuery do begin
      SQL.Clear;
      SQL.add('insert into TB900_SessionSettings(Ip, SessionActive, Timestamp) values (:ip, :SessionActive, :timestamp)');
      Parameters.ParamByName('ip').Value := myIp;
      Parameters.ParamByName('SessionActive').Value := true;
      Parameters.ParamByName('timestamp').Value := newTimestamp;
      try
        execSql;
      except
        try
          updateSessionSettings(myIp);
        except
          result := 'error';
        end;
      end;
    end;
  end;

  function updateSessionSettings(myIp: string): string;
    var
    thisQuery: tAdoQuery;
  begin
    thisQuery := tAdoQuery.Create(nil);
    thisQuery.Connection := form1.adoVoorThuisCustomerSales;

    with thisQuery do begin
      SQL.Clear;
      SQL.add('update TB900_SessionSettings set sessionActive = true, timestamp = :timestamp where Ip = :ip');
      Parameters.ParamByName('ip').Value := myIp;
      Parameters.ParamByName('timestamp').Value := generateTimestamp;
      execSQL;
    end;
  end;

  function generateSessionId: string;
  var
    t: integer;
    hex: string;
  begin
    Randomize;
    for t  := 1 to 20 do
      hex := hex + intToHex(random(15), 1);
    result := hex;
  end;

  function generateTimestamp(offset: integer = 0): string;
  var
    thisDate: string;
  begin
    thisDate := FormatDateTime('yyyy/mm/dd hh:mm:ss:zzz', Now() - EncodeTime(0, offset, 0, 0));
    result := thisDate;
  end;

  function generateTimestampMonthOld: string;
  var
    thisDate: string;
  begin
    thisDate := FormatDateTime('yyyy/mm/dd hh:mm:ss:zzz', Now() - 30);
    result := thisDate;
  end;

  function binPower(value, exponent: integer): integer;
  var
    hulp: integer;
  begin
    hulp := 1;
    case exponent of
     0: hulp := 1;
     1: hulp := 2;
     2: hulp := 4;
     3: hulp := 8;
     4: hulp := 16;
     5: hulp := 32;
     6: hulp := 64;
    end;
    result := hulp;
  end;

  function getCurrentNumber(itemName: string): string;
  var
    htmlQuery: tAdoQuery;
    hulp: integer;
    wYear, wMonth, wDay: Word;
begin
    DecodeDate(Date, wYear, wMonth, wDay);

    htmlQuery := tAdoQuery.Create(nil);
    htmlQuery.Connection := form1.adoConnHtmlPages;
    with htmlQuery do begin
      SQL.Clear;
      SQL.Add('select itemnumber from tb900_numberstabel where itemType = :itemType');
      Parameters.ParamByName('itemType').Value := itemName;
      open;
      hulp := fields[0].AsInteger;
      Result := fillLeft(hulp, 5);
    end;

    inc(hulp);

    with htmlQuery do begin
      SQL.Clear;
      SQL.Add('delete from tb900_numberstabel where itemType = :itemType');
      Parameters.ParamByName('itemType').Value := itemName;
      execSQL;

      SQL.Clear;
      SQL.Add('insert into tb900_numberstabel(itemType, itemNumber) values (:itemType, :ItemNumber)');
      Parameters.ParamByName('itemType').Value := itemName;
      Parameters.ParamByName('itemNumber').Value := hulp ;
      execSQL;
    end;
    result := itemName + intToStr(wYear) + fillLeft(wMonth, 2) + result;
  end;


  function fillLeft(myNumber, size: integer): string;
  var
    hulp: string;
  begin
    hulp := intToStr(myNumber);
    result := StringOfChar('0', size - length(hulp)) + hulp;
  end;

  function Left(myString: string; getPart: integer): string;
  begin
    result := copy(myString, 0, getPart);
  end;

  { Returns a count of the number of occurences of SubText in Text }
  function CountOccurences( const SubText: string; const Text: string): Integer;
  begin
    if (SubText = '') OR (Text = '') OR (Pos(SubText, Text) = 0) then
      Result := 0
    else
      Result := (Length(Text) - Length(StringReplace(Text, SubText, '', [rfReplaceAll]))) div  Length(subtext);
  end;

  function readEntireFile(fileName: String): String;
  var
    readFile: TFile;
  begin
    result := readfile.ReadAllText(FileName);
  end;



end.
