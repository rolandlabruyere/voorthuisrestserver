unit CommonFunctionUnit;

interface
  uses System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, System.StrUtils, System.math;

  function storeSessionSettings(myIp: String): String;
  function updateSessionSettings(myIp: String): String;
  function generateSessionId(): String;
  function generateTimestamp(offset: integer = 0): String;
  function generateTimestampMonthOld: String;
  function binPower(value, exponent: integer): integer;
  function fillLeft(myNumber, size: integer): String;
  function Left(myString: String; getPart: integer): String;
  function Right(myString: String; getPart: integer): String;
  function getCurrentNumber(itemName: String): String;
  function CountOccurences( const SubText: String; const Text: String): Integer;
  function readEntireFile(fileName: String): String;
  function writeEntireFile(fileName, textToWrite: String): String;
  function getTrafoBinValue(myIp: String): integer;
  function fetchAddressByZipcode(zipCode, houseNumber, houseNumTvo: String): String;
  function getSumVaSecundary(myIp, trafoNum: String): single;
  function getWireSize(secAmps: single; isMilliAmps: boolean): single; overload;
  function getWireSize(primVa, primVoltage: single): single; overload;
  function calcTurnArea(d, N: single): single;
  function getSuitableEiType(calculatedWindowsArea: single): String;
  function getCsvHeader(documentName: String): String;
  function fetchTrafoData(myIp, trafoNumber, csvHeader: String): String;

implementation
uses FormUnit1, dialogs, CommonProcedureUnit, IOUtils;

function fetchTrafoData(myIp, trafoNumber, csvHeader: String): String;
var
  thisQuery: tAdoQuery;
  headerFields: TArray<String>;
  T: integer;
  hulp: String;
begin
  thisQuery := tAdoQuery.Create(nil);
  headerFields := csvHeader.Split([';']);
  hulp := '';

  with thisQuery do begin
    connection := Form1.adoConnHtmlPages;

    SQL.add('select * from vw810_full_csv_layout_turn_schem where ip = :myIp and orderNum = :trafoNum');
    Parameters.ParamByName('myIp').Value := myIp;
    Parameters.ParamByName('trafoNum').Value := trafoNumber;
    open;
    for T := 0 to length(headerFields) - 1 do hulp := hulp + fields[T + 1].AsString.replace('.', ',') + ';';
  end;

  hulp := left(hulp, length(hulp) - 1);
  result := hulp;
end;

function getCsvHeader(documentName: String): String;
var
  thisQuery: tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);

  with thisQuery do begin
    connection := Form1.adoConnHtmlPages;

    SQL.add('select header from tb800_csv_headers where docName >= :docName');
    Parameters.ParamByName('docName').Value := documentName;
    Open;
    Result := fields[0].AsString;
  end;
end;

function calcTurnArea(d, N: single): single;
const
  Fv = 0.25 ;
begin
  result := ((N * sqr(d)) / Fv)/100
end;

function getSuitableEiType(calculatedWindowsArea: single): String;
var
  thisQuery: tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  with thisQuery do begin
    connection := Form1.adoConnHtmlPages;

    SQL.add('select min(OppervlakVensters), TypeAanduiding from tb250_trafoblik where OppervlakVensters >= :WindowArea');
    Parameters.ParamByName('WindowArea').Value := calculatedWindowsArea;
    Open;
    Result := fields[1].AsString;

    if result = '' then raise exception.Create('no suitable sheets found for these values');
  end;
end;


function getSumVaSecundary(myIp, trafoNum: String): single;
  var
    customerQuery: tAdoQuery;
    primaryVA: single;
  begin
    customerQuery := tAdoQuery.Create(nil);
    customerQuery.Connection := form1.adoVoorThuisCustomerSales;
    primaryVA := 0;

    with customerQuery, SQL do begin
      clear;
      add('select * from vw205_power_trafo_all where ip = :myIp and trafoNum = :trafoNum');
      Parameters.ParamByName('myIp').Value := myIp;
      Parameters.ParamByName('trafoNum').Value := trafoNum;
      open;

      primaryVA := primaryVA + fieldByName('volts').asFloat * (fieldByName('milliAmps').asFloat / 1000);
      primaryVA := primaryVA + fieldByName('filamentFiveAmps').asFloat * filamentFiveVolts;
      primaryVA := primaryVA + fieldByName('filamentSixAmps').asFloat * filamentSixVolts;
      primaryVA := primaryVA + fieldByName('filamentTwelveAmps').asFloat * filamentTwelveVolts;
      primaryVA := primaryVA / 0.9;
      result := primaryVA;
    end;
  end;

function getTrafoBinValue(myIp: String): integer;
  var
    customerQuery: tAdoQuery;
  begin
    customerQuery := tAdoQuery.Create(nil);
    customerQuery.Connection := form1.adoVoorThuisCustomerSales;
    with customerQuery, SQL do begin
      clear;
      add('select commonValues from tb910_temp_trafo_settings where ip = :myIp and part = 1');
      Parameters.ParamByName('myIp').Value := myIp;
      open;
      result := fields[0].AsInteger;
    end;
  end;

function storeSessionSettings(myIp: String): String;
    var
    thisQuery: tAdoQuery;
    newTimeStamp: String;
  begin
    thisQuery := tAdoQuery.Create(nil);
    thisQuery.Connection := form1.adoVoorThuisCustomerSales;
    newTimestamp := generateTimestamp;
    with thisQuery do begin
      SQL.Clear;
      SQL.add('insert into TB900_Session_Settings(Ip, SessionActive, Timestamp) values (:ip, :SessionActive, :timestamp)');
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

function updateSessionSettings(myIp: String): String;
    var
    thisQuery: tAdoQuery;
  begin
    thisQuery := tAdoQuery.Create(nil);
    thisQuery.Connection := form1.adoVoorThuisCustomerSales;

    with thisQuery do begin
      SQL.Clear;
      SQL.add('update TB900_Session_Settings set sessionActive = true, timestamp = :timestamp where Ip = :ip');
      Parameters.ParamByName('ip').Value := myIp;
      Parameters.ParamByName('timestamp').Value := generateTimestamp;
      execSQL;
    end;
  end;

  function generateSessionId: String;
  var
    t: integer;
    hex: String;
  begin
    Randomize;
    for t  := 1 to 20 do
      hex := hex + intToHex(random(15), 1);
    result := hex;
  end;

  function generateTimestamp(offset: integer = 0): String;
  var
    thisDate: String;
  begin
    thisDate := FormatDateTime('yyyy/mm/dd hh:mm:ss:zzz', Now() - EncodeTime(0, offset, 0, 0));
    result := thisDate;
  end;

  function generateTimestampMonthOld: String;
  var
    thisDate: String;
  begin
    thisDate := FormatDateTime('yyyy/mm/dd hh:mm:ss:zzz', Now() - 30);
    result := thisDate;
  end;

  function binPower(value, exponent: integer): integer;
  var
    hulp: integer;
  begin
    hulp := 0;

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

function getCurrentNumber(itemName: String): String;
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
      SQL.Add('select itemNumber from tb900_numberstabel where itemType = :itemType');
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
      SQL.Add('insert into tb900_numberstabel values (:itemType, :currentYear, :currentMonth, :ItemNumber)');
      Parameters.ParamByName('itemType').Value := itemName;
      Parameters.ParamByName('currentYear').Value := wYear;
      Parameters.ParamByName('currentMonth').Value := wMonth;
      Parameters.ParamByName('itemNumber').Value := hulp ;
      execSQL;
    end;
    result := intToStr(wYear) + fillLeft(wMonth, 2) + result;
  end;

function fetchAddressByZipcode(zipCode, houseNumber, houseNumTvo: String): String;
  var
    htmlQuery: tAdoQuery;
    hulp: String;
begin
    htmlQuery := tAdoQuery.Create(nil);
    htmlQuery.Connection := form1.adoConnHtmlPages;

    with htmlQuery do begin
      SQL.Clear;
      SQL.Add('select street, city from tb990_postcode_tabel where postcode = :zipcode and :houseNumber between minNumber and maxNumber');
      Parameters.ParamByName('zipcode').Value := zipCode;
      Parameters.ParamByName('houseNumber').Value := houseNumber;
      open;

      hulp := fields[0].AsString + ' ' + houseNumber + ' ' + houseNumTvo + '<br>';
      Result := hulp + left(zipcode, 4) + ' ' + right(zipcode, 2)  + '  ' + fields[1].AsString;
    end;
  end;

  function fillLeft(myNumber, size: integer): String;
  var
    hulp: String;
  begin
    hulp := intToStr(myNumber);
    result := StringOfChar('0', size - length(hulp)) + hulp;
  end;

  function Left(myString: String; getPart: integer): String;
  begin
    result := copy(myString, 0, getPart);
  end;

  function Right(myString: String; getPart: integer): String;
  begin
    result := copy(myString, length(myString) - (getpart - 1), getPart);
  end;

  { Returns a count of the number of occurences of SubText in Text }
  function CountOccurences( const SubText: String; const Text: String): Integer;
  begin
    if (SubText = '') OR (Text = '') OR (Pos(SubText, Text) = 0) then
      Result := 0
    else
      Result := (Length(Text) - Length(StringReplace(Text, SubText, '', [rfReplaceAll]))) div  Length(subtext);
  end;

  {$HINTS OFF}
  function readEntireFile(fileName: String): String;
  var
    readFile: TFile;
  begin
    result := readfile.ReadAllText(FileName);
  end;
  function writeEntireFile(fileName, textToWrite: String): String;
  var
    writeFile: TFile;
  begin
    try
      writefile.WriteAllText(FileName, textToWrite);
      result := 'Ok'
    except
      on E:exception do writelog(E.Message);
    end;
  end;
  {$HINTS ON}

  function getWireSize(primVa, primVoltage: single): single; overload;
  var
    thisQuery: tAdoQuery;
    current: single;
  begin
    thisQuery := tAdoQuery.Create(nil);
    current := primVA / primVoltage;
    result := 0;

    with thisQuery do begin
      connection := form1.adoConnHtmlPages;
      SQL.add('select min(diameter) from tb230_draad_metrisch where MaxAmp >= :amperage');
      Parameters.ParamByName('amperage').Value := current;
      try
        Open;
        Result := fields[0].AsFloat;
      except
        on E:exception do writelog(E.Message);
      end;
    end;
  end;

  function getWireSize(secAmps: single; isMilliAmps: boolean): single; overload;
  var
    thisQuery: tAdoQuery;
    current: single;
  begin
    thisQuery := tAdoQuery.Create(nil);
    result := 0;

    if isMilliAmps then
      current := secAmps / 1000
    else
      current := secAmps;

    with thisQuery do begin
      connection := form1.adoConnHtmlPages;
      SQL.add('select min(diameter) from tb230_draad_metrisch where MaxAmp >= :amperage');
      Parameters.ParamByName('amperage').Value := current;
      try
        Open;
        Result := fields[0].AsFloat;
      except
        on E:exception do writelog(E.Message);
      end;
    end;
  end;



end.
