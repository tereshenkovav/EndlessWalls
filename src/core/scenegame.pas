﻿unit SceneGame;

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
    tex_markers:array of TSfmlTexture ;
    tex_objects:array of TSfmlTexture ;
    wr:TWallsRender ;
    font:TSfmlFont ;
    arrow:TSfmlSprite ;
    map:TMap ;
    textInfo:TSfmlText ;
    ineffect:Boolean ;
    lastrotdir:TDir ;
    mapvertex:TSfmlVertexArray ;
    spr_tekmarker:TSfmlSprite ;
    spr_objects:array of TSfmlSprite ;
    objects_on_search:TUniDictionary<Integer,Boolean> ;
    tekmarkercode:Integer ;
    procedure MiniMapRebuild() ;
    procedure SaveMapToImage(const filename:string) ;
    procedure SwitchTekMarker(code:Integer) ;
  public
    constructor Create(Amap:TMap) ;
    function Init():Boolean ; override ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; override ;
    procedure RenderFunc() ; override ;
    procedure UnInit() ; override ;
  end;

implementation
uses Math,
  SfmlUtils, homedir,
  Constants ;

const MMAPRES = 33 ;
      MMAPD = (MMAPRES-1) div 2 ;
      MMAPSZ = 7 ;

constructor TSceneGame.Create(Amap:TMap);
begin
  map:=Amap ;
end;

function TSceneGame.Init():Boolean ;
var i,j,p:Integer ;
begin
  wr:=TWallsRender.Create(map,768,768) ;
  wr.SetStart(0,0,dUp) ;
  ogl:=TSceneOpenGL.Create(0,0,768,768,CreateSfmlColor($000000),wr) ;
  overscene:=ogl ;
  font:=TSfmlFont.Create('fonts'+PATH_SEP+'arial.ttf');
  textInfo:=createText(font,'',24,SfmlBlack) ;
  arrow:=loadSprite('images'+PATH_SEP+'arrow.png',[sloCentered,sloNoSmooth]) ;
  ineffect:=False ;

  SetLength(tex_markers,MARKERS_COUNT) ;
  for i := 0 to MARKERS_COUNT-1 do
    tex_markers[i]:=TSfmlTexture.Create(Format('images%smarker%d.png',[PATH_SEP,i])) ;
  wr.AddMarkers(tex_markers) ;

  SetLength(tex_objects,OBJECTS_COUNT) ;
  for i := 0 to OBJECTS_COUNT-1 do
    tex_objects[i]:=TSfmlTexture.Create(Format('images%sobject%.2d.png',[PATH_SEP,i])) ;
  wr.AddObjects(tex_objects) ;

  spr_tekmarker:=TSfmlSprite.Create() ;
  spr_tekmarker.Scale(0.33,0.33) ;
  spr_tekmarker.Origin:=SfmlVector2f(64,64) ;
  SwitchTekMarker(0) ;

  SetLength(spr_objects,OBJECTS_COUNT) ;
  for i := 0 to OBJECTS_COUNT-1 do begin
    spr_objects[i]:=TSfmlSprite.Create() ;
    spr_objects[i].Scale(64/tex_objects[i].Size.X,64/tex_objects[i].Size.Y) ;
    spr_objects[i].SetTexture(tex_objects[i],True) ;
    spr_objects[i].Origin:=SfmlVector2f(tex_objects[i].Size.X/2,tex_objects[i].Size.X/2) ;
  end;

  mapvertex:=TSfmlVertexArray.Create ;
  mapvertex.PrimitiveType:=sfQuads ;
  mapvertex.Resize(MMAPRES*MMAPRES*4+4);
  p:=0 ;
  for i := 0 to MMAPRES-1 do
    for j := 0 to MMAPRES-1 do begin
	    mapvertex.Vertex[p].Position:=SfmlVector2f(768+14+i*MMAPSZ, 55+j*MMAPSZ);
	    mapvertex.Vertex[p+1].Position:=SfmlVector2f(768+14+i*MMAPSZ+MMAPSZ, 55+j*MMAPSZ);
	    mapvertex.Vertex[p+2].Position:=SfmlVector2f(768+14+i*MMAPSZ+MMAPSZ, 55+j*MMAPSZ+MMAPSZ);
	    mapvertex.Vertex[p+3].Position:=SfmlVector2f(768+14+i*MMAPSZ, 55+j*MMAPSZ+MMAPSZ);
      Inc(p,4) ;
    end ;

  mapvertex.Vertex[p].Position:=SfmlVector2f(768+14+MMAPD*MMAPSZ+1, 55+MMAPD*MMAPSZ+1);
  mapvertex.Vertex[p+1].Position:=SfmlVector2f(768+14+MMAPD*MMAPSZ+MMAPSZ-1, 55+MMAPD*MMAPSZ+1);
  mapvertex.Vertex[p+2].Position:=SfmlVector2f(768+14+MMAPD*MMAPSZ+MMAPSZ-1, 55+MMAPD*MMAPSZ+MMAPSZ-1);
  mapvertex.Vertex[p+3].Position:=SfmlVector2f(768+14+MMAPD*MMAPSZ+1, 55+MMAPD*MMAPSZ+MMAPSZ-1);

  MiniMapRebuild() ;

  THomeDir.createDirInHomeIfNeed('EndlessWalls') ;
  SaveMapToImage(THomeDir.getFileNameInHome('EndlessWalls','map.png')) ;

  objects_on_search:=map.getObjectsCodes() ;

  Result:=True ;
end ;

procedure TSceneGame.MiniMapRebuild;
var i,j,p:Integer ;
    c:TSfmlColor ;
begin
  map.UpdateOpenedByPosDirDist(wr.getX(),wr.getY(),wr.getDir(),MAX_DIST) ;
  p:=0 ;
  for i := 0 to MMAPRES-1 do
    for j := 0 to MMAPRES-1 do begin
      c:=createSFMLColor($404040) ;
      if (map.isPointOpened(wr.getX()-MMAPD+i,wr.getY()+MMAPD-j)) then c:=createSFMLColor($008000) ;
      if (map.isPointDark(wr.getX()-MMAPD+i,wr.getY()+MMAPD-j)) then c:=createSFMLColor($006000) ;
      mapvertex.Vertex[p].Color:=c ;
      mapvertex.Vertex[p+1].Color:=c ;
      mapvertex.Vertex[p+2].Color:=c ;
      mapvertex.Vertex[p+3].Color:=c ;
      Inc(p,4) ;
    end;

  c:=createSFMLColor($E0E0E0) ;
  mapvertex.Vertex[p].Color:=c ;
  mapvertex.Vertex[p+1].Color:=c ;
  mapvertex.Vertex[p+2].Color:=c ;
  mapvertex.Vertex[p+3].Color:=c ;
end;

function TSceneGame.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
var event:TSfmlEventEx ;
    dir:TDir ;
    code:Integer ;
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
          if wr.getFrontObjectCode(code) then
            objects_on_search[code]:=True ;
          ogl.Reset() ;
          MiniMapRebuild() ;
        end;
        if (event.event.key.code = sfKeyDown) then begin
          wr.MoveBack() ;
          if wr.getFrontObjectCode(code) then
            objects_on_search[code]:=True ;
          ogl.Reset() ;
          MiniMapRebuild() ;
        end;
        if (event.event.key.code = sfKeyLeft) then begin
          wr.RotLeft() ;
          ogl.Reset() ;
          MiniMapRebuild() ;
          lastrotdir:=dLeft ;
        end;
        if (event.event.key.code = sfKeyRight) then begin
          wr.RotRight() ;
          ogl.Reset() ;
          MiniMapRebuild() ;
          lastrotdir:=dRight ;
        end;
        if (event.event.key.code in [sfKeyZ,sfKeyX,sfKeyC]) then begin
          if event.event.key.code=sfKeyZ then dir:=dLeft else
          if event.event.key.code=sfKeyX then dir:=dUp else dir:=dRight ;
          if map.canSetMarker(wr.getX(),wr.getY(),wr.getDir(),dir) then begin
            map.SetMarker(wr.getX(),wr.getY(),wr.getDir(),dir,tekmarkercode) ;
            ogl.Reset() ;
          end ;
        end;
        if (event.event.key.code in [sfKeyNum1,sfKeyNum2,sfKeyNum3,sfKeyNum4,
          sfKeyNum5,sfKeyNum6,sfKeyNum7,sfKeyNum8,sfKeyNum9]) then begin
          SwitchTekMarker(ord(event.event.key.code)-ord(sfKeyNum1)) ;
        end;
      end ;
  end;

  if wr.isInEffect() then begin
    wr.Update(dt) ;
    ogl.Reset() ;
    ineffect:=True ;
  end
  else begin
    if ineffect then begin
      MiniMapRebuild() ;
      ineffect:=False ;
      if not map.canSeeAtToDir(wr.getX(),wr.getY(),wr.getDir()) then begin
        if lastrotdir=dLeft then wr.RotLeft() else wr.RotRight() ;
      end;
    end ;
  end
end ;

procedure TSceneGame.RenderFunc() ;
var code,p,x,y:Integer;
begin
  window.Clear(SfmlWhite);
  textInfo.UnicodeString:=Format('Map result: %d/%d',[map.getResult(),map.getTotalLen()]) ;
  DrawText(textInfo,800,10) ;
  window.Draw(mapvertex) ;

  case wr.getDir() of
    dUp: arrow.Rotation:=0 ;
    dLeft: arrow.Rotation:=-90 ;
    dRight: arrow.Rotation:=90 ;
    dDown: arrow.Rotation:=180 ;
  end;
  DrawSprite(arrow,846,340) ;
  DrawSprite(spr_tekmarker,930,340) ;

  x:=820 ;
  y:=440 ;
  p:=0 ;
  for code in objects_on_search.AllKeys do begin
    spr_objects[code].Color:=IfThen(objects_on_search[code],SfmlWhite,SfmlBlack) ;
    DrawSprite(spr_objects[code],x,y) ;
    Inc(x,80) ;
    if p mod 3 = 2 then begin
      x:=820 ;
      Inc(y,90) ;
    end;
    Inc(p) ;
  end;
end ;

procedure TSceneGame.SaveMapToImage(const filename: string);
var m2:T2DMap ;
    img:TSFMLImage;
    i,j,x,y,sx,sy,startx,starty:Integer ;
    c,cstart:TSfmlColor ;
const SZ = 4 ;
begin
  m2:=map.SaveTo2D(sx,sy,startx,starty) ;
  c:=createSFMLColor($FF00FF00) ;
  cstart:=createSFMLColor($FFFF0000) ;

  img:=TSFMLImage.Create(SZ*sx,SZ*sy) ;
  for x := 0 to sx-1 do
    for y := 0 to sy-1 do
      if m2[x][y] then begin
        for i := 0 to SZ-1 do
          for j := 0 to SZ-1 do
            if (x=startx)and(y=starty) then
              img.Pixel[x*SZ+i,(sy-1-y)*SZ+j]:=cstart
            else
              img.Pixel[x*SZ+i,(sy-1-y)*SZ+j]:=c ;
      end;
  img.SaveToFile(filename) ;

  SetLength(m2,0,0) ;
end;

procedure TSceneGame.SwitchTekMarker(code: Integer);
begin
  if code<Length(tex_markers) then begin
    tekmarkercode:=code ;
    spr_tekmarker.SetTexture(tex_markers[code],True) ;
  end;
end;

procedure TSceneGame.UnInit() ;
var i:Integer ;
begin
  ogl.Free ;
  wr.Free ;
  map.Free ;
  textinfo.Free ;
  font.Free ;
  mapvertex.Free ;

  for i:=0 to Length(tex_markers)-1 do
    tex_markers[i].Free ;
  SetLength(tex_markers,0) ;
end ;

end.

