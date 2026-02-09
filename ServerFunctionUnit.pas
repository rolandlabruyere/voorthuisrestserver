unit ServerFunctionUnit;

interface
  uses System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, FormUnit1, System.StrUtils, system.math,
       CommonProcedureUnit, CommonFunctionUnit;

  function getScreen(htmlItem: string): string;
  function getDetailScreen(htmlItem: string): string;
  function constructPowerTrafoScreen(myIp, value: String): string;
  function checkForUnfinishedTrafo(myIp : String): string;
  function initNewPowerTrafo(myIp : String): string;
  function calculatePowerTrafo(myIp, fixValue: String): string;
  function storeTempTrafoSettings(myIp, myTrafoType, Part, pickedValues: String): string;
  function getObjectPrice(objectDescription: string): string;
  function getObjectInCart(objectArray, SessionId: string): string;
  function listGroupedCartItems(sessionId: string): string;
  function checkCart(sessionId: string): string;
  function listGroupedInvoiceItems(sessionId: string): string;
  function binPower(base, exponent: integer): integer;

implementation


function calculatePowerTrafo(myIp, fixValue: String): string;
  var
  htmlQuery, customerQuery: tAdoQuery;
  T, tempValue: integer;
  mainHtml: string;
begin
  htmlQuery := tAdoQuery.Create(nil);
  htmlQuery.Connection := form1.adoConnHtmlPages;
  customerQuery := tAdoQuery.Create(nil);
  customerQuery.Connection := form1.adoVoorThuisCustomerSales;

  if storeTempTrafoSettings(myIp, 'powertrafo', '2', fixValue) = 'ok' then begin
    with htmlQuery do begin
      SQL.Clear;
      SQL.add('select HtmlCode from TB120_html_snippets where id = :idName and itemNr = :itemNr');
      Parameters.ParamByName('idName').Value := 'powerTrafoCalculator';
      Parameters.ParamByName('itemNr').Value := 0;
      try
        open;
      except
        on E:exception do writelog(E.Message);
      end;
      mainHtml := fields[0].AsString;
      close;
    end;

    for T := 5 downto 0 do begin
 //     tempValue := binPower(2, T);

//      if (fixValue and tempValue = tempValue) then begin
//        with htmlQuery do begin
//          SQL.Clear;
//          SQL.add('select HtmlCode from TB120_html_snippets where id = :idName and itemNr = :itemNr');
//          Parameters.ParamByName('idName').Value := 'powerTrafoDetails';
//          Parameters.ParamByName('itemNr').Value := intToStr(tempValue);
//          open;
//          mainHtml := mainHtml.Replace('$snippet' + intToStr(tempValue), fields[0].AsString);
//          close;
//        end;
//      end else
//        mainHtml := mainHtml.Replace('$snippet' + intToStr(tempValue), '');
    end;
    result := mainHtml;
  end;
end;


function getScreen(htmlItem: string): string;
  var
  thisQuery: tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoConnHtmlPages;
  with thisQuery do begin
    SQL.Clear;
    SQL.add('select inlineHtml from TB100_HtmlPages where id = :loadItem');
    Parameters.ParamByName('loadItem').Value := htmlItem;
    open;
    Result := fields[0].AsString;
  end;
end;

function storeTempTrafoSettings(myIp, myTrafoType, Part, pickedValues: String): string;
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

function checkForUnfinishedTrafo(myIp : String): string;
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
    writelog(result);
  end;
end;

function initNewPowerTrafo(myIp : String): string;
  var
  thisQuery: tAdoQuery;
  currentTrafoNum: string;
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
            ':filamentFiveVolt, :filamentFiveAmps, :filamentSixVolt, :filamentSixAmps, ' +
            ':filamentTwelveVolt, :filamentTwelveAmps, :filamentCenterTap, :timestamp)');

    Parameters.ParamByName('ip').Value := myIp;
    Parameters.ParamByName('trafoNum').Value := currentTrafoNum;
    Parameters.ParamByName('isClosed').Value := false;
    Parameters.ParamByName('secundary').Value := true;
    Parameters.ParamByName('volts').Value := 0;
    Parameters.ParamByName('milliAmps').Value := 0;

    Parameters.ParamByName('centerTap').Value := false;
    Parameters.ParamByName('tapFiftyVolt').Value := false;
    Parameters.ParamByName('filamentFiveVolt').Value := false;
    Parameters.ParamByName('filamentFiveAmps').Value := 0;
    Parameters.ParamByName('filamentSixVolt').Value := false;

    Parameters.ParamByName('filamentSixAmps').Value := 0;
    Parameters.ParamByName('filamentTwelveVolt').Value := false;
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


function constructPowerTrafoScreen(myIp, value: String): string;
  var
  thisQuery: tAdoQuery;
  T, tempValue: integer;
  mainHtml, trafoId: string;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoConnHtmlPages;

  if (storeTempTrafoSettings(myIp, 'powertrafo', '1', value) = 'ok') then begin
    trafoId := initNewPowerTrafo(myIp);
    writelog(trafoId);

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


function getDetailScreen(htmlItem: string): string;
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

function getObjectPrice(objectDescription: string): string;
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

function checkCart(sessionId: string): string;
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

function listGroupedCartItems(sessionId: string): string;
  var
  salesQuery, htmlQuery: tAdoQuery;
  outterHtml, inlineHtml, cartFlexBox, cartFlexBoxContainer, cartLines, hulp1String, hulp2String: string;
  placeHolder: array[0..7] of string;
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
  writelog(result);
end;

function listGroupedInvoiceItems(sessionId: string): string;
  var
  salesQuery, htmlQuery: tAdoQuery;
  inlineHtml, cartFlexBox, cartFlexBoxContainer, cartLines, hulp1String, hulp2String, totalLine: string;
  placeHolder: array[0..8] of string;
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


function getObjectInCart(objectArray, SessionId: string): string;
  var
  thisQuery: tAdoQuery;
  objectList: TStringList;
  myDescription, itemName, IndexNr: string;
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
