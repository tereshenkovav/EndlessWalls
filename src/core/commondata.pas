unit CommonData;

interface

uses
  Classes, SysUtils,
  SfmlSystem,SfmlWindow,SfmlGraphics,
  Profile, SfmlAnimation, Texts, Languages ;

type

  { TCommonData }

  TCommonData = class
  private
  public
    class var Font:TSfmlFont ;
    class var selector:TSfmlSprite ;
    class var texts:TTexts ;
    class var languages:TLanguages ;
    class function Init():Boolean ;
    class procedure reloadTexts() ;
    class procedure UnInit() ;
  end;

implementation
uses SfmlUtils, Helpers, Scene ;

{ TCommonData }

class function TCommonData.Init():Boolean ;
begin
  Font:=TSfmlFont.Create('fonts'+PATH_SEP+'arial.ttf');
  selector:=loadSprite('images'+PATH_SEP+'arrow.png');
  selector.Origin:=SfmlVector2f(-10,-10) ;
  selector.Rotate(90) ;
  languages:=TLanguages.Create() ;
  languages.loadFromFile('texts'+PATH_SEP+'languages');
  languages.setCurrentByFile('texts'+PATH_SEP+'deflang');
  texts:=TTexts.Create() ;
  reloadTexts() ;
  Result:=True ;
end ;

class procedure TCommonData.reloadTexts;
begin
  texts.loadFromFile('texts'+PATH_SEP+'texts.'+languages.getCurrent()) ;
end;

class procedure TCommonData.UnInit() ;
var i:Integer ;
begin
  Font.Free ;
  selector.Free ;
  texts.Free ;
  languages.Free ;
end ;

end.

