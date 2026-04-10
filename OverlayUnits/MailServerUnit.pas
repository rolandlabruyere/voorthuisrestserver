Unit MailServerUnit;

Interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, dataBaseUnit,
  Dialogs, StdCtrls, EASendMailObjLib_TLB, CommonProcedureUnit;

  function sendMail(myIp, attachment: string): string;

const
  ConnectNormal = 0;
  ConnectSSLAuto = 1;
  ConnectSTARTTLS = 2;
  ConnectDirectSSL = 3;
  ConnectTryTLS = 4;
  vbCrLf = #13 + #10;
  licCode = 'TryIt';
Implementation

function sendMail(myIp, attachment: string): string;
var
    oSmtp : TMail;
begin
    oSmtp := TMail.Create(Application);
    oSmtp.LicenseCode := licCode;

    // Set your sender email address
    oSmtp.FromAddr := 'roland.labruyere@gmail.com';

    // Add recipient email address
    oSmtp.AddRecipientEx(getEmailAddress(myIp), ConnectNormal);
    oSmtp.Subject := 'wikkelschema';
    oSmtp.BodyText := 'Bijgaand uw gevraagde PDF document. Dit document is te openen met Adobe reader of een willekeurige internet browser.' +
                      vbCrLf + vbCrLf + 'Groet' + vbCrLf + 'Het VoorThuis team.';
    oSmtp.AddAttachment(attachment);

    // Your SMTP server address
    oSmtp.ServerAddr := 'smtp.gmail.com';
    oSmtp.UserName := 'roland.labruyere@gmail.com';
    oSmtp.Password := 'muqv lhzw gisj rzvl';
    oSmtp.ConnectType := ConnectSSLAuto;

    if oSmtp.SendMail() = 0 then
      result := 'success'
    else
      result := 'error: ' + oSmtp.GetLastErrDescription;

end;

End.
