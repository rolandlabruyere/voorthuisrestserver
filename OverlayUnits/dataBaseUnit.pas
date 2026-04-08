unit dataBaseUnit;

interface
  uses System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, FormUnit1, CommonProcedureUnit, CommonFunctionUnit;

  function initCustSales(thisQuery: tAdoQuery): tAdoQuery;
  function initHtmlPages(thisQuery: tAdoQuery): tAdoQuery;
  function getFilename(myIp, trafoNum: String): String;
  function saveDocument(myIp, trafoNum, filePath: String): String;
  function checkUnfinishedTrafo(myIp: String): String;
  function getScreen(htmlItem: String): String;
  function saveCalculatedTrafoSpecs(myIp, thisTrafoNum: String; allSpecs: array of String): boolean;

const
  fluxDensity = 1;
  filamentFiveVolts = 5;
  filamentSixVolts = 6.3;
  filamentTwelveVolts = 12.6;

implementation

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

function getFilename(myIp, trafoNum: String): String;
  var
  thisQuery: tAdoQuery;
begin
  thisQuery := initCustSales(thisQuery);

  with thisQuery do begin
    SQL.Clear;
    SQL.add('select fullPath from tb990_paper_trail where ip =:ip and itemNumber = :itemNumber');
    Parameters.ParamByName('ip').Value := myIp;
    Parameters.ParamByName('itemNumber').Value := trafoNum;
    try
      open;
      Result := fields[0].AsString;
    except
      on E:exception do writelog(E.Message);
    end;
  end;
end;


function saveDocument(myIp, trafoNum, filePath: String): String;
  var
  thisQuery: tAdoQuery;
begin
  thisQuery := initCustSales(thisQuery);

  with thisQuery do begin
    SQL.Clear;
    SQL.add('delete from tb990_paper_trail where ip =:ip and itemNumber = :itemNumber');
    Parameters.ParamByName('ip').Value := myIp;
    Parameters.ParamByName('itemNumber').Value := trafoNum;
    execSql;

    SQL.Clear;
    SQL.add('insert into tb990_paper_trail values (:ip, :itemNumber, :fullPath, :timestamp)');
    Parameters.ParamByName('ip').Value := myIp;
    Parameters.ParamByName('itemNumber').Value := trafoNum;
    Parameters.ParamByName('fullPath').Value := filePath;
    Parameters.ParamByName('timestamp').Value := generateTimestamp;
    try
      execSql;
      Result := 'ok';
    except
      on E:exception do writelog(E.Message);
    end;
  end;
end;

function checkUnfinishedTrafo(myIp: String): String;
var
  customerQuery: tAdoQuery;
begin
  customerQuery := initCustSales(customerQuery);

  with customerQuery do begin
    Connection := Form1.adoVoorThuisCustomerSales;
    SQL.Clear;
    SQL.add('select * from tb200_power_trafo_config where Ip = :Ip and isClosed = false');
    Parameters.ParamByName('Ip').Value := myIp;
  writelog('open query');
    open;
    if (recordCount = 0) then
      result := getScreen('powerTrafoSpecs')
    else
      result := getScreen('trafoFoundText');
  end;
  writelog('einde function');
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
    add('insert into tb210_power_trafo_calcspecs values (:myIp, :thisTrafoNum, :isClosed, :isOrdered, :hasDownloadedSchematic, :primaryVA,' +
        ':primaryAmps, :coreArea, :turnsPerVolt, :primWireSize, :primaryTurns, :secundaryTurns, :fiftyVoltTapTurns, :secCenterTapTurns, ' +
        ':secWireSize, :filFiveTurns, :filFiveCtTurns, :filFiveWireSize, :filSixTurns, :filSixCtTurns, :filSixWireSize, :filTwelveTurns,' +
        ':filTwelveCtTurns, :filTwelveWireSize, :primTurnArea, :secTurnArea, :fiveVoltTurnArea, :sixVoltTurnArea, :twelveVoltTurnArea, ' +
        ':totalTurnArea, :sizeEiSheets, :timestamp)');
    Parameters.ParamByName('myIp').Value := myIp;
    Parameters.ParamByName('thisTrafoNum').Value := thisTrafoNum;
    Parameters.ParamByName('isClosed').Value := false;
    Parameters.ParamByName('isOrdered').Value := false;
    Parameters.ParamByName('hasDownloadedSchematic').Value := false;
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
      result := true;
    except
      on E:exception do writelog(E.Message);
    end;
  end;
end;


end.
