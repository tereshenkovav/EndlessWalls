program EndlessWallsDelphi;

{$APPTYPE GUI}

{$R *.res}

uses
  System.SysUtils,
  main in 'core\main.pas',
  scenegame in 'core\scenegame.pas',
  map in 'core\map.pas',
  wallsrender in 'core\wallsrender.pas',
  mapgenerator in 'core\mapgenerator.pas',
  sceneloader in 'core\sceneloader.pas',
  constants in 'core\constants.pas',
  commondata in 'core\commondata.pas',
  sceneabout in 'core\sceneabout.pas',
  scenehelp in 'core\scenehelp.pas',
  scenemainmenu in 'core\scenemainmenu.pas',
  subscenemenugame in 'core\subscenemenugame.pas',
  scenesizeselect in 'core\scenesizeselect.pas',
  subscenemenuwin in 'core\subscenemenuwin.pas';

begin
  with TMain.Create() do begin
    Run() ;
    Free ;
  end;
end.
