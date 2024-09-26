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
  Game, Scene, SceneMainMenu, Helpers, Logger, CommonData ;

procedure TMain.Run() ;
var game:TGame ;
begin
  ChDir(ExtractFilePath(ParamStr(0))+PATH_SEP+'..'+PATH_SEP+'data') ;
  TCommonData.Init() ;
  game:=TGame.Create(1024,768,'EndlessWalls',
    TCommonData.texts.getText('GAME_TITLE'),'images'+PATH_SEP+'icon.png') ;
  if FileExists('developer.config') then game.enableFPSInTitle(True) ;
  game.Run(TSceneMainMenu.Create()) ;
  game.Free ;
  TCommonData.UnInit() ;
end ;

end.
