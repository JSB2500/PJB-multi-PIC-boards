{
  +-----------------------------------------------------------------------------
  |
  | ComDrv32.pas (see ComDrv16.pas for Delphi 1.0)
  |
  | TCommPortDriver component
  | COM Port Driver for Delphi 2.0
  | v1.08/32 - November 19th, 1997
  |
  | Written by Marco Cocco
  | Copyright (c) 1996-97 by Marco Cocco. All rights reseved.
  | Copyright (c) 1996-97 by d3k The Artisan Of Ware. All rights reseved.
  |
  | Please send comments to d3k@mdnet.it
  | URL: http://www.mdlive.com/d3k/
  |
  +-----------------------------------------------------------------------------

  ******************************************************************************
  *   Permission to use, copy,  modify, and distribute this software and its   *
  *        documentation without fee for any purpose is hereby granted,        *
  *   provided that the above copyright notice appears on all copies and that  *
  *     both that copyright notice and this permission notice appear in all    *
  *                         supporting documentation.                          *
  *                                                                            *
  * NO REPRESENTATIONS ARE MADE ABOUT THE SUITABILITY OF THIS SOFTWARE FOR ANY *
  *    PURPOSE. IT IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED WARRANTY.    *
  *   NEITHER MARCO COCCO OR D3K SHALL BE LIABLE FOR ANY DAMAGES SUFFERED BY   *
  *                          THE USE OF THIS SOFTWARE.                         *
  ******************************************************************************
  *          d3k - The Artisan Of Ware - A Marco Cocco's Company               *
  *           Casella Postale 99 - 09047 Selargius (CA) - ITALY                *
  *       Tel. +39 70 846091 (Italian speaking)   Fax +39 70 848331            *
  *     E-mail: d3k@mdnet.it    Home page: http://www.mdlive.com/d3k/          *
  ******************************************************************************
}

unit ComDrv32;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms;

type
  { COM Port Baud Rates }
  TComPortBaudRate = ( br110, br300, br600, br1200, br2400, br4800,
                       br9600, br14400, br19200, br38400, br56000,
                       br57600, br115200 );
  { COM Port Numbers }
  TComPortNumber = ( pnCOM1, pnCOM2, pnCOM3, pnCOM4, pnCOM5, pnCOM6, pnCOM7,
                     pnCOM8, pnCOM9, pnCOM10, pnCOM11, pnCOM12, pnCOM13,
                     pnCOM14, pnCOM15, pnCOM16 );
  { COM Port Data bits }
  TComPortDataBits = ( db5BITS, db6BITS, db7BITS, db8BITS );
  { COM Port Stop bits }
  TComPortStopBits = ( sb1BITS, sb1HALFBITS, sb2BITS );
  { COM Port Parity }
  TComPortParity = ( ptNONE, ptODD, ptEVEN, ptMARK, ptSPACE );
  { COM Port Hardware Handshaking }
  TComPortHwHandshaking = ( hhNONE, hhNONERTSON, hhRTSCTS );
  { COM Port Software Handshaing }
  TComPortSwHandshaking = ( shNONE, shXONXOFF );
  { What to do with incomplete (incoming) packets }
  TPacketMode = ( pmDiscard, pmPass );

  TComPortReceiveDataEvent = procedure( Sender: TObject; DataPtr: pointer; DataSize: UINT ) of object;
  TComPortReceivePacketEvent = procedure( Sender: TObject; Packet: pointer; DataSize: UINT ) of object;

  TComPortLineStatus = ( lsCTS, lsDSR, lsRING, lsRLSD{CD} );
  TComPortLineStatusSet = set of TComPortLineStatus;

  TCommPortDriver = class(TComponent)
  protected
    { COM Port Device Handle }
    FComPortHandle             : THANDLE;
    { # of the COM Port to use }
    FComPort                   : TComPortNumber;
    { COM Port speed (brXXX) }
    FComPortBaudRate           : TComPortBaudRate;
    { Data bits size (dbXXX) }
    FComPortDataBits           : TComPortDataBits;
    { How many stop bits to use (sbXXX) }
    FComPortStopBits           : TComPortStopBits;
    { Type of parity to use (ptXXX) }
    FComPortParity             : TComPortParity;
    { Type of hw handshaking (hw flow control) to use (hhXXX) }
    FComPortHwHandshaking      : TComPortHwHandshaking;
    { Type of sw handshaking (sw flow control) to use (shXXX) }
    FComPortSwHandshaking      : TComPortSwHandshaking;
    { Size of the input buffer }
    FComPortInBufSize          : word;
    { Size of the output buffer }
    FComPortOutBufSize         : word;
    { Size of a data packet }
    FPacketSize                : smallint;
    { ms to wait for a complete packet (<=0 = disabled) }
    FPacketTimeout             : integer;
    { What to do with incomplete packets (pmXXX) }
    FPacketMode                : TPacketMode;
    { Event to raise on data reception (asynchronous) }
    FComPortReceiveData        : TComPortReceiveDataEvent;
    { Event to raise on packet reception (asynchronous) }
    FComPortReceivePacket      : TComPortReceivePacketEvent;
    { ms of delay between COM port pollings }
    FComPortPollingDelay       : word;
    { Specifies if the DTR line must be enabled/disabled on connect }
    FEnableDTROnOpen           : boolean;
    { Output timeout - milliseconds }
    FOutputTimeout             : word;
    { Timeout for ReadData }
    FInputTimeout              : UINT;
    { Set to TRUE to prevent hangs when no device connected or
      device is OFF }
    FCkLineStatus              : boolean;
    { This is used for the timer }
    FNotifyWnd                 : HWND;
    { Temporary buffer (RX) - used internally }
    FTempInBuffer              : pointer;
    { Time of the first byte of current RX packet }
    FFirstByteOfPacketTime     : DWORD;
    { Number of RX polling timer pauses }
    FRXPollingPauses: integer;

    { Sets the COM port handle }
    procedure SetComHandle( Value: THANDLE );
    { Selects the COM port to use }
    procedure SetComPort( Value: TComPortNumber );
    { Selects the baud rate }
    procedure SetComPortBaudRate( Value: TComPortBaudRate );
    { Selects the number of data bits }
    procedure SetComPortDataBits( Value: TComPortDataBits );
    { Selects the number of stop bits }
    procedure SetComPortStopBits( Value: TComPortStopBits );
    { Selects the kind of parity }
    procedure SetComPortParity( Value: TComPortParity );
    { Selects the kind of hardware flow control }
    procedure SetComPortHwHandshaking( Value: TComPortHwHandshaking );
    { Selects the kind of software flow control }
    procedure SetComPortSwHandshaking( Value: TComPortSwHandshaking );
    { Sets the RX buffer size }
    procedure SetComPortInBufSize( Value: word );
    { Sets the TX buffer size }
    procedure SetComPortOutBufSize( Value: word );
    { Sets the size of incoming packets }
    procedure SetPacketSize( Value: smallint );
    { Sets the timeout for incoming packets }
    procedure SetPacketTimeout( Value: integer );
    { Sets the delay between polling checks }
    procedure SetComPortPollingDelay( Value: word );
    { Applies current settings to open COM port }
    procedure ApplyCOMSettings;
    { Polling proc }
    procedure TimerWndProc( var msg: TMessage );
  public
    { Constructor }
    constructor Create( AOwner: TComponent ); override;
    { Destructor }
    destructor Destroy; override;

    { Opens the COM port and takes of it. Returns false if something
      goes wrong. }
    function Connect: boolean;
    { Closes the COM port and releases control of it }
    procedure Disconnect;
    { Returns true if COM port has been opened }
    function Connected: boolean;
    { Returns the current state of CTS, DSR, RING and RLSD (CD) lines.
      The function fails if the hardware does not support the control-register
      values (that is, returned set is always empty). }
    function GetLineStatus: TComPortLineStatusSet;
    { Returns true if polling has not been paused }
    function IsPolling: boolean;
    { Pauses polling }
    procedure PausePolling;
    { Re-starts polling (after pause) }
    procedure ContinuePolling;
    { Flushes the rx/tx buffers }
    procedure FlushBuffers( inBuf, outBuf: boolean );
    { Returns number of received bytes in the RX buffer }
    function CountRX: integer;
    { Returns the output buffer free space or 65535 if not connected }
    function OutFreeSpace: word;
    { Sends binary data }
    function SendData( DataPtr: pointer; DataSize: UINT ): UINT;
    { Sends binary data. Returns number of bytes sent. Timeout overrides
      the value specifiend in the OutputTimeout property }
    function SendDataEx( DataPtr: pchar; DataSize, Timeout: UINT ): UINT;
    { Sends a byte. Returns true if the byte has been sent }
    function SendByte( Value: byte ): boolean;
    { Sends a char. Returns true if the char has been sent }
    function SendChar( Value: char ): boolean;
    { Sends a pascal string (NULL terminated if $H+ (default)) }
    function SendString( s: string ): boolean;
    { Sends a C-style strings (NULL terminated) }
    function SendZString( s: pchar ): boolean;
    { Reads binary data. Returns number of bytes read }
    function ReadData( DataPtr: pchar; MaxDataSize: UINT ): UINT;
    { Reads a byte. Returns true if the byte has been read }
    function ReadByte( var Value: byte ): boolean;
    { Reads a char. Returns true if char has been read }
    function ReadChar( var Value: char ): boolean;
    { Set DTR line high (onOff=TRUE) or low (onOff=FALSE).
      You must not use HW handshaking. }
    procedure ToggleDTR( onOff: boolean );
    { Set RTS line high (onOff=TRUE) or low (onOff=FALSE).
      You must not use HW handshaking. }
    procedure ToggleRTS( onOff: boolean );

    { Make the Handle of the COM port public (for TAPI...) [read/write] }
    property ComHandle: THANDLE read FComPortHandle write SetComHandle;
  published
    { # of the COM Port to use }
    property ComPort: TComPortNumber read FComPort write SetComPort default pnCOM2;
    { COM Port speed (bauds) }
    property ComPortSpeed: TComPortBaudRate read FComPortBaudRate write SetComPortBaudRate default br9600;
    { Data bits to used (5..8, for the 8250 the use of 5 data bits with 2 stop
      bits is an invalid combination, as is 6, 7, or 8 data bits with 1.5 stop
      bits) }
    property ComPortDataBits: TComPortDataBits read FComPortDataBits write SetComPortDataBits default db8BITS;
    { Stop bits to use (1, 1.5, 2) }
    property ComPortStopBits: TComPortStopBits read FComPortStopBits write SetComPortStopBits default sb1BITS;
    { Kind of Parity to use (none,odd,even,mark,space) }
    property ComPortParity: TComPortParity read FComPortParity write SetComPortParity default ptNONE;
    { Kind of Hardware Handshaking to use:
        hhNONE          no handshaking
        hhNONERTSON     no handshaking but keep RTS line on
        hhCTSRTS        RTS/CTS }
    property ComPortHwHandshaking: TComPortHwHandshaking
             read FComPortHwHandshaking write SetComPortHwHandshaking default hhNONERTSON;
    { Kind of Software Handshaking to use:
        shNONE          no handshaking
        shXONXOFF       XON/XOFF handshaking }
    property ComPortSwHandshaking: TComPortSwHandshaking
             read FComPortSwHandshaking write SetComPortSwHandshaking default shNONE;
    { Input Buffer size }
    property ComPortInBufSize: word read FComPortInBufSize write SetComPortInBufSize default 2048;
    { Output Buffer size }
    property ComPortOutBufSize: word read FComPortOutBufSize write SetComPortOutBufSize default 2048;
    { RX packet size (this value must be less than ComPortInBufSize) }
    property PacketSize: smallint read FPacketSize write SetPacketSize default -1;
    { Timeout (ms) for a complete packet (in RX) }
    property PacketTimeout: integer read FPacketTimeout write SetPacketTimeout default -1;
    { What to do with incomplete packets (in RX) }
    property PacketMode: TPacketMode read FPacketMode write FPacketMode default pmDiscard;
    { ms of delay between COM port pollings }
    property ComPortPollingDelay: word read FComPortPollingDelay write SetComPortPollingDelay default 50;
    { Set to TRUE to enable DTR line on connect and to leave it on until disconnect.
      Set to FALSE to disable DTR line on connect. }
    property EnableDTROnOpen: boolean read FEnableDTROnOpen write FEnableDTROnOpen default true;
    { Output timeout (milliseconds) }
    property OutputTimeout: word read FOutputTimeOut write FOutputTimeout default 500;
    { Input timeout (milliseconds) }
    property InputTimeout: UINT read FInputTimeOut write FInputTimeout default 200;
    { Set to TRUE to prevent hangs when not device connected or device is OFF }
    property CheckLineStatus: boolean read FCkLineStatus write FCkLineStatus default false;
    { Event to raise when there is data available (input buffer has data)
      (called only if PacketSize = 0) }
    property OnReceiveData: TComPortReceiveDataEvent read FComPortReceiveData write FComPortReceiveData;
    { Event to raise when there is data packet available (called only if PacketSize <> 0) }
    property OnReceivePacket: TComPortReceivePacketEvent read FComPortReceivePacket write FComPortReceivePacket;
  end;

function BaudRateOf( bRate: TComPortBaudRate ): integer;
function DelayForRX( bRate: TComPortBaudRate; DataSize: integer ): integer;

procedure Register;

implementation

{+-------------------------------------------------------------------------+
 | HELPER ROUTINES                                                         |
 +-------------------------------------------------------------------------+}

function GetWinPlatform: string;
var ov: TOSVERSIONINFO;
begin
  ov.dwOSVersionInfoSize := sizeof(ov);
  if GetVersionEx( ov ) then
  begin
    case ov.dwPlatformId of
      VER_PLATFORM_WIN32s: { Win32s on Windows 3.1 }
        Result := 'W32S';
      VER_PLATFORM_WIN32_WINDOWS: { Win32 on Windows 95 }
        Result := 'W95';
      VER_PLATFORM_WIN32_NT: {	Windows NT }
        Result := 'WNT';
    end;
  end
  else
    Result := '??';
end;

function GetWinVersion: UINT;
var ov: TOSVERSIONINFO;
begin
  ov.dwOSVersionInfoSize := sizeof(ov);
  if GetVersionEx( ov ) then
    Result := MAKELONG( ov.dwMinorVersion, ov.dwMajorVersion )
  else
    Result := $00000000;
end;

function BaudRateOf( bRate: TComPortBaudRate ): integer;
begin
  case bRate of
    br110    : Result := 110;
    br300    : Result := 300;
    br600    : Result := 600;
    br1200   : Result := 1200;
    br2400   : Result := 2400;
    br4800   : Result := 4800;
    br9600   : Result := 9600;
    br14400  : Result := 14400;
    br19200  : Result := 19200;
    br38400  : Result := 38400;
    br56000  : Result := 56000;
    br57600  : Result := 57600;
    else
    {br115200 :} Result := 115200;
  end;
end;

function DelayForRX( bRate: TComPortBaudRate; DataSize: integer ): integer;
begin
  Result := round( DataSize / (BaudRateOf(bRate) / 10) * 1000 );
end;

{+-------------------------------------------------------------------------+
 | TCOMMPORTDRIVER                                                         |
 +-------------------------------------------------------------------------+}

constructor TCommPortDriver.Create( AOwner: TComponent );
begin
  inherited Create( AOwner );
  { ** Initialize to default values *************************************** }
  { Not connected }
  FComPortHandle             := 0;
  { COM 2 }
  FComPort                   := pnCOM2;
  { 9600 bauds }
  FComPortBaudRate           := br9600;
  { 8 data bits }
  FComPortDataBits           := db8BITS;
  { 1 stop bit }
  FComPortStopBits           := sb1BITS;
  { no parity }
  FComPortParity             := ptNONE;
  { No hardware handshaking but RTS on }
  FComPortHwHandshaking      := hhNONERTSON;
  { No software handshaking }
  FComPortSwHandshaking      := shNONE;
  { Input buffer of 2048 bytes }
  FComPortInBufSize          := 2048;
  { Output buffer of 2048 bytes }
  FComPortOutBufSize         := 2048;
  { Don't pack data }
  FPacketSize                := -1;
  { Packet timeout disabled }
  FPacketTimeout             := -1;
  { Discard incomplete packets }
  FPacketMode                := pmDiscard;
  { Poll COM port every 50ms }
  FComPortPollingDelay       := 50;
  { Output timeout of 500ms } 
  FOutputTimeout             := 500;
  { Timeout for ReadData(), 200ms }
  FInputTimeout              := 200;
  { DTR high on connect }
  FEnableDTROnOpen           := true;
  { Time not valid }
  FFirstByteOfPacketTime     := DWORD(-1);
  { Don't check of off-line devices }
  FCkLineStatus              := false;
  { Init number of RX polling timer pauses - not paused }
  FRXPollingPauses := 0;
  { Temporary buffer for received data }
  GetMem( FTempInBuffer, FComPortInBufSize );
  { Allocate a window handle to catch timer's notification messages }
  if not (csDesigning in ComponentState) then
    FNotifyWnd := AllocateHWnd( TimerWndProc );
end;

destructor TCommPortDriver.Destroy;
begin
  { Be sure to release the COM port }
  Disconnect;
  { Free the temporary buffer }
  FreeMem( FTempInBuffer, FComPortInBufSize );
  { Destroy the timer's window }
  if not (csDesigning in ComponentState) then
    DeallocateHWnd( FNotifyWnd );
  inherited Destroy;
end;

{ The COM port handle made public and writeable.
  This lets you connect to external opened com port.
  Setting ComPortHandle to 0 acts as Disconnect. }
procedure TCommPortDriver.SetComHandle( Value: THANDLE );
begin
  { If same COM port then do nothing }
  if FComPortHandle = Value then
    exit;
  { If value is $FFFFFFFF then stop controlling the COM port
    without closing in }
  if Value = $FFFFFFFF then
  begin
    if Connected then
      { Stop the timer }
      if Connected then
        KillTimer( FNotifyWnd, 1 );
    { No more connected }
    FComPortHandle := 0;
  end
  else
  begin
    { Disconnect }
    Disconnect;
    { If Value is = 0 then exit now }
    { (ComPortHandle := 0 acts as Disconnect) }
    if Value = 0  then
      exit;

    { Set COM port handle }
    FComPortHandle := Value;

    { Start the timer (used for polling) }
    SetTimer( FNotifyWnd, 1, FComPortPollingDelay, nil );
  end;
end;

procedure TCommPortDriver.SetComPort( Value: TComPortNumber );
begin
  { Be sure we are not using any COM port }
  if Connected then
    exit;
  { Change COM port }
  FComPort := Value;
end;

procedure TCommPortDriver.SetComPortBaudRate( Value: TComPortBaudRate );
begin
  { Set new COM speed }
  FComPortBaudRate := Value;
  { Apply changes }
  if Connected then
    ApplyCOMSettings;
end;

procedure TCommPortDriver.SetComPortDataBits( Value: TComPortDataBits );
begin
  { Set new data bits }
  FComPortDataBits := Value;
  { Apply changes }
  if Connected then
    ApplyCOMSettings;
end;

procedure TCommPortDriver.SetComPortStopBits( Value: TComPortStopBits );
begin
  { Set new stop bits }
  FComPortStopBits := Value;
  { Apply changes }
  if Connected then
    ApplyCOMSettings;
end;

procedure TCommPortDriver.SetComPortParity( Value: TComPortParity );
begin
  { Set new parity }
  FComPortParity := Value;
  { Apply changes }
  if Connected then
    ApplyCOMSettings;
end;

procedure TCommPortDriver.SetComPortHwHandshaking( Value: TComPortHwHandshaking );
begin
  { Set new hardware handshaking }
  FComPortHwHandshaking := Value;
  { Apply changes }
  if Connected then
    ApplyCOMSettings;
end;

procedure TCommPortDriver.SetComPortSwHandshaking( Value: TComPortSwHandshaking );
begin
  { Set new software handshaking }
  FComPortSwHandshaking := Value;
  { Apply changes }
  if Connected then
    ApplyCOMSettings;
end;

procedure TCommPortDriver.SetComPortInBufSize( Value: word );
begin
  { Do nothing if connected }
  if Connected then
    exit;
  { Free the temporary input buffer }
  FreeMem( FTempInBuffer, FComPortInBufSize );
  { Set new input buffer size }
  FComPortInBufSize := Value;
  { Allocate the temporary input buffer }
  GetMem( FTempInBuffer, FComPortInBufSize );
  { Adjust the RX packet size }
  SetPacketSize( FPacketSize );
end;

procedure TCommPortDriver.SetComPortOutBufSize( Value: word );
begin
  { Do nothing if connected }
  if Connected then
    exit;
  { Set new output buffer size }
  FComPortOutBufSize := Value;
end;

procedure TCommPortDriver.SetPacketSize( Value: smallint );
begin
  { PackeSize = -1 if data isn't to be 'packetized' }
  if Value < 1 then
    Value := -1
  { If the PacketSize if greater than then RX buffer size then
    increase the RX buffer size }
  else if Word(Value) > FComPortInBufSize then
    FComPortInBufSize := Value * 2;
  FPacketSize := Value;
end;

procedure TCommPortDriver.SetPacketTimeout( Value: integer );
begin
  { PacketTimeout = -1 if packet timeout is to be disabled }
  if Value < 1 then
    Value := -1
  { PacketTimeout cannot be less than polling delay + some extra ms }
  else if Value < FComPortPollingDelay then
    Value := FComPortPollingDelay + 150;
  FPacketTimeout := Value;
end;

procedure TCommPortDriver.SetComPortPollingDelay( Value: word );
begin
  { If new delay is not equal to previous value... }
  if Value <> FComPortPollingDelay then
  begin
    { Stop the timer }
    if Connected then
      KillTimer( FNotifyWnd, 1 );
    { Store new delay value }
    FComPortPollingDelay := Value;
    { Restart the timer }
    if Connected then
      SetTimer( FNotifyWnd, 1, FComPortPollingDelay, nil );
    { Adjust the packet timeout }
    SetPacketTimeout( FPacketTimeout );
  end;
end;

const
  Win32BaudRates: array[br110..br115200] of DWORD =
    ( CBR_110, CBR_300, CBR_600, CBR_1200, CBR_2400, CBR_4800, CBR_9600,
      CBR_14400, CBR_19200, CBR_38400, CBR_56000, CBR_57600, CBR_115200
      {,CRB_128000, CBR_256000} );

const
  dcb_Binary              = $00000001;
  dcb_ParityCheck         = $00000002;
  dcb_OutxCtsFlow         = $00000004;
  dcb_OutxDsrFlow         = $00000008;
  dcb_DtrControlMask      = $00000030;
    dcb_DtrControlDisable   = $00000000;
    dcb_DtrControlEnable    = $00000010;
    dcb_DtrControlHandshake = $00000020;
  dcb_DsrSensivity        = $00000040;
  dcb_TXContinueOnXoff    = $00000080;
  dcb_OutX                = $00000100;
  dcb_InX                 = $00000200;
  dcb_ErrorChar           = $00000400;
  dcb_NullStrip           = $00000800;
  dcb_RtsControlMask      = $00003000;
    dcb_RtsControlDisable   = $00000000;
    dcb_RtsControlEnable    = $00001000;
    dcb_RtsControlHandshake = $00002000;
    dcb_RtsControlToggle    = $00003000;
  dcb_AbortOnError        = $00004000;
  dcb_Reserveds           = $FFFF8000;

{ Apply COM settings }
procedure TCommPortDriver.ApplyCOMSettings;
var dcb: TDCB;
begin
  { Do nothing if not connected }
  if not Connected then
    exit;

  { ** Setup dcb (Device Control Block) fields ****************************** }

  { Clear all }
  fillchar( dcb, sizeof(dcb), 0 );
  { dcb structure size }
  dcb.DCBLength := sizeof(dcb);
  { Baud rate to use }
  dcb.BaudRate := Win32BaudRates[ FComPortBaudRate ];
  { Set fBinary: Win32 does not support non binary mode transfers
    (also disable EOF check) }
  dcb.Flags := dcb_Binary;
  { Enables the DTR line when the device is opened and leaves it on }
  if EnableDTROnOpen then
    dcb.Flags := dcb.Flags or dcb_DtrControlEnable;
  { Kind of hw handshaking to use }
  case FComPortHwHandshaking of
    { No hardware handshaking }
    hhNONE:;
    { No hardware handshaking but set RTS high and leave it high }
    hhNONERTSON:
      dcb.Flags := dcb.Flags or dcb_RtsControlEnable;
    { RTS/CTS (request-to-send/clear-to-send) hardware handshaking }
    hhRTSCTS:
      dcb.Flags := dcb.Flags or dcb_OutxCtsFlow or dcb_RtsControlHandshake;
  end;
  { Kind of sw handshaking to use }
  case FComPortSwHandshaking of
    { No software handshaking }
    shNONE:;
    { XON/XOFF software handshaking }
    shXONXOFF:
      dcb.Flags := dcb.Flags or dcb_OutX or dcb_InX;
  end;
  { Set XONLim: specifies the minimum number of bytes allowed in the input
    buffer before the XON character is sent (or CTS is set). }
  if (GetWinPlatform = 'WNT') and (GetWinVersion >= $00040000) then
  begin
    { WinNT 4.0 + Service Pack 3 needs XONLim to be less than or
      equal to 4096 bytes. Win95 doesn't have such limit. }
    if FComPortInBufSize div 4 > 4096 then
      dcb.XONLim := 4096
    else
      dcb.XONLim := FComPortInBufSize div 4;
  end
  else
    dcb.XONLim := FComPortInBufSize div 4;
  { Specifies the maximum number of bytes allowed in the input buffer before
    the XOFF character is sent (or CTS is set low). The maximum number of bytes
    allowed is calculated by subtracting this value from the size, in bytes, of
    the input buffer. }
  dcb.XOFFLim := dcb.XONLim;
  { How many data bits to use }
  dcb.ByteSize := 5 + ord(FComPortDataBits);
  { Kind of parity to use }
  dcb.Parity := ord(FComPortParity);
  { How many stop bits to use }
  dcb.StopBits := ord(FComPortStopbits);
  { XON ASCII char - DC1, Ctrl-Q, ASCII 17}
  dcb.XONChar := #17;
  { XOFF ASCII char - DC3, Ctrl-S, ASCII 19}
  dcb.XOFFChar := #19;

  { Apply new settings }
  SetCommState( FComPortHandle, dcb );
  { Flush buffers }
  FlushBuffers( true, true );
  { Setup buffers size }
  SetupComm( FComPortHandle, FComPortInBufSize, FComPortOutBufSize );
end;

function TCommPortDriver.Connect: boolean;
var comName: string;
    tms: TCOMMTIMEOUTS;
begin
  { Do nothing if already connected }
  Result := Connected;
  if Result then
    exit;
  { Open the COM port }
  SysUtils.FmtStr( comName, '\\.\COM%-d', [1+ord(FComPort)] );
  FComPortHandle := CreateFile(
                                pchar(comName),
                                GENERIC_READ or GENERIC_WRITE,
                                0, { Not shared }
                                nil, { No security attributes }
                                OPEN_EXISTING,
                                FILE_ATTRIBUTE_NORMAL,
                                0 { No template }
                              ) ;
  Result := Connected;
  if not Result then
    exit;
  { Apply settings }
  ApplyCOMSettings;
  { Set ReadIntervalTimeout: Specifies the maximum time, in milliseconds,
    allowed to elapse between the arrival of two characters on the
    communications line.
    We disable timeouts because we are polling the com port! }
  tms.ReadIntervalTimeout := 1;
  { Set ReadTotalTimeoutMultiplier: Specifies the multiplier, in milliseconds,
    used to calculate the total time-out period for read operations. }
  tms.ReadTotalTimeoutMultiplier := 0;
  { Set ReadTotalTimeoutConstant: Specifies the constant, in milliseconds,
    used to calculate the total time-out period for read operations. }
  tms.ReadTotalTimeoutConstant := 1;
  { Set WriteTotalTimeoutMultiplier: Specifies the multiplier, in milliseconds,
    used to calculate the total time-out period for write operations. }
  tms.WriteTotalTimeoutMultiplier := 0;
  { Set WriteTotalTimeoutConstant: Specifies the constant, in milliseconds,
    used to calculate the total time-out period for write operations. } 
  tms.WriteTotalTimeoutConstant := 1;
  { Apply timeouts }
  SetCommTimeOuts( FComPortHandle, tms );
  { Start the timer (used for polling) }
  SetTimer( FNotifyWnd, 1, FComPortPollingDelay, nil );
end;

procedure TCommPortDriver.Disconnect;
begin
  if Connected then
  begin
    { Stop the timer (used for polling) }
    KillTimer( FNotifyWnd, 1 );
    { Release the COM port }
    CloseHandle( FComPortHandle );
    { No more connected }
    FComPortHandle := 0;
  end;
end;

{ Returns true if connected }
function TCommPortDriver.Connected: boolean;
begin
  Result := FComPortHandle > 0;
end;

{ Returns CTS, DSR, RING and RLSD (CD) signals status }
function TCommPortDriver.GetLineStatus: TComPortLineStatusSet;
var dwS: DWORD;
begin
  Result := [];
  if not Connected then
    exit;
  { Retrieves modem control-register values.
    The function fails if the hardware does not support the control-register
    values. }
  if not GetCommModemStatus( FComPortHandle, dwS ) then
    exit;
  if dwS and MS_CTS_ON <> 0 then Result := Result + [lsCTS];
  if dwS and MS_DSR_ON <> 0 then Result := Result + [lsDSR];
  if dwS and MS_RING_ON <> 0 then Result := Result + [lsRING];
  if dwS and MS_RLSD_ON <> 0 then Result := Result + [lsRLSD];
end;

{ Returns true if polling has not been paused }
function TCommPortDriver.IsPolling: boolean;
begin
  Result := FRXPollingPauses <= 0;
end;

{ Pauses polling }
procedure TCommPortDriver.PausePolling;
begin
  { Inc. RX polling pauses counter }
  inc( FRXPollingPauses );
end;

{ Re-starts polling (after pause) }
procedure TCommPortDriver.ContinuePolling;
begin
  { Dec. RX polling pauses counter }
  dec( FRXPollingPauses );
end;

{ Flush rx/tx buffers }
procedure TCommPortDriver.FlushBuffers( inBuf, outBuf: boolean );
var dwAction: DWORD;
begin
  { Do nothing if not connected }
  if not Connected then
    exit;
  { Flush the RX data buffer }
  dwAction := 0;
  if outBuf then
    dwAction := dwAction or PURGE_TXABORT or PURGE_TXCLEAR;
  { Flush the TX data buffer }
  if inBuf then
    dwAction := dwAction or PURGE_RXABORT or PURGE_RXCLEAR;
  PurgeComm( FComPortHandle, dwAction );
  { Used by the RX packet mechanism }
  FFirstByteOfPacketTime := DWORD(-1);
end;

{ Returns number of received bytes in the RX buffer }
function TCommPortDriver.CountRX: integer;
var stat: TCOMSTAT;
    errs: DWORD;
begin
  { Do nothing if port has not been opened }
  Result := 65535;
  if not Connected then
    exit;
  { Get count }
  ClearCommError( FComPortHandle, errs, @stat );
  Result := stat.cbInQue;
end;

{ Returns the output buffer free space or 65535 if not connected }
function TCommPortDriver.OutFreeSpace: word;
var stat: TCOMSTAT;
    errs: DWORD;
begin
  if not Connected then
    Result := 65535
  else
  begin
    ClearCommError( FComPortHandle, errs, @stat );
    Result := FComPortOutBufSize - stat.cbOutQue;
  end;
end;

{ Sends binary data. Returns number of bytes sent. Timeout overrides
  the value specifiend in the OutputTimeout property }
function TCommPortDriver.SendDataEx( DataPtr: pchar; DataSize, Timeout: UINT ): UINT;
var
  nToSend: integer;
  t1: longint;
  nSent:LongWord;
begin
  { Do nothing if port has not been opened }
  Result := 0;
  if not Connected then
    exit;
  { Current time }
  t1 := GetTickCount;
  { Loop until all data sent or timeout occurred }
  while DataSize > 0 do
  begin
    { Get TX buffer free space }
    nToSend := OutFreeSpace;
    { If output buffer has some free space... }
    if nToSend > 0 then
    begin
      { Check signals }
      if FCkLineStatus and (GetLineStatus = []) then
        exit;
      { Don't send more bytes than we actually have to send }
      if UINT(nToSend) > DataSize then
        nToSend := DataSize;
      { Send }
      WriteFile( FComPortHandle, DataPtr^, nToSend, nSent, nil );
      nSent := abs( nSent );
      if nSent > 0 then
      begin
        { Update number of bytes sent }
        Result := Result + nSent;
        { Decrease the count of bytes to send }
        DataSize := DataSize - nSent;
        { Inc. data pointer }
        DataPtr := DataPtr + nSent;
        { Get current time }
        t1 := GetTickCount;
        { Continue. This skips the time check below (don't stop
          trasmitting if the Timeout is set too low) }
        continue;
      end;
    end;
    { Buffer is full. If we are waiting too long then exit }
    if (GetTickCount-t1) > Timeout then
      exit;
  end;
end;

{ Send data (breaks the data in small packets if it doesn't fit in the output
  buffer) }
function TCommPortDriver.SendData( DataPtr: pointer; DataSize: UINT ): UINT;
begin
  Result := SendDataEx( DataPtr, DataSize, FOutputTimeout );
end;

{ Sends a byte. Returns true if the byte has been sent }
function TCommPortDriver.SendByte( Value: byte ): boolean;
begin
  Result := SendData( @Value, 1 ) = 1;
end;

{ Sends a char. Returns true if the char has been sent }
function TCommPortDriver.SendChar( Value: char ): boolean;
begin
  Result := SendData( @Value, 1 ) = 1;
end;

{ Sends a pascal string (NULL terminated if $H+ (default)) }
function TCommPortDriver.SendString( s: string ): boolean;
var len: UINT;
begin
  len := length( s );
  {$IFOPT H+}  { New syle pascal string (NULL terminated) }
  Result := SendData( pchar(s), len ) = len;
  {$ELSE} { Old style pascal string (s[0] = length) }
  Result := SendData( pchar(@s[1]), len ) = len;
  {$ENDIF}
end;

{ Sends a C-style string (NULL terminated) }
function TCommPortDriver.SendZString( s: pchar ): boolean;
var len: UINT;
begin
  len := strlen( s );
  Result := SendData( s, len ) = len;
end;

{ Reads binary data. Returns number of bytes read }
function TCommPortDriver.ReadData( DataPtr: pchar; MaxDataSize: UINT ): UINT;
var
  nToRead: integer;
  t1: longint;
  nRead: LongWord;
begin
  { Do nothing if port has not been opened }
  Result := 0;
  if not Connected then
    exit;
  { Pause polling }
  PausePolling;
  { Current time }
  t1 := GetTickCount;
  { Loop until all requested data read or timeout occurred }
  while MaxDataSize > 0 do
  begin
    { Get data bytes count in RX buffer }
    nToRead := CountRX;
    { If input buffer has some data... }
    if nToRead > 0 then
    begin
      { Don't read more bytes than we actually have to read }
      if nToRead > MaxDataSize then
        nToRead := MaxDataSize;
      { Read }
      ReadFile( FComPortHandle, DataPtr^, nToRead, nRead, nil );
      { Update number of bytes read }
      Result := Result + nRead;
      { Decrease the count of bytes to read }
      MaxDataSize := MaxDataSize - nRead;
      { Inc. data pointer }
      DataPtr := DataPtr + nRead;
      { Get current time }
      t1 := GetTickCount;
      { Continue. This skips the time check below (don't stop
        reading if the FInputTimeout is set too low) }
      continue;
    end;
    { Buffer is empty. If we are waiting too long then exit }
    if (GetTickCount-t1) > FInputTimeout then
      break;
  end;
  { Continue polling }
  ContinuePolling;
end;

{ Reads a byte. Returns true if the byte has been read }
function TCommPortDriver.ReadByte( var Value: byte ): boolean;
begin
  Result := ReadData( @Value, 1 ) = 1;
end;

{ Reads a char. Returns true if char has been read }
function TCommPortDriver.ReadChar( var Value: char ): boolean;
begin
  Result := ReadData( @Value, 1 ) = 1;
end;

{ Set DTR line high (onOff=TRUE) or low (onOff=FALSE).
  You must not use HW handshaking. }
procedure TCommPortDriver.ToggleDTR( onOff: boolean );
const funcs: array[boolean] of integer = (CLRDTR,SETDTR);
begin
  if Connected then
    EscapeCommFunction( FComPortHandle, funcs[onOff] );
end;

{ Set RTS line high (onOff=TRUE) or low (onOff=FALSE).
  You must not use HW handshaking. }
procedure TCommPortDriver.ToggleRTS( onOff: boolean );
const funcs: array[boolean] of integer = (CLRRTS,SETRTS);
begin
  if Connected then
    EscapeCommFunction( FComPortHandle, funcs[onOff] );
end;

{ COM port polling proc }
procedure TCommPortDriver.TimerWndProc( var msg: TMessage );
var nRead, nToRead, dummy: UINT;
    comStat: TCOMSTAT;
begin
  if (msg.Msg = WM_TIMER) and Connected then
  begin
    { Do nothing if RX polling has been paused }
    if FRXPollingPauses > 0 then
      exit;
    { If PacketSize is > 0 then raise the OnReceiveData event only if the RX
      buffer has at least PacketSize bytes in it. }
    ClearCommError( FComPortHandle, dummy, @comStat );
    if FPacketSize > 0 then
    begin
      { Complete packet received ? }
      if comStat.cbInQue >= FPacketSize then
      begin
        repeat
          { Read the packet and pass it to the app }
          nRead := 0;
          if ReadFile( FComPortHandle, FTempInBuffer^, FPacketSize, nRead, nil ) then
            if (nRead <> 0) and Assigned(FComPortReceivePacket) then
              FComPortReceivePacket( Self, FTempInBuffer, nRead );
          { Adjust time }
          if comStat.cbInQue >= FPacketSize then
            FFirstByteOfPacketTime := FFirstByteOfPacketTime +
                                      DelayForRX( FComPortBaudRate, FPacketSize );
          comStat.cbInQue := comStat.cbInQue - FPacketSize;
          if comStat.cbInQue = 0 then
            FFirstByteOfPacketTime := DWORD(-1);
        until comStat.cbInQue < FPacketSize;
        { Done }
        exit;
      end;
      { Handle packet timeouts }
      if (FPacketTimeout > 0) and (FFirstByteOfPacketTime <> DWORD(-1)) and
         (GetTickCount - FFirstByteOfPacketTime > FPacketTimeout) then
      begin
        nRead := 0;
        { Read the "incomplete" packet }
        if ReadFile( FComPortHandle, FTempInBuffer^, comStat.cbInQue, nRead, nil ) then
          { If PacketMode is not pmDiscard then pass the packet to the app }
          if (FPacketMode <> pmDiscard) and (nRead <> 0) and Assigned(FComPortReceivePacket) then
            FComPortReceivePacket( Self, FTempInBuffer, nRead );
        { Restart waiting for a packet }
        FFirstByteOfPacketTime := DWORD(-1);
        { Done }
        exit;
      end;
      { Start time }
      if (comStat.cbInQue > 0) and (FFirstByteOfPacketTime = DWORD(-1)) then
        FFirstByteOfPacketTime := GetTickCount;
      { Done }
      exit;
    end;

    { Standard data handling }
    nRead := 0;
    nToRead := comStat.cbInQue;
    if (nToRead > 0) and ReadFile( FComPortHandle, FTempInBuffer^, nToRead, nRead, nil ) then
      if (nRead <> 0) and Assigned(FComPortReceiveData) then
        FComPortReceiveData( Self, FTempInBuffer, nRead );
  end
  { Let Windows handle other messages }
  else
    Msg.Result := DefWindowProc( FNotifyWnd, Msg.Msg, Msg.wParam, Msg.lParam ) ;
end;

procedure Register;
begin
  { Register this component and show it in the 'System' tab
    of the component palette }
  RegisterComponents('System', [TCommPortDriver]);
end;

end.
