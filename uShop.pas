unit uShop;

interface

uses
  BeaRLibItems, uPlayer, uItem;

type
  TShopEnum = (shPotions, shScrolls, shHealer, shMana, shSmith, shArmors,
    shWeapons, shFoods, shTavern, shShields);

type
  TItemsStore = array [0 .. ItemMax - 1] of Item;

type
  TShop = class
  private
    FItemsStore: TItemsStore;
    FCount: Byte;
  public
    constructor Create;
    procedure Clear;
    property Count: Byte read FCount;
    procedure Add(const AItem: Item);
    function GetItem(const Index: Byte): Item;
  end;

type
  TShops = class
    FCurrent: TShopEnum;
    FShop: array [TShopEnum] of TShop;
    function GetShop(I: TShopEnum): TShop;
    procedure SetShop(I: TShopEnum; const Value: TShop);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Render;
    function Count: Byte;
    property Current: TShopEnum read FCurrent write FCurrent;
    property Shop[I: TShopEnum]: TShop read GetShop write SetShop;
  end;

var
  Shops: TShops;

implementation

uses
  SysUtils, Math;

{ TShop }

procedure TShop.Add(const AItem: Item);
begin
  FItemsStore[FCount] := AItem;
  Inc(FCount);
end;

procedure TShop.Clear;
var
  I: Byte;
begin
  for I := Low(FItemsStore) to High(FItemsStore) do
    Items_Clear_Item(FItemsStore[I]);
  FCount := 0;
end;

constructor TShop.Create;
begin
  Self.Clear;
end;

function TShop.GetItem(const Index: Byte): Item;
begin
  Result := FItemsStore[EnsureRange(Index, 0, ItemMax)];
end;

{ TShops }

procedure TShops.Clear;
var
  Shop: TShopEnum;
begin
  for Shop := Low(TShopEnum) to High(TShopEnum) do
    FShop[Shop].Clear;
end;

function TShops.Count: Byte;
begin
  Result := Length(FShop);
end;

constructor TShops.Create;
var
  Shop: TShopEnum;
begin
  for Shop := Low(TShopEnum) to High(TShopEnum) do
    FShop[Shop] := TShop.Create;
end;

destructor TShops.Destroy;
var
  Shop: TShopEnum;
begin
  for Shop := Low(TShopEnum) to High(TShopEnum) do
    FreeAndNil(FShop[Shop]);
  inherited;
end;

function TShops.GetShop(I: TShopEnum): TShop;
begin
  Result := FShop[I];
end;

procedure TShops.Render;
var
  I, C: Integer;
begin
  C := EnsureRange(Shops.Shop[Shops.Current].Count, 0, ItemMax);
  for I := 0 to C - 1 do
    Items.RenderInvItem(5, 2, I, Shops.Shop[Shops.Current].GetItem(I),
      True, True, ptBuy);
end;

procedure TShops.SetShop(I: TShopEnum; const Value: TShop);
begin
  FShop[I] := Value;
end;

initialization
  Shops := TShops.Create;
  Shops.Current := shPotions;

finalization
  FreeAndNil(Shops);

end.