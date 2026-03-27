unit PrinterServerUnit;

interface
uses System.SysUtils, System.Classes, System.StrUtils, system.math, Word2000, Variants, CommonProcedureUnit;

procedure OpenWordDocument(filename: String);

implementation

  procedure OpenWordDocument(filename: String);
  Var
    wordServer : TWordApplication;
    EmptyParam : OleVariant;
  begin
    wordServer := TWordApplication.Create(nil);
    EmptyParam := Variants.EmptyParam;

    with wordServer do begin
      try
        Visible := false;
        Connect;
        Documents.Open(filename, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
      except
        on E: exception do writelog(E.Message);
      end;
      Quit(wdDoNotSaveChanges, EmptyParam, EmptyParam);
    end;
  end;

  {
wordApp: TWordApplication;
FileFormat: OleVariant;
begin
try
wordApp := TWordApplication.Create(nil);
wordApp.Connect;
wordApp.Visible := false;
wordApp.Documents.Open(FileName, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
wordApp.ActiveDocument.MailMerge.MainDocumentType := wdFormLetters;
wordApp.ActiveDocument.MailMerge.OpenDataSource('D ata.htm', EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
wordApp.ActiveDocument.MailMerge.Destination := wdSendToNewDocument;
wordApp.ActiveDocument.MailMerge.SuppressBlankLine s := true;
wordApp.ActiveDocument.MailMerge.Execute(false);
wordApp.Quit(wdDoNotSaveChanges, EmptyParam, EmptyParam);
wordApp.ActiveDocument.SaveAs(pad, FileFormat, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
EmptyParam, EmptyParam, EmptyParam);
finally
wordApp.Free();
end;
end;
  }
end.
