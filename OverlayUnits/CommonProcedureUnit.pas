unit CommonProcedureUnit;

interface
  uses System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, System.StrUtils, System.math, Winapi.Messages,  Winapi.ShellApi;
  procedure writeLog(writeItem: string);
  procedure resetSession();
  procedure createShoppingCart(sessionId: string);
  procedure removeEmptyCarts();
  procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
  procedure writeToFile(fileName,fileContent: String);
  procedure runCmd(const ExecutableName, Parameters: string);
  procedure createSlideShow;

implementation
  uses FormUnit1, dialogs, CommonFunctionUnit, FindFiles;
  var
    primVA: single;

  procedure writeLog(writeItem: string);
  var
    F: TextFile;
  begin
    AssignFile(F, 'c:\GitHub\voorthuisrestserver\log\session.log');
    try
      Append(F);
    except
      reWrite(F);
    end;

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

  procedure writeToFile(fileName, fileContent: String);
  var
    outputFile: text;
  begin
    assignFile(outputFile, filename);
    rewrite(outputFile);
    writeLn(outputFile, fileContent);
    closeFile(outputFile);
  end;

  procedure runCmd(const ExecutableName, Parameters: string);
  begin
    ShellExecute(0, 'open', PChar(ExecutableName), Pointer(Parameters), nil, 0);
  end;

  procedure createSlideShow;
  var
    fileList: TstringList;
    relPath, images, dots, body, spanDot: String;
    t: integer;
    thisQuery: tAdoQuery;
    placeHolder: array[0..2] of String;
    splitter: array[0..0] of char;
    htmlParts : Tarray<String>;
  const
    pathRoot = 'c:\Git\voorthuisrestsupplies\Win32\Release\';
  begin
    thisQuery := tAdoQuery.Create(nil);
    thisQuery.Connection := form1.adoConnHtmlPages;
    fileList := TstringList.Create;
    splitter[0] := '|';

    with thisQuery do begin
      SQL.Clear;
      SQL.add('select * from tb100_htmlpaginas where id = :id');
      Parameters.ParamByName('Id').Value := 'slideshow';
      open;
      placeHolder[0] := fieldByName('TextPlaceHolder').AsString;
      placeHolder[1] := fieldByName('PricePlaceholder').AsString;
      placeHolder[2] := fieldByName('ImagePlaceHolderBig').AsString;
      body := fieldByName('InlineHtml').AsString;
    end;
     htmlParts := body.Split(splitter);
    findAllFiles(pathRoot + 'images\Slideshow\', '*.jpg', false, fileList);

    for t := 0 to fileList.Count -1 do begin
     body := htmlParts[1];
     relPath := replaceStr(fileList[t], pathRoot, '');
     images := images + body.Replace(placeHolder[2], relPath) + #10;
     spanDot := spanDot + htmlParts[2] + #10;
    end;

    htmlParts[0] := htmlParts[0].Replace(placeHolder[0], images);
    htmlParts[0] := htmlParts[0].Replace(placeHolder[1], spanDot);

    with thisQuery do begin
      SQL.Clear;
      SQL.add('REPLACE INTO tb100_htmlpaginas (Id, InlineHtml) VALUES (:Id, :InlineHtml)');
      Parameters.ParamByName('Id').Value := 'splashPageInfo';
      Parameters.ParamByName('InlineHtml').Value := htmlParts[0];
      execSql;
    end;
  end;
end.
