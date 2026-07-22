unit dataBaseUnit;

interface
  uses System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, FormUnit1, CommonProcedureUnit, CommonFunctionUnit,
       System.StrUtils;

  function initCustSales(thisQuery: tAdoQuery): tAdoQuery;
  function initHtmlPages(thisQuery: tAdoQuery): tAdoQuery;
  function getFilename(myIp, trafoNum, docName: String): String;
  function saveDocument(myIp, trafoNum, docName,filePath: String): String;
  function checkUnfinishedTrafo(myIp: String): String;
  function getScreen(htmlItem: String): String;
  function saveCalculatedTrafoSpecs(myIp, thisTrafoNum: String; allSpecs: array of String): boolean;
  function getEmailAddress(myIp: String): String;
  function checkDbSwitch(myIp, trafoNum, itemName: String): boolean;

  procedure setDbSwitch(myIp, trafoNum, itemName: String);

  const
  fluxDensity = 1;
  filamentFiveVolts = 5;
  filamentSixVolts = 6.3;
  filamentTwelveVolts = 12.6;

implementation
 {$WARNINGS OFF}

function initCustSales(thisQuery: tAdoQuery): tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := Form1.adoVoorThuisCustomerSales;
  result := thisQuery;
end;

function initHtmlPages(thisQuery: tAdoQuery): tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := Form1.adoConnHtmlPages;
  result := thisQuery;
end;

function checkDbSwitch(myIp, trafoNum, itemName: String): boolean;
  var
  thisQuery: tAdoQuery;
  itemIndex: array of String;
  item: string;
  hulp: integer;
begin
  thisQuery := initCustSales(thisQuery);
  itemIndex := ['wikkelschema', 'materiaalLijst', 'offerte', 'wikkelschemaMM', 'materiaalLijstMM', 'offerteMM'];

  with thisQuery do begin
    SQL.Clear;
    SQL.add('select hasDownlTurnSchematic, hasDownlMaterialList, hasDownlQuote, hasTurnSchematicMM, hasMaterialListMM, hasQuoteMM ' +
            'from tb940_trafo_exportflags where ip = :myIp and trafonum = :trafonumber');
    Parameters.ParamByName('myIp').Value := myIp;
    Parameters.ParamByName('trafonumber').Value := trafoNum;
    try
      open;
      hulp := fields[IndexStr(itemName, itemIndex)].AsInteger;
    except
      on E:exception do writelog(E.Message);
    end;
  end;
  if hulp = 0 then
    result := false
  else
    result := true;
end;

procedure setDbSwitch(myIp, trafoNum, itemName: String);
  var
  thisQuery: tAdoQuery;
  itemIndex: array of String;
  query: string;
begin
  thisQuery := initCustSales(thisQuery);

  itemIndex := ['wikkelschema', 'materiaalLijst', 'offerte', 'wikkelschemaMM', 'materiaalLijstMM', 'offerteMM'];
  case IndexStr(itemName, itemIndex) of
    0: query:= 'update tb940_trafo_exportflags set hasDownlTurnSchematic = true where ip = :myIp and trafonum = :trafonumber';
    1: query:= 'update tb940_trafo_exportflags set hasDownlMaterialList  = true where ip = :myIp and trafonum = :trafonumber';
    2: query:= 'update tb940_trafo_exportflags set hasDownlQuote         = true where ip = :myIp and trafonum = :trafonumber';
    3: query:= 'update tb940_trafo_exportflags set hasTurnSchematicMM    = true where ip = :myIp and trafonum = :trafonumber';
    4: query:= 'update tb940_trafo_exportflags set hasMaterialListMM     = true where ip = :myIp and trafonum = :trafonumber';
    5: query:= 'update tb940_trafo_exportflags set hasQuoteMM            = true where ip = :myIp and trafonum = :trafonumber';
  end;

  with thisQuery do begin
    SQL.Clear;
    SQL.add(query);
    Parameters.ParamByName('myIp').Value := myIp;
    Parameters.ParamByName('trafonumber').Value := trafoNum;
    try
      execSql;
    except
      on E:exception do writelog(E.Message);
    end;
  end;
end;

function getFilename(myIp, trafoNum, docName: String): String;
  var
  thisQuery: tAdoQuery;
begin
  thisQuery := initCustSales(thisQuery);

  with thisQuery do begin
    SQL.Clear;
    SQL.add('select fullPath from tb990_paper_trail where ip = :myIp and itemNumber = :itemNumber and docName = :docName');
    Parameters.ParamByName('myIp').Value := myIp;
    Parameters.ParamByName('itemNumber').Value := trafoNum;
    Parameters.ParamByName('docName').Value := docName;
    try
      open;
      Result := fields[0].AsString;
    except
      on E:exception do writelog(E.Message);
    end;
  end;
end;


function saveDocument(myIp, trafoNum, docName, filePath: String): String;
  var
  thisQuery: tAdoQuery;
begin
  thisQuery := initCustSales(thisQuery);

  with thisQuery do begin
    SQL.Clear;
    SQL.add('delete from tb990_paper_trail where ip =:ip and itemNumber = :itemNumber and docName = :docName');
    Parameters.ParamByName('ip').Value := myIp;
    Parameters.ParamByName('itemNumber').Value := trafoNum;
    Parameters.ParamByName('docName').Value := docName;

    execSql;

    SQL.Clear;
    SQL.add('insert into tb990_paper_trail values (:ip, :itemNumber, :docName, :fullPath, :timestamp)');
    Parameters.ParamByName('ip').Value := myIp;
    Parameters.ParamByName('itemNumber').Value := trafoNum;
    Parameters.ParamByName('fullPath').Value := filePath;
    Parameters.ParamByName('timestamp').Value := generateTimestamp;
    Parameters.ParamByName('docName').Value := docName;
    try
      execSql;
      Result := 'ok';
    except
      on E:exception do writelog(E.Message);
    end;
  end;
end;

function checkUnfinishedTrafo(myIp: String): String;
begin
   result := getScreen('powerTrafoSpecs')
end;

function getScreen(htmlItem: String): String;
  var
  thisQuery: tAdoQuery;
begin
  thisQuery := initHtmlPages(thisQuery);

  with thisQuery do begin
    SQL.Clear;
    SQL.add('select inlineHtml from TB100_HtmlPages where id = :loadItem');
    Parameters.ParamByName('loadItem').Value := htmlItem;
    open;
    Result := fields[0].AsString;
  end;
end;

function getEmailAddress(myIp: String): String;
  var
  customerQuery: tAdoQuery;
begin
  customerQuery := initCustSales(customerQuery);

  with customerQuery do begin
    SQL.Clear;
    SQL.add('select email from tb110_address where ip = :myIp');
    Parameters.ParamByName('myIp').Value := myIp;
    open;
    Result := fields[0].AsString;
  end;
end;

function saveCalculatedTrafoSpecs(myIp, thisTrafoNum: String; allSpecs: array of String): boolean;
var
  customerQuery: tAdoQuery;
begin
  customerQuery := initCustSales(customerQuery);

  result := false;

  with customerQuery, SQL do begin
    clear;
    add('delete from tb210_power_trafo_calcspecs where ip = :myIp and trafoNum = :thisTrafoNum');
    Parameters.ParamByName('myIp').Value := myIp;
    Parameters.ParamByName('thisTrafoNum').Value := thisTrafoNum;
    try
      execSql;
    except
      on E:exception do writelog(E.Message);
    end;

    clear;
    add('delete from tb940_trafo_exportflags where ip = :myIp and trafoNum = :thisTrafoNum');
    Parameters.ParamByName('myIp').Value := myIp;
    Parameters.ParamByName('thisTrafoNum').Value := thisTrafoNum;
    try
      execSql;
    except
      on E:exception do writelog(E.Message);
    end;

    clear;
    add('insert into tb210_power_trafo_calcspecs values (:myIp, :thisTrafoNum, :primaryVA, :primaryAmps, :coreArea, :turnsPerVolt, ' +
        ':primWireSize, :primaryTurns, :secundaryTurns, :fiftyVoltTapTurns, :secCenterTapTurns, :secWireSize, :filFiveTurns, ' +
        ':filFiveCtTurns, :filFiveWireSize, :filSixTurns, :filSixCtTurns, :filSixWireSize, :filTwelveTurns, :filTwelveCtTurns, ' +
        ':filTwelveWireSize, :primTurnArea, :secTurnArea, :fiveVoltTurnArea, :sixVoltTurnArea, :twelveVoltTurnArea, ' +
        ':totalTurnArea, :sizeEiSheets, :timestamp)');

    Parameters.ParamByName('myIp').Value := myIp;
    Parameters.ParamByName('thisTrafoNum').Value := thisTrafoNum;
    Parameters.ParamByName('primaryVA').Value := allSpecs[0];
    Parameters.ParamByName('primaryAmps').Value := allSpecs[1];
    Parameters.ParamByName('coreArea').Value := allSpecs[2];
    Parameters.ParamByName('turnsPerVolt').Value := allSpecs[3];
    Parameters.ParamByName('primWireSize').Value := allSpecs[4];
    Parameters.ParamByName('primaryTurns').Value := allSpecs[5];
    Parameters.ParamByName('secundaryTurns').Value := allSpecs[6];
    Parameters.ParamByName('fiftyVoltTapTurns').Value := allSpecs[7];
    Parameters.ParamByName('secCenterTapTurns').Value := allSpecs[8];
    Parameters.ParamByName('secWireSize').Value := allSpecs[9];
    Parameters.ParamByName('filFiveTurns').Value := allSpecs[10];
    Parameters.ParamByName('filFiveCtTurns').Value := allSpecs[11];
    Parameters.ParamByName('filFiveWireSize').Value := allSpecs[12];
    Parameters.ParamByName('filSixTurns').Value := allSpecs[13];
    Parameters.ParamByName('filSixCtTurns').Value := allSpecs[14];
    Parameters.ParamByName('filSixWireSize').Value := allSpecs[15];
    Parameters.ParamByName('filTwelveTurns').Value := allSpecs[16];
    Parameters.ParamByName('filTwelveCtTurns').Value := allSpecs[17];
    Parameters.ParamByName('filTwelveWireSize').Value := allSpecs[18];
    Parameters.ParamByName('primTurnArea').Value := allSpecs[19];
    Parameters.ParamByName('secTurnArea').Value := allSpecs[20];
    Parameters.ParamByName('fiveVoltTurnArea').Value := allSpecs[21];
    Parameters.ParamByName('sixVoltTurnArea').Value := allSpecs[22];
    Parameters.ParamByName('twelveVoltTurnArea').Value := allSpecs[23];
    Parameters.ParamByName('totalTurnArea').Value := allSpecs[24];
    Parameters.ParamByName('sizeEiSheets').Value := allSpecs[25];
    Parameters.ParamByName('timestamp').Value := generateTimeStamp;

    try
      execSql;
    except
      on E:exception do writelog(E.Message);
    end;

    clear;
    add('insert into tb940_trafo_exportflags values (:myIp, :thisTrafoNum, :isOrdered, :hasDownlMaterialList, ' +
        ':hasDownlTurnSchematic, :hasDownlQuote, :hasMaterialListMM, :hasTurnSchematicMM, :hasQuoteMM, :timestamp)');

    Parameters.ParamByName('myIp').Value := myIp;
    Parameters.ParamByName('thisTrafoNum').Value := thisTrafoNum;
    Parameters.ParamByName('isOrdered').Value := false;
    Parameters.ParamByName('hasDownlMaterialList').Value := false;
    Parameters.ParamByName('hasDownlTurnSchematic').Value := false;
    Parameters.ParamByName('hasDownlQuote').Value := false;
    Parameters.ParamByName('hasMaterialListMM').Value := false;
    Parameters.ParamByName('hasTurnSchematicMM').Value := false;
    Parameters.ParamByName('hasQuoteMM').Value := false;
    Parameters.ParamByName('timestamp').Value := generateTimeStamp;
    try
      execSql;
      result := true;
    except
      on E:exception do writelog(E.Message);
    end;

  end;
end;


end.
