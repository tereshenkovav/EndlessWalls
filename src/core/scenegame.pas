unit SceneGame;

interface

uses
  Classes, SysUtils,
  SfmlSystem,SfmlWindow,SfmlGraphics,SfmlAudio,
  Scene, Helpers, SceneOpenGL, WallsRender, Map ;

type

  { TSceneGame }

  TSceneGame = class(TScene)
  private
    ogl:TSceneOpenGL ;
    wr:TWallsRender ;
    font:TSfmlFont ;
    map:TMap ;
    textInfo:TSfmlText ;
  public
    constructor Create() ;
    function Init():Boolean ; override ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; override ;
    procedure RenderFunc() ; override ;
    procedure UnInit() ; override ;
  end;

implementation
uses SfmlUtils ;

constructor TSceneGame.Create();
begin
end;

function TSceneGame.Init():Boolean ;
begin
  map:=TMap.Create() ;
  wr:=TWallsRender.Create(map,768,768) ;
  wr.SetStart(0,0,dUp) ;
  ogl:=TSceneOpenGL.Create(0,0,768,768,CreateSfmlColor($000000),wr) ;
  overscene:=ogl ;
  font:=TSfmlFont.Create('fonts'+PATH_SEP+'arial.ttf');
  textInfo:=createText(font,'',24,SfmlWhite) ;
  Result:=True ;
end ;

function TSceneGame.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
var event:TSfmlEventEx ;
begin
  Result:=Normal ;

  if not wr.isInEffect() then begin
    for event in events do
      if (event.event.EventType = sfEvtKeyPressed) then begin
        if (event.event.key.code = sfKeyEscape) then begin
          Exit(TSceneResult.Close) ;
        end;
        if (event.event.key.code = sfKeyUp) then begin
          wr.MoveForw() ;
          ogl.Reset() ;
        end;
        if (event.event.key.code = sfKeyDown) then begin
          wr.MoveBack() ;
          ogl.Reset() ;
        end;
        if (event.event.key.code = sfKeyLeft) then begin
          wr.RotLeft() ;
          ogl.Reset() ;
        end;
        if (event.event.key.code = sfKeyRight) then begin
          wr.RotRight() ;
          ogl.Reset() ;
        end;
      end ;
  end;

  if wr.isInEffect() then begin
    wr.Update(dt) ;
    ogl.Reset() ;
  end;
end ;

procedure TSceneGame.RenderFunc() ;
begin
  textInfo.UnicodeString:=Format('x=%d y=%d dir=%s',[wr.getX(),wr.getY(),
    TMap.GetDirStr(wr.getDir())]) ;
  DrawText(textInfo,800,10) ;
end ;

procedure TSceneGame.UnInit() ;
begin
  ogl.Free ;
  wr.Free ;
  map.Free ;
  textinfo.Free ;
  font.Free ;
end ;

end.

