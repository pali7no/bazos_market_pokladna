unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
     Grids, LazFileUtils, LazUtf8;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject; Shift: TShiftState; suradnice: TPoint);
    procedure StringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
  private

  public

  end;

var
  Form1: TForm1;
  sgRiadky, sgStlpce: integer;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
     for sgStlpce:=0 to 1 do
         for sgRiadky:=0 to 9 do
             StringGrid1.Cells[sgStlpce,sgRiadky]:= intToStr(sgStlpce+sgRiadky+1);
end;

procedure TForm1.StringGrid1Click(Sender: TObject; Shift: TShiftState;
  suradnice: TPoint);
//var
   //Col, Row: Integer;
begin
     Memo1.Append('Klik!');
     StringGrid1.MouseToCell(suradnice);
     Memo1.Append(intToStr(suradnice.x)+' '+intToStr(suradnice.y));
     //StringGrid1.MouseToCell(X, Y, Col, Row);
     //Memo1.Append(intToStr(Col)+' '+intToStr(Row));
end;

procedure TForm1.StringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
   Col, Row: Integer;
begin
  StringGrid1.MouseToCell(X, Y, Col, Row);
  StringGrid1.Hint := IntToStr(Col) + '   ' + IntToStr(Row);
  Memo1.Append(intToStr(Col)+' '+intToStr(Row));
end;

end.
//pokus pokus pokus dis dis
//pokuskus
//blablabla
