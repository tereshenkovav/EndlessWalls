unit SceneLoader;

interface

uses
  Classes, SysUtils,
  SfmlSystem,SfmlWindow,SfmlGraphics,
  Scene, Helpers ;

type
  TBackgroundTask = class(TThread)
  private
    ready:Boolean ;
    size:Integer ;
    map:TObject ;
  protected
    procedure Execute; override ;
  public
    constructor Create(Asize:Integer) ;
    function getResult():TObject ;
    function isReady():Boolean ;
  end;

  { TSceneLoader }

  TSceneLoader = class(TScene)
  private
    t:Single ;
    font:TSfmlFont ;
    textLoad:TSfmlText ;
    str:string ;
    task:TBackgroundTask ;
  public
    function Init():Boolean ; override ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; override ;
    procedure RenderFunc() ; override ;
    procedure UnInit() ; override ;
  end;

implementation
uses SceneGame, Map, SfmlUtils ;

function TSceneLoader.Init():Boolean ;
begin
  font:=TSfmlFont.Create('fonts'+PATH_SEP+'arial.ttf');
  str:='Generate map' ;
  textLoad:=createText(font,str,24,SfmlWhite) ;

  task:=TBackgroundTask.Create(4096) ;

  Result:=True ;
end ;

function TSceneLoader.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
begin
  Result:=Normal ;

  if task.Suspended then task.Start() ;

  t:=t+dt ;
  if t>0.5 then begin
    t:=0 ;
    str:=str+'.' ;
    textLoad.UnicodeString:=str ;
  end;

  if task.isReady() then begin
    nextscene:=TSceneGame.Create(TMap(task.getResult())) ;
    Exit(TSceneResult.Switch) ;
  end;
end ;

procedure TSceneLoader.RenderFunc() ;
begin
  drawText(textLoad,30,728) ;
end ;

procedure TSceneLoader.UnInit() ;
begin
  font.Free ;
  textLoad.Free ;
end ;

{ TBackgroundTask }

constructor TBackgroundTask.Create(Asize: Integer);
begin
  inherited Create(True) ;
  size:=Asize ;
  ready:=False ;
end;

procedure TBackgroundTask.Execute;
begin
  map:=TMap.Create(size) ;
  ready:=True ;
end;

function TBackgroundTask.getResult: TObject;
begin
  Result:=map ;
end;

function TBackgroundTask.isReady: Boolean;
begin
  Result:=ready ;
end;

end.
