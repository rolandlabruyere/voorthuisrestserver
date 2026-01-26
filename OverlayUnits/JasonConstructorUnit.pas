unit JasonConstructorUnit;

interface
  procedure resetJson();
  procedure beginObject(key: String);
  procedure endObject(key: String);
  procedure beginArray(key: String);
  procedure endArray();
  procedure add(key, value: String); overload;
  procedure add(key: String; value: Integer); overload;
  procedure add(key: String; value: Double); overload;
  procedure add(value: String); overload;
  procedure add(value: Integer ); overload;
  procedure add(value: Double ); overload;
  function jsonBuild(suppressFormatting: boolean): String;


  implementation
  uses CommonFunctionUnit, System.StrUtils, System.SysUtils;

  var
    jsonFile: String;
    withinArray: boolean;

  function jsonBuild(suppressFormatting: boolean): String;
  var
    countOpen: longint;
    countClose: longint;
  begin
      //doe een basale check of aantallen accolades en blokhaken kloppen
      countOpen := CountOccurences('{', jsonFile);
      countClose := CountOccurences('}', jsonFile);
      //assertEquals(countOpen, countClose);
      countOpen := CountOccurences('[', jsonFile);
      countClose := CountOccurences(']', jsonFile);
      //assertEquals(countOpen, countClose);
      jsonFile := left(jsonFile, length(jsonFile) - 1);
      if (suppressFormatting) then jsonFile := replaceStr(jsonFile, '' + #10, '');
      result := jsonFile;
  end;

  procedure resetJson();
  begin
      jsonFile := '';
  end;

  procedure beginObject(key: String);
  begin
      if (key ='')then
          jsonFile := jsonFile + '{' + #10
      else
          jsonFile := jsonFile + '"' + key + '" : {' + #10;
  end;

  procedure endObject(key: String);
  begin
      jsonFile := left(jsonFile, length(jsonFile) - 3) + '' + #10;

      //within an array, objects must be separated by comma..
      //hence, overriding "key"
      if (withinArray) then key := ' ';

      if (key = '')then
          jsonFile := jsonFile + '}' + #10
      else
          jsonFile := jsonFile + '}, ' + #10;
  end;

  procedure beginArray(key: String);
  begin
      withinArray := true;
      jsonFile := jsonFile + '"' + key + '" : [' + #10;
  end;

  procedure endArray();
  begin
      withinArray := false;
      jsonFile := left(jsonFile, length(jsonFile) - 3);
      jsonFile := jsonFile + '' + #10;
      jsonFile := '], ' + #10;
  end;

  // overloading for different data types. first object arrays
  procedure add(key, value: String); overload;
  begin
      jsonFile := jsonFile + '"' + key + '": "' + value + '", ' + #10;
  end;

  procedure add(key: String; value: Integer); overload;
  begin
      jsonFile := jsonFile + '"' + key + '": ' + intToStr(value) + ', ' + #10;
  end;

  procedure add(key: String; value: Double); overload;
  begin
      jsonFile := jsonFile + '"' + key + '": ' + Format ('%*.*f', [5, 2, value]) + ', ' + #10;
  end;

  // and common data arrays
  procedure add(value: String); overload;
  begin
      jsonFile := jsonFile + '"' + value + '", ' + #10;
  end;

  procedure add(value: Integer ); overload;
  begin
      jsonFile := jsonFile + '"' + intToStr(value) + ', ' + #10;
  end;

  procedure add(value: Double ); overload;
  begin
      jsonFile := jsonFile + '\"' + Format ('%*.*f', [5, 2, value]) + ', ' + #10;
  end;

end.
