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
    font:TSfmlFont ;
    textLoad:TSfmlText ;
    str:string ;
    runner:TTaskBGRunner ;
    function Run(pg:IProgressGetter):TObject ;
  public
    function Init():Boolean ; override ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; override ;
    procedure RenderFunc() ; override ;
    procedure UnInit() ; override ;
  end;

implementation
uses SfmlUtils,
  SceneGame, Map, Constants ;

function TSceneLoader.Init():Boolean ;
begin
  font:=TSfmlFont.Create('fonts'+PATH_SEP+'arial.ttf');
  textLoad:=createText(font,'',24,SfmlWhite) ;
  str:='' ;

  runner:=TTaskBGRunner.Create() ;

  Result:=True ;
end ;

function TSceneLoader.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
var basestr:string ;
begin
  Result:=Normal ;

  runner.RunTaskIfNot(Run) ;
  basestr:=runner.getProgressMessage() ;

  t:=t+dt ;
  if t>0.5 then begin
    t:=0 ;
    str:=str+'.' ;
    textLoad.UnicodeString:=basestr+str ;
  end;

  if runner.isTaskReady() then begin
    nextscene:=TSceneGame.Create(TMap(runner.getResult())) ;
    Exit(TSceneResult.Switch) ;
  end;
end ;

procedure TSceneLoader.RenderFunc() ;
begin
  drawText(textLoad,30,728) ;
end ;

function TSceneLoader.Run(pg: IProgressGetter): TObject;
begin
  pg.SetMessage('Map generation') ;
  Result:=TMap.Create(128) ;
  TMap(Result).PopulateObjects(12,OBJECTS_COUNT) ;
end;

procedure TSceneLoader.UnInit() ;
begin
  font.Free ;
  textLoad.Free ;
end ;

end.
