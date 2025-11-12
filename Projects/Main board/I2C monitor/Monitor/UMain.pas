unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComDrv32, ExtCtrls, UTypes, UGeneral;

type
  TOnDataItem=procedure (Sender:TObject;Value:TString) of object;

  TI2CStateMachine=class(TJSBObject)
  private
    CurrentClock,CurrentData:TBoolean;
    ClockIndex:TInteger;
    DataByte:TByte;
    Receiving:TBoolean;
  public
    OnDataItem:TOnDataItem;
    constructor Create; override;
    destructor Destroy; override;
    procedure Initialize;
    procedure Process(Clock,Data:TBoolean);
  end;

  TMain = class(TForm)
    RawDataControl: TMemo;
    Panel1: TPanel;
    GoButton: TButton;
    ClearButton: TButton;
    ProcessedDataControl: TMemo;
    ParseAgainButton: TButton;
    procedure GoButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure ParseAgainButtonClick(Sender: TObject);
  private
    CommPortDriver:TCommPortDriver;
    I2CStateMachine:TI2CStateMachine;
    Total:TString;
    procedure Parse(Value:TString);
    procedure ReceiveData(Sender:TObject;DataPtr:Pointer;DataSize:LongWord);
    procedure OnDataItem(Sender:TObject;Value:TString);
  public
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

///////////////////////////////////////////////////////////////////////////////

constructor TI2CStateMachine.Create;
begin
  inherited;
end;

destructor TI2CStateMachine.Destroy;
begin
  inherited;
end;

procedure TI2CStateMachine.Initialize;
begin
  CurrentClock:=True;
  CurrentData:=True;
  Receiving:=False;
end;

procedure TI2CStateMachine.Process(Clock,Data:TBoolean);
begin
  if (CurrentClock=True) and (Clock=True) and (CurrentData=True) and (Data=False) then
  begin
    if Receiving then
    begin
      OnDataItem(Self,'Restart');
      ClockIndex:=0;
      DataByte:=0;
    end
    else
    begin
      OnDataItem(Self,'Start');
      Receiving:=True;
      ClockIndex:=0;
      DataByte:=0;
    end;
  end
  else
  begin
    if Receiving and (CurrentClock=True) and (Clock=True) and (CurrentData=False) and (Data=True) then
    begin
      OnDataItem(Self,'Stop');
      Receiving:=False;
    end
    // Read data on rising edge of clock as it started changing on the falling edge and should be stable by now.
    // Reading on the falling edge risks the data changing slightly before the clock falls when unequal Data and Clock
    // delays are present.
    else if (CurrentClock=False) and (Clock=True) then
    begin
      if Receiving then
      begin
        Inc(ClockIndex);
        if ClockIndex<=8 then
        begin
          DataByte:=DataByte shl 1;
          if Data=True then
            DataByte:=DataByte or 1;
        end
        else 
        begin
          OnDataItem(Self,ByteToHexString(DataByte));

          if Data=True then
            OnDataItem(Self,'Nack')
          else
            OnDataItem(Self,'Ack');

          ClockIndex:=0;
          DataByte:=0;
        end;
      end;
    end;
  end;
  
  CurrentClock:=Clock;
  CurrentData:=Data;
end;

///////////////////////////////////////////////////////////////////////////////

procedure TMain.FormCreate(Sender: TObject);
begin
  CommPortDriver:=TCommPortDriver.Create(Self);
  I2CStateMachine:=TI2CStateMachine.Create;
  I2CStateMachine.OnDataItem:=OnDataItem;
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(CommPortDriver);
  FreeAndNil(I2CStateMachine);
end;

procedure TMain.GoButtonClick(Sender: TObject);
begin
  CommPortDriver.ComPort:=pnCOM3;
  CommPortDriver.ComPortSpeed:=br115200;
  CommPortDriver.ComPortDataBits:=db8BITS;
  CommPortDriver.ComPortHwHandshaking:=hhNONE;
  CommPortDriver.ComPortParity:=ptNONE;
  CommPortDriver.ComPortStopBits:=sb1BITS;
  CommPortDriver.ComPortSwHandshaking:=shNONE;
  CommPortDriver.OnReceiveData:=ReceiveData;
  CommPortDriver.Connect;
  I2CStateMachine.Initialize;
end;

procedure TMain.Parse(Value:TString);
var
  Index:TInteger;
begin
  for Index:=1 to Length(Value) do
  begin
    case Value[Index] of
      '0': I2CStateMachine.Process(False,False);
      '1': I2CStateMachine.Process(True,False);
      '2': I2CStateMachine.Process(False,True);
      '3': I2CStateMachine.Process(True,True);
    end;
  end;
end;

procedure TMain.ReceiveData(Sender:TObject;DataPtr:Pointer;DataSize:LongWord);
var
  pData:PChar;
  S:TString;
begin
  CommPortDriver.PausePolling;

  S:='';
  pData:=DataPtr;
  while DataSize>0 do
  begin
    S:=S+pData^;
    Dec(DataSize);
    Inc(pData);
  end;

  RawDataControl.Lines.Add(S);

  Parse(S);

  Total:=Total+S;

  RawDataControl.Update;

  CommPortDriver.ContinuePolling;
end;

procedure TMain.ClearButtonClick(Sender: TObject);
begin
  RawDataControl.Clear;
  ProcessedDataControl.Clear;
  I2CStateMachine.Initialize;
  Total:='';
end;

procedure TMain.OnDataItem(Sender:TObject;Value:TString);
begin
  ProcessedDataControl.Lines.Add(Value);
end;

procedure TMain.ParseAgainButtonClick(Sender: TObject);
begin
  ProcessedDataControl.Clear;
  I2CStateMachine.Initialize;
  Parse(Total);
end;

///////////////////////////////////////////////////////////////////////////////

end.

