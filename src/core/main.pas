unit main ;

interface

type
  TMain = class
  private
  public
    procedure Run() ;
  end;

implementation
uses SysUtils,
  SfmlWindow,
  Game, Scene, SceneLoader, Helpers, Logger ;

procedure TMain.Run() ;
var game:TGame ;
begin
  ChDir(ExtractFilePath(ParamStr(0))+PATH_SEP+'..'+PATH_SEP+'data') ;
  game:=TGame.Create(1024,768,'EndlessWalls',
    'EndlessWalls','images'+PATH_SEP+'icon.png') ;
  if FileExists('developer.config') then game.enableFPSInTitle(True) ;
  game.Run(TSceneLoader.Create()) ;
  game.Free ;
end ;

end.
