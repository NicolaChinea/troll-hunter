unit uCalendar;

interface

type
  TCalendar = class(TObject)
  private
    FMinute: Byte;
    FHour: Byte;
    FDay: Byte;
    FDayOfWeek: Byte;
    FMonth: Byte;
    FYear: Word;
  public
    constructor Create(const ADay, AMonth: Byte; const AYear: Word);
    property Minute: Byte read FMinute;
    property Hour: Byte read FHour;
    property Day: Byte read FDay;
    property DayOfWeek: Byte read FDayOfWeek;
    property Month: Byte read FMonth;
    property Year: Word read FYear;
    function DaysPerMonth(AMonth: Byte): Byte;
    function DaysThisMonth(): Byte;
    function GetMonthName(AMonth: Byte = 0): string;
    function GetDayName(): string;
    function GetTime(): string;
    function GetTimeStr(): string;
    procedure OnHour();
    procedure OnDay();
    procedure OnWeek();
    procedure OnMonth();
    procedure OnYear();
    procedure Turn();
  end;

var
  Calendar: TCalendar;

implementation

uses SysUtils, Math, uLanguage, uItem, uShop;

{ TCalendar }

constructor TCalendar.Create(const ADay, AMonth: Byte; const AYear: Word);
begin
  Randomize();
  FMinute := Math.RandomRange(0, 60);
  FHour := Math.RandomRange(9, 18);
  FDay := ADay;
  FDayOfWeek := ADay;
  FMonth := AMonth;
  FYear := AYear;
end;

function TCalendar.DaysPerMonth(AMonth: Byte): Byte;
const
  DaysInMonth: array [1 .. 12] of Integer = (31, 28, 31, 30, 31, 30, 31, 31, 30,
    31, 30, 31);
begin
  Result := DaysInMonth[AMonth];
end;

function TCalendar.DaysThisMonth(): Byte;
begin
  Result := DaysPerMonth(Month)
end;

function TCalendar.GetDayName(): string;
const
  DayName: array [1..7] of string = (
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
begin
  Result := DayName[DayOfWeek];
end;

function TCalendar.GetMonthName(AMonth: Byte): string;
const
  MonthName: array [1..12] of string = ('January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August', 'September', 'October', 'November',
    'December');
begin
  if (AMonth = 0) then
    AMonth := FMonth;
  Result := MonthName[AMonth];
end;

function TCalendar.GetTime(): string;
begin
  Result := Format('%d:%d', [Hour, Minute]);
end;

function TCalendar.GetTimeStr(): string;
begin
  case Hour of
    6 .. 8:
      Result := _('Morning');
    9 .. 18:
      Result := _('Day');
    19 .. 21:
      Result := _('Evening');
  else
    Result := _('Night');
  end;
end;

procedure TCalendar.OnDay();
begin

end;

procedure TCalendar.OnHour();
begin
  //Game.Log('Hour');
end;

procedure TCalendar.OnMonth();
begin

end;

procedure TCalendar.OnWeek();
begin
  Shops.New();
  Items.DelCorpses();
  Items.AddPlants();
end;

procedure TCalendar.OnYear();
begin

end;

procedure TCalendar.Turn();
begin
  Inc(FMinute);
  if (Minute > SysUtils.MinsPerHour - 1) then
  begin
    FMinute := Minute - SysUtils.MinsPerHour;
    Inc(FHour);
    OnHour();
  end;
  if (Hour > SysUtils.HoursPerDay - 1) then
  begin
    FHour := 0;
    Inc(FDay);
    Inc(FDayOfWeek);
    OnDay();
  end;
  if (DayOfWeek > 7) then
  begin
    FDayOfWeek := 1;
    OnWeek();
  end;
  if (Day > DaysThisMonth) then
  begin
    FDay := 1;
    Inc(FMonth);
    OnMonth();
  end;
  if (Month > 12) then
  begin
    FMonth := 1;
    Inc(FYear);
    OnYear();
  end;
end;

initialization

Calendar := TCalendar.Create(1, 1, 1297);

finalization

FreeAndNil(Calendar);

end.
