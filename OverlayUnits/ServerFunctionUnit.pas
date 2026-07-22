unit ServerFunctionUnit;

interface
  uses System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, FormUnit1, System.StrUtils, system.math,
       CommonProcedureUnit, CommonFunctionUnit, PrinterServerUnit, dataBaseUnit;

  function getPlaceholders(htmlItem: String): String;
  function getDetailScreen(htmlItem: String): String;
  function constructPowerTrafoScreen(myIp, value: String): String;
  function checkForUnfinishedTrafo(myIp : String): String;
  function initNewPowerTrafo(myIp : String): String;
  function calculatePowerTrafo(myIp, fixValue: String): String;
  function storeTempTrafoSettings(myIp, myTrafoType, Part, pickedValues: String): String;
  function getObjectPrice(objectDescription: String): String;
  function getObjectInCart(objectArray, SessionId: String): String;
  function listGroupedCartItems(sessionId: String): String;
  function checkCart(sessionId: String): String;
  function listGroupedInvoiceItems(sessionId: String): String;
  function binPower(base, exponent: integer): integer;
  function saveSitePrefs(myIp, checkedOptions: String): String;
  function saveGridSettings(myIp, Voltage, Frequency: String): String;
  function getAddress(myIp, email, zipcode, houseNumber, houseNumberAdd: String): String;
  function saveSettings(myIp, fixValue: String): String;
  function checkSettings(myIp: String): String;
  function showStoredSettings(myIp: String; thisQuery: tAdoQuery): String;
  function prepareTrafoSales(myIp, trafoNumber: String): String;
  function performGenericMailMerge(myIp, trafoNumber, returnHTML, mailmergeLetter: String): String;
  function generateMaterialList(myIp, trafoNumber, returnHTML: String): String;
  function generateTurnSchematic(myIp, trafoNumber, returnHTML: String): String;

implementation

const
  dwnldMap = '\templates\download\';
  dataMap = '\templates\data\';
  templatesMap = '\templates\doc\';
  vbCrLf = #13 + #10;

function performGenericMailMerge(myIp, trafoNumber, returnHTML, mailmergeLetter: String): String;
  var
    myHeader, myData, sourceFile, curMap, plcHolder: String;
begin
  curMap := getCurrentDir;
  if returnHTML.IsEmpty then returnHTML := getScreen('emptyInfoDiv');

  plcHolder :=  getPlaceHolders('emptyInfoDiv');
  writelog(plcHolder);
  //init mailmerge
  sourceFile :=  mailmergeLetter + '_' + trafoNumber + '.csv';
  myHeader := getCsvHeader(mailmergeLetter) + vbCrLf ;
  myData := fetchTrafoData(myIp, trafoNumber, myHeader, mailmergeLetter);
  writeEntireFile(curMap + dataMap + sourceFile, myHeader + myData);

  if not checkDbSwitch(myIp, trafoNumber, mailmergeLetter) then begin
    returnHTML := StringReplace(returnHTML, plcHolder, getScreen(mailmergeLetter), [rfIgnoreCase]);
    returnHTML := StringReplace(returnHTML, plcHolder, getScreen(mailmergeLetter + 'Show'), [rfIgnoreCase]);
    PerformMailMergePdfPrinter(myIp, trafoNumber, mailmergeLetter, sourceFile);
    //PerformMailMerge(myIp, trafoNumber, mailmergeLetter, sourceFile);
  end;
  result := returnHTML;
end;

function generateMaterialList(myIp, trafoNumber, returnHTML: String): String;
begin
  result := performGenericMailMerge(myIp, trafoNumber, returnHTML, 'materiaalLijst');
end;

function generateTurnSchematic(myIp, trafoNumber, returnHTML: String): String;
begin
  result := performGenericMailMerge(myIp, trafoNumber, returnHTML, 'wikkelschema');
end;

function prepareTrafoSales(myIp, trafoNumber: String): String;
var
  returnHTML, placeHolderAll: String;
  placeHolders: TArray<String>;
begin
  returnHTML := getScreen('finalizeTrafoVmenu');
  placeHolderAll := getPlaceHolders('finalizeTrafo');
  placeHolders := placeHolderAll.Split(['|']);
  returnHTML := returnHTML.Replace(placeHolders[0], trafoNumber);

  closeTrafoConfig(myIp, trafoNumber);
  result := returnHTML;
end;


function calculatePowerTrafo(myIp, fixValue: String): String;
  var
    htmlQuery, customerQuery: tAdoQuery;
    trafoNum, exportHtml, placeHoldersAll, placeBoolsAll: String;
    placeHolders, placeBools: TArray<String>;
    T, secCenterTap, tapFiftyVolt, filCenterTap: integer;

    primVoltage, primFreq, primaryAmps, secVoltage, secMilliAmps,
    primaryVA, coreArea, turnsPerVolt, primWireSize,
    primaryTurns, secundaryTurns, fiftyVoltTapTurns, secCenterTapTurns,
    secWireSize, filFiveAmps, filSixAmps, filTwelveAmps, filFiveTurns,
    filSixTurns, filTwelveTurns, filFiveWireSize, filSixWireSize,
    filTwelveWireSize, primTurnArea, secTurnArea, fiveVoltTurnArea,
    sixVoltTurnArea, twelveVoltTurnArea, filFiveCTturns, filSixCTturns,
    filTwelveCTturns: single;
    itemValues: array[0..26] of String;
  const
    htmlItem = 'calculatedTrafoSpecs';
begin
  htmlQuery := tAdoQuery.Create(nil);
  htmlQuery.Connection := form1.adoConnHtmlPages;
  customerQuery := tAdoQuery.Create(nil);
  customerQuery.Connection := form1.adoVoorThuisCustomerSales;

  exportHtml := getScreen(htmlItem);
  placeHoldersAll := getPlaceholders(htmlItem);
  placeBoolsAll := getPlaceholders(htmlItem + 'Bools');
  placeHolders := placeHoldersAll.Split(['|']);
  placeBools := placeBoolsAll.Split(['|']);

  if storeTempTrafoSettings(myIp, 'powertrafo', '2', fixValue) = 'ok' then begin
    powerTrafoSaveFinalizeSpecs(myIp, fixValue);

    with customerQuery, SQL do begin
      clear;
      add('select * from tb200_power_trafo_config where ip = :myIp and isClosed = false');
      Parameters.ParamByName('myIp').Value := myIp;
      open;

      trafoNum := fieldByName('trafoNum').AsString;
      secVoltage := fieldByName('volts').AsFloat;
      secMilliAmps := fieldByName('milliAmps').AsFloat;
      filFiveAmps := fieldByName('filamentFiveAmps').AsFloat;
      filSixAmps := fieldByName('filamentSixAmps').AsFloat;
      filTwelveAmps := fieldByName('filamentTwelveAmps').AsFloat;
      secCenterTap := fieldByName('centerTap').asInteger;
      tapFiftyVolt := fieldByName('tapFiftyVolt').asInteger;
      filCenterTap := fieldByName('filamentCenterTap').asInteger;
    end;

    getGridValues(myIp, primVoltage, primFreq);

    //hier starten de berekeningen
    primaryVA          := getSumVASecundary(myIp, trafoNum);
    primaryAmps        := primaryVA / primVoltage;
    coreArea           := sqrt(primaryVA) * 1.15;
    turnsPerVolt       := primFreq / coreArea * fluxDensity;
    primWireSize       := getWireSize(primaryVA, primVoltage);
    primaryTurns       := turnsPerVolt * primVoltage;
    secundaryTurns     := turnsPerVolt * secVoltage;
    fiftyVoltTapTurns  := 50 * turnsPerVolt;
    secCenterTapTurns  := secundaryTurns / 2;
    secWireSize        := getWireSize(secMilliAmps, true);
    filFiveTurns       := turnsPerVolt * filamentFiveVolts;
    filFiveCTturns     := filFiveTurns / 2;
    filSixTurns        := turnsPerVolt * filamentSixVolts;
    filSixCTturns      := filSixTurns / 2;
    filTwelveTurns     := turnsPerVolt * filamentTwelveVolts;
    filTwelveCTturns   := filTwelveTurns / 2;
    filFiveWireSize    := getWireSize(filFiveAmps, false);
    filSixWireSize     := getWireSize(filSixAmps, false);
    filTwelveWireSize  := getWireSize(filTwelveAmps, false);
    primTurnArea       := calcTurnArea(primWireSize, primaryTurns);
    secTurnArea        := calcTurnArea(secWireSize, secundaryTurns);
    fiveVoltTurnArea   := calcTurnArea(filFiveWireSize, filFiveTurns);
    sixVoltTurnArea    := calcTurnArea(filSixWireSize, filSixTurns);
    twelveVoltTurnArea := calcTurnArea(filTwelveWireSize, filTwelveTurns);

    //vervang de placeholders door de berekende waarden
    itemValues[00] := format('%5.0f', [primaryVA]).trim;
    itemValues[01] := format('%5.2f', [primaryAmps]).trim;
    itemValues[02] := format('%5.2f', [coreArea]).trim;
    itemValues[03] := format('%5.2f', [turnsPerVolt]).trim;
    itemValues[04] := format('%5.2f', [primWireSize]).trim;
    itemValues[05] := format('%5.0f', [primaryTurns]).trim;
    itemValues[06] := format('%5.0f', [secundaryTurns]).trim;
    itemValues[07] := format('%5.0f', [fiftyVoltTapTurns]).trim;
    itemValues[08] := format('%5.0f', [secCenterTapTurns]).trim;
    itemValues[09] := format('%5.2f', [secWireSize]).trim;
    itemValues[10] := format('%5.0f', [filFiveTurns]).trim;
    itemValues[11] := format('%5.0f', [filFiveCTturns]).trim;
    itemValues[12] := format('%5.2f', [filFiveWireSize]).trim;
    itemValues[13] := format('%5.0f', [filSixTurns]).trim;
    itemValues[14] := format('%5.0f', [filSixCTturns]).trim;
    itemValues[15] := format('%5.2f', [filSixWireSize]).trim;
    itemValues[16] := format('%5.0f', [filTwelveTurns]).trim;
    itemValues[17] := format('%5.0f', [filTwelveCTturns]).trim;
    itemValues[18] := format('%5.2f', [filTwelveWireSize]).trim;
    itemValues[19] := format('%5.2f', [primTurnArea]).trim;
    itemValues[20] := format('%5.2f', [secTurnArea]).trim;
    itemValues[21] := format('%5.2f', [fiveVoltTurnArea]).trim;
    itemValues[22] := format('%5.2f', [sixVoltTurnArea]).trim;
    itemValues[23] := format('%5.2f', [twelveVoltTurnArea]).trim;
    itemValues[24] := format('%5.2f', [primTurnArea + secTurnArea + fiveVoltTurnArea + sixVoltTurnArea + twelveVoltTurnArea]).trim;
    itemValues[25] := getSuitableEiType(primTurnArea + secTurnArea + fiveVoltTurnArea + sixVoltTurnArea + twelveVoltTurnArea);
    itemValues[26] := trafoNum;

    for T := 0 to length(placeholders) do exportHtml := exportHtml.Replace(placeHolders[T], itemValues[T]);

    if tapFiftyVolt = 0 then begin
      exportHtml := exportHtml.Replace(placeBools[0],'hidden');
      itemValues[07] := '0';
    end else exportHtml.Replace(placeBools[0],'');

    if secCenterTap = 0 then begin
      exportHtml := exportHtml.Replace(placeBools[1],'hidden');
      itemValues[08] := '0'
    end else exportHtml.Replace(placeBools[1],'');

    if filCenterTap = 0 then begin
      exportHtml := exportHtml.Replace(placeBools[2],'hidden');
      itemValues[11] := '0';
      itemValues[14] := '0';
      itemValues[17] := '0';
    end else exportHtml.Replace(placeBools[2],'');

    if filFiveWireSize   = 0 then begin
      exportHtml := exportHtml.Replace(placeBools[3],'hidden');
      itemValues[10] := '0';
      itemValues[11] := '0';
      itemValues[12] := '0.00';
    end else exportHtml.Replace(placeBools[3],'');

    if filSixWireSize    = 0 then begin
      exportHtml := exportHtml.Replace(placeBools[4],'hidden');
      itemValues[13] := '0';
      itemValues[14] := '0';
      itemValues[15] := '0.00';
    end else exportHtml.Replace(placeBools[4],'');

    if filTwelveWireSize = 0 then begin
      exportHtml := exportHtml.Replace(placeBools[5],'hidden');
      itemValues[16] := '0';
      itemValues[17] := '0';
      itemValues[18] := '0.00';
    end else exportHtml.Replace(placeBools[5],'');

    if saveCalculatedTrafoSpecs(myIp, trafoNum, itemValues) then result := exportHtml;
  end;
end;

function checkSettings(myIp: String): String;
var
  customerQuery: tAdoQuery;
begin
  customerQuery := tAdoQuery.Create(nil);
  customerQuery.Connection := form1.adoVoorThuisCustomerSales;

  with customerQuery do begin
    SQL.Clear;
    SQL.add('select * from vw925_customerstats where Ip = :Ip');
    Parameters.ParamByName('Ip').Value := myIp;
    open;
    if (recordCount = 0) then
      result := getScreen('settings')
    else
      result := showStoredSettings(myIp, customerQuery);
  end;
end;

function showStoredSettings(myIp: String; thisQuery: tAdoQuery): String;
var
  settingsHtml, StringPlaceHolders: String;
  placeHolders: TArray<String>;
  T: integer;
begin
  settingsHtml := getScreen('storedSettings');
  StringPlaceHolders := getPlaceholders('storedSettings');
  placeHolders := StringPlaceHolders.Split(['|']);
  for T := 0 to length(placeHolders) do begin
    if thisQuery.Fields[T + 1].asString = '1' then
      settingsHtml := settingsHtml.Replace(placeHolders[T], 'checked')
    else
      settingsHtml := settingsHtml.Replace(placeHolders[T], thisQuery.Fields[T + 1].asString);
  end;

  result := settingsHtml;
end;

function saveSettings(myIp, fixValue: String): String;
var
  fixElements: TArray<String>;
  elementParts: TArray<String>;
  T: integer;
  gridVoltage, gridFreq, email, zipcode, hsNumber, hsNumberTvo, saveSettings: String;
begin
  fixElements :=  fixValue.Split(['-']);

  for T := 0 to length(fixElements) - 1 do begin
    try
    elementParts := fixElements[T].Split(['=']);

    if elementParts[0] = 'gridVoltage' then gridVoltage := elementParts[1];
    if elementParts[0] = 'gridFreq' then gridFreq := elementParts[1];
    if elementParts[0] = 'email' then email := elementParts[1];
    if elementParts[0] = 'zipcode' then zipcode := elementParts[1];
    if elementParts[0] = 'hsNumber' then hsNumber := elementParts[1];
    if elementParts[0] = 'hsNumberTvo' then hsNumberTvo := elementParts[1];
    if elementParts[0] = 'saveSettings' then saveSettings := elementParts[1];
    except
    if elementParts[0] = 'gridVoltage' then gridVoltage := '';
    if elementParts[0] = 'gridFreq' then gridFreq := '';
    if elementParts[0] = 'email' then email := '';
    if elementParts[0] = 'zipcode' then zipcode := '';
    if elementParts[0] = 'hsNumber' then hsNumber := '';
    if elementParts[0] = 'hsNumberTvo' then hsNumberTvo := '';
    if elementParts[0] = 'saveSettings' then saveSettings := '';
    end;
  end;
  saveGridSettings(myIp, gridVoltage, gridFreq);
  getAddress(myIp, email, zipcode, hsNumber, hsNumberTvo);
  saveSitePrefs(myIp, saveSettings);
  result := checkSettings(myIp);
end;

function getAddress(myIp, email, zipcode, houseNumber, houseNumberAdd: String): String;
var
  customerQuery: tAdoQuery;
begin
  customerQuery := tAdoQuery.Create(nil);
  customerQuery.Connection := form1.adoVoorThuisCustomerSales;

  with customerQuery do begin
    SQL.Clear;
    SQL.add('delete from tb110_address where Ip = :Ip');
    Parameters.ParamByName('Ip').Value := myIp;
    try
      execSql;
    except
      on E:exception do writelog(E.Message);
    end;

    SQL.Clear;
    SQL.add('insert into tb110_address values (:Ip, :email, :zipCode, :hsNumber, :hsNumTvo, :Timestamp)');
    Parameters.ParamByName('Ip').Value := myIp;
    Parameters.ParamByName('email').Value := email;
    Parameters.ParamByName('zipCode').Value := zipcode;
    Parameters.ParamByName('hsNumber').Value := houseNumber;
    Parameters.ParamByName('hsNumTvo').Value := houseNumberAdd;
    Parameters.ParamByName('timestamp').Value := generateTimestamp;
    try
      execSql;
      result := '<br>' + fetchAddressByZipcode(zipcode, houseNumber, houseNumberAdd);
    except
      on E:exception do writelog(E.Message);
    end;
  end;
end;

function saveGridSettings(myIp, Voltage, Frequency: String): String;
var
  customerQuery: tAdoQuery;
begin
  customerQuery := tAdoQuery.Create(nil);
  customerQuery.Connection := form1.adoVoorThuisCustomerSales;

  with customerQuery do begin
    SQL.Clear;
    SQL.add('delete from tb930_grid_settings_per_ip where Ip = :Ip');
    Parameters.ParamByName('Ip').Value := myIp;
    try
      execSql;
    except
      on E:exception do writelog(E.Message);
    end;

    SQL.Clear;
    SQL.add('insert into tb930_grid_settings_per_ip values (:Ip, :VoltageElectraGrid, :FreqElectraGrid, :Timestamp)');
    Parameters.ParamByName('Ip').Value := myIp;
    Parameters.ParamByName('VoltageElectraGrid').Value := Voltage;
    Parameters.ParamByName('FreqElectraGrid').Value := Frequency;
    Parameters.ParamByName('timestamp').Value := generateTimestamp;
    try
      execSql;
      result := 'Netwerkgegevens opgeslagen.'
    except
      on E:exception do writelog(E.Message);
    end;
  end;
end;

function saveSitePrefs(myIp, checkedOptions: String): String;
var
  customerQuery: tAdoQuery;
  options: array[1..4] of boolean;
  T: integer;
begin
  customerQuery := tAdoQuery.Create(nil);
  customerQuery.Connection := form1.adoVoorThuisCustomerSales;

  for T := 1 to 4 do begin
    if (StrToInt(checkedOptions) and binPower(2, T) = binPower(2, T)) then
      options[T] := true
    else
      options[T] := false;
  end;


  with customerQuery do begin
    SQL.Clear;
    SQL.add('delete from tb920_customer_settings where Ip = :Ip');
    Parameters.ParamByName('Ip').Value := myIp;
    try
      execSql;
    except
      on E:exception do writelog(E.Message);
    end;

    SQL.Clear;
    SQL.add('insert into tb920_customer_settings values (:Ip, :PermissionStoreAddress, :PermissionStorePaymentStats, ' +
            ':AgreeShopConditions, :ShowInteractiveHelp, :Timestamp)');

    Parameters.ParamByName('Ip').Value := myIp;
    Parameters.ParamByName('PermissionStoreAddress').Value := options[1];
    Parameters.ParamByName('PermissionStorePaymentStats').Value := options[2];
    Parameters.ParamByName('AgreeShopConditions').Value := options[3];
    Parameters.ParamByName('ShowInteractiveHelp').Value := options[4];
    Parameters.ParamByName('timestamp').Value := generateTimestamp;
    try
      execSql;
      result := 'Opties opgeslagen.'
    except
      on E:exception do writelog(E.Message);
    end;
  end;
end;

function getPlaceholders(htmlItem: String): String;
  var
  thisQuery: tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoConnHtmlPages;
  with thisQuery do begin
    SQL.Clear;
    SQL.add('select placeHolderString from tb910_placeholders where functionName = :loadItem');
    Parameters.ParamByName('loadItem').Value := htmlItem;
    open;
    Result := fields[0].AsString;
  end;
end;


function storeTempTrafoSettings(myIp, myTrafoType, Part, pickedValues: String): String;
  var
  thisQuery: tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoVoorThuisCustomerSales;

  with thisQuery do begin
    SQL.Clear;
    SQL.add('delete from tb910_temp_trafo_settings where Ip = :ip and Part = :part');
    Parameters.ParamByName('Ip').Value := myIp;
    Parameters.ParamByName('part').Value := Part;
    execSql;
  end;

  with thisQuery do begin
    SQL.Clear;
    SQL.add('insert into tb910_temp_trafo_settings (Ip, Part, TrafoType, CommonValues, Timestamp) values (:ip, :Part, :TrafoType, :CommonValues, :timestamp)');
    Parameters.ParamByName('Ip').Value := myIp;
    Parameters.ParamByName('Part').Value := Part;
    Parameters.ParamByName('TrafoType').Value := myTrafoType;
    Parameters.ParamByName('CommonValues').Value := pickedValues;
    Parameters.ParamByName('timestamp').Value := generateTimestamp;
    try
      execSql;
      Result := 'ok';
    except
      on E:exception do writelog(E.Message);
    end;
  end;
end;

function checkForUnfinishedTrafo(myIp : String): String;
  var
  thisQuery: tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoVoorThuisCustomerSales;

  result := '';

  with thisQuery do begin
    SQL.Clear;
    SQL.add('select trafoNum from tb200_power_trafo_config where ip = :myIp and isClosed = :isClosed');
    Parameters.ParamByName('myIp').Value := myIp;
    Parameters.ParamByName('isClosed').Value := false;
    try
    open;
    if thisQuery.RecordCount > 0 then
      result := fields[0].AsString;
    except
      on E:exception do writelog(E.Message);
    end;
  end;
end;

function initNewPowerTrafo(myIp : String): String;
  var
  thisQuery: tAdoQuery;
  currentTrafoNum: String;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoVoorThuisCustomerSales;

  currentTrafoNum := checkForUnfinishedTrafo(myIp);

  if currentTrafoNum = '' then
    currentTrafoNum := getCurrentNumber('powertrafo')
  else begin
    with thisQuery do begin
      SQL.Clear;
      SQL.add('delete from tb200_power_trafo_config where ip = :myIp and trafoNum = :trafoNum and isClosed = :isClosed');
      Parameters.ParamByName('myIp').Value := myIp;
      Parameters.ParamByName('trafoNum').Value := currentTrafoNum;
      Parameters.ParamByName('isClosed').Value := false;
      try
        execSql;
      except
        on E:exception do writelog(E.Message);
      end;
    end;
  end;

  with thisQuery do begin
    SQL.Clear;
    SQL.add('insert into tb200_power_trafo_config values' +
            '(:ip, :trafoNum, :isClosed, :secundary, :volts, :milliAmps, :centerTap, :tapFiftyVolt, ' +
            ':filamentFiveAmps, :filamentSixAmps, :filamentTwelveAmps, :filamentCenterTap, :timestamp)');

    Parameters.ParamByName('ip').Value := myIp;
    Parameters.ParamByName('trafoNum').Value := currentTrafoNum;
    Parameters.ParamByName('isClosed').Value := false;
    Parameters.ParamByName('secundary').Value := true;
    Parameters.ParamByName('volts').Value := 0;
    Parameters.ParamByName('milliAmps').Value := 0;
    Parameters.ParamByName('centerTap').Value := false;
    Parameters.ParamByName('tapFiftyVolt').Value := false;
    Parameters.ParamByName('filamentFiveAmps').Value := 0;
    Parameters.ParamByName('filamentSixAmps').Value := 0;
    Parameters.ParamByName('filamentTwelveAmps').Value := 0;
    Parameters.ParamByName('filamentCenterTap').Value := false;
    Parameters.ParamByName('timestamp').Value := generateTimestamp;

    try
      execSql;
      Result := currentTrafoNum;
    except
      on E:exception do writelog(E.Message);
    end;
  end;
end;


function constructPowerTrafoScreen(myIp, value: String): String;
  var
  thisQuery: tAdoQuery;
  T, tempValue: integer;
  mainHtml, trafoId: String;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoConnHtmlPages;

  if (storeTempTrafoSettings(myIp, 'powertrafo', '1', value) = 'ok') then begin
    trafoId := initNewPowerTrafo(myIp);

    with thisQuery do begin
      SQL.Clear;
      SQL.add('select HtmlCode from TB120_html_snippets where id = :idName and itemNr = :itemNr');
      Parameters.ParamByName('idName').Value := 'powerTrafoDetails';
      Parameters.ParamByName('itemNr').Value := 0;
      try
        open;
      except
        on E:exception do writelog(E.Message);
      end;
      mainHtml := fields[0].AsString;
      close;
    end;

    for T := 6 downto 0 do begin
      tempValue := binPower(2, T);

      if (strToInt(value) and tempValue = tempValue) then begin
        with thisQuery do begin
          SQL.Clear;
          SQL.add('select HtmlCode from TB120_html_snippets where id = :idName and itemNr = :itemNr');
          Parameters.ParamByName('idName').Value := 'powerTrafoDetails';
          Parameters.ParamByName('itemNr').Value := tempValue;
          open;
          mainHtml := mainHtml.Replace('$snippet' + intToStr(tempValue), fields[0].AsString);
          close;
        end;
      end else
        mainHtml := mainHtml.Replace('$snippet' + intToStr(tempValue), '');
    end;
    result := mainHtml;
  end;
end;


function getDetailScreen(htmlItem: String): String;
  var
  thisQuery: tAdoQuery;
  inlineHTML, textPlaceHolder, pricePlaceHolder, bigImagePH, thumbNailPH: String;
  buildThumbNailBar, zoomImage, imageTitle, candlePrice: String;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoConnHtmlPages;
  with thisQuery do begin
    SQL.Clear;
    SQL.Add('select * from TB100_HtmlPages where id = "DetailPage"');
    open;
    inlineHTML := fieldByName('InlineHtml').AsString;
    textPlaceHolder := fieldByName('TextPlaceHolder').AsString;
    pricePlaceHolder := fieldByName('PricePlaceHolder').AsString;
    bigImagePH := fieldByName('ImagePlaceHolderBig').AsString;
    thumbNailPH := fieldByName('ImagePlaceHolderThumbNailBar').AsString;
  end;

  buildThumbNailBar := '';
  with thisQuery do begin
    SQL.Clear;
    SQL.add('select * from vw200_pricelist where name = :imageHtml order by 2');
    Parameters.ParamByName('imageHtml').Value := htmlItem;
    open;
    First;

    zoomImage := fieldByName('ImagePathHTML').AsString;
    zoomImage := StringReplace(zoomImage, 'smallImage', 'bigImage', [rfReplaceAll, rfIgnoreCase]);
    candlePrice := format('%4.2f', [fieldByName('Price').Asfloat]);
    imageTitle := fieldByName('Description').AsString;

    while not Eof do begin
      buildThumbNailBar := buildThumbNailBar + fieldByName('ImagePathHTML').AsString;
      Next;
    end;
  end;
  inlineHtml := StringReplace(inlineHtml, bigImagePH, zoomImage, [rfReplaceAll, rfIgnoreCase]);
  inlineHtml := StringReplace(inlineHtml, thumbNailPH, buildThumbNailBar, [rfReplaceAll, rfIgnoreCase]);

  with thisQuery do begin
    SQL.Clear;
    SQL.add('select * from tb120_textblocks where ItemName = :ItemName');
    Parameters.ParamByName('ItemName').Value := htmlItem;
    open;
    inlineHtml := StringReplace(inlineHtml, textPlaceHolder, StringReplace(fieldByName('Description').AsString, #10, '<br>', [rfReplaceAll, rfIgnoreCase]), [rfReplaceAll, rfIgnoreCase]);
    inlineHtml := StringReplace(inlineHtml, pricePlaceHolder, '€ ' + candlePrice, [rfReplaceAll, rfIgnoreCase]);
    inlineHtml := StringReplace(inlineHtml, 'Header Tekst', imageTitle, [rfReplaceAll, rfIgnoreCase]);
  end;

  result := inlineHtml;
end;

function getObjectPrice(objectDescription: String): String;
  var
  thisQuery: tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoConnHtmlPages;

  with thisQuery do begin
    SQL.Clear;
    SQL.Add('select price from vw200_pricelist where description = :description');
    Parameters.ParamByName('description').Value := objectDescription;
    open;
    result := '€ ' + format('%4.2f', [fieldByName('price').AsFloat]);
  end;
end;

function checkCart(sessionId: String): String;
  var
  thisQuery: tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoVoorThuisCustomerSales;

  with thisQuery do begin
    SQL.Clear;
    SQL.Add('select gotItems from tb300_shoppingcart where ClientId = :ClientId');
    Parameters.ParamByName('ClientId').Value := sessionId;
    open;
    result := fieldByName('gotItems').AsString;
  end;
end;

function listGroupedCartItems(sessionId: String): String;
  var
  salesQuery, htmlQuery: tAdoQuery;
  outterHtml, inlineHtml, cartFlexBox, cartFlexBoxContainer, cartLines, hulp1String, hulp2String: String;
  placeHolder: array[0..7] of String;
begin
  salesQuery := tAdoQuery.Create(nil);
  htmlQuery := tAdoQuery.Create(nil);
  salesQuery.Connection := form1.adoVoorThuisCustomerSales;
  htmlQuery.Connection := form1.adoConnHtmlPages;

  with htmlQuery do begin
    SQL.Clear;
    SQL.Add('SELECT * from tb100_htmlpages WHERE id IN ("cartFlexBox", "cartOrderLine", "cartFlexBoxContainer", "shoppingCartItems")order by 1 desc');
    open;

    first;
    outterHtml := fieldByName('inlineHtml').AsString;
    placeHolder[0] := fieldByName('TextPlaceHolder').AsString;

    next;
    inlineHtml := fieldByName('inlineHtml').AsString;
    placeHolder[1] := fieldByName('TextPlaceHolder').AsString;
    placeHolder[2] := fieldByName('PricePlaceholder').AsString;
    placeHolder[3] := fieldByName('ImagePlaceHolderBig').AsString;
    placeHolder[4] := fieldByName('ImagePlaceHolderThumbNailBar').AsString;

    next;
    cartFlexBoxContainer := fieldByName('inlineHtml').AsString;
    placeHolder[5] := fields[1].AsString;

    next;
    cartFlexBox := fieldByName('inlineHtml').AsString;
    placeHolder[6] := fields[1].AsString;
    placeHolder[7] := fields[3].AsString;
  end;

  with salesQuery do begin
    SQL.Clear;
    SQL.Add('SELECT a.Description, SUM(a.itemsOrdered) AS itemTotal, a.Price AS itemPrice, SUM(a.totalItemPrice) AS orderLineTotal, b.ImageSource ');
    SQL.Add('from TB310_ShoppingCartItems a, ');
    SQL.Add('	  	VoorThuisHtmlPages.tb110_images b ');
    SQL.Add('where ClientId = :ClientIdEen ');
    SQL.Add('AND   a.Description = b.Description ');
    SQL.Add('GROUP BY a.Description ');
    SQL.Add('UNION ');
    SQL.Add('SELECT "totaal", SUM(itemsOrdered) AS itemTotal, null, SUM(totalItemPrice) AS orderLineTotal, "images/diversen/order_icon.png" ');
    SQL.Add('from TB310_ShoppingCartItems ');
    SQL.Add('where ClientId = :ClientIdTwee');

    Parameters.ParamByName('ClientIdEen').Value := sessionId;
    Parameters.ParamByName('ClientIdTwee').Value := sessionId;
    open;

    cartLines := '';
    first;
    while not Eof do begin
      hulp1String := StringReplace(inlineHTML, placeHolder[1], fieldByName('description').AsString,[rfReplaceAll, rfIgnoreCase]);
      hulp1String := StringReplace(hulp1String, placeHolder[2], fieldByName('itemTotal').AsString,[rfReplaceAll, rfIgnoreCase]);
      hulp1String := StringReplace(hulp1String, placeHolder[3], format('%4.2f', [fieldByName('itemPrice').AsFloat]),[rfReplaceAll, rfIgnoreCase]);
      hulp1String := StringReplace(hulp1String, placeHolder[4], format('%4.2f', [fieldByName('orderLineTotal').AsFloat]),[rfReplaceAll, rfIgnoreCase]);
      hulp2String := StringReplace(cartFlexBox, placeHolder[6], hulp1String, [rfReplaceAll, rfIgnoreCase]);
      hulp2String := StringReplace(hulp2String, placeHolder[7], fieldByName('ImageSource').AsString, [rfReplaceAll, rfIgnoreCase]);
      cartLines := cartLines + hulp2String + #13#10;
      next;
    end;
    cartFlexBoxContainer := StringReplace(cartFlexBoxContainer, placeHolder[5], cartLines, [rfReplaceAll, rfIgnoreCase]);

  end;
  result := StringReplace(outterHtml, placeHolder[0], cartFlexBoxContainer, [rfReplaceAll, rfIgnoreCase]);
end;

function listGroupedInvoiceItems(sessionId: String): String;
  var
  salesQuery, htmlQuery: tAdoQuery;
  inlineHtml, cartFlexBox, cartFlexBoxContainer, cartLines, hulp1String, hulp2String, totalLine: String;
  placeHolder: array[0..8] of String;
  T: integer;
begin
  salesQuery := tAdoQuery.Create(nil);
  htmlQuery := tAdoQuery.Create(nil);
  salesQuery.Connection := form1.adoVoorThuisCustomerSales;
  htmlQuery.Connection := form1.adoConnHtmlPages;

  with htmlQuery do begin
    SQL.Clear;
    SQL.Add('SELECT * from tb100_htmlpages WHERE id IN ("invoiceFlexBox", "invoiceOrderLine", "invoiceFlexBoxContainer", "invoiceAbsTotalLine")order by 1 desc');
    open;

    first;
    inlineHtml := fieldByName('inlineHtml').AsString;
    placeHolder[0] := fieldByName('TextPlaceHolder').AsString;
    placeHolder[1] := fieldByName('PricePlaceholder').AsString;
    placeHolder[2] := fieldByName('ImagePlaceHolderBig').AsString;
    placeHolder[3] := fieldByName('ImagePlaceHolderThumbNailBar').AsString;

    next;
    cartFlexBoxContainer := fieldByName('inlineHtml').AsString;
    placeHolder[4] := fields[1].AsString;

    next;
    cartFlexBox := fieldByName('inlineHtml').AsString;
    placeHolder[5] := fields[1].AsString;
    placeHolder[6] := fields[3].AsString;

    next;
    totalLine := fieldByName('inlineHtml').AsString;
    placeHolder[7] := fields[1].AsString;
    placeHolder[8] := fields[3].AsString;
  end;

  with salesQuery do begin
    SQL.Clear;
    SQL.Add('SELECT a.Description, SUM(a.itemsOrdered) AS itemTotal, a.Price AS itemPrice, SUM(a.totalItemPrice) AS orderLineTotal, b.ImageSource ');
    SQL.Add('from TB310_ShoppingCartItems a, ');
    SQL.Add('	  	VoorThuisHtmlPages.tb110_images b ');
    SQL.Add('where ClientId = :ClientIdEen ');
    SQL.Add('AND   a.Description = b.Description ');
    SQL.Add('GROUP BY a.Description ');
    SQL.Add('UNION ');
    SQL.Add('SELECT "totaal", SUM(itemsOrdered) AS itemTotal, null, SUM(totalItemPrice) AS orderLineTotal, "images/diversen/order_icon.png" ');
    SQL.Add('from TB310_ShoppingCartItems ');
    SQL.Add('where ClientId = :ClientIdTwee');

    Parameters.ParamByName('ClientIdEen').Value := sessionId;
    Parameters.ParamByName('ClientIdTwee').Value := sessionId;
    open;

    cartLines := '';
    first;
    for T := 0 to recordCount - 1 do begin
      hulp1String := StringReplace(inlineHTML, placeHolder[0], fieldByName('description').AsString,[rfReplaceAll, rfIgnoreCase]);
      hulp1String := StringReplace(hulp1String, placeHolder[1], fieldByName('itemTotal').AsString,[rfReplaceAll, rfIgnoreCase]);
      hulp1String := StringReplace(hulp1String, placeHolder[2], format('%4.2f', [fieldByName('itemPrice').AsFloat]),[rfReplaceAll, rfIgnoreCase]);
      hulp1String := StringReplace(hulp1String, placeHolder[3], format('%4.2f', [fieldByName('orderLineTotal').AsFloat]),[rfReplaceAll, rfIgnoreCase]);
      hulp1String := StringReplace(hulp1String, '#', intToStr(T),[rfReplaceAll, rfIgnoreCase]);

      if T = recordCount - 1 then begin
        hulp1String := StringReplace(hulp1String, 'type="button"', 'type="button" disabled',[rfReplaceAll, rfIgnoreCase]);
        hulp1String := StringReplace(hulp1String, '0,00', '',[rfReplaceAll, rfIgnoreCase]);
        hulp1String := StringReplace(hulp1String, 'numberInput' + intToStr(T), 'totalNumberItems',[rfReplaceAll, rfIgnoreCase]);
        hulp1String := StringReplace(hulp1String, 'tdInvoiceRowTotal' + intToStr(T), 'totalInput',[rfReplaceAll, rfIgnoreCase]);
        hulp1String := StringReplace(hulp1String, '"images/diversen/bin.png"', '"images/diversen/wallet.png"',[rfReplaceAll, rfIgnoreCase]);
        hulp1String := StringReplace(hulp1String, '"regel verwijderen"', '"naar afrekenen"',[rfReplaceAll, rfIgnoreCase]);
        //invoiceWallet
        hulp1String := StringReplace(hulp1String, '"invoiceIcon"', '"invoiceWallet"',[rfReplaceAll, rfIgnoreCase]);
      end;

      hulp2String := StringReplace(cartFlexBox, placeHolder[5], hulp1String, [rfReplaceAll, rfIgnoreCase]);
      hulp2String := StringReplace(hulp2String, placeHolder[6], fieldByName('ImageSource').AsString, [rfReplaceAll, rfIgnoreCase]);
      cartLines := cartLines + hulp2String + #13#10;
      next;
    end;
    cartFlexBoxContainer := StringReplace(cartFlexBoxContainer, placeHolder[4], cartLines, [rfReplaceAll, rfIgnoreCase]);
    writeLog(cartFlexBoxContainer);
  end;
  result := cartFlexBoxContainer;
end;


function getObjectInCart(objectArray, SessionId: String): String;
  var
  thisQuery: tAdoQuery;
  objectList: TStringList;
  myDescription, itemName, IndexNr: String;
  numberOfItems, Price: single;
  lastOrderNum: integer;
begin
  objectList := TStringList.Create;
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoVoorThuisCustomerSales;

  Split('|', objectArray, objectList);

  myDescription := objectList[0];
  numberOfItems := StrToFloat(objectList[1]);

  with thisQuery do begin
    SQL.Clear;
    SQL.Add('select * from vw200_pricelist where description = :description');
    Parameters.ParamByName('description').Value := myDescription;
    open;
    itemName := fieldByName('Name').AsString;
    IndexNr := fieldByName('IndexNr').AsString;
    Price := fieldByName('Price').AsFloat;
  end;

  with thisQuery do begin
    SQL.Clear;
    SQL.Add('select (max(OrderRow) + 1) as maxOrderNum from TB310_ShoppingCartItems where ClientId = :ClientId');
    Parameters.ParamByName('ClientId').Value := SessionId;
    open;
    lastOrderNum := fieldByName('maxOrderNum').AsInteger;
  end;

  with thisQuery do begin
    SQL.Clear;
    SQL.Add('insert into TB310_ShoppingCartItems (ClientId, OrderRow, Description, IndexNr, ItemsOrdered, Price, TotalItemPrice, Timestamp) values (:ClientId, :OrderRow, :Description, :IndexNr, :ItemsOrdered, :Price, :TotalItemPrice, :Timestamp)');
    Parameters.ParamByName('ClientId').Value := SessionId;
    Parameters.ParamByName('OrderRow').Value := lastOrderNum;
    Parameters.ParamByName('Description').Value := myDescription;
    Parameters.ParamByName('IndexNr').Value := IndexNr;
    Parameters.ParamByName('ItemsOrdered').Value := numberOfItems;
    Parameters.ParamByName('Price').Value := Price;
    Parameters.ParamByName('TotalItemPrice').Value := numberOfItems * Price;
    Parameters.ParamByName('Timestamp').Value := generateTimestamp();
    execSql;
  end;

  with thisQuery do begin
    SQL.Clear;
    SQL.Add('update tb300_shoppingcart set gotItems = true, Timestamp = :Timestamp where ClientId = :ClientId');
    Parameters.ParamByName('ClientId').Value := SessionId;
    Parameters.ParamByName('Timestamp').Value := generateTimestamp();
    execSql;
  end;
  result := 'item is succesvol in het winkelwagentje geplaatst';
end;

function binPower(base, exponent: integer): integer;
var
  I, myResult, tempBase: integer;
begin
  tempBase := base;
  if exponent = 0 then
    myResult := 1
  else begin
    for I := 1 to exponent-1 do begin
      base := base * tempBase;
    end;
    myResult := base;
    end;
    result := myResult;
end;

end.
