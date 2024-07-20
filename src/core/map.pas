unit Map;

interface

uses
  Classes, SysUtils,
  Helpers ;

type
  TDir = (dLeft,dUp,dRight,dDown) ;

  TColor = record
    r:Single ;
    g:Single ;
    b:Single ;
  end ;

  TPoint = record
    x:Integer ;
    y:Integer ;
    c:TColor ;
    class operator Equal(a: TPoint; b: TPoint): Boolean;
    class function NewP(Ax,Ay:Integer; r,g,b:Single):TPoint ; static ;
  end;

  { TMap }

  TMap = class
  private
    freecells:TUniList<TPoint> ;
    function isPointExist(x,y:Integer):Boolean ;
    function getColor(x,y:Integer):TColor ;
  public
    class procedure UpdateXYByDir(var x:Integer; var y:Integer; dir:TDir; delta:Integer=1) ;
    class procedure RollDirLeft(var dir:TDir) ;
    class procedure RollDirRight(var dir:TDir) ;
    class function GetDirStr(dir:TDir):string ;
    constructor Create() ;
    destructor Destroy() ; override ;
    function isFreeAtDist(x,y:Integer; dir:TDir; dist:Integer):Boolean ;
    function getColorAtDist(x,y:Integer; dir:TDir; dist:Integer):TColor ;
    function getColorAtDistLeft(x,y:Integer; dir:TDir; dist:Integer):TColor ;
    function getColorAtDistRight(x,y:Integer; dir:TDir; dist:Integer):TColor ;
    function isWallLeftAtDist(x,y:Integer; dir:TDir; dist:Integer):Boolean ;
    function isWallRightAtDist(x,y:Integer; dir:TDir; dist:Integer):Boolean ;
  end;

implementation

constructor TMap.Create();
begin
  freecells:=TUniList<TPoint>.Create() ;
  freecells.Add(TPoint.NewP(0,0,0,1,0)) ;
  freecells.Add(TPoint.NewP(0,1,0,1,0)) ;
  freecells.Add(TPoint.NewP(0,2,0,1,0)) ;
  freecells.Add(TPoint.NewP(0,3,0,1,0)) ;
  freecells.Add(TPoint.NewP(0,4,0,1,0)) ;
  freecells.Add(TPoint.NewP(1,4,0,0,1)) ;
  freecells.Add(TPoint.NewP(2,4,0,0,1)) ;
  freecells.Add(TPoint.NewP(3,4,0,0,1)) ;
  freecells.Add(TPoint.NewP(4,4,0,0,1)) ;
  freecells.Add(TPoint.NewP(5,4,0,0,1)) ;
  freecells.Add(TPoint.NewP(6,4,0,0,1)) ;
  freecells.Add(TPoint.NewP(7,4,0,0,1)) ;
  freecells.Add(TPoint.NewP(8,4,0,0,1)) ;
  freecells.Add(TPoint.NewP(0,5,0,1,0)) ;
  freecells.Add(TPoint.NewP(0,6,0,1,0)) ;
  freecells.Add(TPoint.NewP(0,7,0,1,0)) ;
  freecells.Add(TPoint.NewP(0,8,0,1,0)) ;
  freecells.Add(TPoint.NewP(0,9,0,1,0)) ;
  freecells.Add(TPoint.NewP(-1,9,0,0,1)) ;
  freecells.Add(TPoint.NewP(-2,9,0,0,1)) ;
  freecells.Add(TPoint.NewP(-3,9,0,0,1)) ;
  freecells.Add(TPoint.NewP(0,10,0,1,0)) ;
  freecells.Add(TPoint.NewP(0,11,0,1,0)) ;
  freecells.Add(TPoint.NewP(0,12,0,1,0)) ;
  freecells.Add(TPoint.NewP(0,13,0,1,0)) ;
  freecells.Add(TPoint.NewP(0,14,0,1,0)) ;
  freecells.Add(TPoint.NewP(1,14,0,1,0)) ;
  freecells.Add(TPoint.NewP(2,14,0,1,0)) ;
  freecells.Add(TPoint.NewP(3,14,0,1,0)) ;
  freecells.Add(TPoint.NewP(4,14,0,1,1)) ;
end;

destructor TMap.Destroy() ;
begin
  freecells.Free ;
  inherited Destroy ;
end ;

function TMap.getColor(x, y: Integer): TColor;
var p:TPoint ;
begin
  Result.r:=1 ;
  Result.g:=1 ;
  Result.b:=1 ;
  for p in freecells do
    if (p.x=x)and(p.y=y) then Exit(p.c) ;
end;

function TMap.getColorAtDist(x, y: Integer; dir: TDir; dist: Integer): TColor;
begin
  UpdateXYByDir(x,y,dir,dist) ;
  Result:=getColor(x,y) ;
end;

function TMap.getColorAtDistLeft(x, y: Integer; dir: TDir;
  dist: Integer): TColor;
begin
  UpdateXYByDir(x,y,dir,dist) ;
  RollDirLeft(dir) ;
  UpdateXYByDir(x,y,dir,1) ;
  Result:=getColor(x,y) ;
end;

function TMap.getColorAtDistRight(x, y: Integer; dir: TDir;
  dist: Integer): TColor;
begin
  UpdateXYByDir(x,y,dir,dist) ;
  RollDirRight(dir) ;
  UpdateXYByDir(x,y,dir,1) ;
  Result:=getColor(x,y) ;
end;

class function TMap.GetDirStr(dir: TDir): string;
begin
  Result:='???' ;
  case dir of
    dLeft: Result:='Left' ;
    dUp:  Result:='Up' ;
    dRight:  Result:='Right' ;
    dDown:  Result:='Down' ;
  end;
end;

function TMap.isFreeAtDist(x, y: Integer; dir: TDir; dist: Integer): Boolean;
begin
  UpdateXYByDir(x,y,dir,dist) ;
  Result:=isPointExist(x,y)
end;

function TMap.isPointExist(x, y: Integer): Boolean;
var p:TPoint ;
begin
  Result:=False ;
  for p in freecells do
    if (p.x=x)and(p.y=y) then Exit(True) ;
end;

function TMap.isWallLeftAtDist(x, y: Integer; dir: TDir;
  dist: Integer): Boolean;
begin
  UpdateXYByDir(x,y,dir,dist) ;
  RollDirLeft(dir) ;
  UpdateXYByDir(x,y,dir,1) ;
  Result:=not isPointExist(x,y) ;
end;

function TMap.isWallRightAtDist(x, y: Integer; dir: TDir;
  dist: Integer): Boolean;
begin
  UpdateXYByDir(x,y,dir,dist) ;
  RollDirRight(dir) ;
  UpdateXYByDir(x,y,dir,1) ;
  Result:=not isPointExist(x,y)
end;

class procedure TMap.RollDirLeft(var dir: TDir);
var n:Integer ;
begin
  n:=Ord(dir)-1 ;
  if n<Ord(Low(TDir)) then n:=Ord(High(TDir)) ;
  dir:=TDir(n) ;
end;

class procedure TMap.RollDirRight(var dir: TDir);
var n:Integer ;
begin
  n:=Ord(dir)+1 ;
  if n>Ord(High(TDir)) then n:=Ord(Low(TDir)) ;
  dir:=TDir(n) ;
end;

class procedure TMap.UpdateXYByDir(var x, y: Integer; dir: TDir; delta:Integer);
begin
  if dir=dLeft then x:=x-delta ;
  if dir=dRight then x:=x+delta ;
  if dir=dUp then y:=y+delta ;
  if dir=dDown then y:=y-delta ;
end;

{ TPoint }

class function TPoint.NewP(Ax, Ay: Integer; r,g,b:Single): TPoint;
begin
  Result.x:=Ax ;
  Result.y:=Ay ;
  Result.c.r:=r ;
  Result.c.g:=g ;
  Result.c.b:=b ;
end;

class operator TPoint.Equal(a, b: TPoint): Boolean;
begin
  Result:=(a.x=b.x)and(a.y=b.y) ;
end;

end.
