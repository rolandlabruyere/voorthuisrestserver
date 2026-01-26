unit FindFiles;

interface
  uses System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, System.StrUtils, System.math,
       FormUnit1, dialogs, CommonFunctionUnit, CommonProcedureUnit, JasonConstructorUnit;

  procedure findAllFiles(RootFolder: string; Mask: string; Recurse: Boolean; Var fileList: TstringList);


implementation
var
  Accending    : Boolean = False;

  procedure findAllFiles(RootFolder: string; Mask: string; Recurse: Boolean; Var fileList: TstringList);
  var
    SR           : TSearchRec;
  begin
    if RootFolder = '' then
      Exit;
    if AnsiLastChar(RootFolder)^ <> '\' then
      RootFolder := RootFolder + '\';

    RootFolder := IncludeTrailingPathDelimiter(RootFolder);

    if Recurse then
      if FindFirst(RootFolder + '*.*', faAnyFile, SR) = 0 then
      try
        repeat
          if SR.Attr and faDirectory = faDirectory then
            if (SR.Name <> '.') and (SR.Name <> '..') then
              FindAllFiles(RootFolder + SR.Name, Mask, Recurse, fileList);
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;

    if FindFirst(RootFolder + Mask, faAnyFile, SR) = 0 then
    try
      repeat
        if SR.Attr and faDirectory <> faDirectory then
        begin
          //ListItem := Listview1.Items.Add;
          fileList.add(RootFolder + SR.Name);
          //ListItem.SubItems.Add(IntToStr(GetFileSize(PChar(RootFolder + SR.Name))));
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;

end.
