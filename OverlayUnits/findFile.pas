type
  TForm1 = class(TForm)
    ListView1: TListView;
    procedure FormCreate(Sender: TObject);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
  private
    { Private-Deklarationen }
    procedure FindAllFiles(RootFolder: string; Mask: string = '*.*'; Recurse:
      Boolean = True);
  public
    { Public-Deklarationen }
  end;
var
  Form1        : TForm1;
implementation
{$R *.dfm}
var
  ColumnToSort : Integer;
  Accending    : Boolean = False;
function GetFileSize(szFile: PChar): Int64;
var
  fFile        : THandle;
  wfd          : TWIN32FINDDATA;
begin
  result := 0;
  if not FileExists(szFile) then
    exit;
  fFile := FindFirstfile(pchar(szFile), wfd);
  if fFile = INVALID_HANDLE_VALUE then
    exit;
  result := (wfd.nFileSizeHigh * (Int64(MAXDWORD) + 1)) + wfd.nFileSizeLow;
  windows.FindClose(fFile);
end;
procedure TForm1.FindAllFiles(RootFolder: string; Mask: string = '*.*'; Recurse:
  Boolean = True);
var
  SR           : TSearchRec;
  ListItem     : TListItem;
begin
  if RootFolder = '' then
    Exit;
  if AnsiLastChar(RootFolder)^ <> '\' then
    RootFolder := RootFolder + '\';
  RootFolder := IncludeTrailingPathDelimiter(RootFolder);
  if Recurse then
    if FindFirst(RootFolder + '*.*', faAnyFile, SR) = 0 then
    try
      repeat
        if SR.Attr and faDirectory = faDirectory then
          if (SR.Name <> '.') and (SR.Name <> '..') then
            FindAllFiles(RootFolder + SR.Name, Mask, Recurse);
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  if FindFirst(RootFolder + Mask, faAnyFile, SR) = 0 then
  try
    repeat
      if SR.Attr and faDirectory <> faDirectory then
      begin
        ListItem := Listview1.Items.Add;
        ListItem.Caption := SR.Name;
        ListItem.SubItems.Add(IntToStr(GetFileSize(PChar(RootFolder +
          SR.Name))));
      end;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  Listview1.SortType := stData;
  FindAllFiles('c:\', '*.*', False);
end;
procedure TForm1.ListView1ColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  ColumnToSort := Column.Index;
  Listview1.AlphaSort;
  Accending := not Accending;
end;
procedure TForm1.ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
begin
  case ColumnToSort of
    0:
      begin
        if Accending then
          Compare := CompareText(Item1.Caption, Item2.Caption)
        else
          Compare := CompareText(Item2.Caption, Item1.Caption);
      end;
    1:
      begin
        if Accending then
          Compare := StrToInt(Item1.SubItems[0]) - StrToInt(Item2.SubItems[0])
        else
          Compare := StrToInt(Item2.SubItems[0]) - StrToInt(Item1.SubItems[0]);
      end;
  end;
end;
