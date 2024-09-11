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
  Game, Scene, SceneGame, Helpers, Logger ;

procedure TMain.Run() ;
var game:TGame ;
begin
  ChDir(ExtractFilePath(ParamStr(0))+PATH_SEP+'..'+PATH_SEP+'data') ;
  game:=TGame.Create(1024,768,'EndlessWalls',
    'EndlessWalls','images'+PATH_SEP+'icon.png') ;
  if FileExists('developer.config') then game.enableFPSInTitle(True) ;
  game.Run(TSceneGame.Create()) ;
  game.Free ;
end ;

end.
