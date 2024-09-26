unit SceneHelp;

interface

uses
  Classes, SysUtils,
  SfmlSystem,SfmlWindow,SfmlGraphics,SfmlAudio,
  Scene, Helpers ;

type

  { TSceneHelp }

  TSceneHelp = class(TScene)
  private
    textTitle:TSfmlText ;
    textInfo:TSfmlText ;
  public
    function Init():Boolean ; override ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; override ;
    procedure RenderFunc() ; override ;
    procedure UnInit() ; override ;
  end;

implementation
uses SceneMainMenu, SfmlUtils, CommonData ;

function TSceneHelp.Init():Boolean ;
begin
  textTitle:=createText(TCommonData.Font,TCommonData.texts.getText('HELP_TITLE'),28,SfmlBlack) ;
  textInfo:=createText(TCommonData.Font,TCommonData.texts.getText('HELP_TEXT'),24,SfmlBlack) ;
  Result:=True ;
end ;

function TSceneHelp.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
var event:TSfmlEventEx ;
begin
  Result:=Normal ;
  for event in events do
    if (event.event.EventType = sfEvtKeyPressed) then begin
      nextscene:=TSceneMainMenu.Create() ;
      Exit(TSceneResult.Switch) ;
    end ;
end ;

procedure TSceneHelp.RenderFunc() ;
begin
  window.Clear(SfmlWhite) ;
  DrawTextCentered(textTitle,wwidth/2,50) ;
  DrawTextCentered(textInfo,wwidth/2,140) ;
end ;

procedure TSceneHelp.UnInit() ;
begin
  textTitle.Free ;
  textInfo.Free ;
end ;

end.
