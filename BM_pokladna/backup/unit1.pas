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
        //asi je nutne ;)
        kod, mnozstvo, iVPonuke, iVKosiku: integer; //iVPonuke = -1 => nie je v Ponuke
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
     for odpadInt:=0 to 99 do begin
         Tovary[odpadInt].iVPonuke:= -1;
         Tovary[odpadInt].iVKosiku:= -1;
     end;

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
         Tovary[iTovaru].iVPonuke:= iTovaru+1; //0. riadok - hlavicka tabulky
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
    for iTovaru:=0 to tovarov-1 do Tovary[iTovaru].iVPonuke:= -1;
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
           Tovary[iTovaru].iVPonuke:= iRiadku;
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
        Tovary[iTovaru].iVPonuke:= iRiadku;
    end;
end;

procedure TForm1.zobrazIneClick(Sender: TObject);
begin
    VycistiPonuku;
    ZobrazJedenDruh(4); //4 = ine
end;

procedure TForm1.PonukaClick(Sender: TObject);
var
   iStlpca, iRiadku, iVybratehoVTovary, iVybratehoVPKosik, iTovaru
     , ziadaneMnozstvo: Integer;
   inputRiadok: string;
   novyTovar, niecoZadal, zadalInt: boolean;
begin
     //testy
     //iStlpca:= Ponuka.Col;
     //iRiadku:= Ponuka.Row;
     //Memo1.Append(intToStr(iStlpca)+' '+intToStr(iRiadku));

     //hard vyberanie
     iRiadku:= Ponuka.Row;

     //najdenie tovaru v Tovary[] a PKosik[]
     iTovaru:= 0;
     while(Tovary[iTovaru].iVPonuke <> iRiadku) do inc(iTovaru);
     iVybratehoVTovary:= iTovaru;

     if (Tovary[iVybratehoVTovary].iVKosiku = -1) then begin //este nekupene
        novyTovar:= true;
        iVybratehoVPKosik:= kupenychTovarov; //novy riadok
        Tovary[iVybratehoVTovary].iVKosiku:= iVybratehoVPKosik;
     end else begin
        novyTovar:= false;
        iVybratehoVPKosik:= Tovary[iVybratehoVTovary].iVKosiku;
     end;

     //niecoZadal:= inputQuery(PKosik[iVybratehoVPKosik].nazov,
     //             'Zadajte mnozstvo:', inputRiadok);
     //if niecoZadal then begin
     //   zadalInt:= tryStrToInt(inputRiadok, ziadaneMnozstvo);
     //   if not zadalInt then begin
     //     showMessage('zadaj CISLO. CELE CISLO. A ne*er ma.');
     //   end else begin
     //     showMessage('Som zadany (' +intToStr(ziadaneMnozstvo)+')');
     //   end;
     //end;

     niecoZadal:= true;
     zadalInt:= false;
     while niecoZadal and not zadalInt do begin
         inputRiadok:= '1';
         niecoZadal:= inputQuery(PKosik[iVybratehoVPKosik].nazov,
                  'Zadajte mnozstvo:', inputRiadok);
         zadalInt:= tryStrToInt(inputRiadok, ziadaneMnozstvo);
         if not zadalInt or (ziadaneMnozstvo < 1) then begin
           showMessage('zadaj CISLO. PRIRODZENE CISLO. Vies, ako ma stves?!');
           exit;
           exit;
         end else begin
           showMessage('Som zadany (' +intToStr(ziadaneMnozstvo)+')');
         end;
     end;
     //if not zadalInt then abort;

     //ziadaneMnozstvo:= strToInt(inputbox(
     //   PKosik[iVybratehoVPKosik].nazov, 'Zadajte mnozstvo:', inputRiadok));
     if (ziadaneMnozstvo > Tovary[iVybratehoVTovary].mnozstvo) then begin
        showMessage('Na sklade mame iba '
                  +intToStr(Tovary[iVybratehoVTovary].mnozstvo) +' '
                  +Tovary[iVybratehoVTovary].nazov);
        exit;
     end;

     //Tovary[iVybratehoVTovary] => PKosik[iVybratehoVPKosik]
     //osetreny pripad noveho i stareho tovaru
     PKosik[iVybratehoVPKosik].nazov:= Tovary[iVybratehoVTovary].nazov;
     PKosik[iVybratehoVPKosik].kod:= Tovary[iVybratehoVTovary].kod;
     PKosik[iVybratehoVPKosik].cenaKusPredaj:= Tovary[iVybratehoVTovary].cenaKusPredaj;
     PKosik[iVybratehoVPKosik].iVPonuke:= iVybratehoVPKosik + 1;
     PKosik[iVybratehoVPKosik].cenaKusNakup:= -1; //nepotrebujeme
     PKosik[iVybratehoVPKosik].mnozstvo:= PKosik[iVybratehoVPKosik].mnozstvo +
                                          ziadaneMnozstvo;
     PKosik[iVybratehoVPKosik].cenaSpolu:= PKosik[iVybratehoVPKosik].cenaSpolu +
                  (PKosik[iVybratehoVPKosik].cenaKusPredaj * ziadaneMnozstvo);

     //odratanie v Tovary[iVybratehoVTovary] a v Ponuke
     Tovary[iVybratehoVTovary].mnozstvo:= Tovary[iVybratehoVTovary].mnozstvo
                                          - ziadaneMnozstvo;
     Ponuka.Cells[3, iRiadku]:= intToStr(Tovary[iVybratehoVTovary].mnozstvo);

     //testy
     Memo1.Clear;
     Memo1.Append(intToStr(PKosik[iVybratehoVPKosik].mnozstvo)
         +' '+ floatToStr(PKosik[iVybratehoVPKosik].cenaSpolu));

     //hard hard verzia (2 rovnake tovar => 1 riadok)
     //+1 lebo fixed riadok (nadpisy)
     Kosik.Cells[0, iVybratehoVPKosik+1]:= PKosik[iVybratehoVPKosik].nazov;
     Kosik.Cells[1, iVybratehoVPKosik+1]:=
                    floatToStr(PKosik[iVybratehoVPKosik].cenaKusPredaj);
     Kosik.Cells[2, iVybratehoVPKosik+1]:=
                    intToStr(PKosik[iVybratehoVPKosik].mnozstvo);
     Kosik.Cells[3, iVybratehoVPKosik+1]:=
                    floatToStr(PKosik[iVybratehoVPKosik].cenaSpolu);

     if (novyTovar = true) then begin
         inc(kupenychTovarov);
     end;
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
begin
     close;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin

end;

end.

//Windows GitBash test
