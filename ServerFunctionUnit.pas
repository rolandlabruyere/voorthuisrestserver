unit ServerFunctionUnit;

interface
  uses System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, FormUnit1, System.StrUtils;

  function  loadPage(): string;
  function  getScreen(htmlItem: string): string;
  function  getDetailScreen(htmlItem: string): string;
  function  storeSessionSettings(myIp: string): string;
  function  updateSessionSettings(mySessId: string): string;
  function  generateSessionId(): string;
  function  generateTimestamp(offset: integer = 0): string;
  function  generateTimestampMonthOld: string;
  function  getObjectPrice(objectDescription: string): string;
  function  getObjectInCart(objectArray, SessionId: string): string;
  function  listGroupedCartItems(sessionId: string): string;
  function  checkCart(sessionId: string): string;
  function  listGroupedInvoiceItems(sessionId: string): string;

  procedure writeLog(writeItem: string);
  procedure resetSession();
  procedure createShoppingCart(sessionId: string);
  procedure removeEmptyCarts();
  procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;

implementation

function loadPage(): string;
  var
  thisQuery: tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoConnHtmlPages;

  with thisQuery do begin
    SQL.Clear;
    SQL.add('select * from TB100_HtmlPages where id = "SplashPage"');
    open;
    Result := fieldByName('InlineHtml').AsString;
  end;
end;

function storeSessionSettings(myIp: string): string;
  var
  thisQuery: tAdoQuery;
  newSessionId, newTimeStamp: string;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoVoorThuisCustomerSales;
  newSessionId := generateSessionId;
  newTimestamp := generateTimestamp;

  with thisQuery do begin
    SQL.Clear;
    SQL.add('insert into TB900_SessionSettings(SessionId, Ip_v4, ClientId, SessionActive, Timestamp) values (:SessionId, :ip_v4, :ClientId, :SessionActive, :timestamp)');
    Parameters.ParamByName('SessionId').Value := newSessionId;
    Parameters.ParamByName('ip_v4').Value := myIp;
    Parameters.ParamByName('ClientId').Value := newSessionId + '_' + myIp;
    Parameters.ParamByName('SessionActive').Value := true;
    Parameters.ParamByName('timestamp').Value := newTimestamp;
    execSql;
    Result := newSessionId + '_' + myIp;
  end;
end;

function updateSessionSettings(mySessId: string): string;
  var
  thisQuery: tAdoQuery;
  myId, myIp: string;
  delimiter: integer;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoVoorThuisCustomerSales;

  delimiter := pos('_', mySessId);
  myId := copy(mySessId, 0, delimiter - 1);
  myIp := copy(mySessId, delimiter + 1, length(mySessId) - delimiter);

  with thisQuery do begin
    SQL.Clear;
    SQL.add('update TB900_SessionSettings set sessionActive = true, timestamp = :timestamp where clientId = :clientId');
    Parameters.ParamByName('clientId').Value := mySessId;
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


//getDetailScreenClick(elementId)
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

{
  ************************************************************************************************
      procedures
  *************************************************************************************************
 }

procedure writeLog(writeItem: string);
var
  F: TextFile;
begin
  AssignFile(F, 'c:\git\voorthuisrestserver\log\logfile.log');
  Rewrite(F);
  WriteLn(F, writeItem);
  CloseFile(F);
end;

procedure resetSession();
var
  thisQuery: tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoVoorThuisCustomerSales;
  with thisQuery do begin
    SQL.Clear;
    SQL.add('update TB900_SessionSettings set sessionActive = false, timestamp = :timestamp where timestamp <= :timestampMin30');
    Parameters.ParamByName('timestamp').Value := generateTimestamp();
    Parameters.ParamByName('timestampMin30').Value := generateTimestamp(30);
    execSQL;
  end;
end;

procedure removeEmptyCarts();
var
  thisQuery: tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoVoorThuisCustomerSales;
  with thisQuery do begin
    SQL.Clear;
    SQL.add('delete from tb300_shoppingcart where GotItems = false and timestamp <= :timestampMin30');
    Parameters.ParamByName('timestampMin30').Value := generateTimestamp(30);
    execSQL;
  end;
end;

procedure createShoppingCart(sessionId: string);
var
  thisQuery: tAdoQuery;
begin
  thisQuery := tAdoQuery.Create(nil);
  thisQuery.Connection := form1.adoVoorThuisCustomerSales;
  with thisQuery do begin
    SQL.Clear;
    SQL.add('insert into TB300_ShoppingCart (ClientId, Gotitems, Timestamp) values (:ClientId, :Gotitems, :Timestamp)');
    Parameters.ParamByName('ClientId').Value := sessionId;
    Parameters.ParamByName('Gotitems').Value := false;
    Parameters.ParamByName('Timestamp').Value := generateTimestamp();
    try
      execSQL;
    except
      //als het mis gaat dan is de cart er al
    end;
  end;
end;

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter       := Delimiter;
   ListOfStrings.StrictDelimiter := True;
   ListOfStrings.DelimitedText   := Str;
end;

end.
