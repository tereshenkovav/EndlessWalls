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
var tekc:Integer ;
    x,y:Integer ;
    dir,dirl,dirr:TDir ;
    leftc:Integer ;
    leftd:Integer ;
    newways:TUniList<TDir> ;
begin
  Result:=TUniList<TMapCell>.Create() ;
  newways:=TUniList<TDir>.Create ;

  Randomize ;

  tekc:=0 ;
  x:=0 ; y:=0 ; dir:=dUp ;
  leftc:=4+Random(4) ;
  leftd:=4+Random(4) ;
  while Result.Count<size do begin
    Result.Add(TMapCell.NewP(x,y,colors[tekc])) ;
    TMap.UpdateXYByDir(x,y,dir) ;

    Dec(leftc) ;
    if leftc<=0 then begin
      leftc:=4+Random(4) ;
      tekc:=Random(Length(colors)) ;
    end ;

    Dec(leftd) ;
    if leftd<=0 then begin
      leftd:=4+Random(4) ;
      newways.Clear() ;
      dirl:=TMap.GetRolledDirLeft(dir) ;
      dirr:=TMap.GetRolledDirRight(dir) ;
      if isNoCrossLine(Result,x,y,dirl,leftd) then newways.Add(dirl) ;
      if isNoCrossLine(Result,x,y,dirr,leftd) then newways.Add(dirr) ;
      if newways.Count=0 then
        if isNoCrossLine(Result,x,y,dir,leftd) then newways.Add(dir) ;

      if newways.Count=0 then Break ;

      dir:=newways[Random(newways.Count)] ;
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
begin
  Result:=True ;
  for i := 0 to len do begin
    TMap.UpdateXYByDir(x,y,dir) ;
    if isPointExist(cells,x,y) then Exit(False) ;
  end;
end;

end.
