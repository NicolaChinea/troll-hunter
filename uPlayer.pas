unit uPlayer;

interface

uses uCommon;

type
  TSkillEnum = (skLearning,
    // Attributes skills
    skAthletics, skDodge, skConcentration, skToughness,
    // Weapon skills
    skBlade, skAxe, skSpear, skMace,
    // Skills
    skStealth, skHealing);
    
type
  TSkill = record
    Value: Integer;
    Exp: Integer;
  end;

const
  SkillMin = 5;
  SkillMax = 75;
  SkillExp = 100;
  AtrMax = 100;
  RadiusMax = 15;
  DVMax = 80;
  PVMax = 250;
  ExpMax = 10;

type
  TPlayer = class(TObject)
  private
    FX: Byte;
    FY: Byte;
    FLX: Byte;
    FLY: Byte;
    FTurn: Word;
    FLevel: Byte;
    FLife: Word;
    FMaxLife: Word;
    FMana: Word;
    FMaxMana: Word;
    FRadius: Byte;
    FDV: Byte;
    FPV: Byte;
    FExp: Byte;
    FDamage: TDamage;
    FLook: Boolean;
    FStrength: Byte;
    FDexterity: Byte;
    FWillpower: Byte;
    FPerception: Byte;
    FGold: Integer;
    FSkill: array [TSkillEnum] of TSkill;
    FWeaponSkill: TSkillEnum;
  public
    constructor Create;
    destructor Destroy; override;
    property X: Byte read FX write FX;
    property Y: Byte read FY write FY;
    property LX: Byte read FLX write FLX;
    property LY: Byte read FLY write FLY;
    property Turn: Word read FTurn write FTurn;
    property Level: Byte read FLevel write FLevel;
    property Life: Word read FLife write FLife;
    property MaxLife: Word read FMaxLife write FMaxLife;
    property Mana: Word read FMana write FMana;
    property MaxMana: Word read FMaxMana write FMaxMana;
    property Radius: Byte read FRadius write FRadius;
    property DV: Byte read FDV write FDV;
    property PV: Byte read FPV write FPV;
    property Exp: Byte read FExp write FExp;
    property Look: Boolean read FLook write FLook;
    property Strength: Byte read FStrength write FStrength;
    property Dexterity: Byte read FDexterity write FDexterity;
    property Willpower: Byte read FWillpower write FWillpower;
    property Perception: Byte read FPerception write FPerception;
    property Gold: Integer read FGold write FGold;
    procedure Render(AX, AY: Byte);
    procedure Move(AX, AY: ShortInt);
    property Damage: TDamage read FDamage write FDamage;
    procedure Calc;
    procedure Fill;
    procedure Wait;
    procedure AddTurn;
    function GetRadius: Byte;
    function GetDV: Byte;
    function GetPV: Byte;
    function SaveCharacterDump(AReason: string): string;
    procedure Skill(ASkill: TSkillEnum; AExpValue: Byte = 1);
    function GetSkill(ASkill: TSkillEnum): TSkill;
    procedure Defeat(AKiller: string);
    procedure Attack(Index: Integer);
    function GetSkillName(ASkill: TSkillEnum): string;
    function GetSkillValue(ASkill: TSkillEnum): Byte;
    procedure PickUp;
    procedure Drop(Index: Integer);
    procedure Use(Index: Integer);
    procedure Equip(Index: Integer);
    procedure UnEquip(Index: Integer);
    procedure AddExp(Value: Byte = 1);
    procedure StarterSet;
  end;

var
  Player: TPlayer = nil;

implementation

uses Classes, SysUtils, Dialogs, Math, uMap, uMob, uScenes,
  uTerminal, uMsgLog, gnugettext, BeaRLibItems, uItem;

{ TPlayer }

procedure TPlayer.AddTurn;
var
  V: Byte;
begin
  Turn := Turn + 1;
  V := Clamp(100 - Player.GetSkillValue(skToughness), 25, 100);
  if ((Turn / V) = (Turn div V)) then
  begin
    if (RandomRange(0, 4) = 0) then
      Life := Clamp(Life + Player.GetSkillValue(skHealing), 0, MaxLife);
    Mana := Clamp(Life + Player.GetSkillValue(skConcentration), 0, MaxMana);
  end;
  Mobs.Process;
end;

procedure TPlayer.Attack(Index: Integer);
var
  Mob: TMob;
  Dam: Word;
  The: string;
begin
  if (Index < 0) then
    Exit;
  Mob := Mobs.FMob[Index];
  if not Mob.Alive then
    Exit;
  The := GetDescThe(Mobs.GetName(TMobEnum(Mob.ID)));
  if (MobBase[TMobEnum(Mob.ID)].DV < Math.RandomRange(0, 100)) then
  begin
    // Attack
    Dam := Clamp(RandomRange(Self.Damage.Min, Self.Damage.Max + 1), 0, High(Word));
    Mob.Life := Clamp(Mob.Life - Dam, 0, High(Word));
    MsgLog.Add(Format(_('You hit %s (%d).'), [The, Dam]));
    case FWeaponSkill of
      skBlade:
      begin
        Skill(FWeaponSkill, Player.GetSkillValue(skLearning));
        Skill(skAthletics, 2);
        Skill(skDodge, 2);
      end;
      skAxe:
      begin
        Skill(FWeaponSkill, Player.GetSkillValue(skLearning));
        Skill(skAthletics, 3);
        Skill(skDodge);
      end;
      skSpear:
      begin
        Skill(FWeaponSkill, Player.GetSkillValue(skLearning));
        Skill(skAthletics);
        Skill(skDodge, 3);
      end;
      skMace:
      begin
        Skill(FWeaponSkill, Player.GetSkillValue(skLearning));
        Skill(skAthletics, 4);
      end;
    end;
    if (RandomRange(0, 2) = 0) then Skill(skLearning) else Skill(skToughness);
    // Victory
    if (Mob.Life = 0) then
    begin
      Mob.Defeat;
    end;
  end
  else
  begin
    // Miss
    MsgLog.Add(Format(_('You fail to hurt %s.'), [The]));
  end;
  AddTurn;
end;

procedure TPlayer.Calc;
var
  I, FCount, Def: Integer;
  Dam: TDamage;
  FI: TItemEnum;
  FItem: Item;
begin
  Dam.Min := 0;
  Dam.Max := 0;
  Def := 0;
  FCount := Clamp(Items_Inventory_GetCount(), 0, 26);
  for I := 0 to FCount - 1 do
  begin
    FItem := Items_Inventory_GetItem(I);
    if (FItem.Equipment > 0) then
    begin
      FI := TItemEnum(FItem.ItemID);
      Dam.Min := Dam.Min + ItemBase[FI].Damage.Min;
      Dam.Max := Dam.Max + ItemBase[FI].Damage.Max;
      Def := Def + ItemBase[FI].Defense;
      if (ItemBase[FI].SlotType = stRHand) then
        case ItemBase[FI].ItemType of
          itBlade: FWeaponSkill := skBlade;
          itAxe  : FWeaponSkill := skAxe;
          itSpear: FWeaponSkill := skSpear;
          itMace : FWeaponSkill := skMace;
          else FWeaponSkill := skLearning;
        end;
    end;
  end;
  //
  Self.Gold := Clamp(Items_Inventory_GetItemAmount(Ord(iGold)), 0, High(Integer));
  //
  Strength := Clamp(Round(FSkill[skAthletics].Value * 0.5) +
    Round(FSkill[skToughness].Value * 0.9), 1, AtrMax);
  Dexterity := Clamp(Round(FSkill[skDodge].Value * 1.4), 1, AtrMax);
  Willpower := Clamp(Round(FSkill[skConcentration].Value * 1.4), 1, AtrMax);
  Perception := Clamp(Round(FSkill[skToughness].Value * 1.4), 1, AtrMax);
  //
  DV := Clamp(Round(Dexterity * (DVMax / AtrMax)), 0, DVMax);
  PV := Clamp(Round(FSkill[skToughness].Value / 1.4) - 4 + Def,
    0, PVMax);
  MaxLife := Round(Strength * 3.6) + Round(Dexterity * 2.3);
  MaxMana := Round(Willpower * 4.2) + Round(Dexterity * 0.4);
  Radius := Round(Perception / 8.3);
  //
  FDamage.Min := Clamp(Dam.Min + Strength div 3, 1, High(Byte) - 1);
  FDamage.Max := Clamp(Dam.Max + Strength div 2, 2, High(Byte));
end;

constructor TPlayer.Create;
var
  I: TSkillEnum;
begin
  Exp := 0;
  Turn := 0;
  Gold := 0;
  Level := 1;
  Look := False;
  FWeaponSkill := skLearning;
  for I := Low(TSkillEnum) to High(TSkillEnum) do
    with FSkill[I] do
    begin
      if WizardMode then
        Value := Math.RandomRange(SkillMin, SkillMax)
      else
        Value := SkillMin;
      Exp := Math.RandomRange(0, SkillExp);
    end;
  Self.Calc;
  Self.Fill;
end;

procedure TPlayer.Defeat(AKiller: string);
begin
  Killer := AKiller;
  MsgLog.Add(_('[color=red]You die...[/color]'));
  TextScreenshot := GetTextScreenshot();
end;

destructor TPlayer.Destroy;
begin

  inherited;
end;

procedure TPlayer.Fill;
begin
  Life := MaxLife;
  Mana := MaxMana;
end;

function TPlayer.GetDV: Byte;
begin
  Result := Clamp(Self.DV, 0, DVMax);
end;

function TPlayer.GetPV: Byte;
begin
  Result := Clamp(Self.PV, 0, PVMax);
end;

function TPlayer.GetRadius: Byte;
begin
  Result := Clamp(Self.Radius + 3, 1, RadiusMax);
end;

function TPlayer.GetSkill(ASkill: TSkillEnum): TSkill;
begin
  Result := FSkill[ASkill];
end;

function TPlayer.GetSkillName(ASkill: TSkillEnum): string;
begin
  case ASkill of
    skLearning:
      Result := _('Learning');
    // Attributes skills
    skAthletics:
      Result := _('Athletics');
    skDodge:
      Result := _('Dodge');
    skConcentration:
      Result := _('Concentration');
    skToughness:
      Result := _('Toughness');
    // Weapon skills
    skBlade:
      Result := _('Blade');
    skAxe:
      Result := _('Axe');
    skSpear:
      Result := _('Spear');
    skMace:
      Result := _('Mace');
    // Skills
    skStealth:
      Result := _('Stealth');
    skHealing:
      Result := _('Healing');
  end;
end;

function TPlayer.GetSkillValue(ASkill: TSkillEnum): Byte;
begin
  Result := FSkill[ASkill].Value;
end;

procedure TPlayer.Move(AX, AY: ShortInt);
var
  FX, FY: Byte;
begin
  if Look then
  begin
    if Map.InMap(LX + AX, LY + AY) and
      ((Map.InView(LX + AX, LY + AY) and not Map.GetFog(LX + AX, LY + AY)) or
      (WizardMode)) then
    begin
      LX := Clamp(LX + AX, 0, High(Byte));
      LY := Clamp(LY + AY, 0, High(Byte));
    end;
  end
  else
  begin
    if (Life = 0) then
    begin
      Scenes.SetScene(scDef);
      Exit;
    end;
    if WonGame then
    begin
      Scenes.SetScene(scWin);
      Exit;
    end;
    FX := Clamp(X + AX, 0, High(Byte));
    FY := Clamp(Y + AY, 0, High(Byte));
    if (Map.GetTileEnum(FX, FY, Map.Deep) in StopTiles) and not WizardMode then
      Exit;
    if not Mobs.GetFreeTile(FX, FY) then
    begin
      Self.Attack(Mobs.GetIndex(FX, FY));
    end
    else
    begin
      X := FX;
      Y := FY;
      AddTurn;
    end;
  end;
end;

procedure TPlayer.Use(Index: Integer);
var
  The: string;
  AItem: Item;
  FCount: Integer;
begin
  AItem := Items_Inventory_GetItem(Index);
  The := GetDescThe(Items.GetName(TItemEnum(AItem.ItemID)));
  FCount := Items_Inventory_GetItemCount(AItem.ItemID);
  if (AItem.Equipment = 1) then
    Self.UnEquip(Index) else
  if (AItem.Equipment = 0) then
    Self.Equip(Index) else
  MsgLog.Add(Format(_('You don''t know how to use %s.'), [The]));
end;

procedure TPlayer.Equip(Index: Integer);
var
  The: string;
  AItem, AUnEquipItem: Item;
  I, C: Integer;
begin
  // Replace
  I := Items_Inventory_EquipItem(Index);
  if (I > -1) then
  begin
    AUnEquipItem := Items_Inventory_GetItem(I);
    //Items.GetItemEnum(AUnEquipItem.ItemID)
    The := GetDescThe(Items.GetName(Items.GetItemEnum(AUnEquipItem.ItemID)));
    MsgLog.Add(Format(_('You unequip %s.'), [The]));
    Wait;
  end;
  // Equip
  AItem := Items_Inventory_GetItem(Index);
  The := GetDescThe(Items.GetName(Items.GetItemEnum(AItem.ItemID)));
  MsgLog.Add(Format(_('You equip %s.'), [The]));
  Self.Calc;
  Wait;
end;

procedure TPlayer.UnEquip(Index: Integer);
var
  The: string;
  AItem: Item;
begin
  if (Items_Inventory_UnEquipItem(Index) > 0) then
  begin
    AItem := Items_Inventory_GetItem(Index);
    The := GetDescThe(Items.GetName(Items.GetItemEnum(AItem.ItemID)));
    MsgLog.Add(Format(_('You unequip %s.'), [The]));
    Self.Calc;
    Wait;
  end;
end;

procedure TPlayer.Drop(Index: Integer);
var
  AItem: Item;
  MapID, FCount, C: Integer;

  procedure DeleteItem;
  var
    The: string;
  begin
    if (Items_Inventory_DeleteItem(Index, AItem) > 0) then
    begin
      AItem.X := Player.X;
      AItem.Y := Player.Y;
      AItem.MapID := Ord(Map.Deep);
      Items_Dungeon_AppendItem(AItem);
      The := GetDescThe(Items.GetName(TItemEnum(AItem.ItemID)));
      MsgLog.Add(Format(_('You drop %s.'), [The]));
      Wait;
    end;
  end;

begin
  MapID := Ord(Map.Deep);
  AItem := Items_Inventory_GetItem(Index);
  FCount := Items_Inventory_GetItemCount(AItem.ItemID);
  if (AItem.Stack > 1) and (AItem.Amount > 1) then
  begin

    Exit;
  end else DeleteItem;
end;

procedure TPlayer.PickUp;
var
  The: string;
  MapID, FCount, Index: Integer;
  FItem: Item;
begin
  //// Your backpack is full!
  MapID := Ord(Map.Deep);
  FCount := Items_Dungeon_GetMapCountXY(MapID, Player.X, Player.Y);
//  if (FItem.Stack > 1) and (FItem.Amount > 1) then
  if (FCount > 0) then
  begin
    if (FCount = 1) then
    begin
      // Pickup an item
      Items.AddItemToInv(0);
    end else begin
      // Items scene
      Scenes.SetScene(scItems);
    end;
  end;
end;

procedure TPlayer.Render(AX, AY: Byte);
begin
  if (Self.Life = 0) then
    Terminal.Print(AX + View.Left, AY + View.Top, '%', clDarkGray)
  else
    Terminal.Print(AX + View.Left, AY + View.Top, '@', clDarkBlue);
end;

function TPlayer.SaveCharacterDump(AReason: string): string;
var
  SL: TStringList;
begin
  if WizardMode then
    Exit;
  SL := TStringList.Create;
  try
    SL.Append(Format(FT, [_('Trollhunter')]));
    SL.Append('');
    SL.Append(GetDateTime);
    SL.Append('');
    SL.Append(AReason);
    SL.Append('');
    SL.Append(Format(FT, [_('Screenshot')]));
    SL.Append(TextScreenshot);
    SL.Append(Format(FT, [_('Last messages')]));
    SL.Append('');
    SL.Append(MsgLog.GetLastMsg(10));
    SL.Append(Format(FT, [_('Inventory')]));
    SL.Append('');
    SL.Append('');
    SL.SaveToFile(GetDateTime('-', '-') + '-character-dump.txt');
  finally
    SL.Free;
  end;
end;

procedure TPlayer.AddExp(Value: Byte = 1);
begin
  Exp := Exp + Value;
  if (Exp >= ExpMax) then
  begin
    Exp := Exp - ExpMax;
    FLevel := FLevel + 1;
    MsgLog.Add(Format('%s +1.', [_('Level')]));
  end;
end;

procedure TPlayer.Skill(ASkill: TSkillEnum; AExpValue: Byte = 1);
begin
  if (FSkill[ASkill].Value < SkillMax) then
  begin
    Inc(FSkill[ASkill].Exp, AExpValue);
    if (FSkill[ASkill].Exp >= SkillExp) then
    begin
      AddExp();
      FSkill[ASkill].Exp := FSkill[ASkill].Exp - SkillExp;
      Inc(FSkill[ASkill].Value);
      // Add message
      MsgLog.Add(Format('%s %s +1.', [_('Skill'), Self.GetSkillName(ASkill)]));
      FSkill[ASkill].Value := Clamp(FSkill[ASkill].Value, SkillMin, SkillMax);
      Self.Calc;
    end;
  end;
end;

procedure TPlayer.Wait;
begin
  if not DeepVis[Map.Deep] then
  begin
    MsgLog.Add(Format(_('You have opened a new territory: %s.'),
      [Map.GetName]));
    DeepVis[Map.Deep] := True;
  end;
  Move(0, 0);
end;

procedure TPlayer.StarterSet;
var
  G: Word;
begin
  // Add weapon and armor
  if WizardMode then
  begin
    Items.AddItemToInv(iTrollSlayer, 1, True);
  end else begin
    Items.AddItemToInv(iSlagHammer, 1, True);
  end;
  // Add potions and scrolls
  Items.AddItemToInv(iPotionOfHealth, 5);
  Items.AddItemToInv(iPotionOfMana, 5);
  // Add coins
  G := IfThen(WizardMode, RandomRange(3333, 9999), 30);
  Items.AddItemToInv(iGold, G);
  Self.Calc;
end;

initialization

Player := TPlayer.Create;

finalization

FreeAndNil(Player);

end.
