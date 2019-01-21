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
        //iVPonuke zatial nie je nutne, ale funguje a moze sa zist
        kod, mnozstvo, iVTabulke: integer; //iVPonuke = -1 => nie je v Ponuke
        cenaKusNakup, cenaKusPredaj, cenaSpolu: real;
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
    procedure VycistiPonuku;
    procedure zobrazIneClick(Sender: TObject);
    procedure zobrazOvocieClick(Sender: TObject);
    procedure zobrazPecivoClick(Sender: TObject);
    procedure zobrazVsetkoClick(Sender: TObject);
    procedure zobrazZeleninaClick(Sender: TObject);
    procedure ZobrazJedenDruh(druh: integer);
  private

  public


  end;

var
  Form1: TForm1;
  Tovary, PKosik: array [0..99] of tovarTyp;
  sklad, tovar, cennik, statistiky: textFile;
  tovarov, kupenychTovarov: integer;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
    odpadInt, iTovaru, iZnaku: integer;
    odpadChar: char;
    odpadString, kodString, nazovString, kodNazovString: string;
begin
    //pociatocna inicializacia
    kupenychTovarov:= 0;
     //iVPonuke = -1 => nie je v Ponuke
     for odpadInt:=0 to 99 do Tovary[odpadInt].iVTabulke:= -1;

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
         Tovary[iTovaru].iVTabulke:= iTovaru+1; //0. riadok - hlavicka tabulky
     end;


     //testy
     //for sgStlpce:=0 to 3 do
     //    for sgRiadky:=1 to 9 do
     //        Ponuka.Cells[sgStlpce,sgRiadky]:= intToStr(sgStlpce+sgRiadky+1);
end;

procedure TForm1.NacitaniePolozkyTOVARtxt(iTovaru: integer);
var
   tovarRiadok, kodString, nazovString: string;
   iZnaku, iRiadku: integer;
begin
    iRiadku:= iTovaru + 1;
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
    Form1.Ponuka.Cells[1, iRiadku]:= intToStr(Tovary[iTovaru].kod);
    Tovary[iTovaru].nazov:= nazovString;
    Form1.Ponuka.Cells[0, iRiadku]:= Tovary[iTovaru].nazov;
end;

procedure TForm1.NacitaniePolozkySKLADtxt(iTovaru: integer);
var
   skladRiadok, kodString, mnozstvoString: string;
   iZnaku, iRiadku: integer;
begin
    iRiadku:= iTovaru + 1;
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
    //Form1.Tovary.Cells[1, iRiadku]:= intToStr(Tovary[iTovaru].kod);
    Tovary[iTovaru].mnozstvo:= strToInt(mnozstvoString);
    Form1.Ponuka.Cells[3, iRiadku]:= intToStr(Tovary[iTovaru].mnozstvo);
end;

procedure TForm1.NacitaniePolozkyCENNIKtxt(iTovaru: integer);
var
   cennikRiadok, kodString, cenaKusNakupString, cenaKusPredajString: string;
   iZnaku, iRiadku, preskokCennik2: integer;
begin
    iRiadku:= iTovaru + 1;
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

    Tovary[iTovaru].cenaKusNakup:= strToFloat(cenaKusNakupString);
    Tovary[iTovaru].cenaKusPredaj:= strToFloat(cenaKusPredajString);
    Form1.Ponuka.Cells[2, iRiadku]:= floatToStr(Tovary[iTovaru].cenaKusPredaj);
end;

procedure TForm1.VycistiPonuku;
var
   iStlpca, iRiadku, iTovaru: integer;
begin
    for iStlpca:=0 to Ponuka.ColCount-1 do begin
        for iRiadku:= 1 to Ponuka.RowCount-1 do begin
            Ponuka.Cells[iStlpca, iRiadku]:= '';
        end;
    end;

    //-1 => nie je v Ponuka
    for iTovaru:=0 to tovarov-1 do Tovary[iTovaru].iVTabulke:= -1;
end;

procedure TForm1.ZobrazJedenDruh(druh: integer);
var
   iTovaru,iRiadku: integer;
begin
    VycistiPonuku;
    iRiadku:= 1;
    for iTovaru:=0 to tovarov-1 do begin
        if (Tovary[iTovaru].kod div 1000 = druh) then begin
           Ponuka.Cells[0, iRiadku]:= Tovary[iTovaru].nazov;
           Ponuka.Cells[1, iRiadku]:= intToStr(Tovary[iTovaru].kod);
           Ponuka.Cells[2, iRiadku]:= floatToStr(Tovary[iTovaru].cenaKusPredaj);
           Ponuka.Cells[3, iRiadku]:= intToStr(Tovary[iTovaru].mnozstvo);
           Tovary[iTovaru].iVTabulke:= iRiadku;
           inc(iRiadku);
        end;
    end;
end;

procedure TForm1.zobrazOvocieClick(Sender: TObject);
begin
    VycistiPonuku;
    ZobrazJedenDruh(1); //1 = ovocie
end;

procedure TForm1.zobrazZeleninaClick(Sender: TObject);
begin
    VycistiPonuku;
    ZobrazJedenDruh(2); //2 = zelenina
end;

procedure TForm1.zobrazPecivoClick(Sender: TObject);
begin
    VycistiPonuku;
    ZobrazJedenDruh(3); //3 = pecivo
end;

procedure TForm1.zobrazVsetkoClick(Sender: TObject);
var
   iTovaru, iRiadku: integer;
begin
    VycistiPonuku;
    iRiadku:= -1;
    for iTovaru:=0 to tovarov-1 do begin
        iRiadku:= iTovaru + 1;
        Ponuka.Cells[0, iRiadku]:= Tovary[iTovaru].nazov;
        Ponuka.Cells[1, iRiadku]:= intToStr(Tovary[iTovaru].kod);
        Ponuka.Cells[2, iRiadku]:= floatToStr(Tovary[iTovaru].cenaKusPredaj);
        Ponuka.Cells[3, iRiadku]:= intToStr(Tovary[iTovaru].mnozstvo);
        Tovary[iTovaru].iVTabulke:= iRiadku;
    end;
end;

procedure TForm1.zobrazIneClick(Sender: TObject);
begin
    VycistiPonuku;
    ZobrazJedenDruh(4); //4 = ine
end;

procedure TForm1.PonukaClick(Sender: TObject);
var
   iStlpca, iRiadku, iKupovaneho, iTovaru: Integer;
   inputRiadok: string;
begin
     //testy
     iStlpca:= Ponuka.Col;
     iRiadku:= Ponuka.Row;
     Memo1.Append(intToStr(iStlpca)+' '+intToStr(iRiadku));

     ////easy vyberanie z vsetkeho
     //iKupovaneho:= iRiadku-1;
     ////ak 0, tak chcem zapisat na 0. miesto
     //PKosik[kupenychTovarov]:= Tovary[iKupovaneho];
     ////na 0. riadku nadpisy
     //Kosik.Cells[0, kupenychTovarov+1]:= PKosik[kupenychTovarov].nazov;
     //Kosik.Cells[1, kupenychTovarov+1]:=
     //               floatToStr(PKosik[kupenychTovarov].cenaKusPredaj);
     //inc(kupenychTovarov);

     //hard vyberanie
     iTovaru:= 0;
     while(Tovary[iTovaru].iVTabulke <> iRiadku) do inc(iTovaru);
     iKupovaneho:= iTovaru;
     //PKosik[kupenychTovarov]:= Tovary[iKupovaneho];
     PKosik[kupenychTovarov].nazov:= Tovary[iKupovaneho].nazov;
     PKosik[kupenychTovarov].kod:= Tovary[iKupovaneho].kod;
     PKosik[kupenychTovarov].cenaKusPredaj:= Tovary[iKupovaneho].cenaKusPredaj;
     PKosik[kupenychTovarov].iVTabulke:= kupenychTovarov + 1;
     PKosik[kupenychTovarov].cenaKusNakup:= -1; //nepotrebujeme
     PKosik[kupenychTovarov].mnozstvo:= strToInt(inputbox(
        PKosik[kupenychTovarov].nazov, 'Zadajte mnozstvo:', inputRiadok));
     PKosik[kupenychTovarov].cenaSpolu:= PKosik[kupenychTovarov].cenaKusPredaj
                                         * PKosik[kupenychTovarov].mnozstvo;

     //a:= strToInt(inputbox('','',r));
     //na 0. riadku nadpisy
     Kosik.Cells[0, kupenychTovarov+1]:= PKosik[kupenychTovarov].nazov;
     Kosik.Cells[1, kupenychTovarov+1]:=
                    floatToStr(PKosik[kupenychTovarov].cenaKusPredaj);
     Kosik.Cells[2, kupenychTovarov+1]:=
                    intToStr(PKosik[kupenychTovarov].mnozstvo);
     Kosik.Cells[3, kupenychTovarov+1]:=
                    floatToStr(PKosik[kupenychTovarov].cenaSpolu);

     inc(kupenychTovarov);




end;

procedure TForm1.MenuItem1Click(Sender: TObject);
begin
     close;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin

end;

end.
