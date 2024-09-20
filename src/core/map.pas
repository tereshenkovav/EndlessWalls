unit Map;

interface

uses
  Classes, SysUtils,
  Helpers ;

type
  TDir = (dLeft,dUp,dRight,dDown) ;

  TDirLen = record
    dir:TDir ;
    len:Integer ;
    class operator Equal(a: TDirLen; b: TDirLen): Boolean ;
    class function NewP(Adir:TDir;Alen:Integer):TDirLen ; static ;
  end ;

  T2DMap = array of array of Boolean ;

  TColor = record
    r:Single ;
    g:Single ;
    b:Single ;
  end ;

  TNextPoint = record
    x:Integer ;
    y:Integer ;
    class operator Equal(a: TNextPoint; b: TNextPoint): Boolean ;
    class function NewP(Ax,Ay:Integer):TNextPoint ; static ;
  end ;

  TMapCell = record
    x:Integer ;
    y:Integer ;
    c:TColor ;
    opened:Boolean ;
    dark:Boolean ;
    class operator Equal(a: TMapCell; b: TMapCell): Boolean;
    class function NewP(Ax,Ay:Integer; Ac:TColor):TMapCell ; static ;
  end;

  TMarker = record
    x:Integer ;
    y:Integer ;
    dir:TDir ;
    code:Integer ;
    class operator Equal(a: TMarker; b: TMarker): Boolean;
    class function NewP(Ax,Ay:Integer; Adir:TDir; Acode:Integer):TMarker ; static ;
  end ;

  TQuestObject = record
    x:Integer ;
    y:Integer ;
    code:Integer ;
    class operator Equal(a: TQuestObject; b: TQuestObject): Boolean;
    class function NewP(Ax,Ay:Integer; Acode:Integer):TQuestObject ; static ;
  end ;

  { TMap }

  TMap = class
  private
    freecells:TUniList<TMapCell> ;
    idxcells:TUniDictionary<Integer,Integer> ;
    markers:TUniList<TMarker> ;
    objects:TUniList<TQuestObject> ;
    function getColor(x,y:Integer):TColor ;
    procedure setOpened(x, y: Integer);
    procedure setDark(x, y: Integer);
    function isPointExist(x,y:Integer):Boolean ;
    function getIndexByXY(x,y:Integer):Integer ;
  public
    class procedure UpdateXYByDir(var x:Integer; var y:Integer; dir:TDir; delta:Integer=1) ;
    class procedure RollDirLeft(var dir:TDir) ;
    class procedure RollDirRight(var dir:TDir) ;
    class function GetRolledDirLeft(dir:TDir):TDir ;
    class function GetRolledDirRight(dir:TDir):TDir ;
    class function GetDirStr(dir:TDir):string ;
    constructor Create(size:Integer) ;
    destructor Destroy() ; override ;
    procedure PopulateObjects(count:Integer) ;
    function getResult():Integer ;
    function getTotalLen():Integer ;
    function isPointOpened(x,y:Integer):Boolean ;
    function isPointDark(x, y: Integer):Boolean;
    function isFreeAtDist(x,y:Integer; dir:TDir; dist:Integer):Boolean ;
    function getColorAtDist(x,y:Integer; dir:TDir; dist:Integer):TColor ;
    function getColorAtDistLeft(x,y:Integer; dir:TDir; dist:Integer):TColor ;
    function getColorAtDistRight(x,y:Integer; dir:TDir; dist:Integer):TColor ;
    function isWallLeftAtDist(x,y:Integer; dir:TDir; dist:Integer):Boolean ;
    function isWallRightAtDist(x,y:Integer; dir:TDir; dist:Integer):Boolean ;
    function canSeeAtToDir(x,y:Integer; dir:TDir):Boolean ;
    function canSetMarker(x,y:Integer; dir,markerdir:TDir):Boolean ;
    function isMarkerAt(x,y:Integer; dir:TDir; var markercode:Integer):Boolean ;
    function isObjectAt(x,y:Integer; var objectcode:Integer):Boolean ;
    procedure UpdateOpenedByPosDirDist(x,y:Integer; dir:TDir; dist:Integer) ;
    procedure SetMarker(x,y:Integer; dir,markerdir:TDir; code:Integer) ;
    function SaveTo2D(var sx:Integer; var sy:Integer; var startx:Integer; var starty:Integer):T2DMap ;
  end;

implementation
uses MapGenerator ;

const
  MAX_TRY_COUNT=20 ;
  MIN_PROCENT_FOR_SAVE = 0.8 ;

// Лучше использовать полноценный индекс через 64-битное значение или TPoint
function XY2Int(x,y:Integer):Integer ;
begin
  Result:=x*10000+y ;
end;

constructor TMap.Create(size:Integer);
var i:Integer ;
begin
  with TMapGenerator.Create(size) do begin
    for i := 0 to MAX_TRY_COUNT-1 do begin
      if Assigned(freecells) then freecells.Free ;
      freecells:=genCells() ;
      if freecells.Count>=size*MIN_PROCENT_FOR_SAVE then Break ;
    end;
    Free ;
  end;

  idxcells:=TUniDictionary<Integer,Integer>.Create() ;
  for i:=0 to freecells.Count-1 do
    idxcells.Add(XY2Int(freecells[i].x,freecells[i].y),i) ;

  markers:=TUniList<TMarker>.Create ;
  objects:=TUniList<TQuestObject>.Create ;
end;

destructor TMap.Destroy() ;
begin
  freecells.Free ;
  idxcells.Free ;
  markers.Free ;
  objects.Free ;
  inherited Destroy ;
end ;

class function TMap.GetRolledDirLeft(dir: TDir): TDir;
begin
  RollDirLeft(dir) ;
  Result:=dir ;
end;

class function TMap.GetRolledDirRight(dir: TDir): TDir;
begin
  RollDirRight(dir) ;
  Result:=dir ;
end;

function TMap.getTotalLen: Integer;
begin
  Result:=freecells.Count ;
end;

function TMap.getColor(x, y: Integer): TColor;
var idx:Integer ;
begin
  Result.r:=1 ;
  Result.g:=1 ;
  Result.b:=1 ;
  idx:=getIndexByXY(x,y) ;
  if idx<>-1 then Result:=freecells[idx].c ;
end;

procedure TMap.setDark(x, y: Integer);
var idx:Integer ;
    p:TMapCell ;
begin
  idx:=getIndexByXY(x,y) ;
  if idx<>-1 then begin
    p:=freecells[idx] ;
    if p.opened then Exit ;
    p.dark:=True ;
    freecells[idx]:=p ;
  end ;
end;

function TMap.canSetMarker(x, y: Integer; dir, markerdir: TDir): Boolean;
begin
  if markerdir=dLeft then RollDirLeft(dir) ;
  if markerdir=dRight then RollDirRight(dir) ;
  UpdateXYByDir(x,y,dir) ;
  Result:=not isPointExist(x,y) ;
end;

procedure TMap.SetMarker(x, y: Integer; dir, markerdir: TDir; code: Integer);
begin
  if markerdir=dLeft then RollDirLeft(dir) ;
  if markerdir=dRight then RollDirRight(dir) ;
  markers.Add(TMarker.NewP(x,y,dir,code)) ;
end;

procedure TMap.setOpened(x, y: Integer);
var idx:Integer ;
    p:TMapCell ;
begin
  idx:=getIndexByXY(x,y) ;
  if idx<>-1 then begin
    p:=freecells[idx] ;
    p.opened:=True ;
    p.dark:=False ;
    freecells[idx]:=p ;
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

function TMap.getIndexByXY(x, y: Integer): Integer;
begin
  if idxcells.ContainsKey(XY2Int(x,y)) then
    Result:=idxcells[XY2Int(x,y)]
  else
    Result:=-1 ;
end;

// Реализация неоптимальна, нужно вести учет открытых ячеек в момент setOpened
function TMap.getResult: Integer;
var p:TMapCell ;
begin
  Result:=0 ;
  for p in freecells do
    if p.opened then Inc(Result) ;
end;

function TMap.isFreeAtDist(x, y: Integer; dir: TDir; dist: Integer): Boolean;
begin
  UpdateXYByDir(x,y,dir,dist) ;
  Result:=isPointExist(x,y)
end;

function TMap.isMarkerAt(x, y: Integer; dir: TDir;
  var markercode: Integer): Boolean;
var m:TMarker ;
begin
  Result:=False ;
  for m in markers do
    if (m.x=x)and(m.y=y)and(m.dir=dir) then begin
      markercode:=m.code ;
      Exit(True) ;
    end;
end;

function TMap.isObjectAt(x, y: Integer; var objectcode: Integer): Boolean;
var o:TQuestObject ;
begin
  Result:=False ;
  for o in objects do
    if (o.x=x)and(o.y=y) then begin
      objectcode:=o.code ;
      Exit(True) ;
    end;
end;

function TMap.isPointDark(x, y: Integer): Boolean;
var idx:Integer ;
begin
  idx:=getIndexByXY(x,y) ;
  if idx=-1 then Result:=False else Result:=freecells[idx].dark ;
end;

function TMap.isPointExist(x, y: Integer): Boolean;
begin
  Result:=getIndexByXY(x,y)<>-1 ;
end;

function TMap.isPointOpened(x, y: Integer): Boolean;
var idx:Integer ;
begin
  idx:=getIndexByXY(x,y) ;
  if idx=-1 then Result:=False else Result:=freecells[idx].opened ;
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

procedure TMap.PopulateObjects(count: Integer);
var c:TMapCell ;
    d:TDir ;
    cnt:Integer ;
    xn,yn:Integer ;
    list:TUniList<TNextPoint> ;
    i:Integer ;
    np:TNextPoint ;
begin
  list:=TUniList<TNextPoint>.Create() ;
  for c in freecells do begin
    cnt:=0 ;
    for d in [dLeft,dRight,dUp,dDown] do begin
      xn:=c.x ; yn:=c.y ;
      TMap.UpdateXYByDir(xn,yn,d) ;
      if isPointExist(xn,yn) then Inc(cnt) ;
    end;
    if (cnt=1)and((c.x<>0)and(c.y<>0)) then list.Add(TNextPoint.NewP(c.x,c.y)) ;
  end;

  for i := 0 to count-1 do begin
    if list.Count=0 then break ;
    np:=list.ExtractAt(Random(list.Count)) ;
    objects.Add(TQuestObject.NewP(np.x,np.y,i)) ;
  end;

  list.Free ;
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

function TMap.SaveTo2D(var sx:Integer; var sy:Integer;
   var startx:Integer; var starty:Integer): T2DMap;
var minx,miny,maxx,maxy:Integer ;
    p:TMapCell ;
    i,j:Integer ;
begin
  minx:=freecells[0].x ;
  miny:=freecells[0].y ;
  maxx:=freecells[0].x ;
  maxy:=freecells[0].y ;
  for p in freecells do begin
    if (p.x<minx) then minx:=p.x ;
    if (p.x>maxx) then maxx:=p.x ;
    if (p.y<miny) then miny:=p.y ;
    if (p.y>maxy) then maxy:=p.y ;
  end;
  sx:=maxx-minx+1 ;
  sy:=maxy-miny+1 ;
  startx:=-minx ;
  starty:=-miny ;
  SetLength(Result,sx,sy) ;
  for i := 0 to sx-1 do
    for j := 0 to sy-1 do
      Result[i][j]:=False ;
  for p in freecells do
    Result[p.x-minx][p.y-miny]:=True ;
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
    if isPointExist(x2,y2) then begin
      setOpened(x2,y2) ;
      UpdateXYByDir(x2,y2,dirleft,1) ;
      setDark(x2,y2) ;
    end;
    x2:=x ; y2:=y ;
    UpdateXYByDir(x2,y2,dirright,1) ;
    if isPointExist(x2,y2) then begin
      setOpened(x2,y2) ;
      UpdateXYByDir(x2,y2,dirright,1) ;
      setDark(x2,y2) ;
    end;
  end;
  UpdateXYByDir(x,y,dir) ;
  if isPointExist(x,y) then setDark(x,y) ;
end;

class procedure TMap.UpdateXYByDir(var x, y: Integer; dir: TDir; delta:Integer);
begin
  if dir=dLeft then x:=x-delta ;
  if dir=dRight then x:=x+delta ;
  if dir=dUp then y:=y+delta ;
  if dir=dDown then y:=y-delta ;
end;

{ TMapCell }

class function TMapCell.NewP(Ax, Ay: Integer; Ac:TColor): TMapCell;
begin
  Result.x:=Ax ;
  Result.y:=Ay ;
  Result.c:=Ac ;
  Result.opened:=False ;
  Result.dark:=False ;
end;

class operator TMapCell.Equal(a, b: TMapCell): Boolean;
begin
  Result:=(a.x=b.x)and(a.y=b.y) ;
end;

{ TMarker }

class operator TMarker.Equal(a, b: TMarker): Boolean;
begin
  Result:=(a.x=b.x)and(a.y=b.y)and(a.dir=b.dir) ;
end;

class function TMarker.NewP(Ax, Ay: Integer; Adir: TDir;
  Acode: Integer): TMarker;
begin
  Result.x:=Ax ;
  Result.y:=Ay ;
  Result.dir:=Adir ;
  Result.code:=Acode ;
end;

{ TNextPoint }

class operator TNextPoint.Equal(a, b: TNextPoint): Boolean;
begin
  Result:=(a.x=b.x)and(a.y=b.y) ;
end;

class function TNextPoint.NewP(Ax, Ay: Integer): TNextPoint;
begin
  Result.x:=Ax ;
  Result.y:=Ay ;
end;

{ TDirLen }

class operator TDirLen.Equal(a, b: TDirLen): Boolean;
begin
  Result:=(a.dir=b.dir)and(a.len=b.len) ;
end;

class function TDirLen.NewP(Adir: TDir; Alen: Integer): TDirLen;
begin
  Result.dir:=Adir ;
  Result.len:=Alen ;
end;

{ TQuestObject }

class operator TQuestObject.Equal(a, b: TQuestObject): Boolean;
begin
  Result:=(a.x=b.x)and(a.y=b.y) ;
end;

class function TQuestObject.NewP(Ax, Ay, Acode: Integer): TQuestObject;
begin
  Result.x:=Ax ;
  Result.y:=Ay ;
  Result.code:=Acode ;
end;

end.
