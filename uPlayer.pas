unit uPlayer;

interface

uses uEntity, uMob, uSkill, uStatistic;

type
  TSlotType = (stNone, stHead, stTorso, stHands, stFeet, stMainHand, stOffHand,
    stNeck, stFinger);

type
  TEffect = (efLife, efMana, efFood, efTeleportation, efIdentification,
    efTownPortal, efMagicEye, efCurePoison, efCureWeak, efPrmGold,
    efPrmAthletics, efPrmDodge, efPrmConcentration, efPrmToughness, efPrmBlade,
    efPrmAxe, efPrmSpear, efPrmMace, ef2xGold, efBloodlust, efPrmLife, efPrmMana,
    efPrmDV, efPrmPV);

type
  TEffects = set of TEffect;

const
  // Player
  AtrMax = 100;
  RadiusMax = 15;
  DVMax = 80;
  LevelExpMax = 8;
  // Satiation
  StarvingMax = 500;
  SatiatedMax = 8000;
  EngorgedMax = 15000;
  // Inventory
  ItemMax = 26;
  StartGold = 250;
  // Talents
  TalentPrm = 3;
  AttribPrm = 7;

type
  TPlayer = class(TEntity)
  private
    FLX: Byte;
    FLY: Byte;
    FTurn: Word;
    FSatiation: Word;
    FLevel: Byte;
    FMana: Word;
    FMaxMana: Word;
    FRadius: Byte;
    FDV: Byte;
    FPV: Byte;
    FPrmDV: Byte;
    FPrmPV: Byte;
    FPrmLife: Byte;
    FPrmMana: Byte;
    FExp: Byte;
    FMaxMap: Byte;
    FLook: Boolean;
    FStrength: Byte;
    FDexterity: Byte;
    FWillpower: Byte;
    FPerception: Byte;
    FGold: Integer;
    FScore: Word;
    FKiller: string;
    FWeaponSkill: TSkillEnum;
    FItemIsDrop: Boolean;
    FItemIndex: Integer;
    FItemAmount: Integer;
    FSatPerTurn: Byte;
    FIsRest: Boolean;
    FName: string;
    FStatistics: TStatistics;
    FSkills: TSkills;
    FTalentPoint: Boolean;
    procedure GenNPCText;
    function GetDV: Byte;
    function GetPV: Byte;
    function GetRadius: Byte;
    function GetSatiation: Word;
  public
    constructor Create;
    destructor Destroy; override;
    property LX: Byte read FLX write FLX;
    property LY: Byte read FLY write FLY;
    property Turn: Word read FTurn write FTurn;
    property Satiation: Word read GetSatiation write FSatiation; // Nutrition
    property Level: Byte read FLevel write FLevel;
    property Mana: Word read FMana write FMana;
    property MaxMana: Word read FMaxMana write FMaxMana;
    property Radius: Byte read GetRadius write FRadius;
    property DV: Byte read GetDV write FDV;
    property PV: Byte read GetPV write FPV;
    property PrmDV: Byte read FPrmDV write FPrmDV;
    property PrmPV: Byte read FPrmPV write FPrmPV;
    property Exp: Byte read FExp write FExp;
    property MaxMap: Byte read FMaxMap write FMaxMap;
    property PrmLife: Byte read FPrmLife write FPrmLife;
    property PrmMana: Byte read FPrmMana write FPrmMana;
    property Look: Boolean read FLook write FLook;
    property Strength: Byte read FStrength write FStrength;
    property Dexterity: Byte read FDexterity write FDexterity;
    property Willpower: Byte read FWillpower write FWillpower;
    property Perception: Byte read FPerception write FPerception;
    property Gold: Integer read FGold write FGold;
    property Score: Word read FScore write FScore;
    property Killer: string read FKiller write FKiller;
    property IsRest: Boolean read FIsRest write FIsRest;
    property ItemIsDrop: Boolean read FItemIsDrop write FItemIsDrop;
    property ItemIndex: Integer read FItemIndex write FItemIndex;
    property ItemAmount: Integer read FItemAmount write FItemAmount;
    property SatPerTurn: Byte read FSatPerTurn write FSatPerTurn;
    property Statictics: TStatistics read FStatistics write FStatistics;
    property Name: string read FName write FName;
    property TalentPoint: Boolean read FTalentPoint write FTalentPoint;
    property Skills: TSkills read FSkills write FSkills;
    procedure SetAmountScene(IsDrop: Boolean; Index, Amount: Integer);
    procedure Render(AX, AY: Byte);
    procedure Move(AX, AY: ShortInt);
    procedure RenderInfo;
    procedure Calc;
    procedure Fill;
    procedure Wait;
    procedure Clear;
    procedure AddTurn;
    procedure Spawn;
    function GetSatiationStr: string;
    function SaveCharacterDump(AReason: string): string;
    procedure Defeat(AKiller: string = '');
    procedure Attack(Index: Integer);
    procedure ReceiveHealing;
    procedure Buy(Index: Integer);
    procedure PickUp;
    procedure PickUpAmount(Index: Integer);
    procedure Drop(Index: Integer);
    procedure DropAmount(Index: Integer);
    procedure Use(Index: Integer);
    procedure DoEffects(const Effects: TEffects; const Value: Word = 0);
    procedure Equip(Index: Integer);
    procedure UnEquip(Index: Integer);
    procedure Sell(Index: Integer);
    procedure RepairItem(Index: Integer);
    procedure IdentItem(Index: Integer);
    procedure BreakItem(Index: Integer; Value: Byte = 1); overload;
    procedure BreakItem(ASlot: TSlotType; Value: Byte = 1); overload;
    procedure AddExp(Value: Byte = 1);
    procedure Start;
    procedure Rest(ATurns: Word);
    procedure Dialog(AMob: TMob);
    procedure AutoPickup();
  end;

var
  Player: TPlayer = nil;

implementation

uses Classes, SysUtils, Dialogs, Math, IniFiles, uItem, uGame, uMap, uScenes,
  uTerminal, uMsgLog, GNUGetText, BeaRLibItems, uCorpse, uCalendar,
  uShop, BearLibTerminal, uAbility;

{ TPlayer }

procedure TPlayer.AddTurn;
var
  V, C: Byte;
begin
  if IsDead then Exit;
  Turn := Turn + 1;
  Calendar.Turn;
  if (Satiation > 0) then
    Satiation := Satiation - SatPerTurn;
  if Abilities.IsAbility(abWeak) then
    Satiation := Satiation - 10;
  if (Satiation < StarvingMax) then
  begin
    Life := EnsureRange(Life - 1, 0, MaxLife);
  end
  else
  if not Abilities.IsAbility(abDiseased) then
  begin
    V := EnsureRange(100 - Player.Skills.Skill[skHealing].Value, 25, 100);
    if (Turn mod V = 0) then
    begin
      C := Player.Skills.Skill[skHealing].Value;
      if Abilities.IsAbility(abRegen) then C := EnsureRange(C * 3, C, High(Byte));
      Life := EnsureRange(Life + C, 0, MaxLife);
    end;
    V := EnsureRange(100 - Player.Skills.Skill[skConcentration].Value, 25, 100);
    if (Turn mod V = 0) then
    begin
      C := Player.Skills.Skill[skConcentration].Value;
      if Abilities.IsAbility(abRegen) then C := EnsureRange(C * 3, C, High(Byte));
      Mana := EnsureRange(Mana + C, 0, MaxMana);
    end;
  end;
  OnTurn();
  if (Life = 0) then Self.Defeat;
  Mobs.Process;
end;

procedure TPlayer.Attack(Index: Integer);
var
  V, Ch: Byte;
  Mob: TMob;
  Dam, Cr: Word;
  CrStr, The: string;

  procedure Miss();
  begin
    MsgLog.Add(Format(_('You miss %s.'), [The]));
    // MsgLog.Add(Format(_('You fail to hurt %s.'), [The]));
    SatPerTurn := Ord(Game.Difficulty) + 3;
  end;

begin
  if (Index < 0) then
    Exit;
  Mob := Mobs.Mob[Index];
  if not Mob.Alive then
    Exit;
  if (Mob.Force <> fcEnemy) then
  begin
    Self.Dialog(Mob);
    GenNPCText;
    Exit;
  end;
  The := GetDescThe(Mobs.Name[TMobEnum(Mob.ID)]);
  if (Mob.DV < Math.RandomRange(0, 100)) and not Abilities.IsAbility(abCursed) then
  begin
    CrStr := '';
    // Attack
    Dam := EnsureRange(RandomRange(Self.Damage.Min, Self.Damage.Max + 1), 0,
      High(Word));
    // Abilities
    if Abilities.IsAbility(abBloodlust) then
      Dec(Dam, Dam div 3);
    // Critical hits...     .
    Ch := Math.RandomRange(0, 100);
    Cr := Skills.Skill[FWeaponSkill].Value;
    if ((Ch < Cr) and not Abilities.IsAbility(abWeak)) then
    begin
      if (Ch > (Cr div 10)) then
      begin
        V := 2;
        CrStr := _('It was a good hit!');
      end
      else
      begin
        V := 3;
        CrStr := _('It was an excellent hit!');
      end;
      Dam := Dam * V;
      CrStr := CrStr + Format(' (%dx)', [V]);
    end;
    // PV
    Dam := Self.GetRealDamage(Dam, Mob.PV);
    if (Dam = 0) then
    begin
      Miss();
      AddTurn;
      Exit;
    end;
    // Attack
    Mob.Life := EnsureRange(Mob.Life - Dam, 0, Mob.Life);
    MsgLog.Add(Format(_('You hit %s (%d).'), [The, Dam]));
    // Break weapon
    if ((Math.RandomRange(0, 10 - Ord(Game.Difficulty)) = 0)
      and not Game.Wizard) then BreakItem(stMainHand);
    if (CrStr <> '') then
      MsgLog.Add(Terminal.Colorize(CrStr, clAlarm));
    case FWeaponSkill of
      skBlade:
        begin
          Skills.DoSkill(FWeaponSkill, 2);
          Skills.DoSkill(skAthletics, 2);
          Skills.DoSkill(skDodge, 2);
          SatPerTurn := Ord(Game.Difficulty) + 5;
        end;
      skAxe:
        begin
          Skills.DoSkill(FWeaponSkill, 2);
          Skills.DoSkill(skAthletics, 3);
          Skills.DoSkill(skDodge);
          SatPerTurn := Ord(Game.Difficulty) + 6;
        end;
      skSpear:
        begin
          Skills.DoSkill(FWeaponSkill, 2);
          Skills.DoSkill(skAthletics);
          Skills.DoSkill(skDodge, 3);
          SatPerTurn := Ord(Game.Difficulty) + 4;
        end;
      skMace:
        begin
          Skills.DoSkill(FWeaponSkill, 2);
          Skills.DoSkill(skAthletics, 4);
          SatPerTurn := Ord(Game.Difficulty) + 7;
        end;
    end;
    // Victory
    if (Mob.Life = 0) then Mob.Defeat;
  end
  else Miss();
  AddTurn;
end;

procedure TPlayer.AutoPickup;
var
  Index, FCount: Integer;
  ItemType: TItemType;
  FItem: Item;
begin
  FCount := EnsureRange(Items_Dungeon_GetMapCountXY(Ord(Map.Current), X, Y),
    0, ItemMax);
  for Index := FCount - 1 downto 0 do
  begin
    FItem := Items_Dungeon_GetMapItemXY(Ord(Map.Current), Index, X, Y);
    ItemType := ItemBase[TItemEnum(FItem.ItemID)].ItemType;
    if (ItemType in AutoPickupItems) then
    begin
      if ((ItemType = itCoin) and not Game.APCoin) then
        Exit;
      if ((ItemType = itFood) and not Game.APFood) then
        Exit;
      if ((ItemType = itPotion) and not Game.APPotion) then
        Exit;
      if ((ItemType = itScroll) and not Game.APScroll) then
        Exit;
      if ((ItemType = itRune) and not Game.APRune) then
        Exit;
      if ((ItemType = itBook) and not Game.APBook) then
        Exit;
      if ((ItemType = itGem) and not Game.APGem) then
        Exit;
      Items.AddItemToInv(Index, True);
      Wait;
    end;
  end;
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
  FCount := EnsureRange(Items_Inventory_GetCount(), 0, ItemMax);
  for I := 0 to FCount - 1 do
  begin
    FItem := Items_Inventory_GetItem(I);
    if (FItem.Equipment > 0) then
    begin
      FI := TItemEnum(FItem.ItemID);
      Dam.Min := Dam.Min + FItem.MinDamage;
      Dam.Max := Dam.Max + FItem.MaxDamage;
      Def := Def + FItem.Defense;
      if (ItemBase[FI].SlotType = stMainHand) then
        case ItemBase[FI].ItemType of
          itBlade:
            FWeaponSkill := skBlade;
          itAxe:
            FWeaponSkill := skAxe;
          itSpear:
            FWeaponSkill := skSpear;
          itMace:
            FWeaponSkill := skMace;
        else
          FWeaponSkill := skLearning;
        end;
    end;
  end;
  //
  Self.Gold := EnsureRange(Items_Inventory_GetItemAmount(Ord(iGold)), 0,
    High(Integer));
  //
  Strength := EnsureRange(Round(Skills.Skill[skAthletics].Value * 1.2) +
    Round(Skills.Skill[skToughness].Value * 0.2), 1, AtrMax);
  Dexterity := EnsureRange(Round(Skills.Skill[skDodge].Value * 1.4), 1, AtrMax);
  Willpower := EnsureRange(Round(Skills.Skill[skConcentration].Value * 1.4),
    1, AtrMax);
  Perception := EnsureRange(Round(Skills.Skill[skToughness].Value * 1.4),
    1, AtrMax);
  if (Abilities.IsAbility(abWeak)) then
  begin
    Strength := Strength div 2;
    Dexterity := Dexterity div 2;
  end;
  if Abilities.IsAbility(abAfraid) then
  begin
    Willpower := Willpower div 3;
  end;
  if Abilities.IsAbility(abDrunk) then
  begin
    Perception := Perception div 3;
  end;
  //
  DV := EnsureRange(Round(Dexterity * (DVMax / AtrMax)) + PrmDV, 0, DVMax);
  PV := EnsureRange(Round(Skills.Skill[skToughness].Value / 1.4) - 4 + Def +
    PrmPV, 0, PVMax);
  MaxLife := Round(Strength * 3.6) + Round(Dexterity * 2.3) + PrmLife;
  MaxMana := Round(Willpower * 4.2) + Round(Dexterity * 0.4) + PrmMana;
  Radius := Round(Perception / 8.3);
  //
  Self.SetDamage(EnsureRange(Dam.Min + Strength div 3, 1, High(Byte) - 1),
    EnsureRange(Dam.Max + Strength div 2, 2, High(Byte)));
end;

procedure TPlayer.Clear;
begin
  Killer := '';
  Alive := True;
  Look := False;
  IsRest := False;
  SatPerTurn := 2;
  Satiation := SatiatedMax;
  Abilities.Clear;
  // MsgLog.Clear;
  Calc;
  Fill;
end;

constructor TPlayer.Create;
begin
  inherited;
  FStatistics := TStatistics.Create;
  FWeaponSkill := skLearning;
  Exp := 0;
  Turn := 0;
  Gold := 0;
  Score := 0;
  PrmDV := 0;
  PrmPV := 0;
  PrmLife := 0;
  PrmMana := 0;
  Level := 1;
  MaxMap := 0;
  TalentPoint := True;
  Name := _('PLAYER');
  FSkills := TSkills.Create;
  Self.Clear;
end;

procedure TPlayer.Defeat(AKiller: string = '');
begin
  Killer := AKiller;
  MsgLog.Add(Terminal.Colorize(_('You die...'), 'Light Red'));
  MsgLog.Add(Format(_('Press %s to try again...'), [TScene.KeyStr('SPACE')]));
  Corpses.Append();
  Game.Screenshot := Terminal.GetTextScreenshot();
end;

destructor TPlayer.Destroy;
begin
  FreeAndNil(FSkills);
  FreeAndNil(FStatistics);
  inherited;
end;

procedure TPlayer.Dialog(AMob: TMob);
begin
  Game.Timer := High(Byte);
  NPCName := Mobs.Name[TMobEnum(AMob.ID)];
  NPCType := MobBase[TMobEnum(AMob.ID)].NPCType;
  Scenes.SetScene(scDialog);
end;

procedure TPlayer.Fill;
begin
  Life := MaxLife;
  Mana := MaxMana;
end;

procedure TPlayer.GenNPCText;
var
  S: string;
begin
  case Math.RandomRange(0, 3) of
    0:
      S := _('What can I do for you?');
    1:
      S := _('What can I get you today?');
  else
    S := _('Good day!');
  end;
  MsgLog.Add(Format(_('%s says: "%s"'), [NPCName, S]));
end;

function TPlayer.GetDV: Byte;
begin
  Result := EnsureRange(FDV, 0, DVMax);
end;

function TPlayer.GetPV: Byte;
begin
  Result := EnsureRange(FPV, 0, PVMax);
end;

function TPlayer.GetRadius: Byte;
begin
  Result := EnsureRange((FRadius - Abilities.Ability[abBlinded]) + 3, 0,
    RadiusMax);
end;

function TPlayer.GetSatiationStr: string;
begin
  Result := '';
  case Satiation of
    0 .. StarvingMax:
      Result := _('Starving');
    StarvingMax + 1 .. 1500:
      Result := _('Near starving');
    1501 .. 2000:
      Result := _('Very hungry');
    2001 .. 2500:
      Result := _('Hungry');
    SatiatedMax + 1 .. 10000:
      Result := _('Full');
    10001 .. 11000:
      Result := _('Very full');
    11001 .. EngorgedMax:
      Result := _('Engorged');
  end;
  if Game.Wizard then
  begin
    if (Result = '') then
      Result := _('Satiated');
    Result := Result + Format(' (%d)', [Satiation]);
  end;
  case Satiation of
    0 .. StarvingMax:
      Result := Terminal.Colorize(Result, 'Light Red');
    StarvingMax + 1 .. SatiatedMax:
      Result := Terminal.Colorize(Result, 'Light Yellow');
  else
    Result := Terminal.Colorize(Result, 'Light Green');
  end;
end;

function TPlayer.GetSatiation: Word;
begin
  Result := EnsureRange(FSatiation, 0, EngorgedMax);
end;

procedure TPlayer.Move(AX, AY: ShortInt);
var
  FX, FY: Byte;
begin
  if Look then
  begin
    if Map.InMap(LX + AX, LY + AY) and
      ((Map.InView(LX + AX, LY + AY) and not Map.GetFog(LX + AX, LY + AY)) or
      Game.Wizard) then
    begin
      LX := Map.EnsureRange(LX + AX);
      LY := Map.EnsureRange(LY + AY);
    end;
  end
  else
  begin
      if Player.IsDead then Exit;
    FX := Map.EnsureRange(X + AX);
    FY := Map.EnsureRange(Y + AY);
    if (Map.GetTileEnum(FX, FY, Map.Current) in StopTiles) and not Game.Wizard
    then
      Exit;
    // Stunned or burning
    if (Self.Abilities.IsAbility(abStunned) or
      Self.Abilities.IsAbility(abBurning)) then
    begin
      AddTurn;
      Exit;
    end;
    //
    if not Mobs.GetFreeTile(FX, FY) then
    begin
      Self.Attack(Mobs.GetIndex(FX, FY));
    end
    else
    begin
      X := FX;
      Y := FY;
      if ((AX <> 0) or (AY <> 0)) then
      begin
        SatPerTurn := 2;
        AutoPickup;
      end;
      AddTurn;
    end;
  end;
end;

procedure TPlayer.Use(Index: Integer);
var
  The: string;
  AItem: Item;
  I: TItemEnum;
  T: TItemType;
  ItemLevel: Byte;
begin
  if Player.IsDead then Exit;
  AItem := Items_Inventory_GetItem(Index);
  // Need level
  ItemLevel := ItemBase[TItemEnum(AItem.ItemID)].Level;
  if (Player.Level < ItemLevel) and not Game.Wizard then
  begin
    MsgLog.Add(Format(_('You can not use this yet (need level %d)!'),
      [ItemLevel]));
    Self.Calc;
    Exit;
  end;
  I := TItemEnum(AItem.ItemID);
  T := ItemBase[I].ItemType;
  if (T in NotEquipTypeItems) then
  begin
    if (T in UseTypeItems) then
    begin
      if not(T in RuneTypeItems) then
        AItem.Amount := AItem.Amount - 1;
      The := GetDescThe(Items.Name[I]);
      case T of
        itPotion:
          begin
            MsgLog.Add(Format(_('You drink %s.'), [The]));
            Statictics.PotDrunk := Statictics.PotDrunk + 1;
          end;
        itScroll:
          begin
            MsgLog.Add(Format(_('You read %s.'), [The]));
            Statictics.ScrRead := Statictics.ScrRead + 1;
          end;
        itFood:
          MsgLog.Add(Format(_('You ate %s.'), [The]));
        itRune:
          MsgLog.Add(Format(_('You read %s.'), [The]));
        itBook:
          MsgLog.Add(Format(_('You read %s.'), [The]));
      end;
      if not(T in RuneTypeItems) then
        Items_Inventory_SetItem(Index, AItem);
      if (T in ScrollTypeItems + RuneTypeItems) then
      begin
        if (Self.Mana >= ItemBase[I].ManaCost) then
        begin
          Player.Skills.DoSkill(skConcentration);
          Self.Mana := Self.Mana - ItemBase[I].ManaCost;
          Statictics.SpCast := Statictics.SpCast + 1;
        end
        else
        begin
          MsgLog.Add(_('You need more mana!'));
          Self.Calc;
          Wait;
          Exit;
        end;
      end;
      DoEffects(ItemBase[I].Effects, ItemBase[I].Value);
      Self.Calc;
      Wait;
    end;
  end
  else
  begin
    // Equip or unequip an item
    case AItem.Equipment of
      0:
        Self.Equip(Index);
      1:
        Self.UnEquip(Index);
    end;
  end;
  // MsgLog.Add(Format(_('You don''t know how to use %s.'), [The]));
end;

procedure TPlayer.Equip(Index: Integer);
var
  The: string;
  AItem: Item;
  I: Integer;
  ItemLevel: Byte;
begin
  // Need level
  AItem := Items_Inventory_GetItem(Index);
  ItemLevel := ItemBase[TItemEnum(AItem.ItemID)].Level;
  if (Player.Level < ItemLevel) and not Game.Wizard then
  begin
    MsgLog.Add(Format(_('You can not use this yet (need level %d)!'),
      [ItemLevel]));
    Self.Calc;
    Exit;
  end;
  // Replace
  I := Items_Inventory_EquipItem(Index);
  if (I > -1) then
    UnEquip(I);
  // Equip
  The := GetDescThe(Items.Name[Items.GetItemEnum(AItem.ItemID)]);
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
    The := GetDescThe(Items.Name[Items.GetItemEnum(AItem.ItemID)]);
    MsgLog.Add(Format(_('You unequip %s.'), [The]));
    Self.Calc;
    Wait;
  end;
end;

procedure TPlayer.Sell(Index: Integer);
var
  Value: Integer;
  AItem: Item;
  The: string;
begin
  AItem := Items_Inventory_GetItem(Index);
  if ((AItem.Equipment > 0) or Items.ChItem(AItem)) then Exit;
  if (Items_Inventory_DeleteItem(Index, AItem) > 0) then
  begin
    Value := Items.GetPrice(AItem) div 4;
    Items.AddItemToInv(iGold, Value);
    The := GetDescThe(Items.Name[TItemEnum(AItem.ItemID)]);
    MsgLog.Add(Format(_('You sold %s (+%d gold).'), [The, Value]));
  end;
  Self.Calc;
end;

procedure TPlayer.Buy(Index: Integer);
var
  Price: Word;
  AItem: Item;
  The: string;
begin
  AItem := Shops.Shop[Shops.Current].GetItem(Index);
  Price := Items.GetPrice(AItem);
  if (Items_Inventory_DeleteItemAmount(Ord(iGold), Price) > 0) then
  begin
    The := GetDescThe(Items.Name[TItemEnum(AItem.ItemID)]);
    MsgLog.Add(Format(_('You bought %s (-%d gold).'), [The, Price]));
    Items_Inventory_AppendItem(AItem);
    Self.Calc;
    // The %s just frowns. Maybe you'll return when you have enough gold?
  end
  else
    MsgLog.Add(_('You need more gold.'));
end;

procedure TPlayer.ReceiveHealing;
var
  Cost: Word;
begin
  Cost := Round((MaxLife - Life) * 1.6);
  if (Self.Gold >= Cost) then
  begin
    if (Items_Inventory_DeleteItemAmount(Ord(iGold), Cost) > 0) then
    begin
      Life := MaxLife;
      MsgLog.Add(Format(_('You feel better (-%d gold).'), [Cost]));
    end;
  end
  else
    MsgLog.Add(_('You need more gold.'));
  Self.Calc;
end;

procedure TPlayer.IdentItem(Index: Integer);
begin

end;

procedure TPlayer.RepairItem(Index: Integer);
var
  RepairCost: Word;
  AItem: Item;
  The: string;
begin
  AItem := Items_Inventory_GetItem(Index);
  if ((AItem.Stack > 1) or (AItem.Amount > 1)) then
    Exit;
  RepairCost := (AItem.MaxDurability - AItem.Durability) * 10;
  if (RepairCost > 0) then
  begin
    if (Gold < RepairCost) then
    begin
      MsgLog.Add(_('You need more gold.'));
      Exit;
    end;
    AItem.Durability := AItem.MaxDurability;
    if ((Items_Inventory_DeleteItemAmount(Ord(iGold), RepairCost) > 0) and
      (Items_Inventory_SetItem(Index, AItem) > 0)) then
    begin
      The := GetDescThe(Items.Name[TItemEnum(AItem.ItemID)]);
      MsgLog.Add(Format(_('You repaired %s (-%d gold).'), [The, RepairCost]));
    end;
  end;
  Self.Calc;
end;

procedure TPlayer.BreakItem(Index: Integer; Value: Byte = 1);
var
  AItem: Item;
  The: string;
begin
  AItem := Items_Inventory_GetItem(Index);
  if ((AItem.Stack > 1) or (AItem.Amount > 1)) then
    Exit;
  The := GetCapit(GetDescThe(Items.Name[TItemEnum(AItem.ItemID)]));
  AItem.Durability := Math.EnsureRange(AItem.Durability - Value, 0, High(Byte));
  if ((AItem.Durability > 0) and (AItem.Durability < (AItem.MaxDurability div 4))) then
    MsgLog.Add(Terminal.Colorize(Format(_('%s soon will be totally broken (%d/%d).'),
      [The, AItem.Durability, AItem.MaxDurability]), clAlarm));
  Items_Inventory_SetItem(Index, AItem);
  if (AItem.Durability = 0) then
  begin      
    Items_Inventory_DeleteItem(Index, AItem);
    MsgLog.Add(Terminal.Colorize(Format(_('%s been ruined irreversibly.'), [The]), clAlarm));
  end;
  Self.Calc;
end;

procedure TPlayer.BreakItem(ASlot: TSlotType; Value: Byte = 1);
var
  FCount, I: Integer;
  FItem: Item;
  FI: TItemEnum;
begin
  FCount := EnsureRange(Items_Inventory_GetCount(), 0, ItemMax);
  for I := 0 to FCount - 1 do
  begin
    FItem := Items_Inventory_GetItem(I);
    if (FItem.Equipment > 0) then
    begin
      FI := TItemEnum(FItem.ItemID);
      if (ItemBase[FI].SlotType = ASlot) then
      begin
        BreakItem(I, Value);
        Exit;
      end;
    end;
  end;

end;

procedure TPlayer.Drop(Index: Integer);
var
  AItem: Item;

  procedure DeleteItem;
  var
    The: string;
  begin
    if (Items_Inventory_DeleteItem(Index, AItem) > 0) then
    begin
      AItem.X := Player.X;
      AItem.Y := Player.Y;
      AItem.Equipment := 0;
      AItem.MapID := Ord(Map.Current);
      Items_Dungeon_AppendItem(AItem);
      The := GetDescThe(Items.Name[TItemEnum(AItem.ItemID)]);
      MsgLog.Add(Format(_('You drop %s.'), [The]));
      Wait;
    end;
  end;

begin
  AItem := Items_Inventory_GetItem(Index);
  if (AItem.Equipment > 0) then
    Exit;
  if not((AItem.Stack > 1) and (AItem.Amount > 1)) then
    DeleteItem
  else
    Player.SetAmountScene(True, Index, 1);
  Self.Calc;
end;

procedure TPlayer.DropAmount(Index: Integer);
var
  FItem: Item;
  The: string;
begin
  FItem := Items_Inventory_GetItem(Index);
  FItem.Amount := FItem.Amount - Player.ItemAmount;
  Items_Inventory_SetItem(Index, FItem);
  FItem.X := Player.X;
  FItem.Y := Player.Y;
  FItem.Equipment := 0;
  FItem.MapID := Ord(Map.Current);
  FItem.Amount := Player.ItemAmount;
  Items_Dungeon_AppendItem(FItem);
  The := GetDescThe(Items.Name[TItemEnum(FItem.ItemID)]);
  if (FItem.Amount > 1) then
    MsgLog.Add(Format(_('You drop %s (%dx).'), [The, FItem.Amount]))
  else
    MsgLog.Add(Format(_('You drop %s.'), [The]));
  Scenes.SetScene(scDrop);
  Wait;
end;

procedure TPlayer.PickUp;
var
  FCount: Integer;
begin
  Statictics.Found := Statictics.Found + 1;
  Corpses.DelCorpse(Player.X, Player.Y);
  /// / Your backpack is full!
  FCount := Items_Dungeon_GetMapCountXY(Ord(Map.Current), Player.X, Player.Y);
  if (FCount > 0) then
  begin
    if (FCount = 1) then
    begin
      // Pickup an item
      Items.AddItemToInv(0);
    end
    else
    begin
      // Items scene
      Game.Timer := High(Byte);
      Scenes.SetScene(scItems);
    end;
  end
  else
    MsgLog.Add(_('There is nothing here to pick up.'));
end;

procedure TPlayer.PickUpAmount(Index: Integer);
var
  FItem: Item;
  The: string;
begin
  FItem := Items_Dungeon_GetMapItemXY(Ord(Map.Current), Index, Player.X,
    Player.Y);
  FItem.Amount := FItem.Amount - Player.ItemAmount;
  Items_Dungeon_SetMapItemXY(Ord(Map.Current), Index, Player.X,
    Player.Y, FItem);
  FItem.Amount := Player.ItemAmount;
  Items_Inventory_AppendItem(FItem);
  The := GetDescThe(Items.Name[TItemEnum(FItem.ItemID)]);
  if (FItem.Amount > 1) then
    MsgLog.Add(Format(_('You picked up %s (%dx).'), [The, FItem.Amount]))
  else
    MsgLog.Add(Format(_('You picked up %s.'), [The]));
  Scenes.SetScene(scItems);
  Wait;
end;

procedure TPlayer.Render(AX, AY: Byte);
begin
  if (Self.Life = 0) then
    Terminal.Print(AX + View.Left, AY + View.Top, '%', clCorpse)
  else
    Terminal.Print(AX + View.Left, AY + View.Top, '@', clPlayer, clBkPlayer);
end;

procedure TPlayer.RenderInfo;
const
  F = '%s %d/%d';
var
  I: TAbilityEnum;
  S: string;
begin
  Terminal.ForegroundColor(clDefault);
  // Info
  Terminal.Print(Status.Left - 1, Status.Top + 1,
    ' ' + Terminal.Colorize(Format(F, [_('Life'), Player.Life, Player.MaxLife]
    ), 'Life'));
  Terminal.Print(Status.Left - 1, Status.Top + 2,
    ' ' + Terminal.Colorize(Format(F, [_('Mana'), Player.Mana, Player.MaxMana]
    ), 'Mana'));
  // Bars
  Scenes.RenderBar(Status.Left, 13, Status.Top + 1, Status.Width - 14,
    Player.Life, Player.MaxLife, clLife, clDarkGray);
  Scenes.RenderBar(Status.Left, 13, Status.Top + 2, Status.Width - 14,
    Player.Mana, Player.MaxMana, clMana, clDarkGray);
  case Game.ShowEffects of
  False: begin
  Terminal.Print(Status.Left - 1, Status.Top + 3,
    ' ' + Format(_('Turn: %d Gold: %d %s'), [Player.Turn, Player.Gold,
    Player.GetSatiationStr]));
  Terminal.Print(Status.Left - 1, Status.Top + 4,
    ' ' + Format(_('Damage: %d-%d PV: %d DV: %d'), [Player.Damage.Min,
    Player.Damage.Max, Player.PV, Player.DV, Player.Satiation]));
  end;
  else begin
  S := '';
  for I := Low(TAbilityEnum) to High(TAbilityEnum) do
    if Abilities.IsAbility(I) then
      S := S + Terminal.Colorize(Format(' %s (%d)', [Abilities.GetName(I),
        Abilities.Ability[I]]), Abilities.GetColor(I));
  Terminal.Print(Status.Left, Status.Top + 3, Log.Width, 2, S, TK_ALIGN_TOP);
  end;
  end;
end;

function TPlayer.SaveCharacterDump(AReason: string): string;
var
  SL: TStringList;

  function GetDateTime(DateSep: Char = '.'; TimeSep: Char = ':'): string;
  begin
    Result := DateToStr(Date) + '-' + TimeToStr(Time);
    Result := StringReplace(Result, '.', DateSep, [rfReplaceAll]);
    Result := StringReplace(Result, ':', TimeSep, [rfReplaceAll]);
  end;

begin
  if Game.Wizard then
    Exit;
  SL := TStringList.Create;
  try
    SL.Append(Format(FT, [Game.GetTitle]));
    SL.Append('');
    SL.Append(GetDateTime);
    SL.Append(Format(_('%s: %s.'), [_('Difficulty'),
      GetPureText(Game.GetStrDifficulty)]));
    SL.Append('');
    SL.Append(AReason);
    if Player.IsDead then
      SL.Append(Format(_('He scored %d points.'), [Player.Score]))
    else
      SL.Append(Format(_('He has scored %d points so far.'), [Player.Score]));
    SL.Append('');
    SL.Append(Format(FT, [_('Screenshot')]));
    SL.Append(Game.Screenshot);
    SL.Append(Format(FT, [_('Defeated foes')]));
    SL.Append('');
    SL.Append(Format('Total: %d creatures defeated.',
      [Player.Statictics.Kills]));
    SL.Append('');
    SL.Append(Format(FT, [_('Last messages')]));
    SL.Append('');
    SL.Append(GetPureText(MsgLog.GetLastMsg(10)));
    SL.Append(Format(FT, [_('Inventory')]));
    SL.Append('');
    SL.Append(GetPureText(Items.GetInventory));
    SL.Append(Format('%s: %d', [_('Gold'), Player.Gold]));
    SL.SaveToFile(GetDateTime('-', '-') + '-character-dump.txt');
  finally
    SL.Free;
  end;
end;

procedure TPlayer.SetAmountScene(IsDrop: Boolean; Index, Amount: Integer);
begin
  ItemIsDrop := IsDrop;
  ItemIndex := Index;
  ItemAmount := Amount;
  Scenes.SetScene(scAmount);
end;

procedure TPlayer.Spawn;
begin
  Self.Clear;
  X := Game.Spawn.X;
  Y := Game.Spawn.Y;
  Map.Current := deDarkWood;
  MsgLog.Clear;
end;

procedure TPlayer.AddExp(Value: Byte = 1);
begin
  Exp := Exp + Value;
  if (Exp >= LevelExpMax) then
  begin
    Exp := Exp - LevelExpMax;
    Level := Level + 1;
    MsgLog.Add(Terminal.Colorize(Format(_('You advance to level %d!'),
      [Level]), clAlarm));
    if (Level mod 2 = 1) then
    begin
      TalentPoint := True;
      MsgLog.Add(Terminal.Colorize(_('You gained 1 talent point.'), clAlarm));
      Score := Score + 1;
    end else TalentPoint := False;
    Score := Score + (Level * Level);
  end;
end;

procedure TPlayer.Wait;
begin
  if not Map.GetVis(Map.Current) then
  begin
    MsgLog.Add(Terminal.Colorize
      (Format(_('You have opened a new territory: %s.'), [Map.Name]), clAlarm));
    Map.SetVis(Map.Current, True);
    if (Ord(Map.Current) > 0) then
      Score := Score + (Ord(Map.Current) * 15);
    MaxMap := MaxMap + 1;
  end;
  SatPerTurn := 1;
  Move(0, 0);
end;

procedure TPlayer.Rest(ATurns: Word);
var
  T: Word;
begin
  IsRest := True;
  MsgLog.Add(Format(_('Start rest (%d turns)!'), [ATurns]));
  for T := 1 to ATurns do
  begin
    if not IsRest then
      Break;
    Wait;
  end;
  MsgLog.Add(Format(_('Finish rest (%d turns)!'), [T - 1]));
  Abilities.Ability[abWeak] := 0;
  if (Math.RandomRange(0, 9) = 0) then
    Abilities.Ability[abDrunk] := 0;
  IsRest := False;
end;

procedure TPlayer.Start;
var
  D: Byte;
begin
  // Add armors
  if Game.Wizard then
  begin
    Items.AddItemToInv(iWingedHelm, 1, True);
    Items.AddItemToInv(iPlateMail, 1, True);
    Items.AddItemToInv(iPlatedGauntlets, 1, True);
    Items.AddItemToInv(iPlateBoots, 1, True);
    Items.AddItemToInv(iRing, 1, True);
    Items.AddItemToInv(iAmulet, 1, True);
  end
  else
  begin
    Items.AddItemToInv(iCap, 1, True);
    Items.AddItemToInv(iQuiltedArmor, 1, True);
    Items.AddItemToInv(iLeatherGloves, 1, True);
    Items.AddItemToInv(iShoes, 1, True);
  end;
  // Add weapon
  if Game.Wizard then
  begin
    case Math.RandomRange(0, 4) of
      0:
        Items.AddItemToInv(iTrollSlayer, 1, True);
      1:
        Items.AddItemToInv(iDemonAxe, 1, True);
      2:
        Items.AddItemToInv(iHonedSpear, 1, True);
      3:
        Items.AddItemToInv(iDoomHammer, 1, True);
    end;
  end
  else
  begin
    case Math.RandomRange(0, 4) of
      0:
        Items.AddItemToInv(iRustySword, 1, True);
      1:
        Items.AddItemToInv(iHatchet, 1, True);
      2:
        Items.AddItemToInv(iShortSpear, 1, True);
      3:
        Items.AddItemToInv(iSlagHammer, 1, True);
    end;
  end;
  // Add runes, potions and scrolls
  if Game.Wizard then
  begin
    Items.AddItemToInv(iRuneOfFullHealing);
    Items.AddItemToInv(iPotionOfFullHealing, 10);
    Items.AddItemToInv(iPotionOfFullMana, 10);
    Items.AddItemToInv(iScrollOfTownPortal, 10);
    Items.AddItemToInv(iAntidote, 10);
    Items.AddItemToInv(iScrollOfIdentification, 10);
  end
  else
  begin
    Items.AddItemToInv(iLesserHealingPotion, 5);
    Items.AddItemToInv(iLesserManaPotion, 5);
    Items.AddItemToInv(iAntidote, 1);
  end;
  // Add foods
  Items.AddItemToInv(iBreadRation, IfThen(Game.Wizard, 10, 3));
  // Add coins
  D := IfThen(Game.Difficulty <> dfHell, StartGold, 0);
  Items.AddItemToInv(iGold, IfThen(Game.Wizard, RandomRange(6666, 9999), D));
  Self.Calc;
end;

procedure TPlayer.DoEffects(const Effects: TEffects; const Value: Word = 0);
var
  V, VX, VY: Word;
const
  F = '%s +%d.';

  procedure PrmSkill(ASkill: TSkillEnum);
  begin
    Skills.Modify(ASkill, StartSkill);
    Player.Calc;
    Player.Fill;
  end;

  procedure PrmValue(AEffect: TEffect; Value: Byte);
  begin
    case AEffect of
      efPrmLife:
        PrmLife := PrmLife + Value;
      efPrmMana:
        PrmMana := PrmMana + Value;
      efPrmPV:
        PrmPV := PrmPV + Value;
      efPrmDV:
        PrmDV := PrmDV + Value;
    end;
    Player.Calc;
    Player.Fill;
  end;

begin
  // Life
  if (efLife in Effects) then
  begin
    V := Self.Skills.Skill[skHealing].Value + Value;
    MsgLog.Add(_('You feel healthy.'));
    MsgLog.Add(Format(F, [_('Life'), Min(MaxLife - Life, V)]));
    Self.Life := EnsureRange(Self.Life + V, 0, MaxLife);
    Skills.DoSkill(skHealing);
  end;
  // Mana
  if (efMana in Effects) then
  begin
    V := Self.Skills.Skill[skConcentration].Value + Value;
    MsgLog.Add(_('You feel magical energies restoring.'));
    MsgLog.Add(Format(F, [_('Mana'), Min(MaxMana - Mana, V)]));
    Self.Mana := EnsureRange(Self.Mana + V, 0, MaxMana);
    Self.Skills.DoSkill(skConcentration, 5);
  end;
  // Food
  if (efFood in Effects) then
  begin
    FSatiation := FSatiation + Value;
    MsgLog.Add(Format(_('You have sated %d hunger.'), [Value]));
  end;
  // Identification
  if (efIdentification in Effects) then
  begin
    Scenes.SetScene(scIdentification);
  end;
  // Teleportation
  if (efTeleportation in Effects) then
  begin
    VX := Math.RandomRange(Value, Self.Skills.Skill[skConcentration]
      .Value + Value);
    VY := Math.RandomRange(Value, Self.Skills.Skill[skConcentration]
      .Value + Value);
    X := Map.EnsureRange(X + (Math.RandomRange(0, VX * 2 + 1) - VX));
    Y := Map.EnsureRange(Y + (Math.RandomRange(0, VY * 2 + 1) - VY));
    MsgLog.Add(_('You have teleported into new place!'));
    Scenes.SetScene(scGame);
  end;
  // Town Portal
  if (efTownPortal in Effects) then
  begin
    Map.SetTileEnum(Game.Portal.X, Game.Portal.Y, Game.PortalMap,
      Game.PortalTile);
    if ((Player.X = Game.Spawn.X) and (Player.Y = Game.Spawn.Y)) then
      Exit;
    Game.PortalTile := Map.GetTileEnum(X, Y, Map.Current);
    Game.PortalMap := Map.Current;
    Game.Portal.X := X;
    Game.Portal.Y := Y;
    Map.SetTileEnum(X, Y, Map.Current, tePortal);
    Map.SetTileEnum(Game.Spawn.X, Game.Spawn.Y, deDarkWood, teTownPortal);
    Scenes.SetScene(scGame);
  end;
  // Magic Eye
  if (efMagicEye in Effects) then
  begin

  end;
  // Bloodlust
  if (efBloodlust in Effects) then
  begin
    V := Math.RandomRange(Value, Player.Skills.Skill[skConcentration]
      .Value + Value);
    Abilities.Modify(abBloodlust, V);
    MsgLog.Add(Format(_('You feel lust for blood (%d).'), [V]));
  end;
  // Cure poison
  if (efCurePoison in Effects) then
  begin
    if Abilities.IsAbility(abPoisoned) then
    begin
      V := Self.Skills.Skill[skHealing].Value + Value;
      Abilities.Ability[abPoisoned] :=
        Math.EnsureRange(Abilities.Ability[abPoisoned] - V, 0, High(Word));
      Self.Skills.DoSkill(skHealing);
      if Abilities.IsAbility(abPoisoned) then
        MsgLog.Add(_('You feel better.'))
      else
        MsgLog.Add(_('You are better now.'));
    end;
  end;
  // Cure weak
  if (efCureWeak in Effects) then
  begin
    if Abilities.IsAbility(abWeak) then
    begin
      Abilities.Ability[abWeak] := 0;
      MsgLog.Add(_('You are better now.'));
    end;
  end;
  // Gold
  if (efPrmGold in Effects) then
    Items.AddItemToInv(iGold, StartGold);
  // Athletics
  if (efPrmAthletics in Effects) then
    PrmSkill(skAthletics);
  // Dodge
  if (efPrmDodge in Effects) then
    PrmSkill(skDodge);
  // Concentration
  if (efPrmConcentration in Effects) then
    PrmSkill(skConcentration);
  // Toughness
  if (efPrmToughness in Effects) then
    PrmSkill(skToughness);
  // Blade
  if (efPrmBlade in Effects) then
    PrmSkill(skBlade);
  // Axe
  if (efPrmAxe in Effects) then
    PrmSkill(skAxe);
  // Spear
  if (efPrmSpear in Effects) then
    PrmSkill(skSpear);
  // Mace
  if (efPrmMace in Effects) then
    PrmSkill(skMace);
  // 2x to gold
  if (ef2xGold in Effects) then
  begin

  end;
  // Life
  if (efPrmLife in Effects) then
    PrmValue(efPrmLife, IfThen(Value = 0, AttribPrm, Value));
  // Mana
  if (efPrmMana in Effects) then
    PrmValue(efPrmMana, IfThen(Value = 0, AttribPrm, Value));
  // DV
  if (efPrmDV in Effects) then
    PrmValue(efPrmDV, IfThen(Value = 0, TalentPrm, Value));
  // PV
  if (efPrmPV in Effects) then
    PrmValue(efPrmPV, IfThen(Value = 0, TalentPrm, Value));
end;

initialization

Player := TPlayer.Create;

finalization

FreeAndNil(Player);

end.
