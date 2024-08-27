unit mapgenerator;

interface
uses Helpers,
  Map ;

type
  TMapGenerator = class
  private
    size:Integer ;
    colors:array of TColor ;
    function isNoCrossLine(const cells:TUniList<TMapCell>; x,y:Integer;
      dir:TDir; len:Integer):Boolean ;
    // Дублирование с кодом TMap
    function isPointExist(const cells: TUniList<TMapCell>; x,
      y: Integer): Boolean;
  public
    constructor Create(Asize:Integer) ;
    function genCells():TUniList<TMapCell> ;
  end;

implementation

{ TMapGenerator }

constructor TMapGenerator.Create(Asize: Integer);
begin
  size:=Asize ;
  SetLength(colors,6) ;
  colors[0].r:=1 ; colors[0].g:=0 ; colors[0].b:=0 ;
  colors[1].r:=0 ; colors[1].g:=1 ; colors[1].b:=0 ;
  colors[2].r:=0 ; colors[2].g:=0 ; colors[2].b:=1 ;
  colors[3].r:=1 ; colors[3].g:=1 ; colors[3].b:=0 ;
  colors[4].r:=0 ; colors[4].g:=1 ; colors[4].b:=1 ;
  colors[5].r:=1 ; colors[5].g:=0 ; colors[5].b:=1 ;
end;

function TMapGenerator.genCells: TUniList<TMapCell>;
var dir:TDir ;
    newways:TUniList<TDir> ;
    nextpoints:TUniList<TPoint> ;
    np:TPoint ;
    i,len:Integer ;
    ndel:Integer ;
const
  NEXT_POINT_COUNT = 3 ;

procedure genWay(cells:TUniList<TMapCell>; x,y:Integer; dir:TDir; len:Integer;
  c:TColor) ;
var i:Integer ;
begin
  for i := 0 to len-1 do begin
    TMap.UpdateXYByDir(x,y,dir) ;
    cells.Add(TMapCell.NewP(x,y,c)) ;
  end ;
  if nextpoints.Count<NEXT_POINT_COUNT then nextpoints.Add(TPoint.NewP(x,y)) ;
end;

begin
  Result:=TUniList<TMapCell>.Create() ;
  newways:=TUniList<TDir>.Create ;
  nextpoints:=TUniList<TPoint>.Create ;

  Randomize ;

  genWay(Result,0,-1,dUp,4+Random(4),colors[Random(Length(colors))]) ;

  while Result.Count<size do begin
    if nextpoints.Count=0 then Break ;

    np:=nextpoints.ExtractAt(Random(nextpoints.Count)) ;

    newways.Clear() ;
    len:=4+Random(4) ;
    for dir in [dLeft,dRight,dUp,dDown] do
      if isNoCrossLine(Result,np.x,np.y,dir,len) then newways.Add(dir) ;

    if newways.Count>1 then begin
      ndel:=Random(newways.Count) ;
      for i := 0 to ndel-1 do
        newways.Delete(Random(newways.Count)) ;
    end ;

    while newways.Count>0 do begin
      dir:=newways.ExtractAt(Random(newways.Count)) ;

      genWay(Result,np.x,np.y,dir,len,colors[Random(Length(colors))]) ;
    end ;
  end;

end;

function TMapGenerator.isPointExist(const cells: TUniList<TMapCell>; x, y: Integer): Boolean;
var p:TMapCell ;
begin
  Result:=False ;
  for p in cells do
    if (p.x=x)and(p.y=y) then Exit(True) ;
end;

function TMapGenerator.isNoCrossLine(const cells: TUniList<TMapCell>; x,
  y: Integer; dir: TDir; len:Integer): Boolean;
var i:Integer ;
    dleft,dright:TDir ;
    xn,yn:Integer ;
begin
  Result:=True ;
  dleft:=TMap.GetRolledDirLeft(dir) ;
  dright:=TMap.GetRolledDirRight(dir) ;
  for i := 0 to len do begin
    TMap.UpdateXYByDir(x,y,dir) ;
    if isPointExist(cells,x,y) then Exit(False) ;

    xn:=x ; yn:=y ;
    TMap.UpdateXYByDir(xn,yn,dleft) ;
    if isPointExist(cells,xn,yn) then Exit(False) ;
    xn:=x ; yn:=y ;
    TMap.UpdateXYByDir(xn,yn,dright) ;
    if isPointExist(cells,xn,yn) then Exit(False) ;
  end;
end;

end.
