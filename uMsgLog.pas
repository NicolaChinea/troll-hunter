unit uMsgLog;

interface

uses
  Classes;

type
  TMsgLog = class(TObject)
  private
    FMsg: string;
    FLog: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render;
    procedure Clear;
    procedure Add(S: string);
    procedure Turn;
    property Msg: string read FMsg;
  end;

var
  MsgLog: TMsgLog = nil;

implementation

uses SysUtils, uCommon, uTerminal, BearLibTerminal;

{ TMsgLog }

procedure TMsgLog.Add(S: string);
begin
  if (Trim(S) <> '') then
    FMsg := FMsg + ' ' + S;
end;

procedure TMsgLog.Clear;
begin
  FMsg := '';
  FLog.Clear;
end;

constructor TMsgLog.Create;
begin
  FLog := TStringList.Create;
  Self.Clear;
end;

destructor TMsgLog.Destroy;
begin
  FLog.Free;
  FLog := nil;
  inherited;
end;

procedure TMsgLog.Render;
var
  L: string;
begin
  if (Trim(MsgLog.Msg) = '') then
    L := '' else L := '[color=green]' + FMsg + '[/color]';
  Terminal.ForegroundColor(clGray);
  Terminal.Print(Log.Left, Log.Top,
  Log.Width, Log.Height, FLog.Text + L,
  TK_ALIGN_BOTTOM);
end;

procedure TMsgLog.Turn;
begin
  if (Trim(MsgLog.Msg) = '') then Exit;
  FLog.Append(FMsg);
  FMsg := '';
end;

initialization
  MsgLog := TMsgLog.Create;

finalization
  MsgLog.Free;
  MsgLog := nil;

end.
