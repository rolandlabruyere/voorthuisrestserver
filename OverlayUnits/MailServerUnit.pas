Unit MailServerUnit;

Interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, dataBaseUnit,
  Dialogs, StdCtrls, EASendMailObjLib_TLB, CommonProcedureUnit;

  function sendMail(myIp, attachment, subjectLine: string): string;

const
  ConnectNormal = 0;
  ConnectSSLAuto = 1;
  ConnectSTARTTLS = 2;
  ConnectDirectSSL = 3;
  ConnectTryTLS = 4;
  vbCrLf = #13 + #10;
  licCode = 'TryIt';
Implementation

function sendMail(myIp, attachment, subjectLine: string): string;
var
    oSmtp : TMail;
begin
     writelog('start mail server');
    oSmtp := TMail.Create(nil);
     writelog('mail server opgestart');
     try
      oSmtp.LicenseCode := licCode;
     except
      on E:exception do writelog(E.Message);
     end;
     writelog('licence = ' + licCode);

      oSmtp.UserName := 'roland.labruyere@gmail.com';
      oSmtp.Password := 'muqv lhzw gisj rzvl';

      writelog('dit is de attachment: ' + attachment);

      // Add recipient email address
      oSmtp.AddRecipientEx(getEmailAddress(myIp), ConnectNormal);
      oSmtp.Subject := subjectLine.ToLower;
      oSmtp.BodyText := 'Geachte client,' + vbCrLf +  vbCrLf + 'Bijgaand uw gevraagde PDF document. Dit document is te openen met Adobe reader of een willekeurige internet browser.' +
                        vbCrLf + vbCrLf + 'Groet,' + vbCrLf + 'Het VoorThuis team.';
      oSmtp.AddAttachment(attachment);

      // Your SMTP server address
      oSmtp.ServerAddr := 'smtp.gmail.com';
      oSmtp.ConnectType := ConnectSSLAuto;

      if oSmtp.SendMail() = 0 then
        result := 'success'
      else begin
        writelog('error: ' + oSmtp.GetLastErrDescription);
        result := 'error: ' + oSmtp.GetLastErrDescription;
      end;
end;
End.
