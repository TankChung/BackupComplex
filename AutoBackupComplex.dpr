program AutoBackupComplex;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {MF};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMF, MF);
  Application.Run;
end.
