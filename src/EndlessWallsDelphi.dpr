program EndlessWallsDelphi;

{$APPTYPE GUI}

{$R *.res}

uses
  System.SysUtils,
  main in 'core\main.pas',
  scenegame in 'core\scenegame.pas',
  map in 'core\map.pas',
  wallsrender in 'core\wallsrender.pas';

begin
  with TMain.Create() do begin
    Run() ;
    Free ;
  end;
end.
