unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
     Grids, LazFileUtils, LazUtf8;
const
  preskokKod = 5;

type
  tovarTyp = record
        kod, mnozstvo: integer;
        cenaKusNakup, cenaKusPredaj: real;
        nazov: string;
  end;


  { TForm1 }

  TForm1 = class(TForm)
    Memo1: TMemo;
    zaplatit: TButton;
    zobrazOvocie: TButton;
    zobrazZelenina: TButton;
    zobrazPecivo: TButton;
    zobrazIne: TButton;
    zobrazVsetko: TButton;
    zrusitPolozku: TButton;
    zrusitNakup: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Ponuka: TStringGrid;
    Kosik: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure PonukaClick(Sender: TObject);
    procedure NacitanieTovarTxt(iTovaru: integer);
  private

  public


  end;

var
  Form1: TForm1;
  Tovary: array [0..99] of tovarTyp;
  sklad, tovar, cennik, statistiky: textFile;
  tovarov: integer;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.nacitanieTovarTxt(iTovaru: integer);
var
   kodNazovString, kodString, nazovString: string;
   iZnaku: integer;
begin
    readLn(tovar, kodNazovString);

    kodString:= '9999';
    nazovString:= 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    iZnaku:= 1;
    while(kodNazovString[iZnaku] <> ';') do begin
        kodString[iZnaku]:= kodNazovString[iZnaku];
        inc(iZnaku);
    end;

    for iZnaku:=preskokKod+1 to length(kodNazovString) do
        nazovString[iZnaku-preskokKod]:= kodNazovString[iZnaku];
    delete(nazovString, iZnaku-preskokKod+1, length(nazovString) - (iZnaku-preskokKod));
    Form1.Memo1.Append(kodString +' '+ nazovString); //test

    Form1.Memo1.Append('SIGSEGV' +kodString);
    Tovary[iTovaru].kod:= strToInt(kodString);
    Tovary[iTovaru].nazov:= nazovString;
    Form1.Ponuka.Cells[0, iTovaru+1]:= Tovary[iTovaru].nazov;
    Form1.Ponuka.Cells[1, iTovaru+1]:= intToStr(Tovary[iTovaru].kod);
end;


procedure TForm1.FormCreate(Sender: TObject);
var
    sgRiadky, sgStlpce, odpadInt, iTovaru, iZnaku: integer;
    odpadChar: char;
    odpadString, kodString, nazovString, kodNazovString: string;
begin
     //pociatocne priradenie
     assignFile(sklad, 'SKLAD.txt');
     assignFile(tovar, 'TOVAR.txt');
     assignFile(cennik, 'CENNIK.txt');
     assignFile(statistiky, 'STATISTIKY.txt');

     //ideme vyplnit TStringGrid Ponuka
     reset(sklad);
     reset(tovar);
     reset(cennik);
     readLn(sklad, tovarov);
     Memo1.Append(intToStr(tovarov)); //pomocne
     readLn(tovar, odpadInt);
     readLn(cennik, odpadInt);

     //readLn(tovar, odpadString);
     //Memo1.Append(odpadString);
     //kodString:= '9999';
     //nazovString:= 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
     //iZnaku:= 1;
     //while(odPadString[iZnaku] <> ';') do begin
     //    kodString[iZnaku]:= odpadString[iZnaku];
     //    inc(iZnaku);
     //end;
     //preskokKod:= 5;
     //
     //Memo1.Append(intToStr(iZnaku));
     //for iZnaku:=6 to length(odpadString) do
     //    nazovString[iZnaku-preskokKod]:= odpadString[iZnaku];
     //delete(nazovString, iZnaku-preskokKod+1, length(nazovString) - (iZnaku-preskokKod));
     //Memo1.Append(kodString +' '+ nazovString);
     //

     //iTovaru:= 0;
     //readLn(tovar,
     //             Tovary[iTovaru].kod,
     //             odpadChar,
     //             Tovary[iTovaru].nazov);
     //Memo1.Append(intToStr(Tovary[iTovaru].kod)+ ' '
     //             +intToStr(Tovary[iTovaru].nazov));

     //Memo1.Append(intToStr(odpadInt));
     for iTovaru:=0 to tovarov-1 do begin
         nacitanieTovarTxt(iTovaru);

         //read(tovar,Tovary[iTovaru].kod);
         //read(tovar, odpadChar); //bodkociarka
         //read(tovar, Tovary[iTovaru].nazov);
         //Memo1.Append(intToStr(Tovary[iTovaru].kod)+ ' '
         //    +intToStr(Tovary[iTovaru].nazov));
     end;


     //testy
     //for sgStlpce:=0 to 3 do
     //    for sgRiadky:=1 to 9 do
     //        Ponuka.Cells[sgStlpce,sgRiadky]:= intToStr(sgStlpce+sgRiadky+1);
end;

procedure TForm1.PonukaClick(Sender: TObject);
var
   Column, Row: Integer;
   //MousePoint: TPoint;
begin
     {Memo1.Append('Klik!');
     suradnice := Mouse.CursorPos;
     suradnice := ScreenToClient(suradnice);
     //Ponuka.MouseToCell(suradnice);
     Memo1.Append(intToStr(suradnice.x)+' '+intToStr(suradnice.y));
     //Ponuka.MouseToCell(X, Y, Col, Row);
     //Memo1.Append(intToStr(Col)+' '+intToStr(Row));
     }
     //MousePoint := Ponuka.ClientToScreen(Point(X, Y));
     //X:= MousePoint.x;
     //Y:= MousePoint.y;
     //Ponuka.MouseToCell(X, Y, Column, Row);
     //Ponuka.Cells[Column, Row] := 'Col ' + IntToStr(Column) + ',Row ' +
     //IntToStr(Row);
     Column:= Ponuka.Col;
     Row:= Ponuka.Row;
     Memo1.Append(intToStr(Column)+' '+intToStr(Row));
end;

end.
//pokus pokus pokus dis dis
//pokuskus
//blablabla
