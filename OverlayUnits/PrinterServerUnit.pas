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
  filename := getFilename(myIp, trafoNumber);
  if sendMail(myIp, filename) = 'success' then
    result := getScreen('downloaded');
end;
end.
