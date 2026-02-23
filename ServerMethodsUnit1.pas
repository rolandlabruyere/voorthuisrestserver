unit ServerMethodsUnit1;

interface

uses System.SysUtils, System.Classes, Datasnap.DSServer, Datasnap.DSAuth, Dialogs, System.StrUtils,
     ServerFunctionUnit, CommonFunctionUnit, CommonProcedureUnit, RestUnit, REST.Types;


type
{$METHODINFO ON}
  TServerMethods1 = class(TComponent)
  private
    { Private declarations }
  public
    { Public declarations }
    function RestDispatcher(functionPassThru: string): string;
  end;
{$METHODINFO OFF}

implementation

function TServerMethods1.RestDispatcher(functionPassThru: string): string;
var
  passThruItem: tStringList;
  menuIndex: array of String;
begin
  passThruItem := tStringList.Create;
  split('?', functionPassThru, passThruItem);
    {
      de "functionPassThru" string bevat de volgende elementen
        passThruItem[0] ==> functionIndex
        passThruItem[1] ==> ipAddress client
        passThruItem[2] ==> callback id html object
        passThruItem[3] ==> waarde tbv configuratie van trafo
    }

  storeSessionSettings(passThruItem[1]);

  menuIndex := ['home', 'voedingstrafo', 'uitgangstrafo', 'smoorspoel', 'bedrijven', 'diversen', 'winkelwagen', 'zoeken', 'instellingen',
                'savePtrafoSpecs', 'savePtrafoValues', 'saveSettings'];
  writeLog(inttostr(IndexStr(passThruItem[0], menuIndex)) + ' | ' + passThruItem[1] + ' | ' + passThruItem[2] + ' | ' + passThruItem[3]);

//    11  : Result := createJsonPayment(25.00, 'VT202503120001');
//    12  : Result := doRequest(createJsonPayment(35.00, 'VT202503120001'));

  case IndexStr(passThruItem[0], menuIndex) of
    0   : Result := getScreen('splashPage');
    1   : Result := getScreen('powerTrafoSpecs');
    2   : Result := getScreen('logo');
    3   : Result := getScreen('logo');
    4   : Result := getScreen('logo');
    5   : Result := getScreen('logo');
    6   : Result := getScreen('logo');
    7   : Result := getScreen('logo');
    8   : Result := getScreen('settings');
    9   : Result := constructPowerTrafoScreen(passThruItem[1], passThruItem[3]);
    10  : Result := calculatePowerTrafo(passThruItem[1], passThruItem[3]);
    11  : Result := saveSettings(passThruItem[1], passThruItem[3]);
//    12  : Result := '';
//    13  : Result := getScreen('indexPageCandleHolders');
//    14  : Result := getScreen('DetailPage');
//    15  : Result := getScreen('shoppingCartItems');
//    16  : Result := getScreen('indexPageDinerCandle');
//    17  : Result := getScreen('cartFlexBox');
//    18  : Result := '';
//    19  : Result := '';
//    20  : Result := '';
//    21  : Result := '';
//    22  : Result := '';
//    23  : Result := '';
//    24  : Result := '';
//    25  : Result := '';
//    26  : Result := '';
//    27  : Result := getScreen('logo');
//    28  : result := getScreen('indexPageDinerCandle');
//    29  : result := '';
    else result := 'Geen item gevonden';
   end;
     Result := passThruItem[2] + '|' + Result;
end;


end.


