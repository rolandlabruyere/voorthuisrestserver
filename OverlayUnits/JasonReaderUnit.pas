unit JasonReaderUnit;


interface
  uses CommonFunctionUnit, CommonProcedureUnit, System.StrUtils, System.SysUtils, System.Classes, Dialogs;
  procedure init(newJson: String );
  function formatJson(jsonString: String): String;
  function getValue(objectkey: String): String;
  function getArray(arrayName: String): String;
  function getNamesFromObjectArray(arrayName: String): TArray<String>;
  function getStuffFromObjectArray(arrayName: String; wantValues: Integer): TArray<String>;
  function getStuff(thisValue: String; wantValue: integer): String;
  function getValuesFromObjectArray(arrayName: String): TArray<String>;
  function getValuesFromArray(arrayName: String): TArray<String>;
  function getSingleValueFromArray(arrayName: String; itemIndex: integer): String;
  function getItemFromCompoundObject(objectName, itemName: string): string;

implementation

  var
    jsonFile: String;

  procedure init(newJson: String );
  begin
      jsonFile := formatJson(newJson);
      writeToFile('c:\Git\VoorThuisRestSupplies\js\testfile.json', jsonFile);
  end;

  procedure initFromFile(filename: String);
  begin
      jsonFile := formatJson(readEntireFile(filename));
      writeToFile('c:\Git\VoorThuisRestSupplies\js\testfile.json', jsonFile);
  end;

  function formatJson(jsonString: String): String;
  var
    linearize: String;
  begin
    linearize := '';

    //windows style EOL
    if (pos(#13#10, jsonString) > 0) then
        linearize := replaceStr(jsonString, #13#10, '');

//    unix style EOL
    if (pos(#10, jsonString) > 0) then
        linearize := replaceStr(jsonString, #10, '');

    //apple style EOL
    if (pos(#13, jsonString) > 0) then
        linearize := replaceStr(jsonString, #13, '');

    linearize := trim(replaceStr(linearize, ',', ',' + #10));
    linearize := trim(replaceStr(linearize,'[', '[' + #10));
    linearize := trim(replaceStr(linearize,'{', '{' + #10));
    linearize := trim(replaceStr(linearize,'"}', '"' + #10 + '}'));
    linearize := trim(replaceStr(linearize,'}}', '}' + #10 + '}'));
    result := linearize;
  end;


    function getValue(objectkey: String): String;
    var
      startPos, posNewline: integer;
      part, value: String;
    begin
        startPos := pos(objectkey, jsonFile);
        part := copy(jsonFile, startPos);
        startPos := pos(':', part);
        posNewline := pos(#10, part);
        value := trim(copy(part, startPos + 1, abs(posNewline-startPos)));
        value := replaceStr(value, ',', '');
        value := replaceStr(value, '"', '');
        result := value;
    end;

    function getArray(arrayName: String): String;
    var
      startPos, posNewline, arrayStart, arrayEnd: integer;
      part, value: String;
    begin
        startPos := pos(arrayName, jsonFile);
        part := copy(jsonFile, startPos);
        arrayStart := pos('[', part);
        arrayEnd := pos(']', part);
        result := trim(copy(part, arrayStart + 1, arrayEnd));
    end;

    function getNamesFromObjectArray(arrayName: String): TArray<String>;
    begin
       result := getStuffFromObjectArray(arrayName, 0);
    end;

    function getValuesFromObjectArray(arrayName: String): TArray<String>;
    begin
        result := getStuffFromObjectArray(arrayName, 1);
    end;

    function getValuesFromArray(arrayName: String): TArray<String>;
    var
      local: String;
      I: integer;
      splitter: array[0..0] of char;
    begin
        splitter[0] := ',';
        local := getArray(arrayName);
        local := replaceStr(local, #10, '');
        result := local.Split(splitter);
    end;

    function getSingleValueFromArray(arrayName: String; itemIndex: integer): String;
    var
      local: String;
      valueArray: TArray<String>;
      splitter: array[0..0] of char;
    begin
        splitter[0] := ',';
        local := getArray(arrayName);
        local := replaceStr(local, #10, '');
        valueArray := local.Split(splitter);
        result :=  valueArray[itemIndex];
    end;

    function getSingleValueFromObjectArray(arrayName, elementName: String; itemIndex:  integer):String;
    var
      wholeArray, foundValue: String;
      returnArray: TArray<String>;
      posName, posCol, posNewLine: integer;
      splitter: array[0..1] of char;
    begin
        splitter[0] := '}';
        splitter[1] := ',';
        wholeArray := getArray(arrayName);
        returnArray := wholeArray.Split(splitter);
        posName := pos(returnArray[itemIndex], elementName);
        posCol := Pos(':', returnArray[itemIndex], posName);
        posNewLine := Pos(#10, returnArray[itemIndex], posName);
        foundValue := Copy(returnArray[itemIndex],posCol + 1, posNewLine);
        foundValue := foundValue.replace('{', '');
        foundValue := foundValue.replace(',', '');
        result := foundValue;
    end;

    function getStuffFromObjectArray(arrayName: String; wantValues: Integer): TArray<String>;
    var
      myArray: String;
      returnList, members, names: TArray<String>;
      T, I: integer;
      splitter: array[0..1] of char;
      secSplit: array[0..0] of char;
    begin
        splitter[0] := '}';
        splitter[1] := ',';
        secSplit[0] := ' ';

        myArray := getArray(arrayName);
        myArray := replaceStr(myArray, '{', '');
        myArray := replaceStr(myArray, #10, '');
        myArray := replaceStr(myArray, ' ', '');
        members := myArray.split(splitter);


        for I := 0 to Length(members) - 1 do begin
            names := getStuff(members[i], wantValues).split(secSplit);
            for T := 0 to length(names) - 1 do
                returnList[T] := ('[' + intToStr(I) + '] ' + names[t]);
        end;
        result := returnList ;
    end;

    function getStuff(thisValue: String; wantValue: integer): String;
    var
      firstSplit, secondSplit: TArray<String>;
      hulp: String;
      I: integer;
      splitter: array[0..1] of char;
    begin
        splitter[0] := ',';
        // wantValue = 0 ==> the functions returns the names in the array object
        // wantValue = 1 ==> the function returns the values in the array object
        firstSplit := thisValue.Split(splitter);
        hulp := '';

        splitter[0] := ':';
        for I := 0 to length(firstSplit) - 1 do begin
            secondSplit := firstSplit[i].Split(splitter);
            result := result + secondSplit[wantValue] + ' ';
        end;
        result := left(result, length(result) - 1);
    end;

    function getItemFromCompoundObject(objectName, itemName: string): string;
    var
      firstSplit, secondSplit: TArray<String>;
      hulp: String;
      I: integer;
      firstSeparator: array[0..0] of char;
      secondSeparator: array[0..0] of char;
      startPoint,endPoint: integer;
    begin
        result := '';
        firstSeparator[0] := ',';
        secondSeparator[0] := ':';
        startPoint := pos(objectName, jsonFile);
        endPoint := pos('}', jsonFile, startPoint);
        hulp := copy(jsonFile, startPoint, abs(startPoint - endPoint));
        hulp := replaceStr(hulp, objectName, '');
        hulp := replaceStr(hulp, '"', '');
        hulp := replaceStr(hulp, #10, '');
        hulp := replaceStr(hulp, '{', '');
        hulp := replaceStr(hulp, '}', '');
        hulp := copy(hulp, 2, length(hulp) -1);
        firstSplit := hulp.Split(firstSeparator);
        for i := 0 to length(firstSplit) -1 do
        begin
          if pos(itemName, firstSplit[i]) > 0 then begin
            startPoint := pos(secondSeparator[0], firstSplit[i]);
            result := copy(firstSplit[i], startPoint + 1, length(firstSplit[i]));
            exit;
          end;
        end;
    end;
end.

