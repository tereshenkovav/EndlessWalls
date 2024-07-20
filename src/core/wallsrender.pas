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
    tex_marker:TSfmlTexture ;
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
  end;

implementation
uses Math ;

constructor TWallsRender.Create(Amap:TMap; Aw,Ah:Integer);
begin
  map:=Amap ;
  w:=Aw ;
  h:=Ah ;
  a:=0 ;
  da:=0 ;
  px:=0 ;
  pz:=-2 ;
  floorc:=0.9 ;
  tex_marker:=TSfmlTexture.Create('images'+PATH_SEP+'marker.png') ;
end;

destructor TWallsRender.Destroy() ;
begin
  tex_marker.Free ;
  inherited Destroy ;
end ;

function TWallsRender.getDir: TDir;
begin
  Result:=dir ;
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

procedure rightWall() ;
begin
    glBegin(GL_POLYGON);
        glVertex3f(1.0, -1.0, -1.0);
        glVertex3f(1.0, -1.0, 1.0);
        glVertex3f(1.0, 1.0, 1.0);
        glVertex3f(1.0, 1.0, -1.0);
    glEnd();
end ;

procedure leftWall() ;
begin
    glBegin(GL_POLYGON);
        glVertex3f(-1.0, -1.0, -1.0);
        glVertex3f(-1.0, -1.0, 1.0);
        glVertex3f(-1.0, 1.0, 1.0);
        glVertex3f(-1.0, 1.0, -1.0);
    glEnd();
end ;

procedure frontWall(marker:Boolean; tex_marker:TSfmlTexture) ;
begin
    glBegin(GL_POLYGON);
        glVertex3f(-1.0, -1.0, 1.0);
        glVertex3f(1.0, -1.0, 1.0);
        glVertex3f(1.0, 1.0, 1.0);
        glVertex3f(-1.0, 1.0, 1.0);
    glEnd();

    if marker then begin
      glColor3f(1.0,1.0,1.0) ;
      tex_marker.Bind() ;
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
const MAX_DIST = 6 ;
begin
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D);
  glEnable(GL_ALPHA_TEST);

    glViewport(0,0,w,h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(60, w/h, 0.01, 100.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
    glAlphaFunc(GL_GREATER, 0.99);

  gluLookAt(px,0,pz,px+Sin(a),0,pz+Cos(a),0,-1,0) ;
  d1:=0 ;
  for d:=0 to MAX_DIST do begin
      pc:=0.9-0.9*(d-d1)/MAX_DIST ;

      if map.isFreeAtDist(x,y,dir,d) then begin

        if map.isWallLeftAtDist(x,y,dir,d) then begin
          c:=map.getColorAtDist(x,y,dir,d) ;
          setColor(c,pc) ;
          leftWall() ;
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
            frontWall(false,tex_marker) ;
          end;
          pc:=oldpc ;
          glPopMatrix() ;
        end ;

        if map.isWallRightAtDist(x,y,dir,d) then begin
          c:=map.getColorAtDist(x,y,dir,d) ;
          setColor(c,pc) ;
          rightWall() ;
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
            frontWall(false,tex_marker) ;
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
          frontWall((c.g=1)and(c.b=1),tex_marker) ;
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

