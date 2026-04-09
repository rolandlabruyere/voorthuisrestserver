unit PrinterServerUnit;

interface uses System.SysUtils, System.Classes, System.StrUtils, system.math, Variants, CommonProcedureUnit, ComObj,
               idHTTP, dataBaseUnit, MailServerUnit;

  function performMailMerge(myIp, trafoNumber, filename, dataSource: String): String;
  function uploadFile(myIp, trafoNumber: string): string;

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
      WordApp.ActiveDocument.SaveAs2(newFileName, wdExportFormatPDF);
    finally
      WordDoc.Close(False);
      WordApp.Quit;
    end;
    saveDocument(myIp, trafoNumber, newFileName);
    result := newFileName;
  end;

function uploadFile(myIp, trafoNumber: string): string;
var
  IdHTTP1: TIdHTTP;
  Stream: TMemoryStream;
  Url, FileName: String;
begin
//  Url := 'http://' + myIp + '/';
  filename := getFilename(myIp, trafoNumber);
  sendMail(filename);
//  Url := 'http://localhost:8080/';
//
//  IdHTTP1 := TIdHTTP.Create(nil);
//  Stream := TMemoryStream.Create;
//  try
////    IdHTTP1.put(Url, Stream);
//    Stream.LoadFromFile(FileName);
//    IdHTTP1.get(Url, Stream);
//  except
//      on E:exception do writelog(E.Message);
//  end;
//  Stream.Free;
//  IdHTTP1.Free;
  result := Filename;
end;
end.
