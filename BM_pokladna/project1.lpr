program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, pascalscript, Unit1
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='Pokladna';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TPokladna, Pokladna);
  Application.Run;
end.

