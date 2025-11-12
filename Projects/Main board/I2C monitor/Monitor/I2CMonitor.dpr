program I2CMonitor;

uses
  Forms,
  UMain in 'UMain.pas' {Main},
  ComDrv32 in 'ComDrv32.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
