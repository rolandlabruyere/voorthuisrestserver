unit ServerMethodsUnit1;

interface

uses System.SysUtils, System.Classes, Datasnap.DSServer, Datasnap.DSAuth, FormUnit1,
     ServerFunctionUnit;

type
  {$METHODINFO ON}
    TServerMethods1 = class(TComponent)
    private
      { Private declarations }
    public
      { Public declarations }
      function restGetDispatcher(argumentList: string): string;
    end;
  {$METHODINFO OFF}

  implementation

  uses System.StrUtils;

  {
    in argumentlist staat de serverfunctie en de pagina die wordt opgevraagd, gescheiden door een puntkomma
    dus bijv. : getScreen;indexPageCandleHolders
    met het eerste argument wordt de index van de "case of" bepaald. Het tweede argument wordt desgewenst doorgegeven
    en gebruikt om de juiste HTML-pagina op te halen.

    Voordeel hiervan is dat de javascript code in "ServerFunctions.js" eenvoudig blijft. Slechts een GET en een POST functie.
  }



  function TServerMethods1.restGetDispatcher(argumentList: string): string;
    const
      restGetFunctions: TArray<String> = ['loadPage', 'getScreen', 'getDetailScreen', 'sessionSpecs', 'getObjectPrice', 'addCart',
                                          'checkCart', 'listGroupedCartItems', 'listGroupedInvoiceItems'];
    var
      thisFunction, thisArgument, pageId, sessionId: String;
  begin
    thisFunction := trim(copy(argumentList, 0, pos(';', argumentList) - 1));
    thisArgument := trim(copy(argumentList, pos(';', argumentList) + 1, length(argumentList) - pos(';', argumentList)));

    if (pos('?', thisArgument) > 0) then begin
      pageId := trim(copy(thisArgument, 0, pos('?', thisArgument) - 1));
      sessionId := trim(copy(thisArgument, pos('?', thisArgument) + 1, length(thisArgument) - pos('?', thisArgument)));
      updateSessionSettings(sessionId);
      createShoppingCart(sessionId);
    end else begin
      pageId := thisArgument;
    end;

    case IndexText(thisFunction, restGetFunctions) of
      0: begin result := loadPage(); if(thisArgument <> '') then updateSessionSettings(thisArgument); end;
      1: result := ServerFunctionUnit.getScreen(pageId);
      2: result := ServerFunctionUnit.getDetailScreen(pageId);
      3: result := ServerFunctionUnit.storeSessionSettings(pageId);
      4: result := ServerFunctionUnit.getObjectPrice(pageId);
      5: result := ServerFunctionUnit.getObjectInCart(pageId, sessionId);
      6: result := ServerFunctionUnit.checkCart(sessionId);
      7: result := ServerFunctionUnit.listGroupedCartItems(sessionId);
      8: result := ServerFunctionUnit.listGroupedInvoiceItems(sessionId);
    end;
  end;
end.


