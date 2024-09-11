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
    tex_markers:array of TSfmlTexture ;
    wr:TWallsRender ;
    font:TSfmlFont ;
    arrow:TSfmlSprite ;
    map:TMap ;
    textInfo:TSfmlText ;
    ineffect:Boolean ;
    lastrotdir:TDir ;
    mapvertex:TSfmlVertexArray ;
    spr_tekmarker:TSfmlSprite ;
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
uses SfmlUtils, Math, homedir ;

const MMAPRES = 33 ;
      MMAPD = (MMAPRES-1) div 2 ;
      MMAPSZ = 7 ;
      MARKERS_COUNT = 3 ;

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

  spr_tekmarker:=TSfmlSprite.Create() ;
  spr_tekmarker.Scale(0.33,0.33) ;
  spr_tekmarker.Origin:=SfmlVector2f(64,64) ;
  SwitchTekMarker(0) ;

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
          MiniMapRebuild() ;
        end;
        if (event.event.key.code = sfKeyDown) then begin
          wr.MoveBack() ;
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

