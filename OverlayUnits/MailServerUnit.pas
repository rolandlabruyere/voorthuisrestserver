Unit MailServerUnit;

Interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, dataBaseUnit,
  Dialogs, StdCtrls, EASendMailObjLib_TLB, CommonProcedureUnit, IdSmtp, IdMessage, IdAttachmentFile,
  IdUserPassProvider, IdExplicitTLSClientServerBase, IdCoderMIME, IdSSLOpenSSL, IdReplySMTP;

  function sendMail(myIp, attachment, subjectLine: string): string;
  function SendSecureEmail(IdMessage: tIdMessage): string;
  function SendTestEmail(EmailAddress: String): Boolean;

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
    oSmtp := TMail.Create(nil);
     try
      oSmtp.LicenseCode := licCode;
     except
      on E:exception do writelog(E.Message);
     end;

      oSmtp.UserName := 'roland.labruyere@gmail.com';
      oSmtp.Password := 'lbyf npbp omep dgol';

      // Add recipient email address
      oSmtp.AddRecipientEx(getEmailAddress(myIp), ConnectNormal);
      oSmtp.Subject := subjectLine.ToLower;
      oSmtp.BodyText := 'Geachte client,' + vbCrLf +  vbCrLf + 'Bijgaand uw gevraagde PDF document. Dit document is te openen met Adobe reader of een willekeurige internet browser.' +
                        vbCrLf + vbCrLf + 'Groet,' + vbCrLf + 'Het VoorThuis team.';
      oSmtp.AddAttachment(attachment);

      // Your SMTP server address
      oSmtp.ServerAddr := 'voorthuismailserver';
      oSmtp.ConnectType := ConnectSSLAuto;

      if oSmtp.SendMail() = 0 then
        result := 'success'
      else begin
        result := 'error: ' + oSmtp.GetLastErrDescription;
      end;
end;

//function sendMail(myIp, attachment, subjectLine: string): string;
//var
//  Msg: TIdMessage;
//begin
//  if not FileExists(attachment) then
//    Exit;
//  Msg := TIdMessage.Create(nil);
//  Msg.From.Address := 'roland.labruyere@gmail.com';
//  Msg.Recipients.EMailAddresses := getEmailAddress(myIp);
//  Msg.Body.Text := 'Geachte client,' + vbCrLf +  vbCrLf + 'Bijgaand uw gevraagde PDF document. Dit document is te openen met Adobe reader of een willekeurige internet browser.' +
//                      vbCrLf + vbCrLf + 'Groet,' + vbCrLf + 'Het VoorThuis team.';
//  TIdAttachmentFile.Create(Msg.MessageParts, attachment);
//  Msg.Subject := subjectLine;
//
//  if sendTestEmail('roland.labruyere@gmail.com') then
//    result := 'success'
//  else
//    result := 'failed';
//end;

function SendSecureEmail(IdMessage: tIdMessage): string;
var
  UserPassProvider: TIdUserPassProvider;
  SASLString, SenderEmail, senderToken: string;
  idSMTP: TIdSMTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  senderToken := 'w2YNcM01||P3n1sl@nD01';
  SenderEmail := 'roland.labruyere@gmail.com';
  // Bouw de specifieke XOAUTH2-authenticatiestring volgens de specificaties Formaat: user={email}\x01auth=Bearer {token}\x01\x01
  SASLString := 'user=' + SenderEmail + #1 + 'auth=Bearer ' + senderToken + #1 + #1;
  writelog('in SendSecureEmail');

  // 1. Initialize your SMTP credentials
  IdSMTP := TIdSMTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(IdSMTP);
  idSmtp.IOHandler := SSLHandler;
  IdSMTP.host := 'smtp.gmail.com';
  IdSMTP.Port := 587;
  IdSMTP.Password := senderToken;
  //IdSMTP.Username := senderEmail;
  writelog('smtp port added');
  IdSMTP.UseTLS := utUseExplicitTLS;

  writelog('smtp constructed');

  try
   IdSMTP.Connect;
  except
    on E:exception do writelog(E.Message);
  end;
  writelog('smtp connected');

//  try
//    writelog('try sending coded SASL string');
//  // Stuur de gecodeerde SASL-string rechtstreeks naar de SMTP-server
//  IdSMTP.SendCmd('AUTH XOAUTH2 ' + TIdEncoderMIME.EncodeString(SASLString), [235]);
//  except
//    on E:exception do writelog('SASL string failed with error: ' + E.Message);
//  end;
//  // Zet AuthType tijdelijk uit zodat Send() niet opnieuw probeert te authenticeren
//  IdSMTP.AuthType := satNone;
  // 5. Connect and complete your transmission
  if IdSMTP.Connected then begin
    try
      IdSMTP.Send(IdMessage);
      writelog('message sent');
      result := 'success';
    except
      on E:exception do begin
        writelog(E.Message);
        result := E.Message;
      end;
    end;
  end else writelog('not connected');
end;

function SendTestEmail(EmailAddress: String): Boolean;
var
  EmailMessage: TidMessage;
  IdSMTPEmail: TIdSMTP;

begin
  IdSMTPEmail := TIdSMTP.Create(nil);
  IdSMTPEmail.AuthType := satDefault;
  IdSMTPEmail.Username := 'roland.labruyere@gmail.com';
  IdSMTPEmail.Password := 'muqv lhzw gisj rzvl';
  //IdSMTPEmail.Password := 'w2YNcM01||P3n1sl@nD01';
  IdSMTPEmail.Port := 465;

  IdSMTPEmail.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(IdSMTPEmail);
  IdSMTPEmail.UseTLS := utUseExplicitTLS;
  TIdSSLIOHandlerSocketOpenSSL(IdSMTPEmail.IOHandler).SSLOptions.Method := sslvTLSv1_2;
  try
    // Connect
    IdSMTPEmail.Connect('smtp.gmail.com');

    try
      // Create
      EmailMessage := TidMessage.Create(nil);

      try
        // Set values
        EmailMessage.Body.Add('Test Email');
        EmailMessage.Subject := 'Test Email';

        // Set sender details
        EmailMessage.From.Address := 'test@test.com';
        EmailMessage.From.Name := 'SSL Test';

        // Set recipient
        EmailMessage.Recipients.Add.Address := EmailAddress;

        try
          // Send message
          IdSMTPEmail.Send(EmailMessage);
          result := true;
        except
          // Exception
          on E: EIdSMTPReplyError do
          begin
            // Result
            writelog(E.Message);
            Result := False;
          end;
        end;

      finally
        // Free email
        EmailMessage.Free;
      end;

    finally
      // Disconnect
      IdSMTPEmail.Disconnect;
    end;

  except
    // Exception
    on E: Exception do
    begin
      writelog(E.Message);
      IdSMTPEmail.Disconnect;
      // Result
      Result := False;
    end;
  end;
end;
End.
