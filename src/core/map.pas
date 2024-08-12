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

  TMapCell = record
    x:Integer ;
    y:Integer ;
    c:TColor ;
    opened:Boolean ;
    class operator Equal(a: TMapCell; b: TMapCell): Boolean;
    class function NewP(Ax,Ay:Integer; r,g,b:Single):TMapCell ; static ;
  end;

  { TMap }

  TMap = class
  private
    freecells:TUniList<TMapCell> ;
    function getColor(x,y:Integer):TColor ;
    procedure setOpened(x, y: Integer);
    function isPointExist(x,y:Integer):Boolean ;
  public
    class procedure UpdateXYByDir(var x:Integer; var y:Integer; dir:TDir; delta:Integer=1) ;
    class procedure RollDirLeft(var dir:TDir) ;
    class procedure RollDirRight(var dir:TDir) ;
    class function GetDirStr(dir:TDir):string ;
    constructor Create() ;
    destructor Destroy() ; override ;
    function isPointOpened(x,y:Integer):Boolean ;
    function isFreeAtDist(x,y:Integer; dir:TDir; dist:Integer):Boolean ;
    function getColorAtDist(x,y:Integer; dir:TDir; dist:Integer):TColor ;
    function getColorAtDistLeft(x,y:Integer; dir:TDir; dist:Integer):TColor ;
    function getColorAtDistRight(x,y:Integer; dir:TDir; dist:Integer):TColor ;
    function isWallLeftAtDist(x,y:Integer; dir:TDir; dist:Integer):Boolean ;
    function isWallRightAtDist(x,y:Integer; dir:TDir; dist:Integer):Boolean ;
    function canSeeAtToDir(x,y:Integer; dir:TDir):Boolean ;
    procedure UpdateOpenedByPosDirDist(x,y:Integer; dir:TDir; dist:Integer) ;
  end;

implementation

constructor TMap.Create();
begin
  freecells:=TUniList<TMapCell>.Create() ;
  freecells.Add(TMapCell.NewP(0,0,0,1,0)) ;
  freecells.Add(TMapCell.NewP(0,1,0,1,0)) ;
  freecells.Add(TMapCell.NewP(0,2,0,1,0)) ;
  freecells.Add(TMapCell.NewP(0,3,0,1,0)) ;
  freecells.Add(TMapCell.NewP(0,4,0,1,0)) ;
  freecells.Add(TMapCell.NewP(1,4,0,0,1)) ;
  freecells.Add(TMapCell.NewP(2,4,0,0,1)) ;
  freecells.Add(TMapCell.NewP(3,4,0,0,1)) ;
  freecells.Add(TMapCell.NewP(4,4,0,0,1)) ;
  freecells.Add(TMapCell.NewP(5,4,0,0,1)) ;
  freecells.Add(TMapCell.NewP(6,4,0,0,1)) ;
  freecells.Add(TMapCell.NewP(7,4,0,0,1)) ;
  freecells.Add(TMapCell.NewP(8,4,0,0,1)) ;
  freecells.Add(TMapCell.NewP(0,5,0,1,0)) ;
  freecells.Add(TMapCell.NewP(0,6,0,1,0)) ;
  freecells.Add(TMapCell.NewP(0,7,0,1,0)) ;
  freecells.Add(TMapCell.NewP(0,8,0,1,0)) ;
  freecells.Add(TMapCell.NewP(0,9,0,1,0)) ;
  freecells.Add(TMapCell.NewP(-1,9,0,0,1)) ;
  freecells.Add(TMapCell.NewP(-2,9,0,0,1)) ;
  freecells.Add(TMapCell.NewP(-3,9,0,0,1)) ;
  freecells.Add(TMapCell.NewP(0,10,0,1,0)) ;
  freecells.Add(TMapCell.NewP(0,11,0,1,0)) ;
  freecells.Add(TMapCell.NewP(0,12,0,1,0)) ;
  freecells.Add(TMapCell.NewP(0,13,0,1,0)) ;
  freecells.Add(TMapCell.NewP(0,14,0,1,0)) ;
  freecells.Add(TMapCell.NewP(1,14,0,1,0)) ;
  freecells.Add(TMapCell.NewP(2,14,0,1,0)) ;
  freecells.Add(TMapCell.NewP(3,14,0,1,0)) ;
  freecells.Add(TMapCell.NewP(4,14,0,1,1)) ;
end;

destructor TMap.Destroy() ;
begin
  freecells.Free ;
  inherited Destroy ;
end ;

function TMap.getColor(x, y: Integer): TColor;
var p:TMapCell ;
begin
  Result.r:=1 ;
  Result.g:=1 ;
  Result.b:=1 ;
  for p in freecells do
    if (p.x=x)and(p.y=y) then Exit(p.c) ;
end;

procedure TMap.setOpened(x, y: Integer);
var i:Integer ;
    p:TMapCell ;
begin
  for i:=0 to freecells.Count-1 do
    if (freecells[i].x=x)and(freecells[i].y=y) then begin
      p:=freecells[i] ;
      p.opened:=True ;
      freecells[i]:=p ;
      Exit ;
    end ;
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

function TMap.canSeeAtToDir(x, y: Integer; dir: TDir): Boolean;
var xn,yn:Integer ;
    z1,z2:Boolean ;
begin
  xn:=x ; yn:=y ;
  UpdateXYByDir(xn,yn,dir) ;
  // Если спереди есть пространство, то всё ОК
  if isPointExist(xn,yn) then Exit(True) ;

  // Если это коридорный тупик, то смотреть в него тоже можно
  xn:=x ; yn:=y ;
  RollDirRight(dir) ;
  UpdateXYByDir(xn,yn,dir,1) ;
  z1:=isPointExist(xn,yn) ;

  UpdateXYByDir(xn,yn,dir,-2) ;
  z2:=isPointExist(xn,yn) ;

  Result:=(not z1)and(not z2) ;
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
var p:TMapCell ;
begin
  Result:=False ;
  for p in freecells do
    if (p.x=x)and(p.y=y) then Exit(True) ;
end;

function TMap.isPointOpened(x, y: Integer): Boolean;
var p:TMapCell ;
begin
  Result:=False ;
  for p in freecells do
    if (p.x=x)and(p.y=y)and(p.opened) then Exit(True) ;
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

procedure TMap.UpdateOpenedByPosDirDist(x, y: Integer; dir: TDir;
  dist: Integer);
var d:Integer ;
    dirleft,dirright:TDir ;
    x2,y2:Integer ;
begin
  setOpened(x,y) ;

  dirleft:=dir ;
  RollDirLeft(dirleft) ;
  dirright:=dir ;
  RollDirRight(dirright) ;

  for d:=1 to dist-1 do begin
    UpdateXYByDir(x,y,dir) ;
    if isPointExist(x,y) then setOpened(x,y) else Exit ;
    x2:=x ; y2:=y ;
    UpdateXYByDir(x2,y2,dirleft,1) ;
    if isPointExist(x2,y2) then setOpened(x2,y2) ;
    x2:=x ; y2:=y ;
    UpdateXYByDir(x2,y2,dirright,1) ;
    if isPointExist(x2,y2) then setOpened(x2,y2) ;
  end;
end;

class procedure TMap.UpdateXYByDir(var x, y: Integer; dir: TDir; delta:Integer);
begin
  if dir=dLeft then x:=x-delta ;
  if dir=dRight then x:=x+delta ;
  if dir=dUp then y:=y+delta ;
  if dir=dDown then y:=y-delta ;
end;

{ TMapCell }

class function TMapCell.NewP(Ax, Ay: Integer; r,g,b:Single): TMapCell;
begin
  Result.x:=Ax ;
  Result.y:=Ay ;
  Result.c.r:=r ;
  Result.c.g:=g ;
  Result.c.b:=b ;
  Result.opened:=False ;
end;

class operator TMapCell.Equal(a, b: TMapCell): Boolean;
begin
  Result:=(a.x=b.x)and(a.y=b.y) ;
end;

end.
