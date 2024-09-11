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
const
  NEXT_POINT_COUNT = 3 ;
  DIST_FOR_TRUNC = 256 ;
  MIN_LEN = 4 ;
  MAX_LEN = 8 ;

var
  nextpoints:TUniList<TNextPoint> ;

procedure genWay(cells:TUniList<TMapCell>; x,y:Integer; dir:TDir; len:Integer;
  c:TColor) ;
var i:Integer ;
begin
  for i := 0 to len-1 do begin
    TMap.UpdateXYByDir(x,y,dir) ;
    cells.Add(TMapCell.NewP(x,y,c)) ;
  end ;
  if nextpoints.Count<NEXT_POINT_COUNT then nextpoints.Add(TNextPoint.NewP(x,y)) ;
end;

function getRandomLen():Integer ;
begin
  Result:=MIN_LEN+Random(MAX_LEN-MIN_LEN+1) ;
end;

procedure TruncNextPoints() ;
var i:Integer ;
    dir:TDir ;
    maxidx,freeways,maxfreeways:Integer ;
    np:TNextPoint ;
begin
  // Поиск самой лучшей точки - которая наиболее свободна от соседей
  maxidx:=-1 ;
  maxfreeways:=-1 ;
  for i := 0 to nextpoints.Count-1 do begin
    freeways:=0 ;
    for dir in [dLeft,dRight,dUp,dDown] do
      if isNoCrossLine(Result,nextpoints[i].x,nextpoints[i].y,dir,MAX_LEN) then Inc(freeways) ;
    if maxfreeways<freeways then begin
      maxfreeways:=freeways ;
      maxidx:=i ;
    end ;
  end ;

  // Её оставляем, остальные убираем
  np:=nextpoints.ExtractAt(maxidx) ;
  nextpoints.Clear() ;
  nextpoints.Add(np) ;
end;

procedure RandomRemoveOneIfBothExist(newways_dict:TUniDictionary<TDir,Integer>;
  dir1,dir2:TDir) ;
begin
  if newways_dict.ContainsKey(dir1) and newways_dict.ContainsKey(dir2) then begin
    if Random(5)<>0 then begin
      if Random(2)=0 then newways_dict.Remove(dir1) else newways_dict.Remove(dir2) ;
    end;
  end;
end;

var dir:TDir ;
    newways_dict:TUniDictionary<TDir,Integer> ;
    newways:TUniList<TDirLen> ;
    i,len:Integer ;
    ndel:Integer ;
    dirlen:TDirLen ;
    tekdist:Integer ;
    np:TNextPoint ;
begin
  Result:=TUniList<TMapCell>.Create() ;
  newways:=TUniList<TDirLen>.Create() ;
  newways_dict:=TUniDictionary<TDir,Integer>.Create() ;
  nextpoints:=TUniList<TNextPoint>.Create() ;

  Randomize ;

  genWay(Result,0,-1,dUp,getRandomLen(),colors[Random(Length(colors))]) ;

  tekdist:=Result.Count ;
  while Result.Count<size do begin
    if nextpoints.Count=0 then Break ;

    np:=nextpoints.ExtractAt(Random(nextpoints.Count)) ;

    newways_dict.Clear() ;
    for dir in [dLeft,dRight,dUp,dDown] do begin
      len:=getRandomLen() ;
      if isNoCrossLine(Result,np.x,np.y,dir,len) then newways_dict.Add(dir,len) ;
    end ;

    // Уменьшаем вероятность X-перекрестков
    RandomRemoveOneIfBothExist(newways_dict,dLeft,dRight) ;
    RandomRemoveOneIfBothExist(newways_dict,dUp,dDown) ;

    newways.Clear() ;
    for dir in newways_dict.AllKeys do
      newways.Add(TDirLen.NewP(dir,newways_dict[dir])) ;

    if newways.Count>1 then begin
      ndel:=Random(newways.Count) ;
      for i := 0 to ndel-1 do
        newways.Delete(Random(newways.Count)) ;
    end ;

    while newways.Count>0 do begin
      dirlen:=newways.ExtractAt(Random(newways.Count)) ;

      genWay(Result,np.x,np.y,dirlen.dir,dirlen.len,colors[Random(Length(colors))]) ;
      Inc(tekdist,dirlen.len) ;
    end ;

    // Обрезка лишних точек генерации лабиринта
    if tekdist>=DIST_FOR_TRUNC then begin
      tekdist:=0 ;
      TruncNextPoints() ;
    end ;
  end;

  newways.Free ;
  newways_dict.Free ;
  nextpoints.Free ;
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
