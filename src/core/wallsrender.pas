unit WallsRender;

interface

uses
  Classes, SysUtils,
  SfmlGraphics,
  {$ifdef fpc}gl,glu{$else}OpenGL{$endif},
  SceneOpenGL, Helpers,
  Map ;

type

  { TWallsRender }

  TWallsRender = class(TOpenGLRender)
  private
    tex_markers:array of TSfmlTexture ;
    tex_objects:array of TSfmlTexture ;
    w,h:Integer ;
    x,y:Integer ;
    px,pz:Single ;
    a:Single ;
    dir:TDir ;
    map:TMap ;
    da:Single ;
    floorc:Single ;
    stage2:Boolean ;
  public
    constructor Create(Amap:TMap; Aw,Ah:Integer) ;
    destructor Destroy() ; override ;
    procedure SetStart(Ax,Ay:Integer; Adir:TDir) ;
    procedure AddMarkers(Atex_markers:array of TSfmlTexture) ;
    procedure AddObjects(Atex_objects:array of TSfmlTexture) ;
    procedure Render() ; override ;
    procedure MoveForw() ;
    procedure MoveBack() ;
    procedure RotLeft() ;
    procedure RotRight() ;
    function getX():Integer ;
    function getY():Integer ;
    function getDir():TDir ;
    procedure Update(dt:Single) ;
    function isInEffect():Boolean ;
    function getFrontObjectCode(var code:Integer): Boolean;
  end;

const MAX_DIST = 6 ;

var texs:array of TSfmlTexture ;

implementation
uses Math ;

procedure TWallsRender.AddMarkers(Atex_markers: array of TSfmlTexture);
var i:Integer ;
begin
  SetLength(tex_markers,Length(Atex_markers)) ;
  for i := 0 to Length(Atex_markers)-1 do
    tex_markers[i]:=Atex_markers[i] ;
end;

procedure TWallsRender.AddObjects(Atex_objects: array of TSfmlTexture);
var i:Integer ;
begin
  SetLength(tex_objects,Length(Atex_objects)) ;
  for i := 0 to Length(Atex_objects)-1 do
    tex_objects[i]:=Atex_objects[i] ;
end;

constructor TWallsRender.Create(Amap:TMap; Aw,Ah:Integer);
var i:Integer ;
begin
  map:=Amap ;
  w:=Aw ;
  h:=Ah ;
  a:=0 ;
  da:=0 ;
  px:=0 ;
  pz:=-2 ;
  floorc:=0.9 ;
  SetLength(texs,4) ;
  for i := 0 to Length(texs)-1 do
    texs[i]:=TSfmlTexture.Create(Format('images%stex%d.png',[PATH_SEP,i])) ;
end;

destructor TWallsRender.Destroy() ;
var i:Integer ;
begin
  SetLength(tex_markers,0) ;
  SetLength(tex_objects,0) ;
  for i := 0 to Length(texs)-1 do
    texs[i].Free ;
  SetLength(texs,0) ;
  inherited Destroy ;
end ;

function TWallsRender.getDir: TDir;
begin
  Result:=dir ;
end;

function TWallsRender.getFrontObjectCode(var code:Integer): Boolean;
begin
  Result:=map.isObjectAt(x,y,code) ;
  if Result then map.clearObject(x,y) ;
end;

function TWallsRender.getX: Integer;
begin
  Result:=x ;
end;

function TWallsRender.getY: Integer;
begin
  Result:=y ;
end;

function TWallsRender.isInEffect: Boolean;
begin
  Result:=da<>0 ;
end;

procedure TWallsRender.MoveForw;
begin
  if map.isFreeAtDist(x,y,dir,1) then
    TMap.UpdateXYByDir(x,y,dir,1) ;
end;

procedure TWallsRender.MoveBack;
begin
  if map.isFreeAtDist(x,y,dir,-1) then
    TMap.UpdateXYByDir(x,y,dir,-1) ;
end;

procedure rightWall(tex:TSfmlTexture) ;
begin
    tex.Bind() ;
    glBegin(GL_POLYGON);
        glTexCoord2f(0.0, 0.0);
        glVertex3f(1.0, -1.0, -1.0);
        glTexCoord2f(0.0, 1.0);
        glVertex3f(1.0, -1.0, 1.0);
        glTexCoord2f(1.0, 1.0);
        glVertex3f(1.0, 1.0, 1.0);
        glTexCoord2f(1.0, 0.0);
        glVertex3f(1.0, 1.0, -1.0);
    glEnd();
    SfmlTextureBind(nil) ;
end ;

procedure rightMarker(marker:TSfmlTexture; pc:Single) ;
begin
   glColor3f(pc, pc, pc);
      marker.Bind() ;
      glBegin(GL_POLYGON);
        glTexCoord2f(0.0, 0.0);
        glVertex3f(0.99, -0.5, 0.5);
        glTexCoord2f(0.0, 1.0);
        glVertex3f(0.99, 0.5, 0.5);
        glTexCoord2f(1.0, 1.0);
        glVertex3f(0.99, 0.5, -0.5);
        glTexCoord2f(1.0, 0.0);
        glVertex3f(0.99, -0.5, -0.5);
      glEnd();
      SfmlTextureBind(nil) ;
end ;

procedure leftWall(tex:TSfmlTexture) ;
begin
    tex.Bind() ;
    glBegin(GL_POLYGON);
        glTexCoord2f(0.0, 0.0);
        glVertex3f(-1.0, -1.0, -1.0);
        glTexCoord2f(0.0, 1.0);
        glVertex3f(-1.0, -1.0, 1.0);
        glTexCoord2f(1.0, 1.0);
        glVertex3f(-1.0, 1.0, 1.0);
        glTexCoord2f(1.0, 0.0);
        glVertex3f(-1.0, 1.0, -1.0);
    glEnd();
    SfmlTextureBind(nil) ;
end ;

procedure leftMarker(marker:TSfmlTexture; pc:Single) ;
begin
   glColor3f(pc, pc, pc);
      marker.Bind() ;
      glBegin(GL_POLYGON);
        glTexCoord2f(0.0, 0.0);
        glVertex3f(-0.99, -0.5, -0.5);
        glTexCoord2f(0.0, 1.0);
        glVertex3f(-0.99, 0.5, -0.5);
        glTexCoord2f(1.0, 1.0);
        glVertex3f(-0.99, 0.5, 0.5);
        glTexCoord2f(1.0, 0.0);
        glVertex3f(-0.99, -0.5, 0.5);
      glEnd();
      SfmlTextureBind(nil) ;
end ;

procedure frontWall(tex:TSfmlTexture) ;
begin
    tex.Bind() ;
    glBegin(GL_POLYGON);
        glTexCoord2f(0.0, 0.0);
        glVertex3f(-1.0, -1.0, 1.0);
        glTexCoord2f(0.0, 1.0);
        glVertex3f(1.0, -1.0, 1.0);
        glTexCoord2f(1.0, 1.0);
        glVertex3f(1.0, 1.0, 1.0);
        glTexCoord2f(1.0, 0.0);
        glVertex3f(-1.0, 1.0, 1.0);
    glEnd();
    SfmlTextureBind(nil) ;
end ;

procedure frontMarker(marker:TSfmlTexture; pc:Single) ;
begin
   glColor3f(pc, pc, pc);
      marker.Bind() ;
      glBegin(GL_POLYGON);
        glTexCoord2f(0.0, 0.0);
        glVertex3f(-0.5, -0.5, 0.99);
        glTexCoord2f(0.0, 1.0);
        glVertex3f(-0.5, 0.5, 0.99);
        glTexCoord2f(1.0, 1.0);
        glVertex3f(0.5, 0.5, 0.99);
        glTexCoord2f(1.0, 0.0);
        glVertex3f(0.5, -0.5, 0.99);
      glEnd();
      SfmlTextureBind(nil) ;
end ;

procedure renderObject(tex_object:TSfmlTexture; pc:Single) ;
var sz:Single ;
begin
   sz:=tex_object.Size.X/256 ;

   glColor3f(pc, pc, pc);
      tex_object.Bind() ;
      glBegin(GL_POLYGON);
        glTexCoord2f(0.0, 0.0);
        glVertex3f(-sz/2, 1.0-sz, 0.0);
        glTexCoord2f(0.0, 1.0);
        glVertex3f(-sz/2, 1.0, 0.0);
        glTexCoord2f(1.0, 1.0);
        glVertex3f(sz/2, 1.0, 0.0);
        glTexCoord2f(1.0, 0.0);
        glVertex3f(sz/2, 1.0-sz, 0.0);
      glEnd();
      SfmlTextureBind(nil) ;
end ;

procedure roofAndFloor() ;
begin
    glBegin(GL_POLYGON);
        glVertex3f(1.0, -1.0, -1.0);
        glVertex3f(1.0, -1.0, 1.0);
        glVertex3f(-1.0, -1.0, 1.0);
        glVertex3f(-1.0, -1.0, -1.0);
    glEnd();

    glBegin(GL_POLYGON);
        glVertex3f(1.0, 1.0, -1.0);
        glVertex3f(1.0, 1.0, 1.0);
        glVertex3f(-1.0, 1.0, 1.0);
        glVertex3f(-1.0, 1.0, -1.0);
    glEnd();
end;

procedure setColor(c:TColor; pc:Single) ;
begin
  glColor3f(c.r*pc, c.g*pc, c.b*pc);
end;

procedure TWallsRender.Render();
var d1,pc:Single ;
    d:Integer ;
    c:TColor ;
    q:Integer ;
    oldpc:Single ;
    xn,yn:Integer ;
    code:Integer ;
begin
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glViewport(0,0,w,h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(67, w/h, 0.01, 100.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  gluLookAt(px,0,pz,px+Sin(a),0,pz+Cos(a),0,-1,0) ;
  d1:=0 ;
  for d:=0 to MAX_DIST do begin
      pc:=0.9-0.9*(d-d1)/MAX_DIST ;

      if map.isFreeAtDist(x,y,dir,d) then begin

        if map.isWallLeftAtDist(x,y,dir,d) then begin
          c:=map.getColorAtDist(x,y,dir,d) ;
          setColor(c,pc) ;

          xn:=x ; yn:=y ;
          TMap.UpdateXYByDir(xn,yn,dir,d) ;

          leftWall(texs[(xn+yn) mod 4]) ;

          if map.isMarkerAt(xn,yn,TMap.GetRolledDirLeft(dir),code) then leftMarker(tex_markers[code],pc) ;
        end
        else begin
          glPushMatrix() ;
          oldpc:=pc ;
          for q := 0 to IfThen(d=0,2,0) do begin
            pc:=0.9-0.9*(d+q-d1)/MAX_DIST ;
            glTranslatef(-2.0,0.0,0.0);
            glColor3f(pc, pc, pc);
            roofAndFloor() ;
            c:=map.getColorAtDistLeft(x,y,dir,d) ;
            setColor(c,pc) ;

            // Перемещаем вперед на d и влево на q+1
            xn:=x ; yn:=y ;
            TMap.UpdateXYByDir(xn,yn,dir,d) ;
            TMap.UpdateXYByDir(xn,yn,TMap.GetRolledDirLeft(dir),q+1) ;
            frontWall(texs[(xn+yn) mod 4]) ;

            if map.isMarkerAt(xn,yn,dir,code) then frontMarker(tex_markers[code],pc) ;
          end;
          pc:=oldpc ;
          glPopMatrix() ;
        end ;

        if map.isWallRightAtDist(x,y,dir,d) then begin
          c:=map.getColorAtDist(x,y,dir,d) ;
          setColor(c,pc) ;

          xn:=x ; yn:=y ;
          TMap.UpdateXYByDir(xn,yn,dir,d) ;

          rightWall(texs[(xn+yn) mod 4]) ;

          if map.isMarkerAt(xn,yn,TMap.GetRolledDirRight(dir),code) then rightMarker(tex_markers[code],pc) ;
        end
        else begin
          glPushMatrix() ;
          oldpc:=pc ;
          for q := 0 to IfThen(d=0,2,0) do begin
            pc:=0.9-0.9*(d+q-d1)/MAX_DIST ;
            glTranslatef(2.0,0.0,0.0);
            glColor3f(pc, pc, pc);
            roofAndFloor() ;
            c:=map.getColorAtDistRight(x,y,dir,d) ;
            setColor(c,pc) ;

            // Перемещаем вперед на d и влево на q+1
            xn:=x ; yn:=y ;
            TMap.UpdateXYByDir(xn,yn,dir,d) ;
            TMap.UpdateXYByDir(xn,yn,TMap.GetRolledDirRight(dir),q+1) ;
            frontWall(texs[(xn+yn) mod 4]) ;

            if map.isMarkerAt(xn,yn,dir,code) then frontMarker(tex_markers[code],pc) ;
          end;
          pc:=oldpc ;
          glPopMatrix() ;
        end ;

        if (d>0) then
          glColor3f(pc, pc, pc)
        else
          glColor3f(floorc, floorc, floorc) ;
        roofAndFloor() ;
      end ;

      if d<MAX_DIST then
        if not map.isFreeAtDist(x,y,dir,d+1) then begin
          pc:=0.9-0.9*(d-0.5-d1)/MAX_DIST ;
          c:=map.getColorAtDist(x,y,dir,d) ;
          setColor(c,pc) ;

          xn:=x ; yn:=y ;
          TMap.UpdateXYByDir(xn,yn,dir,d) ;

          frontWall(texs[(xn+yn) mod 4]) ;

          if map.isMarkerAt(xn,yn,dir,code) then frontMarker(tex_markers[code],pc) ;

          if map.isObjectAt(xn,yn,code) then renderObject(tex_objects[code],pc) ;

          break ;
        end ;

      glTranslatef(0.0,0.0,2.0);
  end ;
end;

procedure TWallsRender.RotLeft;
begin
  da:=-2.0 ;
  stage2:=False ;
end;

procedure TWallsRender.RotRight;
begin
  da:=2.0 ;
  stage2:=False ;
end;

procedure TWallsRender.SetStart(Ax, Ay: Integer; Adir:TDir);
begin
  x:=Ax ;
  y:=Ay ;
  dir:=Adir ;
end;

procedure TWallsRender.Update(dt: Single);
begin
  if not IsInEffect() then Exit ;

  a:=a+(PI/2)*da*dt ;

  if not stage2 then
    floorc:=floorc-0.1*dt
  else
    floorc:=floorc+0.1*dt ;

  if da<0 then begin
    if not stage2 then begin
      px:=px-da*2*dt ;
      pz:=pz-da*2*dt ;
    end
    else begin
      px:=px-da*2*dt ;
      pz:=pz+da*2*dt ;
    end;

    if not stage2 then begin
    if a<=-PI/4 then begin
      a:=PI/4 ;
      px:=-1 ;
      pz:=-1 ;
      TMap.RollDirLeft(dir) ;
      stage2:=True ;
    end ;
    end ;
    if stage2 then begin
    if a<0 then begin
      a:=0 ;
      da:=0 ;
      px:=0 ;
      pz:=-2 ;
      floorc:=0.9 ;
    end;
    end;
  end ;

  if da>0 then begin
    if not stage2 then begin
      px:=px-da*2*dt ;
      pz:=pz+da*2*dt ;
    end
    else begin
      px:=px-da*2*dt ;
      pz:=pz-da*2*dt ;
    end;

    if not stage2 then begin
    if a>=PI/4 then begin
      a:=-PI/4 ;
      px:=1 ;
      pz:=-1 ;
      TMap.RollDirRight(dir) ;
      stage2:=True ;
    end ;
    end ;
    if stage2 then begin
    if a>0 then begin
      a:=0 ;
      da:=0 ;
      px:=0 ;
      pz:=-2 ;
      floorc:=0.9 ;
    end;
    end;
  end ;

end;

end.

