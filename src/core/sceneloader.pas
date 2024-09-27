unit SceneLoader;

interface

uses
  Classes, SysUtils,
  SfmlSystem,SfmlWindow,SfmlGraphics,
  Scene, Helpers, TaskBGRunner ;

type
  { TSceneLoader }

  TSceneLoader = class(TScene)
  private
    t:Single ;
    textLoad:TSfmlText ;
    str:string ;
    mapsize:Integer ;
    mapobjects:Integer ;
    runner:TTaskBGRunner ;
    oldbasestr:string ;
    function Run(pg:IProgressGetter):TObject ;
  public
    constructor Create(mapsizeidx:Integer) ;
    function Init():Boolean ; override ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; override ;
    procedure RenderFunc() ; override ;
    procedure UnInit() ; override ;
  end;

implementation
uses SfmlUtils,
  CommonData, SceneGame, Map, Constants ;

function TSceneLoader.Init():Boolean ;
begin
  textLoad:=createText(TCommonData.Font,'',24,SfmlBlack) ;
  str:='' ;

  runner:=TTaskBGRunner.Create() ;

  Result:=True ;
end ;

constructor TSceneLoader.Create(mapsizeidx: Integer);
begin
  case mapsizeidx of
    0: begin mapsize:=256 ; mapobjects:=3 ; end ;
    1: begin mapsize:=512 ; mapobjects:=6 ; end ;
    2: begin mapsize:=1024 ; mapobjects:=9 ; end ;
    3: begin mapsize:=2048 ; mapobjects:=12 ; end ;
    4: begin mapsize:=4096 ; mapobjects:=12 ; end ;
  end;
end;

function TSceneLoader.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
var basestr:string ;
begin
  Result:=Normal ;

  runner.RunTaskIfNot(Run) ;
  basestr:=runner.getProgressMessage() ;
  if oldbasestr<>basestr then begin
    textLoad.UnicodeString:=UTF8Decode(basestr) ;
    oldbasestr:=basestr ;
  end;

  t:=t+dt ;
  if t>0.5 then begin
    t:=0 ;
    str:=str+'.' ;
    textLoad.UnicodeString:=UTF8Decode(basestr+str) ;
  end;

  if runner.isTaskReady() then begin
    nextscene:=TSceneGame.Create(TMap(runner.getResult())) ;
    Exit(TSceneResult.Switch) ;
  end;
end ;

procedure TSceneLoader.RenderFunc() ;
begin
  window.Clear(SfmlWhite) ;
  drawText(textLoad,30,728) ;
end ;

function TSceneLoader.Run(pg: IProgressGetter): TObject;
begin
  pg.SetMessage(TCommonData.texts.getText('MAP_GEN')) ;
  Result:=TMap.Create(mapsize) ;
  TMap(Result).PopulateObjects(mapobjects,OBJECTS_COUNT) ;
end;

procedure TSceneLoader.UnInit() ;
begin
  textLoad.Free ;
end ;

end.
