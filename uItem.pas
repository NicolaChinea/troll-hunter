unit uItem;

interface

uses BearLibItems, uGame, uMap, uPlayer, uEntity, uCreature;

type
  TItemType = (itNone, itUnavailable, itCorpse, itKey, itCoin, itGem, itPotion,
    itScroll, itRune, itBook, itFood, itPlant, itBlade, itAxe, itSpear, itMace,
    itStaff, itWand, itShield, itHeadgear, itBodyArmor, itHands, itFeet, itRing,
    itAmulet);

  // From Angband:
  // !   A potion (or flask)    /   A pole-arm
  // ?   A scroll (or book)     |   An edged weapon
  // ,   Food                   \   A hafted weapon
  // -   A wand or rod          }   A sling, bow, or x-bow
  // _   A staff                {   A shot, arrow, or bolt
  // =   A ring                 (   Soft armour (cloak, robes, leather armor)
  // "   An amulet              [   Hard armour (metal armor)
  // $   Money or gems          ]   Misc. armour (gloves, helm, boots)
  // ~   Pelts and body parts   )   A shield
  // &   Chests, Containers

  //

const
  CoinTypeItems = [itCoin];
  PotionTypeItems = [itPotion];
  ScrollTypeItems = [itScroll];
  RuneTypeItems = [itRune];
  BookTypeItems = [itBook];
  CorpseTypeItems = [itCorpse];
  GemTypeItems = [itGem];
  PlantTypeItems = [itPlant];
  FoodTypeItems = [itFood];
  KeyTypeItems = [itKey];
  GlovesTypeItems = [itHands];
  BootsTypeItems = [itFeet];
  ShieldTypeItems = [itShield];
  HelmTypeItems = [itHeadgear];
  JewelryTypeItems = [itRing, itAmulet];
  WeaponTypeItems = [itBlade, itAxe, itSpear, itMace, itStaff];
  ArmorTypeItems = [itHeadgear, itBodyArmor, itShield, itHands, itFeet];
  IdentTypeItems = WeaponTypeItems + ArmorTypeItems + JewelryTypeItems;
  DefenseTypeItems = ArmorTypeItems + JewelryTypeItems;
  DamageTypeItems = WeaponTypeItems + JewelryTypeItems;
  SmithTypeItems = WeaponTypeItems + ArmorTypeItems;
  UseTypeItems = PotionTypeItems + ScrollTypeItems + FoodTypeItems + PlantTypeItems +
    RuneTypeItems + BookTypeItems;
  NotDropTypeItems = [itNone] + KeyTypeItems + CorpseTypeItems + RuneTypeItems;
  NotEquipTypeItems = UseTypeItems + NotDropTypeItems + GemTypeItems + CoinTypeItems;
  AutoPickupItems = CoinTypeItems + PotionTypeItems + ScrollTypeItems
    + FoodTypeItems + RuneTypeItems + BookTypeItems + GemTypeItems + KeyTypeItems
    + PlantTypeItems;
  //NotEquipTypeItems - NotDropTypeItems;

type
  TItemBase = record
    Symbol: Char;
    ItemType: TItemType;
    SlotType: TSlotType;
    MaxStack: Word;
    MaxDurability: Word;
    Level: Byte;
    Defense: TMinMax;
    Damage: TBaseDamage;
    Price: Word;
    Color: Cardinal;
    Deep: set of TMapEnum;
    Effects: TEffects;
    Value: Word;
    ManaCost: Byte;
  end;

type
  TItemEnum = (
    // All maps
    iNone, iCorpse, iGold,
    // Potions
    iLesserHealingPotion, iGreaterHealingPotion, iHeroicHealingPotion,
    iPotionOfFullHealing, iLesserRejuvenationPotion, iGreaterRejuvenationPotion,
    iHeroicRejuvenationPotion, iPotionOfFullRejuvenation, iLesserManaPotion,
    iGreaterManaPotion, iHeroicManaPotion, iPotionOfFullMana, iSoothingBalm,
    iHealingPoultice, iAntidote, iFortifyingPotion,
    // Elixirs and Extracts
    iTrollBloodExtract, iUnicornBloodExtract,
    // Scrolls
    iScrollOfMinorHealing, iScrollOfLesserHealing, iScrollOfGreaterHealing,
    iScrollOfFullHealing, iScrollOfHunger, iScrollOfSidestepping,
    iScrollOfPhasing, iScrollOfTeleportation, iScrollOfDisappearing,
    iScrollOfTownPortal, iScrollOfBloodlust, iScrollOfIdentify,
    // Runes
    iRuneOfMinorHealing, iRuneOfLesserHealing, iRuneOfGreaterHealing,
    iRuneOfFullHealing, iRuneOfTeleportation, iRuneOfTownPortal,
    // Foods
    iBreadRation, iValleyRoot, iRatPod, iKoboldBulb,
    //
    iKey, iRuby, iTopaz, iEmerald, iSapphire, // Gems
    iRing, // Rings
    iAmulet, // Amulets
    // Dark Wood
    iCap, iWarCap, iHood, iRedHat, // Headgear
    iQuiltedArmor, iLeatherArmor, iLightClothes, iLeatherApron, // Body Armor
    iLeatherGloves, iHideGloves, // Gloves
    iShoes, iLeatherBoots, // Boots
    iBuckler, iTargeShield, // Shield
    iRustySword, iShortSword, // Blade
    iHatchet, iBattleAxe, // Axe
    iShortSpear, iSpear, // Spear
    iSlagHammer, iSpikedCudgel, // Mace
    // Gray Cave
    iHelm, iGrandHelm, iLeatherCap, iMask, // Headgear
    iHardLeatherArmor, iBattleArmor, iFancyClothes, iRobe, // Body Armor
    iKoboldGloves, iChainGloves, // Gloves
    iMeshBoots, iHeavyBoots, // Boots
    iSmallShield, iKiteShield, // Shield
    iBroadSword, iLongSword, // Blade
    iMeatAxe, iFleshTearer, // Axe
    iJavelin, iFuscina, // Spear
    iWarhammer, iWarMace, // Mace
    // Deep Cave
    iGreatHelm, iFullHelm, iBoneHelmet, iWizardHat, // Headgear
    iBrigantineArmor, iRingMail, iLightFurs, iCleanRobe, // Body Armor
    iEtchedGloves, iHeavyGloves, // Gloves
    iGreaves, iBoneweaveBoots, // Boots
    iBoneShield, iHeaterShield, // Shield
    iMoonBlade, iScimitar, // Blade
    iWarAxe, iDarkAxe, // Axe
    iWarSpear, iHarpoon, // Spear
    iFlangedMace, iWarGavel, // Mace
    // Blood Cave
    iHornedHelmet, iSpiredHelm, iDiadem, iTiara, // Headgear
    iChainMail, iScaleMail, iThickFurs, iHardRobe, // Body Armor
    iBattleGauntlets, iWarGauntlets, // Gloves
    iChainBoots, iWarBoots, // Boots
    iHeavyShield, iLargeShield, // Shield
    iBastardSword, iGreatSword, // Blade
    iBerserkerAxe, iMarauderAxe, // Axe
    iSilvanWhisper, iImpaler, // Spear
    iBarbarousMace, iAdeptHammer, // Mace
    // Drom
    iCasque, iWingedHelm, iMagicHelmet, iCrown, // Headgear
    iSplintMail, iPlateMail, iMolochRobe, iBoneweaveHauberk, // Body Armor
    iTrollGauntlets, iPlatedGauntlets, // Gloves
    iBattleBoots, iPlateBoots, // Boots
    iTowerShield, iGothicShield, // Shield
    iRuneSword, iTrollSlayer, // Blade
    iChopper, iDemonAxe, // Axe
    iSoulReaver, iHonedSpear, // Spear
    iWarMaul, iDoomHammer // Mace
    );

const
  ItemBase: array [TItemEnum] of TItemBase = (
    /// / == All maps == ////

    // None
    (Symbol: ' '; ItemType: itNone; SlotType: stNone; MaxStack: 1;
    MaxDurability: 0; Level: 0; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 0;
    Color: clGray; Deep: []),
    // Corpse
    (Symbol: '%'; ItemType: itCorpse; SlotType: stNone; MaxStack: 1;
    MaxDurability: 0; Level: 0; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 0;
    Color: clGray; Deep: [deDarkWood .. deDrom]),
    // Gold
    (Symbol: '$'; ItemType: itCoin; SlotType: stNone; MaxStack: 10000;
    MaxDurability: 0; Level: 0; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 0;
    Color: clYellow; Deep: [deDarkWood .. deDrom]),

    // Lesser Healing Potion
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 50; Color: clLightestRed;
    Deep: [deDarkWood .. deDeepCave]; Effects: [efLife]; Value: 50;),
    // Greater Healing Potion
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 3; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 100; Color: clLightRed;
    Deep: [deGrayCave .. deBloodCave]; Effects: [efLife]; Value: 100;),
    // Heroic Healing Potion
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 5; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 200; Color: clRed;
    Deep: [deDeepCave .. deDrom]; Effects: [efLife]; Value: 200;),
    // Potion of Full Healing
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 7; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 500; Color: clDarkRed;
    Deep: [deBloodCave .. deDrom]; Effects: [efLife]; Value: 250;),

    // Lesser Rejuvenation Potion
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 75; Color: clLightestYellow;
    Deep: [deDarkWood .. deDeepCave]; Effects: [efLife, efMana]; Value: 50;),
    // Greater Rejuvenation Potion
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 3; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 150; Color: clLightYellow;
    Deep: [deGrayCave .. deBloodCave]; Effects: [efLife, efMana]; Value: 100;),
    // Heroic Rejuvenation Potion
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 5; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 300; Color: clYellow;
    Deep: [deDeepCave .. deDrom]; Effects: [efLife, efMana]; Value: 200;),
    // Potion Of Full Rejuvenation
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 7; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 750; Color: clDarkYellow;
    Deep: [deBloodCave .. deDrom]; Effects: [efLife, efMana]; Value: 250;),

    // Lesser Mana Potion
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 50; Color: clLightestBlue;
    Deep: [deDarkWood .. deDeepCave]; Effects: [efMana]; Value: 50;),
    // Greater Mana Potion
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 3; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 100; Color: clLightBlue;
    Deep: [deGrayCave .. deBloodCave]; Effects: [efMana]; Value: 100;),
    // Heroic Mana Potion
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 5; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 200; Color: clBlue;
    Deep: [deDeepCave .. deDrom]; Effects: [efMana]; Value: 200;),
    // Potion of Full Mana
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 7; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 500; Color: clDarkBlue;
    Deep: [deBloodCave .. deDrom]; Effects: [efMana]; Value: 250;),

    // Soothing Balm
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 90; Color: clLightestYellow;
    Deep: [deDarkWood .. deDeepCave]; Effects: [efLife, efMana, efFood];
    Value: 40;),
    // Healing Poultice
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 3; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 180; Color: clLightYellow;
    Deep: [deGrayCave .. deBloodCave]; Effects: [efLife, efMana, efCurePoison];
    Value: 80;),
    // Antidote
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 250; Color: clLightestGreen;
    Deep: [deDarkWood .. deDrom]; Effects: [efCurePoison]; Value: 100;),
    // Fortifying Potion
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 300; Color: clLightYellow;
    Deep: [deDarkWood .. deDrom]; Effects: [efCureWeak]; Value: 1;),

    // Troll Blood Extract
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 5000; Color: clDarkRed;
    Deep: [deDarkWood .. deDrom]; Effects: [efPrmLife]; Value: 1;),
    // Unicorn Blood Extract
    (Symbol: '!'; ItemType: itPotion; SlotType: stNone; MaxStack: 10;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 5000; Color: clDarkBlue;
    Deep: [deDarkWood .. deDrom]; Effects: [efPrmMana]; Value: 1;),

    // Scroll of minor healing
    (Symbol: '?'; ItemType: itScroll; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 40; Color: clLightestBlue;
    Deep: [deDarkWood .. deDeepCave]; Effects: [efLife]; Value: 50;
    ManaCost: 20;),
    // Scroll Of Lesser Healing
    (Symbol: '?'; ItemType: itScroll; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 3; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 80; Color: clLightBlue;
    Deep: [deGrayCave .. deBloodCave]; Effects: [efLife]; Value: 100;
    ManaCost: 30;),
    // Scroll Of Greater Healing
    (Symbol: '?'; ItemType: itScroll; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 5; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 160; Color: clBlue;
    Deep: [deDeepCave .. deDrom]; Effects: [efLife]; Value: 200; ManaCost: 40;),
    // Scroll of Full Healing
    (Symbol: '?'; ItemType: itScroll; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 7; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 300; Color: clDarkBlue;
    Deep: [deBloodCave .. deDrom]; Effects: [efLife]; Value: 250;
    ManaCost: 50;),

    // Scroll of Hunger
    (Symbol: '?'; ItemType: itScroll; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 500; Color: clDarkYellow;
    Deep: [deDarkWood .. deDrom]; Effects: [efFood]; Value: 250; ManaCost: 25;),

    // Scroll of Sidestepping
    (Symbol: '?'; ItemType: itScroll; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 2; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 750; Color: clLightRed;
    Deep: [deDarkWood .. deDeepCave]; Effects: [efTeleportation]; Value: 3;
    ManaCost: 50;),
    // Scroll of Phasing
    (Symbol: '?'; ItemType: itScroll; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 4; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 1000; Color: clRed;
    Deep: [deGrayCave .. deBloodCave]; Effects: [efTeleportation]; Value: 6;
    ManaCost: 100;),
    // Scroll of Teleportation
    (Symbol: '?'; ItemType: itScroll; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 6; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 1250; Color: clDarkRed;
    Deep: [deDeepCave .. deDrom]; Effects: [efTeleportation]; Value: 10;
    ManaCost: 150;),
    // Scroll of Disappearing
    (Symbol: '?'; ItemType: itScroll; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 8; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 1500; Color: clDarkRed;
    Deep: [deBloodCave .. deDrom]; Effects: [efTeleportation]; Value: 15;
    ManaCost: 200;),

    // Scroll of Town Portal
    (Symbol: '?'; ItemType: itScroll; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 400; Color: clLightGreen;
    Deep: [deDarkWood .. deDrom]; Effects: [efTownPortal]; Value: 0;
    ManaCost: 20;),
    // Scroll of Bloodlust
    (Symbol: '?'; ItemType: itScroll; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 300; Color: clLightRed;
    Deep: [deDarkWood .. deDrom]; Effects: [efBloodlust]; Value: 10;
    ManaCost: 25;),
    // Scroll of Identify
    (Symbol: '?'; ItemType: itScroll; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 200; Color: clLightYellow;
    Deep: [deDarkWood .. deDrom]; Effects: [efIdentification]; Value: 0;
    ManaCost: 15;),

    // Rune of minor healing
    (Symbol: '*'; ItemType: itRune; SlotType: stNone; MaxStack: 3; MaxDurability: 0; Level: 3;
    Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 1000; Color: clLightestRed; Deep: [deDarkWood .. deGrayCave];
    Effects: [efLife]; Value: 75; ManaCost: 20;),
    // Rune of lesser healing
    (Symbol: '*'; ItemType: itRune; SlotType: stNone; MaxStack: 3; MaxDurability: 0; Level: 5;
    Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 1500; Color: clLightRed; Deep: [deGrayCave .. deDeepCave];
    Effects: [efLife]; Value: 150; ManaCost: 30;),
    // Rune of greater healing
    (Symbol: '*'; ItemType: itRune; SlotType: stNone; MaxStack: 3; MaxDurability: 0; Level: 7;
    Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 2000; Color: clRed; Deep: [deDeepCave .. deBloodCave];
    Effects: [efLife]; Value: 250; ManaCost: 40;),
    // Rune of full healing
    (Symbol: '*'; ItemType: itRune; SlotType: stNone; MaxStack: 3; MaxDurability: 0; Level: 9;
    Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 2500; Color: clDarkRed; Deep: [deBloodCave .. deDrom];
    Effects: [efLife]; Value: 250; ManaCost: 50;),

    // Rune of teleportation
    (Symbol: '*'; ItemType: itRune; SlotType: stNone; MaxStack: 3; MaxDurability: 0; Level: 6;
    Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 7000; Color: clDarkRed; Deep: [deDeepCave .. deBloodCave];
    Effects: [efTeleportation]; Value: 10; ManaCost: 150;),
    // Rune of town portal
    (Symbol: '*'; ItemType: itRune; SlotType: stNone; MaxStack: 3; MaxDurability: 0; Level: 1;
    Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 4800; Color: clLightGreen; Deep: [deDarkWood .. deDrom];
    Effects: [efTownPortal]; Value: 0; ManaCost: 50;),

    // Bread ration
    (Symbol: ':'; ItemType: itFood; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 200; Color: clYellow;
    Deep: [deDarkWood .. deDrom]; Effects: [efFood]; Value: 400;),
    // Valley root
    (Symbol: ':'; ItemType: itPlant; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 125; Color: clLightestYellow;
    Deep: [deDarkWood .. deDrom]; Effects: [efFood]; Value: 250;),
    // Rat pod
    (Symbol: ':'; ItemType: itPlant; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 150; Color: clLightestGreen;
    Deep: [deDarkWood .. deDrom]; Effects: [efFood]; Value: 300;),
    // Kobold bulb
    (Symbol: ':'; ItemType: itPlant; SlotType: stNone; MaxStack: 16;
    MaxDurability: 0; Level: 1; Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 100; Color: clLightestGreen;
    Deep: [deDarkWood .. deDrom]; Effects: [efFood]; Value: 150;),

    // Key
    (Symbol: '`'; ItemType: itKey; SlotType: stNone; MaxStack: 16; MaxDurability: 0; Level: 1;
    Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 50; Color: clYellow; Deep: [deDarkWood .. deDrom];),

    // Ruby
    (Symbol: '$'; ItemType: itGem; SlotType: stNone; MaxStack: 3; MaxDurability: 0; Level: 1;
    Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 750; Color: clRed; Deep: [deDarkWood .. deDrom];),
    // Topaz
    (Symbol: '$'; ItemType: itGem; SlotType: stNone; MaxStack: 3; MaxDurability: 0; Level: 1;
    Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 750; Color: clYellow; Deep: [deDarkWood .. deDrom];),
    // Emerald
    (Symbol: '$'; ItemType: itGem; SlotType: stNone; MaxStack: 3; MaxDurability: 0; Level: 1;
    Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 750; Color: clGreen; Deep: [deDarkWood .. deDrom];),
    // Sapphire
    (Symbol: '$'; ItemType: itGem; SlotType: stNone; MaxStack: 3; MaxDurability: 0; Level: 1;
    Defense: (Min: 0; Max: 0); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 750; Color: clBlue; Deep: [deDarkWood .. deDrom];),

    // Ring
    (Symbol: '='; ItemType: itRing; SlotType: stFinger; MaxStack: 1;
    MaxDurability: 25; Level: 1; Defense: (Min: 1; Max: 5); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 1000;
    Color: clYellow; Deep: [deDarkWood .. deDrom];),
    // Amulet
    (Symbol: ''''; ItemType: itAmulet; SlotType: stNeck; MaxStack: 1;
    MaxDurability: 35; Level: 1; Defense: (Min: 1; Max: 5); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;)); Price: 1000;
    Color: clYellow; Deep: [deDarkWood .. deDrom];),
    /// / == Dark Wood == ////

    // Cap
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 15; Level: 1; Defense: (Min: 1; Max: 2); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 100;
    Color: clWhite; Deep: [deDarkWood];),
    // War Cap
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 20; Level: 2; Defense: (Min: 3; Max: 4); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 150;
    Color: clWhite; Deep: [deDarkWood];),
    // Hood
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 10; Level: 1; Defense: (Min: 1; Max: 2); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 200;
    Color: clLightestBlue; Deep: [deDarkWood];),
    // Red Hat
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 12; Level: 2; Defense: (Min: 2; Max: 3); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 300;
    Color: clLightRed; Deep: [deDarkWood];),
    // Quilted Armor
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 25; Level: 1; Defense: (Min: 3; Max: 6); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 300;
    Color: clWhite; Deep: [deDarkWood];),
    // Leather Armor
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 50; Level: 2; Defense: (Min: 8; Max: 11); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 500;
    Color: clWhite; Deep: [deDarkWood];),
    // Light Clothes
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 20; Level: 1; Defense: (Min: 1; Max: 2); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 600;
    Color: clLightestBlue; Deep: [deDarkWood];),
    // Leather Apron
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 40; Level: 2; Defense: (Min: 3; Max: 4); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 800;
    Color: clLightestBlue; Deep: [deDarkWood];),

    // Leather Gloves
    (Symbol: '%'; ItemType: itHands; SlotType: stHands; MaxStack: 1;
    MaxDurability: 10; Level: 1; Defense: (Min: 1; Max: 2); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 100;
    Color: clWhite; Deep: [deDarkWood];),
    // Hide Gloves
    (Symbol: '%'; ItemType: itHands; SlotType: stHands; MaxStack: 1;
    MaxDurability: 15; Level: 2; Defense: (Min: 3; Max: 4); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 150;
    Color: clWhite; Deep: [deDarkWood];),

    // Shoes
    (Symbol: ';'; ItemType: itFeet; SlotType: stFeet; MaxStack: 1;
    MaxDurability: 15; Level: 1; Defense: (Min: 1; Max: 3); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 200;
    Color: clWhite; Deep: [deDarkWood];),
    // Leather Boots
    (Symbol: ';'; ItemType: itFeet; SlotType: stFeet; MaxStack: 1;
    MaxDurability: 20; Level: 2; Defense: (Min: 4; Max: 6); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 250;
    Color: clWhite; Deep: [deDarkWood];),

    // Buckler
    (Symbol: '+'; ItemType: itShield; SlotType: stOffHand; MaxStack: 1;
    MaxDurability: 25; Level: 1; Defense: (Min: 3; Max: 6); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 120;
    Color: clLightBlue; Deep: [deDarkWood];),
    // Targe Shield
    (Symbol: '+'; ItemType: itShield; SlotType: stOffHand; MaxStack: 1;
    MaxDurability: 30; Level: 2; Defense: (Min: 7; Max: 10); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 200;
    Color: clLightBlue; Deep: [deDarkWood];),

    // Rusty Sword
    (Symbol: '/'; ItemType: itBlade; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 30; Level: 1; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 3; Max: 5;);
    MaxDamage: (Min: 6; Max: 9;)); Price: 185; Color: clDarkRed;
    Deep: [deDarkWood];),
    // Short Sword
    (Symbol: '/'; ItemType: itBlade; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 35; Level: 2; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 5; Max: 7;);
    MaxDamage: (Min: 10; Max: 12;)); Price: 210; Color: clWhite;
    Deep: [deDarkWood];),
    // Hatchet
    (Symbol: '('; ItemType: itAxe; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 30; Level: 1; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 3; Max: 5;);
    MaxDamage: (Min: 6; Max: 8;)); Price: 165; Color: clDarkRed;
    Deep: [deDarkWood];),
    // Battle Axe
    (Symbol: '('; ItemType: itAxe; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 35; Level: 2; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 7; Max: 9;);
    MaxDamage: (Min: 11; Max: 12;)); Price: 195; Color: clDarkRed;
    Deep: [deDarkWood];),
    // Short Spear
    (Symbol: '|'; ItemType: itSpear; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 30; Level: 1; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 1; Max: 3;);
    MaxDamage: (Min: 4; Max: 5;)); Price: 150; Color: clDarkRed;
    Deep: [deDarkWood];),
    // Spear
    (Symbol: '|'; ItemType: itSpear; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 35; Level: 2; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 2; Max: 4;);
    MaxDamage: (Min: 5; Max: 7;)); Price: 180; Color: clDarkRed;
    Deep: [deDarkWood];),
    // Slag Hammer
    (Symbol: ')'; ItemType: itMace; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 30; Level: 1; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 2; Max: 4;);
    MaxDamage: (Min: 5; Max: 6;)); Price: 175; Color: clDarkRed;
    Deep: [deDarkWood];),
    // Spiked Cudgel
    (Symbol: ')'; ItemType: itMace; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 35; Level: 2; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 3; Max: 5;);
    MaxDamage: (Min: 7; Max: 9;)); Price: 220; Color: clDarkRed;
    Deep: [deDarkWood];),

    // == Gray Cave == //

    // Helm
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 25; Level: 3; Defense: (Min: 4; Max: 6); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 300;
    Color: clWhite; Deep: [deGrayCave];),
    // Grand Helm
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 30; Level: 4; Defense: (Min: 6; Max: 8); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 400;
    Color: clWhite; Deep: [deGrayCave];),
    // Leather Cap
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 15; Level: 3; Defense: (Min: 2; Max: 3); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 600;
    Color: clLightestBlue; Deep: [deGrayCave];),
    // Mask
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 18; Level: 4; Defense: (Min: 3; Max: 4); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 700;
    Color: clLightestBlue; Deep: [deGrayCave];),
    // HardLeather Armor
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 75; Level: 3; Defense: (Min: 12; Max: 15); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 700;
    Color: clWhite; Deep: [deGrayCave];),
    // Battle Armor
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 100; Level: 4; Defense: (Min: 17; Max: 20); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 900;
    Color: clWhite; Deep: [deGrayCave];),
    // Fancy Clothes
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 60; Level: 3; Defense: (Min: 5; Max: 6); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1000;
    Color: clLightestBlue; Deep: [deGrayCave];),
    // Robe
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 75; Level: 4; Defense: (Min: 7; Max: 8); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1300;
    Color: clLightestBlue; Deep: [deGrayCave];),

    // Kobold Gloves
    (Symbol: '%'; ItemType: itHands; SlotType: stHands; MaxStack: 1;
    MaxDurability: 22; Level: 3; Defense: (Min: 5; Max: 6); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 200;
    Color: clWhite; Deep: [deGrayCave];),
    // Chain Gloves
    (Symbol: '%'; ItemType: itHands; SlotType: stHands; MaxStack: 1;
    MaxDurability: 29; Level: 4; Defense: (Min: 7; Max: 8); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 250;
    Color: clWhite; Deep: [deGrayCave];),

    // Mesh Boots
    (Symbol: ';'; ItemType: itFeet; SlotType: stFeet; MaxStack: 1;
    MaxDurability: 30; Level: 3; Defense: (Min: 7; Max: 9); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 300;
    Color: clWhite; Deep: [deGrayCave];),
    // Heavy Boots
    (Symbol: ';'; ItemType: itFeet; SlotType: stFeet; MaxStack: 1;
    MaxDurability: 40; Level: 4; Defense: (Min: 10; Max: 12); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 400;
    Color: clWhite; Deep: [deGrayCave];),

    // Small Shield
    (Symbol: '+'; ItemType: itShield; SlotType: stOffHand; MaxStack: 1;
    MaxDurability: 35; Level: 3; Defense: (Min: 10; Max: 12); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 275;
    Color: clLightBlue; Deep: [deGrayCave];),
    // Kite Shield
    (Symbol: '+'; ItemType: itShield; SlotType: stOffHand; MaxStack: 1;
    MaxDurability: 40; Level: 4; Defense: (Min: 13; Max: 15); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 380;
    Color: clLightBlue; Deep: [deGrayCave];),

    // Broad Sword
    (Symbol: '/'; ItemType: itBlade; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 40; Level: 3; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 11; Max: 14;);
    MaxDamage: (Min: 19; Max: 21;)); Price: 345; Color: clDarkRed;
    Deep: [deGrayCave];),
    // Long Sword
    (Symbol: '/'; ItemType: itBlade; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 45; Level: 4; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 14; Max: 18;);
    MaxDamage: (Min: 23; Max: 26;)); Price: 385; Color: clDarkRed;
    Deep: [deGrayCave];),
    // Meat Axe
    (Symbol: '('; ItemType: itAxe; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 40; Level: 3; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 12; Max: 14;);
    MaxDamage: (Min: 16; Max: 19;)); Price: 330; Color: clDarkRed;
    Deep: [deGrayCave];),
    // Flesh Tearer
    (Symbol: '('; ItemType: itAxe; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 45; Level: 4; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 16; Max: 18;);
    MaxDamage: (Min: 21; Max: 24;)); Price: 355; Color: clDarkRed;
    Deep: [deGrayCave];),
    // Javelin
    (Symbol: '|'; ItemType: itSpear; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 40; Level: 3; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 4; Max: 6;);
    MaxDamage: (Min: 10; Max: 12;)); Price: 320; Color: clDarkRed;
    Deep: [deGrayCave];),
    // Fuscina
    (Symbol: '|'; ItemType: itSpear; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 45; Level: 4; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 5; Max: 7;);
    MaxDamage: (Min: 16; Max: 19;)); Price: 360; Color: clDarkRed;
    Deep: [deGrayCave];),
    // Warhammer
    (Symbol: ')'; ItemType: itMace; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 40; Level: 3; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 6; Max: 9;);
    MaxDamage: (Min: 11; Max: 13;)); Price: 345; Color: clDarkRed;
    Deep: [deGrayCave];),
    // War Mace
    (Symbol: ')'; ItemType: itMace; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 45; Level: 4; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 8; Max: 10;);
    MaxDamage: (Min: 17; Max: 19;)); Price: 410; Color: clDarkRed;
    Deep: [deGrayCave];),

    // == Deep Cave == //

    // Great Helm
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 35; Level: 5; Defense: (Min: 8; Max: 10); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 500;
    Color: clWhite; Deep: [deDeepCave];),
    // Full Helm
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 40; Level: 6; Defense: (Min: 10; Max: 12); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 750;
    Color: clWhite; Deep: [deDeepCave];),
    // Bone Helmet
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 20; Level: 5; Defense: (Min: 4; Max: 5); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1000;
    Color: clLightestBlue; Deep: [deDeepCave];),
    // Wizard Hat
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 25; Level: 6; Defense: (Min: 5; Max: 6); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1200;
    Color: clLightestBlue; Deep: [deDeepCave];),
    // Brigantine Armor
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 125; Level: 5; Defense: (Min: 21; Max: 25); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1000;
    Color: clWhite; Deep: [deDeepCave];),
    // Ring Mail
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 150; Level: 6; Defense: (Min: 26; Max: 30); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1200;
    Color: clWhite; Deep: [deDeepCave];),
    // Light Furs
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 85; Level: 5; Defense: (Min: 9; Max: 10); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1500;
    Color: clLightestBlue; Deep: [deDeepCave];),
    // Clean Robe
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 100; Level: 6; Defense: (Min: 11; Max: 12); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1700;
    Color: clLightestBlue; Deep: [deDeepCave];),

    // Etched Gloves
    (Symbol: '%'; ItemType: itHands; SlotType: stHands; MaxStack: 1;
    MaxDurability: 35; Level: 5; Defense: (Min: 9; Max: 10); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 300;
    Color: clWhite; Deep: [deDeepCave];),
    // Heavy Gloves
    (Symbol: '%'; ItemType: itHands; SlotType: stHands; MaxStack: 1;
    MaxDurability: 40; Level: 6; Defense: (Min: 11; Max: 12); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 350;
    Color: clWhite; Deep: [deDeepCave];),

    // Greaves
    (Symbol: ';'; ItemType: itFeet; SlotType: stFeet; MaxStack: 1;
    MaxDurability: 50; Level: 5; Defense: (Min: 13; Max: 15); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 500;
    Color: clWhite; Deep: [deDeepCave];),
    // Boneweave Boots
    (Symbol: ';'; ItemType: itFeet; SlotType: stFeet; MaxStack: 1;
    MaxDurability: 60; Level: 6; Defense: (Min: 16; Max: 18); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 650;
    Color: clWhite; Deep: [deDeepCave];),

    // Bone Shield
    (Symbol: '+'; ItemType: itShield; SlotType: stOffHand; MaxStack: 1;
    MaxDurability: 45; Level: 5; Defense: (Min: 16; Max: 18); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 450;
    Color: clLightBlue; Deep: [deDeepCave];),
    // Heater Shield
    (Symbol: '+'; ItemType: itShield; SlotType: stOffHand; MaxStack: 1;
    MaxDurability: 50; Level: 6; Defense: (Min: 19; Max: 21); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 590;
    Color: clLightBlue; Deep: [deDeepCave];),

    // Moon Blade
    (Symbol: '/'; ItemType: itBlade; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 50; Level: 5; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 17; Max: 20;);
    MaxDamage: (Min: 27; Max: 31;)); Price: 570; Color: clDarkRed;
    Deep: [deDeepCave];),
    // Scimitar
    (Symbol: '/'; ItemType: itBlade; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 55; Level: 6; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 21; Max: 25;);
    MaxDamage: (Min: 35; Max: 38;)); Price: 600; Color: clDarkRed;
    Deep: [deDeepCave];),
    // War Axe
    (Symbol: '('; ItemType: itAxe; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 50; Level: 5; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 21; Max: 24;);
    MaxDamage: (Min: 26; Max: 30;)); Price: 560; Color: clDarkRed;
    Deep: [deDeepCave];),
    // Dark Axe
    (Symbol: '('; ItemType: itAxe; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 55; Level: 6; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 24; Max: 27;);
    MaxDamage: (Min: 30; Max: 33;)); Price: 585; Color: clDarkRed;
    Deep: [deDeepCave];),
    // War Spear
    (Symbol: '|'; ItemType: itSpear; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 50; Level: 5; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 6; Max: 10;);
    MaxDamage: (Min: 25; Max: 28;)); Price: 540; Color: clDarkRed;
    Deep: [deDeepCave];),
    // Harpoon
    (Symbol: '|'; ItemType: itSpear; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 55; Level: 6; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 7; Max: 11;);
    MaxDamage: (Min: 35; Max: 39;)); Price: 575; Color: clDarkRed;
    Deep: [deDeepCave];),
    // Flanged Mace
    (Symbol: ')'; ItemType: itMace; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 50; Level: 5; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 11; Max: 14;);
    MaxDamage: (Min: 22; Max: 25;)); Price: 590; Color: clDarkRed;
    Deep: [deDeepCave];),
    // War Gavel
    (Symbol: ')'; ItemType: itMace; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 55; Level: 6; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 15; Max: 18;);
    MaxDamage: (Min: 30; Max: 33;)); Price: 650; Color: clDarkRed;
    Deep: [deDeepCave];),

    // == Blood Cave == //

    // Horned Helmet
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 45; Level: 7; Defense: (Min: 12; Max: 14); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 850;
    Color: clWhite; Deep: [deBloodCave];),
    // Spired Helm
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 50; Level: 8; Defense: (Min: 14; Max: 16); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1000;
    Color: clWhite; Deep: [deBloodCave];),
    // Diadem
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 30; Level: 7; Defense: (Min: 6; Max: 7); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1300;
    Color: clLightestBlue; Deep: [deBloodCave];),
    // Tiara
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 35; Level: 8; Defense: (Min: 7; Max: 8); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1700;
    Color: clLightestBlue; Deep: [deBloodCave];),
    // Chain Mail
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 175; Level: 7; Defense: (Min: 31; Max: 35); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1300;
    Color: clWhite; Deep: [deBloodCave];),
    // Scale Mail
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 200; Level: 8; Defense: (Min: 36; Max: 40); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1600;
    Color: clWhite; Deep: [deBloodCave];),
    // Thick Furs
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 120; Level: 7; Defense: (Min: 13; Max: 14); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1900;
    Color: clLightestBlue; Deep: [deBloodCave];),
    // Hard Robe
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 150; Level: 8; Defense: (Min: 15; Max: 16); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 2100;
    Color: clLightestBlue; Deep: [deBloodCave];),

    // Battle Gauntlets
    (Symbol: '%'; ItemType: itHands; SlotType: stHands; MaxStack: 1;
    MaxDurability: 45; Level: 7; Defense: (Min: 13; Max: 14); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 400;
    Color: clWhite; Deep: [deBloodCave];),
    // War Gauntlets
    (Symbol: '%'; ItemType: itHands; SlotType: stHands; MaxStack: 1;
    MaxDurability: 50; Level: 8; Defense: (Min: 15; Max: 16); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 450;
    Color: clWhite; Deep: [deBloodCave];),

    // Chain Boots
    (Symbol: ';'; ItemType: itFeet; SlotType: stFeet; MaxStack: 1;
    MaxDurability: 70; Level: 7; Defense: (Min: 19; Max: 21); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 700;
    Color: clWhite; Deep: [deBloodCave];),
    // War Boots
    (Symbol: ';'; ItemType: itFeet; SlotType: stFeet; MaxStack: 1;
    MaxDurability: 80; Level: 8; Defense: (Min: 22; Max: 24); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 850;
    Color: clWhite; Deep: [deBloodCave];),

    // Heavy Shield
    (Symbol: '+'; ItemType: itShield; SlotType: stOffHand; MaxStack: 1;
    MaxDurability: 60; Level: 7; Defense: (Min: 22; Max: 24); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 740;
    Color: clLightBlue; Deep: [deBloodCave];),
    // Large Shield
    (Symbol: '+'; ItemType: itShield; SlotType: stOffHand; MaxStack: 1;
    MaxDurability: 75; Level: 8; Defense: (Min: 25; Max: 27); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 860;
    Color: clLightBlue; Deep: [deBloodCave];),

    // Bastard Sword
    (Symbol: '/'; ItemType: itBlade; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 60; Level: 7; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 24; Max: 27;);
    MaxDamage: (Min: 39; Max: 43;)); Price: 770; Color: clDarkRed;
    Deep: [deBloodCave];),
    // Great Sword
    (Symbol: '/'; ItemType: itBlade; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 65; Level: 8; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 27; Max: 30;);
    MaxDamage: (Min: 44; Max: 48;)); Price: 820; Color: clDarkRed;
    Deep: [deBloodCave];),
    // Berserker Axe
    (Symbol: '('; ItemType: itAxe; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 60; Level: 7; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 28; Max: 32;);
    MaxDamage: (Min: 36; Max: 38;)); Price: 750; Color: clDarkRed;
    Deep: [deDeepCave];),
    // Marauder Axe
    (Symbol: '('; ItemType: itAxe; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 65; Level: 8; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 32; Max: 35;);
    MaxDamage: (Min: 41; Max: 45;)); Price: 885; Color: clDarkRed;
    Deep: [deBloodCave];),
    // Silvan Whisper
    (Symbol: '|'; ItemType: itSpear; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 60; Level: 7; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 8; Max: 11;);
    MaxDamage: (Min: 50; Max: 52;)); Price: 720; Color: clDarkRed;
    Deep: [deBloodCave];),
    // Impaler
    (Symbol: '|'; ItemType: itSpear; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 65; Level: 8; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 9; Max: 11;);
    MaxDamage: (Min: 65; Max: 67;)); Price: 790; Color: clDarkRed;
    Deep: [deBloodCave];),
    // Barbarous Mace
    (Symbol: ')'; ItemType: itMace; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 60; Level: 7; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 19; Max: 22;);
    MaxDamage: (Min: 38; Max: 41;)); Price: 780; Color: clDarkRed;
    Deep: [deBloodCave];),
    // Adept Hammer
    (Symbol: ')'; ItemType: itMace; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 65; Level: 8; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 24; Max: 27;);
    MaxDamage: (Min: 48; Max: 51;)); Price: 850; Color: clDarkRed;
    Deep: [deBloodCave];),

    // == Drom == //

    // Casque
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 60; Level: 9; Defense: (Min: 16; Max: 18); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1300;
    Color: clWhite; Deep: [deDrom];),
    // Winged Helm
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 75; Level: 10; Defense: (Min: 18; Max: 20); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1500;
    Color: clWhite; Deep: [deDrom];),
    // Magic Helmet
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 40; Level: 9; Defense: (Min: 8; Max: 10); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 2300;
    Color: clLightestBlue; Deep: [deDrom];),
    // Crown
    (Symbol: '^'; ItemType: itHeadgear; SlotType: stHead; MaxStack: 1;
    MaxDurability: 50; Level: 10; Defense: (Min: 10; Max: 12); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 2800;
    Color: clLightestBlue; Deep: [deDrom];),
    // Splint Mail
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 225; Level: 9; Defense: (Min: 41; Max: 45); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1900;
    Color: clWhite; Deep: [deDrom];),
    // Plate Mail
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 250; Level: 10; Defense: (Min: 46; Max: 50); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 2500;
    Color: clWhite; Deep: [deDrom];),
    // Moloch Robe
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 180; Level: 9; Defense: (Min: 17; Max: 18); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 2600;
    Color: clLightestBlue; Deep: [deDrom];),
    // Boneweave Hauberk
    (Symbol: '&'; ItemType: itBodyArmor; SlotType: stTorso; MaxStack: 1;
    MaxDurability: 200; Level: 10; Defense: (Min: 19; Max: 20); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 3000;
    Color: clLightestBlue; Deep: [deDrom];),

    // Troll Gauntlets
    (Symbol: '%'; ItemType: itHands; SlotType: stHands; MaxStack: 1;
    MaxDurability: 55; Level: 9; Defense: (Min: 17; Max: 18); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 500;
    Color: clWhite; Deep: [deDrom];),
    // Plated Gauntlets
    (Symbol: '%'; ItemType: itHands; SlotType: stHands; MaxStack: 1;
    MaxDurability: 60; Level: 10; Defense: (Min: 19; Max: 20); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 600;
    Color: clWhite; Deep: [deDrom];),

    // Battle Boots
    (Symbol: ';'; ItemType: itFeet; SlotType: stFeet; MaxStack: 1;
    MaxDurability: 90; Level: 9; Defense: (Min: 25; Max: 27); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 900;
    Color: clWhite; Deep: [deDrom];),
    // Plate Boots
    (Symbol: ';'; ItemType: itFeet; SlotType: stFeet; MaxStack: 1;
    MaxDurability: 100; Level: 10; Defense: (Min: 28; Max: 30); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1000;
    Color: clWhite; Deep: [deDrom];),

    // Tower Shield
    (Symbol: '+'; ItemType: itShield; SlotType: stOffHand; MaxStack: 1;
    MaxDurability: 100; Level: 9; Defense: (Min: 28; Max: 30); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 920;
    Color: clLightBlue; Deep: [deDrom];),
    // Gothic Shield
    (Symbol: '+'; ItemType: itShield; SlotType: stOffHand; MaxStack: 1;
    MaxDurability: 150; Level: 10; Defense: (Min: 31; Max: 35); Damage: (MinDamage: (Min: 0; Max: 0;); MaxDamage: (Min: 0; Max: 0;));Price: 1000;
    Color: clLightBlue; Deep: [deDrom];),

    // Rune Sword
    (Symbol: '/'; ItemType: itBlade; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 70; Level: 9; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 30; Max: 33;);
    MaxDamage: (Min: 50; Max: 54;)); Price: 930; Color: clDarkRed;
    Deep: [deDrom];),
    // Troll Slayer,
    (Symbol: '/'; ItemType: itBlade; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 75; Level: 10; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 33; Max: 37;);
    MaxDamage: (Min: 55; Max: 60;)); Price: 990; Color: clDarkRed;
    Deep: [deDrom];),
    // Chopper
    (Symbol: '('; ItemType: itAxe; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 70; Level: 9; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 36; Max: 39;);
    MaxDamage: (Min: 45; Max: 49;)); Price: 940; Color: clDarkRed;
    Deep: [deDrom];),
    // Demon Axe,
    (Symbol: '('; ItemType: itAxe; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 75; Level: 10; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 40; Max: 45;);
    MaxDamage: (Min: 50; Max: 55;)); Price: 980; Color: clDarkRed;
    Deep: [deDrom];),
    // Soul Reaver
    (Symbol: '|'; ItemType: itSpear; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 70; Level: 9; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 10; Max: 12;);
    MaxDamage: (Min: 80; Max: 89;)); Price: 940; Color: clDarkRed;
    Deep: [deDrom];),
    // Honed Spear,
    (Symbol: '|'; ItemType: itSpear; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 75; Level: 10; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 10; Max: 15;);
    MaxDamage: (Min: 90; Max: 100;)); Price: 970; Color: clDarkRed;
    Deep: [deDrom];),
    // War Maul
    (Symbol: ')'; ItemType: itMace; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 70; Level: 9; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 30; Max: 35;);
    MaxDamage: (Min: 65; Max: 69;)); Price: 950; Color: clDarkRed;
    Deep: [deDrom];),
    // Doom Hammer
    (Symbol: ')'; ItemType: itMace; SlotType: stMainHand; MaxStack: 1;
    MaxDurability: 75; Level: 10; Defense: (Min: 0; Max: 0);Damage: (MinDamage: (Min: 36; Max: 40;);
    MaxDamage: (Min: 70; Max: 80;)); Price: 1000; Color: clDarkRed;
    Deep: [deDrom];)

    );

type
  TPriceType = (ptNone, ptSell, ptBuy, ptRepair);

type
  TBonusType = (btLife, btMana, btVision, btNN);

type
  TItems = class(TEntity)
  private
    function GetName(I: TItemEnum): string; overload;
  public
    class procedure Make(ID: Byte; var AItem: Item);
    class procedure CalcItem(var AItem: Item; APrice: Word = 0);
    constructor Create;
    destructor Destroy; override;
    procedure Render(AX, AY: Byte);
    procedure Add(AZ: TMapEnum; AX: Integer = -1; AY: Integer = -1;
      AID: Integer = -1; IsRare: Boolean = False);
    function GetItemEnum(AItemID: Integer): TItemEnum;
    function GetItemInfo(AItem: Item; IsManyItems: Boolean = False;
      ACount: Byte = 0; IsShort: Boolean = False): string;
    function RenderInvItem(const AX, AY, I: Integer; AItem: Item;
      IsAdvInfo: Boolean = False; IsRender: Boolean = True;
      PriceType: TPriceType = ptNone): string;
    function GetSlotName(const SlotType: TSlotType): string;
    procedure AddItemToInv(Index: Integer = 0; AFlag: Boolean = False);
      overload;
    procedure AddItemToInv(AItemEnum: TItemEnum; AAmount: Word = 1;
      EqFlag: Boolean = False; IdFlag: Boolean = False); overload;
    function GetInventory: string;
    function GetPrice(Price: Word; F: Boolean = False): string;
    function GetLevel(L: Byte): string;
    function GetInfo(Sign: string; Value: Word; Color: string; RareColor: string = ''): string;
    procedure RenderInventory(PriceType: TPriceType = ptNone);
    procedure LootGold(const AX, AY: Byte);
    procedure Loot(const AX, AY: Byte; AItemEnum: TItemEnum); overload;
    procedure Loot(const AX, AY: Byte; AIsBoss: Boolean); overload;
    property Name[I: TItemEnum]: string read GetName;
    function ChItem(AItem: Item): Boolean;
    function Identify(var AItem: Item; IsNew: Boolean = False): Boolean;
    function GetName(AItem: Item; IsShort: Boolean = False): string; overload;
    function GetNameThe(AItem: Item): string;
    procedure AddItemToDungeon(AItem: Item);
    function AddItemInfo(V: array of string): string;
    procedure SetBonus(var AItem: Item; const BonusType: TBonusType; const Value: Byte);
    function GetBonus(const AItem: Item; const BonusType: TBonusType): Byte;
    procedure DelCorpses();
    procedure AddPlants;
  end;

var
  Items: TItems = nil;

implementation

uses Math, Classes, SysUtils, uTerminal, gnugettext, uMsgLog, uScenes,
  uShop, uTalent, uAffixes, uAttribute, uUI;

{ TItems }

class procedure TItems.CalcItem(var AItem: Item; APrice: Word = 0);
begin
  // Damage
  if (AItem.MinDamage > 0) and (AItem.MinDamage >= AItem.MaxDamage) then
    AItem.MinDamage := AItem.MaxDamage - 1;
  // Price  
  AItem.Price := ItemBase[TItemEnum(AItem.ItemID)].Price +
    APrice +
    Round(AItem.MaxDurability * 3.7) +
    Round(AItem.Defense * 4.8) +
    Round(AItem.MaxDamage * 5.6);
end;

function TItems.ChItem(AItem: Item): Boolean;
begin
  Result := (ItemBase[TItemEnum(AItem.ItemID)].ItemType in CorpseTypeItems) or
    (AItem.Stack > 1) or (AItem.Amount > 1);
end;

function TItems.GetItemInfo(AItem: Item; IsManyItems: Boolean = False;
  ACount: Byte = 0; IsShort: Boolean = False): string;
var
  ID: Integer;
  S, T, K, D: string;
  IT: TItemType;
  F: Boolean;
  V: Word;

  function GetAmount(): string;
  begin
    Result := Format('(%dx)', [AItem.Amount])
  end;

begin
  S := '';
  T := '';
  F := False;
  Result := '';
  ID := AItem.ItemID;
  IT := ItemBase[TItemEnum(ID)].ItemType;
  // Info
  if not IsManyItems then
  begin
    if (IT in RuneTypeItems + ScrollTypeItems) then
    begin
      V := ItemBase[TItemEnum(ID)].ManaCost;
      if (V > 0) then
      begin
        S := S + Items.GetInfo('-', V, 'Mana') + ' ';
        F := True;
      end;
    end;
    if (efMana in ItemBase[TItemEnum(ID)].Effects) then
    begin
      V := ItemBase[TItemEnum(ID)].Value;
      if (V > 0) then
      begin
        S := S + Items.GetInfo('+', V, 'Mana') + ' ';
        F := True;
      end;
    end;
    if (efLife in ItemBase[TItemEnum(ID)].Effects) then
    begin
      V := ItemBase[TItemEnum(ID)].Value;
      if (V > 0) then
      begin
        S := S + Items.GetInfo('+', V, 'Life') + ' ';
        F := True;
      end;
    end;
    if (efFood in ItemBase[TItemEnum(ID)].Effects) then
    begin
      V := ItemBase[TItemEnum(ID)].Value;
      if (V > 0) then
      begin
        S := S + Items.GetInfo('+', V, 'Food') + ' ';
        F := True;
      end;
    end;
    if (efCurePoison in ItemBase[TItemEnum(ID)].Effects) then
    begin
      V := ItemBase[TItemEnum(ID)].Value;
      if (V > 0) then
      begin
        S := S + Items.GetInfo('-', V, 'Poison') + ' ';
        F := True;
      end;
    end;
    if IsShort then F := False;
    if F then
      S := '[[' + Trim(S) + ']] ';
  end;
  // Amount
  if (AItem.Stack > 1) then
  begin
    if (AItem.Amount > 1) then S := S + GetAmount();
  end
  // Corpse
  else if (TItemEnum(ID) = iCorpse) then
    S := ''
  else
  begin
    // Defense
    if (IT in ArmorTypeItems + JewelryTypeItems) then
    begin
      if (AItem.Defense > 0) then
        T := Format('%s%d', [UI.Icon(icShield), AItem.Defense]);
      if (AItem.Identify > 0) and (TSuffixEnum(AItem.Identify) in DefenseSuffixes) then
        T := Terminal.Colorize(T, 'Rare');
    end;
    // Damage
    if (IT in WeaponTypeItems + JewelryTypeItems) then
    begin
      if (AItem.MinDamage > 0) then
        T := Format('%s%d-%d', [UI.Icon(icHammer), AItem.MinDamage, AItem.MaxDamage]);
      if (AItem.Identify > 0) and (TSuffixEnum(AItem.Identify) in DamageSuffixes) then
        T := Terminal.Colorize(T, 'Rare');
    end;
    K := '';
    if (ItemBase[TItemEnum(AItem.ItemID)].Level > 0) then
      K := GetLevel(ItemBase[TItemEnum(AItem.ItemID)].Level);
    if (AItem.Bonus > 0) then
    begin
      if (Items.GetBonus(AItem, btVision) > 0) then
        K := K + ' ' + Items.GetInfo('*', Items.GetBonus(AItem, btVision), 'Vision', 'Rare');
      if (Items.GetBonus(AItem, btLife) > 0) then
        K := K + ' ' + Items.GetInfo('*', Items.GetBonus(AItem, btLife), 'Life', 'Rare');
      if (Items.GetBonus(AItem, btMana) > 0) then
        K := K + ' ' + Items.GetInfo('*', Items.GetBonus(AItem, btMana), 'Mana', 'Rare');
    end;
    D := Format('%s%d/%d', [UI.Icon(icHammer), AItem.Durability, AItem.MaxDurability]);
    if (AItem.Identify > 0) and (TSuffixEnum(AItem.Identify) in DurabilitySuffixes) then
      D := Terminal.Colorize(D, 'Rare');
      
    S := S + AddItemInfo([K, T, D]);

    if (AItem.Identify = 0) or Player.Look then S := '';
  end;
  Result := Trim(Format('%s %s', [Items.GetName(AItem), S]));
  // Map's item
  if (IsManyItems or (ACount > 0)) then
  begin
    if Player.Look or IsShort then S := '';
    S := Game.IfThen(AItem.Amount > 1, GetAmount(), '');
    S := GetCapit(GetDescAn(Trim(Items.GetName(AItem, IsShort) + ' ' + S)));
    if IsManyItems then
    begin
      Result := Format(_('Several items (%dx) are lying here (%s).'),
        [ACount, S]);
    end
    else
      Result := Format(_('%s is lying here.'), [S]);
  end;
  if Game.Wizard then
    Result := Result + Format(' ID: %d', [ID]);
end;

class procedure TItems.Make(ID: Byte; var AItem: Item);

  function IsIdentify(): Boolean;
  begin
    Result := False;
    if (ItemBase[TItemEnum(ID)].ItemType in IdentTypeItems) then
      Result := (Math.RandomRange(0, 2) = 0) or
        (ItemBase[TItemEnum(ID)].ItemType in JewelryTypeItems)
  end;

begin
  Items_Clear_Item(AItem);
  AItem.ItemID := ID;
  AItem.SlotID := Ord(ItemBase[TItemEnum(ID)].SlotType);
  AItem.Stack := ItemBase[TItemEnum(ID)].MaxStack;
  // Color
  AItem.Color := ItemBase[TItemEnum(ID)].Color;
  //AItem.Color := Math.RandomRange($FF888888, $FFFFFFFF);
  // Defense
  if (AItem.Stack = 1) and (ItemBase[TItemEnum(ID)].Defense.Min > 0) then
    AItem.Defense := Math.EnsureRange
      (Math.RandomRange(ItemBase[TItemEnum(ID)].Defense.Min,
      ItemBase[TItemEnum(ID)].Defense.Max + 1), 1, High(Byte))
  else
    AItem.Defense := 0;
  // Damage
  if (AItem.Stack = 1) and (ItemBase[TItemEnum(ID)].Damage.MinDamage.Min > 0)
  then
    AItem.MinDamage := Math.EnsureRange
      (Math.RandomRange(ItemBase[TItemEnum(ID)].Damage.MinDamage.Min,
      ItemBase[TItemEnum(ID)].Damage.MinDamage.Max + 1), 1, High(Byte) - 1)
  else
    AItem.MinDamage := 0;
  if (AItem.Stack = 1) and (ItemBase[TItemEnum(ID)].Damage.MaxDamage.Min > 0)
  then
    AItem.MaxDamage := Math.EnsureRange
      (Math.RandomRange(ItemBase[TItemEnum(ID)].Damage.MaxDamage.Min,
      ItemBase[TItemEnum(ID)].Damage.MaxDamage.Max + 1), 2, High(Byte))
  else
    AItem.MaxDamage := 0;
  // Durability
  if (AItem.Stack = 1) then
    AItem.MaxDurability := Math.EnsureRange
      (Math.RandomRange(ItemBase[TItemEnum(ID)].MaxDurability - 5,
      ItemBase[TItemEnum(ID)].MaxDurability + 6), 10, High(Byte))
  else
    AItem.MaxDurability := 0;
  AItem.Durability := AItem.MaxDurability;
  // Bonus
  AItem.Bonus := 0;
  // Price
  CalcItem(AItem);
  // Affix
  AItem.Identify := Math.IfThen(IsIdentify(), 0, -1);
end;

procedure TItems.Add(AZ: TMapEnum; AX: Integer = -1; AY: Integer = -1;
  AID: Integer = -1; IsRare: Boolean = False);
var
  I, ID, FX, FY: Byte;
  FItem: Item;
  Value: Integer;
  IT: TItemType;
begin
  I := 0;
  repeat
    if (AID >= 0) then
      ID := AID
    else
      ID := Math.RandomRange(0, Ord(High(TItemEnum)) + 1);
    if (AX >= 0) then
      FX := AX
    else
      FX := Math.RandomRange(1, High(Byte) - 1);
    if (AY >= 0) then
      FY := AY
    else
      FY := Math.RandomRange(1, High(Byte) - 1);
    if (I >= High(Byte)) then
    begin
      ID := Ord(iGold);
      Break;
    end;
    Inc(I);
  until (Map.GetTileEnum(FX, FY, AZ) in SpawnTiles) and
    (AZ in ItemBase[TItemEnum(ID)].Deep);
  IT := ItemBase[TItemEnum(ID)].ItemType;
  if ((AID < 0) and (IT in NotDropTypeItems)) then
    Exit;
  Make(ID, FItem);
  FItem.Amount := 1;
  FItem.MapID := Ord(AZ);
  case IT of
    itCoin:
      begin
        Value := Ord(AZ) + 1;
        FItem.Amount := Math.RandomRange(Value * Value,
          Value * Value * (5 - Ord(Game.Difficulty))) + 1;
        if Player.Talents.IsTalent(tlMiser) then
          FItem.Amount := FItem.Amount * 2;
      end;
  end;
  if ((FItem.Stack = 1) and (IT in WeaponTypeItems + ArmorTypeItems)) then
    FItem.Durability := Math.RandomRange(FItem.MaxDurability div 4,
      FItem.MaxDurability) + 1;
  FItem.X := FX;
  FItem.Y := FY;
  FItem.Equipment := 0;
  AddItemToDungeon(FItem);
end;

procedure TItems.Loot(const AX, AY: Byte; AItemEnum: TItemEnum);
begin
  Add(Map.Current, AX, AY, Ord(AItemEnum));
end;

procedure TItems.Loot(const AX, AY: Byte; AIsBoss: Boolean);
var
  V, I: Byte;
const
  M = 10;
begin
  V := Math.IfThen(AIsBoss, Ord(Map.Current) + 9, Ord(Map.Current) + 2);
  for I := 1 to V do
  begin
    // Gold
    if (Math.RandomRange(0, M) >= 6) then
      LootGold(AX, AY);
    // Potion
    if ((Math.RandomRange(0, M) >= 7) or AIsBoss) then
      Loot(AX, AY, TItemEnum(Math.RandomRange(Ord(iLesserHealingPotion),
        Ord(iPotionOfFullMana) + 1)));
    // Scroll
    if ((Math.RandomRange(0, M) >= 8) or AIsBoss) then
      Loot(AX, AY, TItemEnum(Math.RandomRange(Ord(iScrollOfMinorHealing),
        Ord(iScrollOfTownPortal) + 1)));
    // Item
    if (Math.RandomRange(0, M) >= 9) then
      Add(Map.Current, AX, AY, -1, AIsBoss);
  end;
end;

procedure TItems.Render(AX, AY: Byte);
var
  MapID: Byte;
  I, Count: Integer;
  FColor: Cardinal;
  FSymbol: Char;
  FItem: Item;
begin
  MapID := Ord(Map.Current);
  Count := Items_Dungeon_GetMapCount(MapID);
  for I := Count - 1 downto 0 do
  begin
    FItem := Items_Dungeon_GetMapItem(MapID, I);
    if not Map.InView(FItem.X, FItem.Y) or
      (not Game.Wizard and not Map.GetFOV(FItem.X, FItem.Y)) then
      Continue;
    X := FItem.X - Player.X + AX + View.Left;
    Y := FItem.Y - Player.Y + AY + View.Top;
    if not Game.Wizard and (Player.GetDist(FItem.X, FItem.Y) > Player.Vision)
    then
    begin
      FColor := clFog;
      FSymbol := '?';
    end
    else
    begin
      FColor := FItem.Color; // ItemBase[TItemEnum(FItem.ItemID)].Color;
      FSymbol := ItemBase[TItemEnum(FItem.ItemID)].Symbol;
    end;
    Terminal.Print(X, Y, FSymbol, FColor);
  end;
end;

constructor TItems.Create;
begin
  Items_Open();
end;

destructor TItems.Destroy;
begin
  Items_Close();
  inherited;
end;

function TItems.GetName(I: TItemEnum): string;
begin
  case I of
    // == All maps == //
    // None
    iNone:
      Result := _('None');
    // Corpse
    iCorpse:
      Result := _('Corpse');
    // Gold
    iGold:
      Result := _('Gold');

    // Potion of rejuvenation
    iLesserRejuvenationPotion:
      Result := _('Lesser Rejuvenation Potion');
    // Potion of rejuvenation
    iGreaterRejuvenationPotion:
      Result := _('Greater Rejuvenation Potion');
    // Potion of rejuvenation
    iHeroicRejuvenationPotion:
      Result := _('Heroic Rejuvenation Potion');
    // Potion of rejuvenation
    iPotionOfFullRejuvenation:
      Result := _('Potion Of Full Rejuvenation');

    // Potion of health
    iLesserHealingPotion:
      Result := _('Lesser healing potion');
    // Potion of health
    iGreaterHealingPotion:
      Result := _('Greater healing potion');
    // Potion of health
    iHeroicHealingPotion:
      Result := _('Heroic healing potion');
    // Potion of health
    iPotionOfFullHealing:
      Result := _('Potion of full healing');

    // Potion of mana
    iLesserManaPotion:
      Result := _('Lesser mana potion');
    // Potion of mana
    iGreaterManaPotion:
      Result := _('Greater mana potion');
    // Potion of mana
    iHeroicManaPotion:
      Result := _('Heroic mana potion');
    // Potion of mana
    iPotionOfFullMana:
      Result := _('Potion of full mana');

    // Soothing Balm
    iSoothingBalm:
      Result := _('Soothing balm');
    // Healing Poultice
    iHealingPoultice:
      Result := _('Healing poultice');
    // Antidote
    iAntidote:
      Result := _('Antidote');
    // Fortifying Potion
    iFortifyingPotion:
      Result := _('Fortifying Potion');

    // Troll Blood Extract
    iTrollBloodExtract:
      Result := _('Troll Blood Extract');
    // Unicorn Blood Extract
    iUnicornBloodExtract:
      Result := _('Unicorn Blood Extract');

    // Scroll of Healing
    iScrollOfMinorHealing:
      Result := _('Scroll of Minor Healing');
    // Scroll of Healing
    iScrollOfLesserHealing:
      Result := _('Scroll of Lesser Healing');
    // Scroll of Healing
    iScrollOfGreaterHealing:
      Result := _('Scroll of Greater Healing');
    // Scroll of Healing
    iScrollOfFullHealing:
      Result := _('Scroll of Full Healing');

    // Scroll of Hunger
    iScrollOfHunger:
      Result := _('Scroll of Hunger');
    // Scroll of Sidestepping
    iScrollOfSidestepping:
      Result := _('Scroll of Sidestepping');
    // Scroll of Phasing
    iScrollOfPhasing:
      Result := _('Scroll of Phasing');
    // Scroll of Teleportation
    iScrollOfTeleportation:
      Result := _('Scroll of Teleportation');
    // Scroll of Disappearing
    iScrollOfDisappearing:
      Result := _('Scroll of Disappearing');
    // Scroll of Town Portal
    iScrollOfTownPortal:
      Result := _('Scroll of Town Portal');
    // Scroll of Bloodlust
    iScrollOfBloodlust:
      Result := _('Scroll of Bloodlust');
    // Scroll of Identify
    iScrollOfIdentify:
      Result := _('Scroll of Identify');

    // Rune Of Minor Healing
    iRuneOfMinorHealing:
      Result := _('Rune of Minor Healing');
    // Rune Of Lesser Healing
    iRuneOfLesserHealing:
      Result := _('Rune of Lesser Healing');
    // Rune Of Greater Healing
    iRuneOfGreaterHealing:
      Result := _('Rune of Greater Healing');
    // Rune Of Full Healing
    iRuneOfFullHealing:
      Result := _('Rune of Full Healing');
    // Rune Of Teleportation
    iRuneOfTeleportation:
      Result := _('Rune of Teleportation');
    // Rune Of Town Portal
    iRuneOfTownPortal:
      Result := _('Rune of Town Portal');

    // Bread ration
    iBreadRation:
      Result := _('Bread ration');
    // Valley root
    iValleyRoot:
      Result := _('Valley root');
    // Rat pod
    iRatPod:
      Result := _('Rat pod');
    // Kobold bulb
    iKoboldBulb:
      Result := _('Kobold bulb');

    // Key
    iKey:
      Result := _('Key');

    // Ruby
    iRuby:
      Result := _('Ruby');
    // Topaz
    iTopaz:
      Result := _('Topaz');
    // Emerald
    iEmerald:
      Result := _('Emerald');
    // Sapphire
    iSapphire:
      Result := _('Sapphire');
    // Ring
    iRing:
      Result := _('Ring');
    // Amulet
    iAmulet:
      Result := _('Amulet');

    // == Dark Wood == //

    // Helm
    iCap:
      Result := _('Cap');
    iWarCap:
      Result := _('War Cap');
    iHood:
      Result := _('Hood');
    iRedHat:
      Result := _('Red Hat');
    // Armor
    iQuiltedArmor:
      Result := _('Quilted Armor');
    iLeatherArmor:
      Result := _('Leather Armor');
    iLightClothes:
      Result := _('Light Clothes');
    iLeatherApron:
      Result := _('Leather Apron');
    // Gloves
    iLeatherGloves:
      Result := _('Leather Gloves');
    iHideGloves:
      Result := _('Hide Gloves');
    // Boots
    iShoes:
      Result := _('Shoes');
    iLeatherBoots:
      Result := _('Leather Boots');
    // Shield
    iBuckler:
      Result := _('Buckler');
    iTargeShield:
      Result := _('Targe Shield');
    // Blade
    iRustySword:
      Result := _('Rusty Sword');
    iShortSword:
      Result := _('Short Sword');
    // Axe
    iHatchet:
      Result := _('Hatchet');
    iBattleAxe:
      Result := _('Battle Axe');
    // Spear
    iShortSpear:
      Result := _('Short Spear');
    iSpear:
      Result := _('Spear');
    // Mace
    iSlagHammer:
      Result := _('Slag Hammer');
    iSpikedCudgel:
      Result := _('Spiked Cudgel');

    // == Gray Cave == //

    // Helm
    iHelm:
      Result := _('Helm');
    iGrandHelm:
      Result := _('Grand Helm');
    iLeatherCap:
      Result := _('Leather Cap');
    iMask:
      Result := _('Mask');
    // Armor
    iHardLeatherArmor:
      Result := _('HardLeather Armor');
    iBattleArmor:
      Result := _('Battle Armor');
    iFancyClothes:
      Result := _('Fancy Clothes');
    iRobe:
      Result := _('Robe');
    // Gloves
    iKoboldGloves:
      Result := _('Kobold Gloves');
    iChainGloves:
      Result := _('Chain Gloves');
    // Boots
    iMeshBoots:
      Result := _('Mesh Boots');
    iHeavyBoots:
      Result := _('Heavy Boots');
    // Shield
    iSmallShield:
      Result := _('Small Shield');
    iKiteShield:
      Result := _('Kite Shield');
    // Blade
    iBroadSword:
      Result := _('Broad Sword');
    iLongSword:
      Result := _('Long Sword');
    // Axe
    iMeatAxe:
      Result := _('Meat Axe');
    iFleshTearer:
      Result := _('Flesh Tearer');
    // Spear
    iJavelin:
      Result := _('Javelin');
    iFuscina:
      Result := _('Fuscina');
    // Mace
    iWarhammer:
      Result := _('Warhammer');
    iWarMace:
      Result := _('War Mace');

    // == Deep Cave == //

    // Helm
    iGreatHelm:
      Result := _('Great Helm');
    iFullHelm:
      Result := _('Full Helm');
    iBoneHelmet:
      Result := _('Bone Helmet');
    iWizardHat:
      Result := _('Wizard Hat');
    // Armor
    iBrigantineArmor:
      Result := _('Brigantine Armor');
    iRingMail:
      Result := _('Ring Mail');
    iLightFurs:
      Result := _('Light Furs');
    iCleanRobe:
      Result := _('Clean Robe');
    // Gloves
    iEtchedGloves:
      Result := _('Etched Gloves');
    iHeavyGloves:
      Result := _('Heavy Gloves');
    // Boots
    iGreaves:
      Result := _('Greaves');
    iBoneweaveBoots:
      Result := _('Boneweave Boots');
    // Shield
    iBoneShield:
      Result := _('Bone Shield');
    iHeaterShield:
      Result := _('Heater Shield');
    // Blade
    iMoonBlade:
      Result := _('Moon Blade');
    iScimitar:
      Result := _('Scimitar');
    // Axe
    iWarAxe:
      Result := _('War Axe');
    iDarkAxe:
      Result := _('Dark Axe');
    // Spear
    iWarSpear:
      Result := _('War Spear');
    iHarpoon:
      Result := _('Harpoon');
    // Mace
    iFlangedMace:
      Result := _('Flanged Mace');
    iWarGavel:
      Result := _('War Gavel');

    // == Blood Cave == //

    // Helm
    iHornedHelmet:
      Result := _('Horned Helmet');
    iSpiredHelm:
      Result := _('Spired Helm');
    iDiadem:
      Result := _('Diadem');
    iTiara:
      Result := _('Tiara');
    // Armor
    iChainMail:
      Result := _('Chain Mail');
    iScaleMail:
      Result := _('Scale Mail');
    iThickFurs:
      Result := _('Thick Furs');
    iHardRobe:
      Result := _('Hard Robe');
    // Gloves
    iBattleGauntlets:
      Result := _('Battle Gauntlets');
    iWarGauntlets:
      Result := _('War Gauntlets');
    // Boots
    iChainBoots:
      Result := _('Chain Boots');
    iWarBoots:
      Result := _('War Boots');
    // Shield
    iHeavyShield:
      Result := _('Heavy Shield');
    iLargeShield:
      Result := _('Large Shield');
    // Blade
    iBastardSword:
      Result := _('Bastard Sword');
    iGreatSword:
      Result := _('Great Sword');
    // Axe
    iBerserkerAxe:
      Result := _('Berserker Axe');
    iMarauderAxe:
      Result := _('Marauder Axe');
    // Spear
    iSilvanWhisper:
      Result := _('Silvan Whisper');
    iImpaler:
      Result := _('Impaler');
    // Mace
    iBarbarousMace:
      Result := _('Barbarous Mace');
    iAdeptHammer:
      Result := _('Adept Hammer');

    // == Drom == //

    // Helm
    iCasque:
      Result := _('Casque');
    iWingedHelm:
      Result := _('Winged Helm');
    iMagicHelmet:
      Result := _('Magic Helmet');
    iCrown:
      Result := _('Crown');
    // Armor
    iSplintMail:
      Result := _('Splint Mail');
    iPlateMail:
      Result := _('Plate Mail');
    iMolochRobe:
      Result := _('Moloch Robe');
    iBoneweaveHauberk:
      Result := _('Boneweave Hauberk');
    // Gloves
    iTrollGauntlets:
      Result := _('Troll Gauntlets');
    iPlatedGauntlets:
      Result := _('Plated Gauntlets');
    // Boots
    iBattleBoots:
      Result := _('Battle Boots');
    iPlateBoots:
      Result := _('Plate Boots');
    // Shield
    iTowerShield:
      Result := _('Tower Shield');
    iGothicShield:
      Result := _('Gothic Shield');
    // Blade
    iRuneSword:
      Result := _('Rune Sword');
    iTrollSlayer:
      Result := _('Troll Slayer');
    // Axe
    iChopper:
      Result := _('Chopper');
    iDemonAxe:
      Result := _('Demon Axe');
    // Spear
    iSoulReaver:
      Result := _('Soul Reaver');
    iHonedSpear:
      Result := _('Honed Spear');
    // Mace
    iWarMaul:
      Result := _('War Maul');
    iDoomHammer:
      Result := _('Doom Hammer');
  end;
end;

function TItems.GetSlotName(const SlotType: TSlotType): string;
begin
  case SlotType of
    stHead:
      Result := _('Head');
    stNeck:
      Result := _('Neck');
    stFinger:
      Result := _('Finger');
    stMainHand:
      Result := _('Main Hand');
    stOffHand:
      Result := _('Off-Hand');
    stTorso:
      Result := _('Torso');
    stHands:
      Result := _('Hands');
    stFeet:
      Result := _('Feet');
  end;
  Result := Terminal.Colorize(Format('{%s}', [Result]), Terminal.GetColorFromIni('Equip'));
end;

function TItems.GetPrice(Price: Word; F: Boolean = False): string;
var
  Color: string;
begin
  if (F or (Player.Gold >= Price)) then
    Color := 'lighter yellow'
  else
    Color := 'light red';
  Result := Terminal.Colorize(UI.Icon(icGold) + IntToStr(Price), Color);
end;

function TItems.GetLevel(L: Byte): string;
var
  Color: string;
begin
  if (L > Player.Attributes.Attrib[atLev].Value) then
    Color := 'Light Red'
  else
    Color := 'Gray';
  Result := Terminal.Colorize(Format('%s%d', [UI.Icon(icElixir), L]), Color);
end;

function TItems.GetInfo(Sign: string; Value: Word; Color: string; RareColor: string = ''): string;
var
  S: string;
begin
  S := '@';
  Result := '';
  if (Sign = '*') then Sign := '';
  if (Color = 'Life') then S := UI.Icon(icLife);
  if (Color = 'Mana') then S := UI.Icon(icMana);
  if (Color = 'Food') then S := UI.Icon(icFood);
  if (Color = 'Poison') then S := UI.Icon(icDrop);
  if (Color = 'Vision') then S := UI.Icon(icVision);
  if (RareColor <> '') then Color := 'Rare';
  if (Value > 0) then
    Result := Terminal.Colorize(Format('%s%s%d', [S, Sign, Value]), Color);
end;

function TItems.RenderInvItem(const AX, AY, I: Integer; AItem: Item;
  IsAdvInfo: Boolean = False; IsRender: Boolean = True;
  PriceType: TPriceType = ptNone): string;
var
  S: string;
  D: TItemBase;
  RepairCost: Word;

const
  T = '------';
  L = Length(T) + 1;

  function GetRedPrice(Price: Word): string;
  begin
    Result := Terminal.Colorize(UI.Icon(icGold) + IntToStr(Price), 'Light Red');
  end;

begin
  Result := '';
  D := ItemBase[TItemEnum(AItem.ItemID)];
  Terminal.Print(AX - 4, AY + I, UI.KeyToStr(Chr(I + Ord('A')), '',
    Game.IfThen(AItem.Equipment > 0, 'Equip', 'Key')));

  if IsRender then
  begin
    Terminal.ForegroundColor(AItem.Color);
    Terminal.Print(AX, AY + I, D.Symbol);
  end
  else
    Result := Result + D.Symbol + ' ';

  Terminal.ForegroundColor(clLightGray);
  if (IsAdvInfo and (Game.Timer = 0)) then
  begin
    S := '';
    if (D.SlotType <> stNone) and (AItem.Equipment > 0) then
      S := GetSlotName(D.SlotType);
  end;
  if (S <> '') then
    S := Items.GetItemInfo(AItem) + ' ' + S
  else
    S := Trim(Items.GetItemInfo(AItem));

  if IsRender then
  begin
    Terminal.Print(AX + 2, AY + I, S);
    S := '';
    case PriceType of
      ptSell:
        begin
          S := T;
          if ((AItem.Price > 1) and not ChItem(AItem)) then
          begin
            S := GetPrice(AItem.Price div 4, True);
            if (AItem.Equipment > 0) then
              S := GetRedPrice(AItem.Price div 4);
          end;
        end;
      ptBuy:
        begin
          S := GetPrice(AItem.Price);
        end;
      ptRepair:
        begin
          S := T;
          if ((AItem.Stack = 1) and (AItem.Amount = 1)) then
          begin
            RepairCost := (AItem.MaxDurability - AItem.Durability) * 10;
            if (RepairCost > 0) then
              S := GetPrice(RepairCost);
          end;
        end;
    end;
    if Game.Timer > 0 then
      Terminal.Print(Status.Left - L, AY + I, S)
    else
      Terminal.Print(Screen.Width - L, AY + I, S);
  end
  else
    Result := Result + S;
end;

function TItems.GetBonus(const AItem: Item; const BonusType: TBonusType): Byte;
begin
  case BonusType of
    btLife:
      Result := Byte(AItem.Bonus shr 24);
    btMana:
      Result := Byte(AItem.Bonus shr 16);
    btVision:
      Result := Byte(AItem.Bonus shr 8);
    btNN:
      Result := Byte(AItem.Bonus);
    else
      Result := 0;
  end;
end;

procedure TItems.SetBonus(var AItem: Item; const BonusType: TBonusType;
  const Value: Byte);
var
  V: array[0..3] of Byte;
begin
  V[0] := GetBonus(AItem, btLife);
  V[1] := GetBonus(AItem, btMana);
  V[2] := GetBonus(AItem, btVision);
  V[3] := GetBonus(AItem, btNN);

  case BonusType of
    btLife:
      V[0] := Value;
    btMana:
      V[1] := Value;
    btVision:
      V[2] := Value;
    btNN:
      V[3] := Value;
  end;
  AItem.Bonus := (V[0] shl 24) or (V[1] shl 16) or (V[2] shl 8) or V[3];
end;

function TItems.AddItemInfo(V: array of string): string;
var
  I: Byte;
begin
  Result := '';
  for I := 0 to Length(V) - 1 do
    Result := Result + V[I] + ' ';
  Result := Trim(Result);
  if (Result <> '') then
    Result := '[[' + Result + ']]';
end;

procedure TItems.AddItemToDungeon(AItem: Item);
var
  FItem: Item;
  I, FCount: Integer;
begin
  // Add an item
  Items_Dungeon_AppendItem(AItem);
  // Sort all items on the tile
  FCount := Items_Dungeon_GetMapCountXY(AItem.MapID, AItem.X, AItem.Y);
  if (FCount = 1) then Exit;
  for I := 0 to FCount - 1 do
  begin
    FItem := Items_Dungeon_GetMapItemXY(AItem.MapID, I, AItem.X, AItem.Y);
    if (ItemBase[TItemEnum(FItem.ItemID)].ItemType in CorpseTypeItems) then
      if (Items_Dungeon_DeleteMapItemXY(AItem.MapID, I, AItem.X, AItem.Y, FItem) > 0) then
        Items_Dungeon_AppendItem(FItem);
  end;
end;

procedure TItems.AddItemToInv(AItemEnum: TItemEnum; AAmount: Word = 1;
  EqFlag: Boolean = False; IdFlag: Boolean = False);
var
  FItem: Item;
begin
  if (AAmount = 0) then
    Exit;
  Make(Ord(AItemEnum), FItem);
  FItem.Amount := AAmount;
  FItem.Equipment := IfThen(EqFlag, 1, 0);
  if IdFlag and (FItem.Identify = 0) then
    Items.Identify(FItem, True);
  Items_Inventory_AppendItem(FItem);
end;

procedure TItems.AddItemToInv(Index: Integer = 0; AFlag: Boolean = False);
var
  FItem: Item;
  MapID: Integer;
begin
  MapID := Ord(Map.Current);
  FItem := Items_Dungeon_GetMapItemXY(MapID, Index, Player.X, Player.Y);
  if (FItem.Stack > 1) and (FItem.Amount > 1) and not AFlag then
  begin
    Player.SetAmountScene(False, Index, FItem.Amount);
    Exit;
  end;
  if (Items_Dungeon_DeleteMapItemXY(MapID, Index, Player.X, Player.Y, FItem) > 0)
  then
  begin
    Items_Inventory_AppendItem(FItem);
    if (FItem.Amount = 1) then
      MsgLog.Add(Format(_('You picked up %s.'), [Items.GetNameThe(FItem)]))
    else
      MsgLog.Add(Format(_('You picked up %s (%dx).'), [Items.GetNameThe(FItem), FItem.Amount]));
    Player.Wait;
    Player.Calc;
  end;
end;

function TItems.GetInventory: string;
var
  SL: TStringList;
  I, FCount: Integer;
  FItem: Item;
begin
  Result := '';
  SL := TStringList.Create;
  try
    FCount := EnsureRange(Items_Inventory_GetCount(), 0, ItemMax);
    for I := 0 to FCount - 1 do
    begin
      FItem := Items_Inventory_GetItem(I);
      SL.Append(Items.RenderInvItem(5, 2, I, FItem, True, False));
    end;
    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

function TItems.GetItemEnum(AItemID: Integer): TItemEnum;
begin
  Result := TItemEnum(AItemID);
end;

procedure TItems.LootGold(const AX, AY: Byte);
begin
  Loot(AX, AY, iGold);
  if (Math.RandomRange(0, 4) = 0) then
  begin
    X := Map.EnsureRange(AX + (Math.RandomRange(0, 3) - 1));
    Y := Map.EnsureRange(AY + (Math.RandomRange(0, 3) - 1));
    if (Map.GetTileEnum(X, Y, Map.Current) in SpawnTiles) then
      Loot(X, Y, iGold);
  end;
end;

procedure TItems.RenderInventory(PriceType: TPriceType = ptNone);
var
  I, FCount: Integer;
begin
  FCount := EnsureRange(Items_Inventory_GetCount(), 0, ItemMax);
  for I := 0 to FCount - 1 do
    Items.RenderInvItem(5, 2, I, Items_Inventory_GetItem(I), True, True,
      PriceType);
end;

function TItems.Identify(var AItem: Item; IsNew: Boolean = False): Boolean;
var
  I: Byte;
  IB: TItemBase;
  SB: TSuffixBase;
begin
  Result := False;
  if (AItem.Identify = 0) then
  begin
    IB := ItemBase[TItemEnum(AItem.ItemID)];
    repeat
      // Random suffix
      I := Math.RandomRange(1, Ord(High(TSuffixEnum)) + 1);
      SB := SuffixBase[TSuffixEnum(I)];
      // Level
      if ((IB.Level < SB.Level.Min) or (IB.Level > SB.Level.Max)) then Continue;
      //
      if not (IB.ItemType in SB.Occurence) then Continue;
      //
      AItem.Identify := I;
      Affixes.DoSuffix(AItem);
      if IsNew then
      begin
        AItem.Durability := AItem.MaxDurability;
      end;
    until (AItem.Identify > 0);
    Result := True;
  end;
end;

function TItems.GetName(AItem: Item; IsShort: Boolean = False): string;
var
  N, S: string;
begin
  N := GetName(TItemEnum(AItem.ItemID));
  case AItem.Identify of
    0:
      begin
        if IsShort then
          S := '' else
          S := ' [[' + _('Unidentified') + ']]';
        Result := Terminal.Colorize(N + S,
        'Unidentified');
      end;
    1 .. High(Byte):
      Result := Terminal.Colorize
        (N + Affixes.GetSuffixName(TSuffixEnum(AItem.Identify)),
        'Rare');
    else
      Result := N;
  end;
end;

function TItems.GetNameThe(AItem: Item): string;
begin
  Result := GetDescThe(GetPureText(Items.GetName(AItem, True)));
end;

procedure TItems.DelCorpses;
var
  I: Integer;
  M: TMapEnum;
  FItem: Item;
begin
  for M := Low(TMapEnum) to High(TMapEnum) do
  begin
    if (M = Map.Current) then Continue;
    for I := Items_Dungeon_GetMapCount(Ord(M)) - 1 downto 0 do
    begin
      FItem := Items_Dungeon_GetMapItem(Ord(M), I);
      if (ItemBase[TItemEnum(FItem.ItemID)].ItemType in CorpseTypeItems
        + FoodTypeItems) then
        if (Items_Dungeon_DeleteMapItem(Ord(M), I, FItem) > 0) then Continue;
    end;
  end;
end;

procedure TItems.AddPlants;
var
  I, FCount: Integer;
  M: TMapEnum;
  FItem: Item;
begin
  for M := Low(TMapEnum) to High(TMapEnum) do
  begin
    FCount := Items_Dungeon_GetMapCount(Ord(M));
    for I := 0 to FCount - 1 do
    begin
      FItem := Items_Dungeon_GetMapItem(Ord(M), I);
      if (ItemBase[TItemEnum(FItem.ItemID)].ItemType in PlantTypeItems) then
      begin
        X := FItem.X + Math.RandomRange(0, 2);
        Y := FItem.Y + Math.RandomRange(0, 2);
        if (Map.InMap(X, Y) and (Map.GetTileEnum(X, Y, M) in SpawnTiles) and
          (M in ItemBase[TItemEnum(FItem.ItemID)].Deep)) then
          Loot(X, Y, TItemEnum(FItem.ItemID));
      end;
    end;
  end;
end;

initialization

Items := TItems.Create;

finalization

FreeAndNil(Items);

end.
