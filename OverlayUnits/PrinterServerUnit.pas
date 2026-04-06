unit PrinterServerUnit;

interface uses System.SysUtils, System.Classes, System.StrUtils, system.math, Variants, CommonProcedureUnit, ComObj, idHTTP;

  function performMailMerge(myIp, trafoNumber, filename, dataSource: String): String;
  function uploadFile(myIp: string): string;

implementation
  const
    dwnldMap = '\templates\download\';
    dataMap = '\templates\data\';
    templatesMap = '\templates\doc\';
    wdExportFormatPDF = 17;

  function performMailMerge(myIp, trafoNumber, filename, dataSource: String): String;
    var
      WordApp, WordDoc: Variant;
      curFolder, newFileName: String;
    begin
      curFolder := getCurrentDir;
      newFileName := curFolder + dwnldMap + trafoNumber + '.pdf';
      filename := curFolder + templatesMap + filename;
      dataSource := curFolder + dataMap + dataSource;

    try
      WordApp := CreateOleObject('Word.Application');
      WordApp.Visible := false;

      WordDoc := WordApp.Documents.Open(filename);
      WordDoc.MailMerge.OpenDataSource(dataSource);
      WordDoc.MailMerge.Execute(False);
      WordApp.ActiveDocument.SaveAs2(newFileName, 17);
    finally
      WordDoc.Close(False);
      WordApp.Quit;
    end;
   // uploadFile(newFileName);
    result := newFileName;
  end;

function uploadFile(myIp: string): string;
var
  IdHTTP1: TIdHTTP;
  Stream: TMemoryStream;
  Url, FileName: String;
begin
  Url := 'http://' + myIp + '/';
  Filename := '';

  IdHTTP1 := TIdHTTP.Create(nil);
  Stream := TMemoryStream.Create;
  try
    IdHTTP1.put(Url, Stream);
    IdHTTP1.Post(Url, Stream);
    Stream.SaveToFile(FileName);
  finally
    Stream.Free;
    IdHTTP1.Free;
  end;
end;
end.
