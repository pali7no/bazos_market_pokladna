unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
     Grids, Menus, ExtCtrls, LazFileUtils, LazUtf8;
const
  preskokKod = 4;

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
    menoPokladnika: TPanel;
    zaplatit: TButton;
    zobrazOvocie: TButton;
    zobrazZelenina: TButton;
    zobrazPecivo: TButton;
    zobrazIne: TButton;
    zobrazVsetko: TButton;
    zrusNakup: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Ponuka: TStringGrid;
    Kosik: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure KosikClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure PonukaClick(Sender: TObject);
    procedure NacitaniePolozkyTOVARtxt(iTovaru: integer);
    procedure NacitaniePolozkySKLADtxt(iTovaru: integer);
    procedure NacitaniePolozkyCENNIKtxt(iTovaru: integer);
    procedure VycistitPonuku;
    procedure zaplatitClick(Sender: TObject);
    procedure zobrazIneClick(Sender: TObject);
    procedure zobrazOvocieClick(Sender: TObject);
    procedure zobrazPecivoClick(Sender: TObject);
    procedure zobrazVsetkoClick(Sender: TObject);
    procedure zobrazZeleninaClick(Sender: TObject);
    procedure ZobrazJedenDruh(druh: integer);
    procedure zrusNakupClick(Sender: TObject);
    procedure zrusitPolozkuClick(Sender: TObject);
    procedure zrusitNakup;
    function dlzkaCisla(cislo: integer): integer;
  private

  public

  end;

var
  Form1: TForm1;
  Tovary, PKosik: array [0..99] of tovarTyp;
  prazdnyTovar: tovarTyp;
  sklad, tovar, cennik, statistiky: textFile;
  tovarov, kupenychTovarov: integer;
  pokladnik: string;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
    odpadInt, iTovaru, iZnaku: integer;
    odpadChar: char;
    odpadString, kodString, nazovString, kodNazovString: string;
    zadalMeno: boolean;
begin
    //prihlasnenie pokladnika
    zadalMeno:= false;
    pokladnik:= '';
    while not zadalMeno or (pokladnik = '') do begin
        zadalMeno:= inputQuery('Modul: Pokladna','Zadajte vase meno',
                    pokladnik);
        menoPokladnika.Caption:= 'Meno pokladnika: '+pokladnik;
    end;

    //pociatocna inicializacia
    randomize;
    kupenychTovarov:= 0;
     //iVPonuke = -1 => nie je v Ponuke
     for odpadInt:=0 to 99 do begin
         Tovary[odpadInt].iVPonuke:= -1;
         Tovary[odpadInt].iVKosiku:= -1;
     end;
     Kosik.RowCount:= 1; //nadpis

     //prazdny tovar inicializacia
     prazdnyTovar.cenaKusNakup:= 0;
     prazdnyTovar.cenaKusPredaj:= 0;
     prazdnyTovar.cenaSpolu:= 0;
     prazdnyTovar.kod:= -1;
     prazdnyTovar.mnozstvo:= 0;
     prazdnyTovar.iVPonuke:= -1;
     prazdnyTovar.iVKosiku:= -1;
     prazdnyTovar.nazov:= '';

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

//     Procedure DeleteRow(Grid: TStringGrid; ARow: Integer);
//var
//  i: Integer;
//begin
//  for i := ARow to Grid.RowCount - 2 do
//    Grid.Rows[i].Assign(Grid.Rows[i + 1]);
//  Grid.RowCount := Grid.RowCount - 1;
//end;

      Ponuka.RowCount:= tovarov + 1; //+nadpis

      //Memo1.Append(intToStr(odpadInt));
     for iTovaru:=0 to tovarov-1 do begin
         NacitaniePolozkyTOVARtxt(iTovaru);
         NacitaniePolozkySKLADtxt(iTovaru);
         NacitaniePolozkyCENNIKtxt(iTovaru);
         Tovary[iTovaru].iVPonuke:= iTovaru+1; //0. riadok - hlavicka tabulky
     end;

     closeFile(sklad);
     closeFile(tovar);
     closeFile(cennik);


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

    kodString:= '999';
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

    kodString:= '999';
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

    kodString:= '999';
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

procedure TForm1.VycistitPonuku;
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
    //VycistitPonuku;
    Ponuka.RowCount:= 1;
    iRiadku:= 1;
    for iTovaru:=0 to tovarov-1 do begin
        if (Tovary[iTovaru].kod div 100 = druh) then begin
           Ponuka.RowCount:= Ponuka.RowCount + 1;
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
    VycistitPonuku;
    ZobrazJedenDruh(1); //1 = ovocie
end;

procedure TForm1.zobrazZeleninaClick(Sender: TObject);
begin
    VycistitPonuku;
    ZobrazJedenDruh(2); //2 = zelenina
end;

procedure TForm1.zobrazPecivoClick(Sender: TObject);
begin
    VycistitPonuku;
    ZobrazJedenDruh(3); //3 = pecivo
end;

procedure TForm1.zobrazIneClick(Sender: TObject);
begin
    VycistitPonuku;
    ZobrazJedenDruh(4); //4 = ine
end;

procedure TForm1.zobrazVsetkoClick(Sender: TObject);
var
   iTovaru, iRiadku: integer;
begin
    //VycistitPonuku;
    Ponuka.RowCount:= tovarov + 1;
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

procedure TForm1.zrusitNakup();
var
   iRiadku, iHlad: integer;
begin
     Kosik.RowCount:= 1; //legendarne nadpisy
     for iRiadku:=0 to kupenychTovarov-1 do begin
         //Tovary[PKosik[iRiadku].iVTovary].iVKosiku:= -1;
         iHlad:= 0;
         while(PKosik[iRiadku].nazov <> Tovary[iHlad].nazov) do begin
             inc(iHlad);
         end;
         Tovary[iHlad].iVKosiku:= -1; //uz nie je v kosiku
         Tovary[iHlad].mnozstvo:= Tovary[iHlad].mnozstvo
                                  + PKosik[iRiadku].mnozstvo;
         if (Tovary[iHlad].iVPonuke <> -1) then begin
            Ponuka.Cells[3, Tovary[iHlad].iVPonuke]:=
                            intToStr(Tovary[iHlad].mnozstvo);
         end;
         PKosik[iRiadku]:= prazdnyTovar;
     end;
     kupenychTovarov:= 0;
end;

procedure TForm1.zrusNakupClick(Sender: TObject);
var
   chceZrusit: integer;
begin
    chceZrusit := messageDlg('Naozaj chcete zrusit cely nakup?'
              ,mtCustom, mbOKCancel, 0);

    if (chceZrusit = mrOK) then begin
        zrusitNakup;
    end;
end;

procedure TForm1.zrusitPolozkuClick(Sender: TObject);
begin

end;

//procedure TForm1.zrusitPolozkuClick(Sender: TObject);
//var
//   keyWord: string;
//   zadalStr: boolean;
//begin
//
//end;

procedure TForm1.PonukaClick(Sender: TObject);
var
   iStlpca, iRiadku, iVybratehoVTovary, iVybratehoVPKosik, iTovaru
     , ziadaneMnozstvo, chcemViac: Integer;
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
                  'Zadajte mnozstvo: '+PKosik[iVybratehoVPKosik].nazov,
                  inputRiadok);
         if not niecoZadal then begin
            exit;
            exit;
         end;
         zadalInt:= tryStrToInt(inputRiadok, ziadaneMnozstvo);
         if not zadalInt or (ziadaneMnozstvo < 1) then begin
           showMessage('zadaj CISLO. PRIRODZENE CISLO. Vies, ako ma stves?!');
         end else begin
           //showMessage('Som zadany (' +intToStr(ziadaneMnozstvo)+')');
         end;
     end;
     //if not zadalInt then abort;

     //ziadaneMnozstvo:= strToInt(inputbox(
     //   PKosik[iVybratehoVPKosik].nazov, 'Zadajte mnozstvo:', inputRiadok));
     if (ziadaneMnozstvo > Tovary[iVybratehoVTovary].mnozstvo) then begin
        //showMessage('Na sklade mame iba '
        //          +intToStr(Tovary[iVybratehoVTovary].mnozstvo) +' '
        //          +Tovary[iVybratehoVTovary].nazov);
        chcemViac := messageDlg('Na sklade mame iba '
                  +intToStr(Tovary[iVybratehoVTovary].mnozstvo) +' '
                  +Tovary[iVybratehoVTovary].nazov+ '. Chcete aj tak predat?'
                  ,mtCustom, mbOKCancel, 0);
        if (chcemViac = mrCancel) then begin
           exit;
        end;
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
     if (Tovary[iVybratehoVTovary].mnozstvo < 0) then begin
        Tovary[iVybratehoVTovary].mnozstvo:= 0;
     end;
     Ponuka.Cells[3, iRiadku]:= intToStr(Tovary[iVybratehoVTovary].mnozstvo);

     //testy
     Memo1.Clear;
     Memo1.Append(intToStr(PKosik[iVybratehoVPKosik].mnozstvo)
         +' '+ floatToStr(PKosik[iVybratehoVPKosik].cenaSpolu));

     if novyTovar then Kosik.RowCount:= Kosik.RowCount + 1;

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

procedure TForm1.KosikClick(Sender: TObject);
var
   iRiadku, iVPKosik, iPosun, iPosunT, iVTovary: integer;
   chceZrusit: integer;
begin
    iRiadku:= Kosik.row;
    iVPKosik:= 0;
    iVTovary:= 0;
    while(Kosik.Cells[0, iRiadku] <> PKosik[iVPKosik].nazov) do begin
        inc(iVPKosik);
    end;
    while(Kosik.Cells[0, iRiadku] <> Tovary[iVTovary].nazov) do begin
        inc(iVTovary);
    end;


    chceZrusit := messageDlg('Naozaj chcete zrusit '
                   +intToStr(PKosik[iVPKosik].mnozstvo) +' '
                   +PKosik[iVPKosik].nazov+ '?'
                   ,mtCustom, mbOKCancel, 0);
    if (chceZrusit = mrOK) then begin
        Tovary[iVTovary].iVKosiku:= -1;
        Tovary[iVTovary].mnozstvo:= Tovary[iVTovary].mnozstvo
                                    + PKosik[iVPKosik].mnozstvo;

        if (Tovary[iVTovary].iVPonuke <> -1) then begin
               Ponuka.Cells[3,Tovary[iVTovary].iVPonuke]:=
                        intToStr(Tovary[iVTovary].mnozstvo);
        end;

        for iPosun:= iVPKosik to kupenychTovarov-2 do begin
            PKosik[iPosun]:= PKosik[iPosun+1];
            PKosik[iPosun].iVKosiku:= PKosik[iPosun].iVKosiku - 1;


            //zmena v TovaryPonuka
            iPosunT:= 0;
            while (Tovary[iPosunT].nazov <>  PKosik[iPosun].nazov) do begin
                inc(iPosunT);
            end;
            Tovary[iPosunT].iVKosiku:= Tovary[iPosunT].iVKosiku - 1;

            Kosik.Rows[iPosun+1].Assign(Kosik.Rows[iPosun+2]);
        end;

        //zmena posledneho
        PKosik[kupenychTovarov-1]:= prazdnyTovar;
        Kosik.RowCount:= Kosik.RowCount - 1;
        dec(kupenychTovarov);
    end;
end;

function TForm1.dlzkaCisla(cislo: integer): integer;
var
   cifier: integer;
begin
   cifier:= 1;
   while (cislo div 10 > 0) do begin
       cislo:= cislo div 10;
       inc(cifier);
   end;
   dlzkaCisla:= cifier;
end;

//prida kupeny tovar do STATISTIKY.txt, uberie zo SKLAD.txt, vytvori
//uctenka_[id_transakcie].txt a zrusi Kosik
procedure TForm1.zaplatitClick(Sender: TObject);
var
   iPredaj, riadkov, statRiadkov, povMnozstvo, iVTovary,
     medzK1, medzK2, medzK3, sepLine, iTovaru, dlzCisla: integer;
   transID: int64;
   aktDatum: TDateTime;
   statStrList, skladStrList, uctStrList: TStringList;
   skladOldRiadok, skladNewRiadok, riadokUctu: string;
   uctenka: textFile;
begin

    //testy
    //Memo1.Append(DateToStr(Now));

    //append STATISTIKY.txt
    //priprava na pracu s statistiky
    repeat
       transID:= 10000000 + random(89999999);
    until not fileExists('uctenka_' +intToStr(transID));
    aktDatum:= now;

    //append(statistiky);
    //for iPredaj:=0 to kupenychTovarov-1 do begin
    //    writeLn(statistiky, 'P;'+ intToStr(transID) +';'+
    //    intToStr(PKosik[iPredaj].kod) +';'+
    //    intToStr(PKosik[iPredaj].mnozstvo) +';'+
    //    floatToStr(PKosik[iPredaj].cenaKusPredaj) +';'+
    //    FormatDateTime('YYMMDD', aktDatum));
    //end;
    //flush(statistiky);
    //closeFile(statistiky);

    statStrList:= TStringList.Create;
    statStrList.LoadFromFile('STATISTIKY.txt');
    statRiadkov:= strToInt(statStrList[0]) + kupenychTovarov;
    statStrList[0]:= intToStr(statRiadkov);
    //statStrList.Text := StringReplace(statStrList.Text, '3', '4', [rfIgnoreCase]);

    for iPredaj:=0 to kupenychTovarov-1 do begin
        statStrList.Add('P;'+ intToStr(transID) +';'+
        intToStr(PKosik[iPredaj].kod) +';'+
        intToStr(PKosik[iPredaj].mnozstvo) +';'+
        floatToStr(PKosik[iPredaj].cenaKusPredaj) +';'+
        FormatDateTime('YYMMDD', aktDatum));
    end;
    statStrList.SaveToFile('STATISTIKY.txt');
    statStrList.Free;

    //ubratie tovaru zo SKLAD.txt
    skladStrList:= TStringList.Create;
    skladStrList.LoadFromFile('SKLAD.txt');
    for iPredaj:=0 to kupenychTovarov-1 do begin
        iVTovary:= 0;
        while (PKosik[iPredaj].kod <> Tovary[iVTovary].kod) do begin
            inc(iVTovary);
        end;
        povMnozstvo:= PKosik[iPredaj].mnozstvo + Tovary[iVTovary].mnozstvo;
        skladOldRiadok:= intToStr(PKosik[iPredaj].kod) +';'+ intToStr(povMnozstvo);
        skladNewRiadok:= intToStr(PKosik[iPredaj].kod) +';'+
                    intToStr(Tovary[iVTovary].mnozstvo);
        skladStrList.Text := StringReplace(skladStrList.Text,
                          skladOldRiadok, skladNewRiadok, [rfIgnoreCase]);
    end;
    skladStrList.SaveToFile('SKLAD.txt');
    skladStrList.Free;

    //vytvorenie uctenka_[id_transakcie].txt
    sepLine:= 50;

    uctStrList:= TStringList.Create;
    uctStrList.Add('╔═══╗');
    uctStrList.Add('║   ║ |\  /|');
    uctStrList.Add('╠═══╣ | \/ |');
    uctStrList.Add('║   ║ |    |');
    uctStrList.Add('╚═══╝ |    |');
    uctStrList.Add('Jesenskeho 4/A, 811 02  Bratislava 1');
    uctStrList.Add(stringOfChar('_',sepLine));

    uctStrList.Add('Datum: ' +stringOfChar(' ',medzK1 - 7)+ dateToStr(now));
    uctStrList.Add('Cas: ' +stringOfChar(' ', medzK1 - 5)+ timeToStr(now));
    uctStrList.Add('Cislo uctenky: ' +stringOfChar(' ', medzK1 - 15)+
                          intToStr(transID));
    uctStrList.Add(stringOfChar('_',sepLine));

    medzK1:= 20;
    medzK2:= 4;
    medzK3:= 6;
    for iTovaru:=0 to kupenychTovarov-1 do begin
        //uctStrList.Add(PKosik[iTovaru].nazov +stringOfChar(' ',medzK1)+
        //intToStr(PKosik[iTovaru].cenaKusPredaj / 100) +' €'+)
        riadokUctu:= PKosik[iTovaru].nazov;
        //if (PKosik[iTovaru].cenaKusPredaj > 999)
        dlzCisla:= dlzkaCisla(Trunc(PKosik[iTovaru].cenaKusPredaj));
        if (dlzCisla < 5) then dlzCisla:= 5; //desatinne cisla typu 00.01
        riadokUctu:= riadokUctu + stringOfChar(' ',
                     medzK1+medzK3-dlzCisla-length(PKosik[iTovaru].nazov)) +
                     floatToStr(PKosik[iTovaru].cenaKusPredaj / 100) +' €';
        dlzCisla:= dlzkaCisla(PKosik[iTovaru].mnozstvo);
        riadokUctu:= riadokUctu + stringOfChar(' ',medzK2-dlzCisla) +
                     intToStr(PKosik[iTovaru].mnozstvo);
        dlzCisla:= dlzkaCisla(Trunc(PKosik[iTovaru].cenaKusPredaj *
                   PKosik[iTovaru].mnozstvo));
        if (dlzCisla < 5) then dlzCisla:= 5; //desatinne cisla typu 0.01
        riadokUctu:= riadokUctu + stringOfChar(' ',medzK3-dlzCisla) +
                     floatToStr(PKosik[iTovaru].cenaKusPredaj / 100 *
                     PKosik[iTovaru].mnozstvo) +' €';
        uctStrList.Add(riadokUctu);
    end;

    //formatfloat('0.0000', float)

    uctStrList.SaveToFile('uctenka_' +intToStr(transID)+ '.txt');
    uctStrList.Free;
    //assignFile(uctenka, 'uctenka_' +intToStr(transID));
    //rewrite(uctenka);
    //closeFile(uctenka);

    //zrusenie nakupu
    zrusitNakup;
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
begin
     close;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin

end;

end.
