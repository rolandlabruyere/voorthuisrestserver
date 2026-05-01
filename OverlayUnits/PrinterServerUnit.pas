unit PrinterServerUnit;

interface uses System.SysUtils, System.Classes, System.StrUtils, system.math, Variants, CommonProcedureUnit,
               CommonFunctionUnit, ComObj, dataBaseUnit, MailServerUnit;

  function performMailMerge(myIp, trafoNumber, filename, dataSource: String): String;
  function performMailMergePdfPrinter(myIp, trafoNumber, filename, dataSource: String): String;
  function uploadFile(selector, myIp, trafoNumber, returnHtml: string): string;

implementation
  const
    dwnldMap = '\templates\download\';
    dataMap = '\templates\data\';
    templatesMap = '\templates\doc\';
    wdExportFormatPDF = 17;

function performMailMerge(myIp, trafoNumber, filename, dataSource: String): String;
  var
      wordApp, wordDoc: Variant;
      curFolder, newFileName, fullFilename: String;
  begin
      curFolder := getCurrentDir;
      newFileName := curFolder + dwnldMap + filename + '_' + trafoNumber + '.pdf';
      fullFilename := curFolder + templatesMap + filename + '.docx';
      dataSource := curFolder + dataMap + dataSource;

    try
      WordApp := CreateOleObject('Word.Application');
      WordApp.Visible := false;

      WordDoc := WordApp.Documents.Open(fullFilename);
      WordDoc.MailMerge.OpenDataSource(dataSource);
      WordDoc.MailMerge.Execute(False);
      WordApp.ActiveDocument.SaveAs2(newFileName, wdExportFormatPDF);
    finally
      WordDoc.Close(false);
      WordApp.Quit;
    end;
    saveDocument(myIp, trafoNumber, filename, newFileName);
    result := newFileName;
  end;

function performMailMergePdfPrinter(myIp, trafoNumber, filename, dataSource: String): String;
  var
      wordApp, wordDoc: Variant;
      curFolder, newFileName, fullFilename: String;
  begin
      curFolder := getCurrentDir;
      newFileName := curFolder + dwnldMap + filename + '_' + trafoNumber + '.pdf';
      fullFilename := curFolder + templatesMap + filename + '.docx';
      dataSource := curFolder + dataMap + dataSource;

    try
      WordApp := CreateOleObject('Word.Application');
      wordApp.ActivePrinter := 'Microsoft Print to PDF';
      WordApp.Visible := false;

      WordDoc := WordApp.Documents.Open(fullFilename);
      WordDoc.MailMerge.OpenDataSource(dataSource);
      WordDoc.MailMerge.Execute(False);
      WordApp.ActiveDocument.printOut(false, false, EmptyParam, newFileName);
      WordApp.activeDocument.close(false);
    finally
      WordDoc.Close(false);
      WordApp.Quit;
    end;
    saveDocument(myIp, trafoNumber, filename, newFileName);
    result := newFileName;
  end;


  function uploadFile(selector, myIp, trafoNumber, returnHtml: string): string;
  var
    FileName, oldHtml, newHtml: String;
  begin
    filename := getFilename(myIp, trafoNumber, selector);

    if sendMail(myIp, filename, selector) = 'success' then
      result := returnHtml.Replace(getScreen(selector), getScreen(selector + '_dl'));
  end;
end.
