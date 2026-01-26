unit RestUnit;

interface
uses FormUnit1, IdHTTP, IdGlobal, System.Classes, REST.Types, REST.Client, dialogs,system.sysutils,  IdBaseComponent, IdComponent, IdIOHandler,
     IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdAuthentication, IdHeaderList, Data.DB, Data.Win.ADODB;

function doRequest(jsonBody: String): String;

implementation

  function doRequest(jsonBody: String): String;
  var
    HTTP: TIdHTTP;
    RequestBody: TStream;
    LHandler: TIdSSLIOHandlerSocketOpenSSL;
    caoQuery: tAdoQuery;
    uri, profile, key: String;
  begin
    http := TIdHTTP.Create;
    LHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    LHandler.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    caoQuery := tAdoQuery.Create(nil);
    caoQuery.Connection := form1.adoVoorThuisCustomerSales;

    with caoQuery do begin
      SQL.Clear;
      SQL.Add('SELECT * FROM tb910_paymentsettings where item IN ("mollieUri", "testKey") ORDER BY 1');
      open;
      first;
        uri := fieldByName('Value').AsString;
      next;
        key := fieldByName('Value').AsString;
    end;

    with http, request do begin
      BasicAuthentication := false;
      CharSet := 'utf-8';
      ContentType := 'application/json';
      Accept := 'application-json';
      ContentEncoding := 'application/json';
      CustomHeaders.Values['Authorization'] := 'bearer ' + key;
      IOHandler := LHandler;
    end;

    try
      RequestBody := TStringStream.Create(jsonBody, TEncoding.UTF8);
      result := HTTP.Post(uri, RequestBody);
    except
      on E: EIdHTTPProtocolException do
      begin
        result := 'HTTP fout:<br><br>' + E.ErrorMessage;
      end;
      on E: Exception do
      begin
        result := 'Runtime exception:<br><br>' + E.Message;
        exit;
      end;
    end;
  end;
end.
