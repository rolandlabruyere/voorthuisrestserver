unit ServerMethodsUnit1;

interface

uses System.SysUtils, System.Classes, Datasnap.DSServer, Datasnap.DSAuth, Dialogs, System.StrUtils,
     ServerFunctionUnit, CommonFunctionUnit, CommonProcedureUnit, RestUnit, REST.Types, dataBaseUnit,
     PrinterServerUnit;


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
        passThruItem[4] ==> reeds aanwezige html code in een div
    }

  storeSessionSettings(passThruItem[1]);

  menuIndex := ['home', 'voedingstrafo', 'uitgangstrafo', 'smoorspoel', 'bedrijven', 'diversen', 'winkelwagen', 'zoeken', 'instellingen',
                'savePtrafoSpecs', 'savePtrafoValues', 'saveSettings', 'settings', 'powerTrafoSpecs', 'prepareSales', 'printTurnSchematic', 'printMaterialList',
                'clear', 'wikkelschema', 'materiaalLijst'];
  writeLog(passThruItem[0] + ' | ' + passThruItem[1] + ' | ' + passThruItem[2] + ' | ' + passThruItem[3]);

//    11  : Result := createJsonPayment(25.00, 'VT202503120001');
//    12  : Result := doRequest(createJsonPayment(35.00, 'VT202503120001'));

  case IndexStr(passThruItem[0], menuIndex) of
    0   : Result := getScreen('splashPage');
    1   : Result := checkUnfinishedTrafo(passThruItem[1]);
    2   : Result := getScreen('logo');
    3   : Result := getScreen('logo');
    4   : Result := getScreen('logo');
    5   : Result := getScreen('logo');
    6   : Result := getScreen('logo');
    7   : Result := getScreen('logo');
    8   : Result := checkSettings(passThruItem[1]);
    9   : Result := constructPowerTrafoScreen(passThruItem[1], passThruItem[3]);
    10  : Result := calculatePowerTrafo(passThruItem[1], passThruItem[3]);
    11  : Result := saveSettings(passThruItem[1], passThruItem[3]);
    12  : Result := getScreen('settings');
    13  : Result := getScreen('powerTrafoSpecs');
    14  : Result := prepareTrafoSales(passThruItem[1], passThruItem[3]);
    15  : Result := generateTurnSchematic(passThruItem[1], passThruItem[3], passThruItem[4]);
    16  : Result := generateMaterialList(passThruItem[1], passThruItem[3], passThruItem[4]);
    17  : Result := '';
    18  : Result := uploadFile(passThruItem[0], passThruItem[1], passThruItem[3], passThruItem[4]);
    19  : Result := uploadFile(passThruItem[0], passThruItem[1], passThruItem[3], passThruItem[4]);
    else result := 'Geen item gevonden';
   end;
     Result := passThruItem[2] + '|' + Result;
end;


end.


