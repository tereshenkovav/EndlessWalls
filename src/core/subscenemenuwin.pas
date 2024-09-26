unit SubSceneMenuWin;

interface

uses
  Classes, SysUtils,
  SfmlSystem,SfmlWindow,SfmlGraphics,SfmlAudio,
  Scene, Helpers ;

type

  { TSubSceneMenuWin }

  TSubSceneMenuWin = class(TScene)
  private
    textWin:TSfmlText ;
    textMenu:TSfmlText ;
    rect:TSfmlRectangleShape ;
  public
    function Init():Boolean ; override ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; override ;
    procedure RenderFunc() ; override ;
    procedure UnInit() ; override ;
  end;

implementation
uses CommonData, SfmlUtils, SceneMainMenu, SceneGame ;

function TSubSceneMenuWin.Init():Boolean ;
begin
  textWin:=createText(TCommonData.Font,TCommonData.texts.getText('BUT_WIN'),24,SfmlColorFromRGB(40,255,40)) ;
  textMenu:=createText(TCommonData.Font,TCommonData.texts.getText('BUT_ENDGAME'),24,SfmlWhite) ;
  rect:=TSfmlRectangleShape.Create() ;
  rect.OutlineThickness:=4;
  rect.Size:=SfmlVector2f(270,180) ;
  rect.Position:=SfmlVector2f(768/2-135,768/2-75);
  rect.FillColor:=SfmlColorFromRGBA(40,40,40,192) ;
  rect.OutlineColor:=SfmlWhite ;
  Result:=True ;
end ;

function TSubSceneMenuWin.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
var event:TSfmlEventEx ;
begin
  Result:=Normal ;
  for event in events do
    if (event.event.EventType = sfEvtKeyPressed) then begin
      if (event.event.key.code = sfKeyEscape) then begin
        nextscene:=TSceneMainMenu.Create() ;
        Exit(TSceneResult.Switch) ;
      end;
    end ;
end ;

procedure TSubSceneMenuWin.RenderFunc() ;
begin
  window.Draw(rect) ;
  drawTextCentered(textWin,768/2,768/2-50) ;
  drawTextCentered(textMenu,768/2,768/2+50) ;
end ;

procedure TSubSceneMenuWin.UnInit() ;
begin
  rect.Free ;
  textWin.Free ;
  textMenu.Free ;
end ;

end.
