program Project1;
{$APPTYPE GUI}

{$R *.dres}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  FormUnit1 in 'FormUnit1.pas' {Form1},
  ServerMethodsUnit1 in 'ServerMethodsUnit1.pas',
  WebModuleUnit1 in 'WebModuleUnit1.pas' {WebModule1: TWebModule},
  ServerFunctionUnit in 'ServerFunctionUnit.pas',
  CommonFunctionUnit in 'OverlayUnits\CommonFunctionUnit.pas',
  CommonProcedureUnit in 'OverlayUnits\CommonProcedureUnit.pas',
  JasonConstructorUnit in 'OverlayUnits\JasonConstructorUnit.pas',
  JasonReaderUnit in 'OverlayUnits\JasonReaderUnit.pas',
  RestUnit in 'OverlayUnits\RestUnit.pas',
  FindFiles in 'OverlayUnits\FindFiles.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
