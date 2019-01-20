unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
     Grids, Menus, LazFileUtils, LazUtf8;
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
    Lista: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
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
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure PonukaClick(Sender: TObject);
    procedure NacitaniePolozkyTOVARtxt(iTovaru: integer);
    procedure NacitaniePolozkySKLADtxt(iTovaru: integer);
    procedure NacitaniePolozkyCENNIKtxt(iTovaru: integer);
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

procedure TForm1.FormCreate(Sender: TObject);
var
    odpadInt, iTovaru, iZnaku: integer;
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

     //Memo1.Append(intToStr(odpadInt));
     for iTovaru:=0 to tovarov-1 do begin
         NacitaniePolozkyTOVARtxt(iTovaru);
         NacitaniePolozkySKLADtxt(iTovaru);
         NacitaniePolozkyCENNIKtxt(iTovaru);
     end;


     //testy
     //for sgStlpce:=0 to 3 do
     //    for sgRiadky:=1 to 9 do
     //        Ponuka.Cells[sgStlpce,sgRiadky]:= intToStr(sgStlpce+sgRiadky+1);
end;

procedure TForm1.NacitaniePolozkyTOVARtxt(iTovaru: integer);
var
   tovarRiadok, kodString, nazovString: string;
   iZnaku: integer;
begin
    readLn(tovar, tovarRiadok);

    kodString:= '9999';
    nazovString:= 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    iZnaku:= 1;
    while(tovarRiadok[iZnaku] <> ';') do begin
        kodString[iZnaku]:= tovarRiadok[iZnaku];
        inc(iZnaku);
    end;

    for iZnaku:=preskokKod+1 to length(tovarRiadok) do
        nazovString[iZnaku-preskokKod]:= tovarRiadok[iZnaku];
    delete(nazovString, iZnaku-preskokKod+1, length(nazovString) - (iZnaku-preskokKod));
    Form1.Memo1.Append(kodString +' '+ nazovString); //test

    Tovary[iTovaru].kod:= strToInt(kodString);
    Form1.Ponuka.Cells[1, iTovaru+1]:= intToStr(Tovary[iTovaru].kod);
    Tovary[iTovaru].nazov:= nazovString;
    Form1.Ponuka.Cells[0, iTovaru+1]:= Tovary[iTovaru].nazov;
end;

procedure TForm1.NacitaniePolozkySKLADtxt(iTovaru: integer);
var
   skladRiadok, kodString, mnozstvoString: string;
   iZnaku: integer;
begin
    readLn(sklad, skladRiadok);

    kodString:= '9999';
    mnozstvoString:= '9999999999999999999';
    iZnaku:= 1;
    //moze byt for 1 az 4, ale toto je pre roznu dlzku kodu
    while(skladRiadok[iZnaku] <> ';') do begin
        kodString[iZnaku]:= skladRiadok[iZnaku];
        inc(iZnaku);
    end;

    for iZnaku:=preskokKod+1 to length(skladRiadok) do
        mnozstvoString[iZnaku-preskokKod]:= skladRiadok[iZnaku];
    delete(mnozstvoString, iZnaku-preskokKod+1, length(mnozstvoString) - (iZnaku-preskokKod));
    Form1.Memo1.Append(kodString +' '+ mnozstvoString); //test

    //nie je nutne, lebo uz je priradene
    //Tovary[iTovaru].kod:= strToInt(kodString);
    //Form1.Ponuka.Cells[1, iTovaru+1]:= intToStr(Tovary[iTovaru].kod);
    Tovary[iTovaru].mnozstvo:= strToInt(mnozstvoString);
    Form1.Ponuka.Cells[3, iTovaru+1]:= intToStr(Tovary[iTovaru].mnozstvo);
end;

procedure TForm1.NacitaniePolozkyCENNIKtxt(iTovaru: integer);
var
   cennikRiadok, kodString, cenaKusNakupString, cenaKusPredajString: string;
   iZnaku, preskokCennik2: integer;
begin
    readLn(cennik, cennikRiadok);

    kodString:= '9999';
    cenaKusNakupString:= '99999999999999';
    cenaKusPredajString:= '99999999999999';
    iZnaku:= 1;
    while(cennikRiadok[iZnaku] <> ';') do begin
        kodString[iZnaku]:= cennikRiadok[iZnaku];
        inc(iZnaku);
    end;

    inc(iZnaku); //skipujeme ;
    while(cennikRiadok[iZnaku] <> ';') do begin
        cenaKusNakupString[iZnaku-preskokKod]:= cennikRiadok[iZnaku];
        inc(iZnaku);
    end;
    delete(cenaKusNakupString, iZnaku-preskokKod+1,
           length(cenaKusNakupString) - (iZnaku-preskokKod));

    preskokCennik2:= iZnaku; //sme na ;
    inc(iZnaku); //skipujeme ;
    for iZnaku:=iZnaku to length(cennikRiadok) do begin
        cenaKusPredajString[iZnaku-preskokCennik2]:= cennikRiadok[iZnaku];
    end;
    delete(cenaKusPredajString, iZnaku-preskokCennik2+1,
           length(cenaKusPredajString) - (iZnaku-preskokCennik2));
    //for iZnaku:=preskokKod+1 to length(cennikRiadok) do
    //    cenaKusNakupString[iZnaku-preskokKod]:= cennikRiadok[iZnaku];
    //delete(cenaKusNakupString, iZnaku-preskokKod+1, length(cenaKusNakupString) - (iZnaku-preskokKod));
    //Form1.Memo1.Append(kodString +' '+ cenaKusNakupString); //test

    //nie je nutne, lebo uz je priradene
    //Tovary[iTovaru].kod:= strToInt(kodString);
    //Form1.Ponuka.Cells[1, iTovaru+1]:= intToStr(Tovary[iTovaru].kod);
    Tovary[iTovaru].cenaKusNakup:= strToFloat(cenaKusNakupString);
    Tovary[iTovaru].cenaKusPredaj:= strToFloat(cenaKusPredajString);
    Form1.Ponuka.Cells[2, iTovaru+1]:= floatToStr(Tovary[iTovaru].cenaKusPredaj);
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

procedure TForm1.MenuItem1Click(Sender: TObject);
begin
     close;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin

end;

end.
