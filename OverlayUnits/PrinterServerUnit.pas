unit PrinterServerUnit;

interface uses System.SysUtils, System.Classes, System.StrUtils, system.math, Variants, CommonProcedureUnit,
               CommonFunctionUnit, ComObj, dataBaseUnit, MailServerUnit;

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
      wordApp, wordDoc: Variant;
      curFolder, newFileName: String;
  begin
      curFolder := getCurrentDir;
      newFileName := curFolder + dwnldMap + trafoNumber + '.pdf';
      filename := curFolder + templatesMap + filename;
      dataSource := curFolder + dataMap + dataSource;

    try
      writeLog(generateTimestamp + ': word application starten');
      WordApp := CreateOleObject('Word.Application');
      writeLog(generateTimestamp + ': word application gestart');
      WordApp.Visible := false;

      writeLog(generateTimestamp + ': server draait op achtergrond');
      WordDoc := WordApp.Documents.Open(filename + '.docx');
      writeLog(generateTimestamp + ': word document geopend');
      WordDoc.MailMerge.OpenDataSource(dataSource);
      writeLog(generateTimestamp + ': mailmerge data bron geopend');
      WordDoc.MailMerge.Execute(False);
      writeLog(generateTimestamp + ': mailmerge uitgevoerd');
      WordApp.ActiveDocument.SaveAs2(newFileName, wdExportFormatPDF);
      writeLog(generateTimestamp + ': document opgeslagen');
    finally
      WordDoc.Close(false);
      WordApp.Quit;
    end;
    saveDocument(myIp, trafoNumber, newFileName);
    result := newFileName;
  end;


  function uploadFile(myIp, trafoNumber: string): string;
  var
    Url, FileName: String;
  begin
    filename := getFilename(myIp, trafoNumber);
    if sendMail(myIp, filename) = 'success' then
      result := getScreen('downloaded');
  end;
end.
