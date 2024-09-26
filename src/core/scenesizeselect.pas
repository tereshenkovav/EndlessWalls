unit SceneSizeSelect;

interface

uses
  Classes, SysUtils,
  SfmlSystem,SfmlWindow,SfmlGraphics,SfmlAudio,
  Scene, Helpers, SfmlAnimation, MenuKeyboardText ;

type

  { TSceneSizeSelect }

  TSceneSizeSelect = class(TScene)
  private
    logo:TSfmlSprite ;
    menu:TMenuKeyboardText ;
    textTitle:TSfmlText ;
    procedure buildMenu() ;
    procedure loadLogo() ;
  public
    function Init():Boolean ; override ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; override ;
    procedure RenderFunc() ; override ;
    procedure UnInit() ; override ;
  end;

implementation
uses StrUtils,
 SceneLoader, SceneMainMenu,
 SfmlUtils, CommonData, Game ;

const MAPS_COUNT=5 ;

function TSceneSizeSelect.Init():Boolean ;
begin
  loadLogo() ;

  textTitle:=createText(TCommonData.Font,TCommonData.texts.getText('SELSIZE_TITLE'),32,SfmlBlack) ;

  menu:=TMenuKeyboardText.Create(TCommonData.selector,wwidth div 2-100,340,55,
    TCommonData.Font,32,SfmlBlack) ;
  buildMenu() ;
  menu.setIndex(0) ;
  overscene:=menu ;

  Result:=True ;
end ;

procedure TSceneSizeSelect.loadLogo;
begin
  if logo<>nil then logo.Free ;
  logo:=loadSprite(TCommonData.languages.formatFileNameWithLang('images'+PATH_SEP+'logo.png'),[sloCentered]);
  logo.Position:=SfmlVector2f(wwidth/2,150) ;
end;

procedure TSceneSizeSelect.buildMenu;
var i:Integer ;
begin
  menu.clearItems() ;
  for i := 0 to MAPS_COUNT-1 do
    menu.addItem(TCommonData.texts.getText('MAPSIZE_'+IntToStr(i))) ;
end;

function TSceneSizeSelect.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
var event:TSfmlEventEx ;
begin
  Result:=Normal ;
  for event in events do
    if (event.event.EventType = sfEvtKeyPressed) then begin
      if (event.event.key.code = sfKeyEscape) then begin
        nextscene:=TSceneMainMenu.Create() ;
        Exit(TSceneResult.Switch) ;
      end;
      if (event.event.key.code in [sfKeySpace,sfKeyReturn]) then begin
        nextscene:=TSceneLoader.Create(menu.getSelIndex()) ;
        Exit(TSceneResult.Switch) ;
      end;
    end ;
end ;

procedure TSceneSizeSelect.RenderFunc() ;
begin
  window.Clear(SfmlWhite) ;
  DrawTextCentered(textTitle,wwidth/2,260) ;
  window.Draw(logo) ;
end ;

procedure TSceneSizeSelect.UnInit() ;
begin
  logo.Free ;
  menu.Free ;
end ;

initialization

end.
