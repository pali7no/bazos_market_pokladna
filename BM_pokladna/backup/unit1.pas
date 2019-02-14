unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
     Grids, Menus, ExtCtrls, EditBtn, LazFileUtils, LazUtf8, Math;
const
  preskokKod = 4;
  //NoSelection: TGridRect = (Left: 0; Top: -1; Right: 0; Bottom: -1);

type
  tovarTyp = record
        //iVPonuke zatial nie je nutne, ale funguje a moze sa zist
        //asi je nutne ;)
        kod, mnozstvo, iVPonuke, iVKosiku: integer; //iVPonuke = -1 => nie je v Ponuke
        cenaKusNakup, cenaKusPredaj, cenaSpolu: currency;
        jeAktivny: boolean;
        nazov: string;
  end;


  { TForm1 }

  TForm1 = class(TForm)
    simpleReload: TButton;
    celkCenaL: TLabel;
    EditButton1: TEditButton;
    Lista: TMainMenu;
    Memo1: TMemo;
    koniec: TMenuItem;
    MenuItem2: TMenuItem;
    vyhlPodlaKoduMenu: TMenuItem;
    vyhlPodlaNazvuMenu: TMenuItem;
    odhlasPokladnika: TMenuItem;
    menoPokladnika: TPanel;
    zaplatit: TButton;
    zobraz0Kat: TButton;
    zobraz1Kat: TButton;
    zobraz2Kat: TButton;
    zobraz3Kat: TButton;
    zobrazVsetko: TButton;
    zrusNakup: TButton;
    vyhlPodlaKoduEdit: TEdit;
    vyhlPodlaNazvuEdit: TEdit;
    Ponuka: TStringGrid;
    Kosik: TStringGrid;
    function jeSlovo(inputString: string): boolean;
    procedure menoPokladnikaClick(Sender: TObject);
    procedure odhlasPokladnikaClick(Sender: TObject);
    procedure simpleReloadClick(Sender: TObject);
    procedure vyhlPodlaNazvuMenuClick(Sender: TObject);
    procedure vyhlPodlaKoduMenuClick(Sender: TObject);
    procedure vyhlPodlaKoduEditChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KosikClick(Sender: TObject);
    procedure koniecClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure PonukaClick(Sender: TObject);
    procedure NacitaniePolozkyTOVARtxt(iTovaru: integer);
    procedure NacitaniePolozkySKLADtxt(iTovaru: integer);
    procedure NacitaniePolozkyCENNIKtxt(iTovaru: integer);
    procedure VycistitPonuku;
    procedure vyhlPodlaKoduEditClick(Sender: TObject);
    procedure vyhlPodlaNazvuEditChange(Sender: TObject);
    procedure vyhlPodlaNazvuEditClick(Sender: TObject);
    procedure zaplatitClick(Sender: TObject);
    procedure zobraz3KatClick(Sender: TObject);
    procedure zobraz0KatClick(Sender: TObject);
    procedure zobraz2KatClick(Sender: TObject);
    procedure zobrazVsetkoClick(Sender: TObject);
    procedure zobraz1KatClick(Sender: TObject);
    procedure ZobrazJedenDruh(druh: integer);
    procedure zrusNakupClick(Sender: TObject);
    procedure zrusitPolozkuClick(Sender: TObject);
    procedure zrusitNakup;
    procedure nacitaniePoloziekSKLADtxtStrList;
    procedure nacitanieCelejDatabazy;
    procedure vyhlPodlaKodu(userInput: string; Sender: TObject);
    procedure vyhlPodlaNazvu(userInput: string; Sender: TObject);
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
  celkCena: currency;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
    odpadInt, iTovaru, iZnaku: integer;
    odpadChar: char;
    odpadString, kodString, nazovString, kodNazovString: string;
    zadalMeno: boolean;
    katStrList: TStringList;
begin
    //Ponuka.Selection:= NoSelection;
   //Ponuka.Selection;

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
         Tovary[odpadInt].jeAktivny:= false;
     end;
     Kosik.RowCount:= 1; //nadpis
     Ponuka.SelectedColor:= clBlue;
     Ponuka.Options:= Ponuka.Options + [goDrawFocusSelected];
     celkCena:= 0;
     celkCenaL.Caption:= 'spolu cely nakup: ' +
                              currToStrF(celkCena, ffFixed, 2) + ' €';
     vyhlPodlaKoduEdit.Clear;
     vyhlPodlaNazvuEdit.Clear;

     //kategorie inciializacia
     katStrList:= TStringList.Create;
     katStrList.LoadFromFile('KATEGORIE.txt');
     zobraz0Kat.Caption:= katStrList[0];
     zobraz1Kat.Caption:= katStrList[1];
     zobraz2Kat.Caption:= katStrList[2];
     zobraz3Kat.Caption:= katStrList[3];


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
     nacitanieCelejDatabazy;

     //testy
     //for sgStlpce:=0 to 3 do
     //    for sgRiadky:=1 to 9 do
     //        Ponuka.Cells[sgStlpce,sgRiadky]:= intToStr(sgStlpce+sgRiadky+1);
end;

procedure TForm1.nacitanieCelejDatabazy;
var
    odpadInt, iTovaru: integer;
begin
     reset(sklad);
     reset(tovar);
     reset(cennik);
     readLn(sklad, tovarov);
     Memo1.Append(intToStr(tovarov)); //pomocne
     readLn(tovar, odpadInt);
     readLn(cennik, odpadInt);

     Ponuka.RowCount:= tovarov + 1; //+nadpis

      //Memo1.Append(intToStr(odpadInt));
     for iTovaru:=0 to tovarov-1 do begin
         NacitaniePolozkyTOVARtxt(iTovaru);
         //NacitaniePolozkySKLADtxt(iTovaru);
         nacitaniePolozkyCENNIKtxt(iTovaru);
         Tovary[iTovaru].iVPonuke:= iTovaru+1; //0. riadok - hlavicka tabulky
     end;

     NacitaniePoloziekSKLADtxtStrList;

     closeFile(sklad);
     closeFile(tovar);
     closeFile(cennik);
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

procedure TForm1.nacitaniePoloziekSKLADtxtStrList;
var
   skladStrList: TStringList;
   iTovaru: integer;
   skladRiadok, kodString, mnozstvoString: string;
   iZnaku, iRiadku, bcPos: integer;
begin
    skladStrList:= TStringList.Create;
    skladStrList.LoadFromFile('SKLAD.txt');
    //for iTovaru:=0 to tovarov do begin
    //    skladRiadok:= skladStrList[iTovaru];
    //    Memo1.Append(skladRiadok);
    //    bcPos:= pos(';',skladRiadok);
    //    Memo1.Append(intToStr(bcPos));
    //end;

    skladRiadok:= '1';
    for iTovaru:=0 to tovarov-1 do begin
        iRiadku:= iTovaru + 1;
        skladRiadok:= skladStrList[iRiadku];
        Memo1.Append(skladRiadok);
        kodString:= '999';
        mnozstvoString:= '9999999999999999999';
        iZnaku:= 1;
        //moze byt for 1 az 3, ale toto je pre roznu dlzku kodu
        //while(skladRiadok[iZnaku] <> ';') do begin
        //    kodString[iZnaku]:= skladRiadok[iZnaku];
        //    inc(iZnaku);
        //end;
        bcPos:= pos(';',skladRiadok);
        iZnaku:= bcPos;
        Memo1.Append(intToStr(iZnaku));

        for iZnaku:=preskokKod+1 to length(skladRiadok) do begin
            mnozstvoString[iZnaku-preskokKod]:= skladRiadok[iZnaku];
        end;
        delete(mnozstvoString, iZnaku-preskokKod+1, length(mnozstvoString) - (iZnaku-preskokKod));
        //Form1.Memo1.Append(kodString +' '+ mnozstvoString);

        Tovary[iTovaru].mnozstvo:= strToInt(mnozstvoString);
        Form1.Ponuka.Cells[3, iRiadku]:= intToStr(Tovary[iTovaru].mnozstvo);
    end;
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
    //moze byt for 1 az 3, ale toto je pre roznu dlzku kodu
    while(skladRiadok[iZnaku] <> ';') do begin
        kodString[iZnaku]:= skladRiadok[iZnaku];
        inc(iZnaku);
    end;

    for iZnaku:=preskokKod+1 to length(skladRiadok) do begin
        mnozstvoString[iZnaku-preskokKod]:= skladRiadok[iZnaku];
    end;
    delete(mnozstvoString, iZnaku-preskokKod+1, length(mnozstvoString) - (iZnaku-preskokKod));
    Form1.Memo1.Append(kodString +' '+ mnozstvoString);

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

    //ak tovar nema cenu, tak je neaktivny
    if (length(cennikRiadok) = 3) then begin
        Tovary[iTovaru].jeAktivny:= false;
        //kod uz priradeny z TOVAR.txt
        Ponuka.Cells[0, iRiadku]:= Ponuka.Cells[0,iRiadku] + '*';
        Ponuka.Cells[2, iRiadku]:= '';

    end else begin
    //tovar ma cenu a treba ju nacitat
        Tovary[iTovaru].jeAktivny:= true;
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

        Tovary[iTovaru].cenaKusNakup:= strToCurr(cenaKusNakupString) / 100{{$IFDEF UNIX} / 100 {$ENDIF}};
        Tovary[iTovaru].cenaKusPredaj:= strToCurr(cenaKusPredajString) / 100{{$IFDEF UNIX} / 100 {$ENDIF}};
        Form1.Ponuka.Cells[2, iRiadku]:= {floatToStr(Tovary[iTovaru].cenaKusPredaj);}
        CurrToStrF(Tovary[iTovaru].cenaKusPredaj, ffFixed, 2);
    end;
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
    Ponuka.RowCount:= 1;
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
           if (Tovary[iTovaru].jeAktivny = false) then begin
              Ponuka.Cells[0, iRiadku]:= Ponuka.Cells[0, iRiadku] + '*';
              Ponuka.Cells[2, iRiadku]:= '';
           end;
           Ponuka.Cells[1, iRiadku]:= intToStr(Tovary[iTovaru].kod);
           Ponuka.Cells[2, iRiadku]:= CurrToStrF(Tovary[iTovaru].cenaKusPredaj, ffFixed, 2);
           Ponuka.Cells[3, iRiadku]:= intToStr(Tovary[iTovaru].mnozstvo);
           Tovary[iTovaru].iVPonuke:= iRiadku;
           inc(iRiadku);
        end;
    end;
end;

procedure TForm1.zobraz0KatClick(Sender: TObject);
begin
    VycistitPonuku;
    ZobrazJedenDruh(1); //1 = ovocie
end;

procedure TForm1.zobraz1KatClick(Sender: TObject);
begin
    VycistitPonuku;
    ZobrazJedenDruh(2); //2 = zelenina
end;

procedure TForm1.zobraz2KatClick(Sender: TObject);
begin
    VycistitPonuku;
    ZobrazJedenDruh(3); //3 = pecivo
end;

procedure TForm1.zobraz3KatClick(Sender: TObject);
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
        if (Tovary[iTovaru].jeAktivny = false) then begin
           Ponuka.Cells[0, iRiadku]:= Ponuka.Cells[0, iRiadku] + '*';
           Ponuka.Cells[2, iRiadku]:= '';
        end;
        Ponuka.Cells[1, iRiadku]:= intToStr(Tovary[iTovaru].kod);
        Ponuka.Cells[2, iRiadku]:= CurrToStrF(Tovary[iTovaru].cenaKusPredaj, ffFixed, 2);
        Ponuka.Cells[3, iRiadku]:= intToStr(Tovary[iTovaru].mnozstvo);
        Tovary[iTovaru].iVPonuke:= iRiadku;
    end;
end;

procedure TForm1.zrusitNakup;
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
     celkCena:= 0;
     celkCenaL.Caption:= 'spolu cely nakup: ' +
                         currToStrF(celkCena, ffFixed, 2) + ' €';
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
     , ziadaneMnozstvo, chcemViac, chceZobrazitVsetko: Integer;
   inputRiadok, oznamKlikMimoNazvu: string;
   novyTovar, niecoZadal, zadalInt: boolean;
begin
     //testy
     //iStlpca:= Ponuka.Col;
     //iRiadku:= Ponuka.Row;
     //Memo1.Append(intToStr(iStlpca)+' '+intToStr(iRiadku));

     iRiadku:= Ponuka.Row;
     iStlpca:= Ponuka.Col;

     if (Ponuka.RowCount > 1) and (Ponuka.Cells[1, 1] = 'XXX') then begin
        chceZobrazitVsetko := messageDlg('Udaje, ktore hladate neexistuju. ' +
                          ' Chcete zobrazit Ponuku?'
                          ,mtCustom, mbOKCancel, 0);
        if (chceZobrazitVsetko = mrOK) then begin
           vyhlPodlaKoduEdit.Clear;
           vyhlPodlaNazvuEdit.Clear;
           zobrazVsetkoClick(Ponuka);
        end;
        exit;
     end;

     //najdenie tovaru v Tovary[] a PKosik[]
     iTovaru:= 0;
     while(Tovary[iTovaru].iVPonuke <> iRiadku) do inc(iTovaru);
     iVybratehoVTovary:= iTovaru;

     case iStlpca of
         0: begin
             //tovar je neaktivny (nema cenu)
             if (Tovary[iVybratehoVTovary].jeAktivny = false) then begin
                 showMessage(Tovary[iVybratehoVTovary].nazov +
                           ' sa momentalne nepredava.');
                 exit;
             end;

             //este nekupene
             if (Tovary[iVybratehoVTovary].iVKosiku = -1) then begin
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
                 +' '+ CurrToStrF(PKosik[iVybratehoVPKosik].cenaSpolu, ffFixed, 2));

             if novyTovar then Kosik.RowCount:= Kosik.RowCount + 1;

             //hard hard verzia (2 rovnake tovar => 1 riadok)
             //+1 lebo fixed riadok (nadpisy)
             Kosik.Cells[0, iVybratehoVPKosik+1]:= PKosik[iVybratehoVPKosik].nazov;
             Kosik.Cells[1, iVybratehoVPKosik+1]:=
                            currToStrF(PKosik[iVybratehoVPKosik].cenaKusPredaj, ffFixed, 2);
             Kosik.Cells[2, iVybratehoVPKosik+1]:=
                            intToStr(PKosik[iVybratehoVPKosik].mnozstvo);
             Kosik.Cells[3, iVybratehoVPKosik+1]:=
                            currToStrF(PKosik[iVybratehoVPKosik].cenaSpolu, ffFixed, 2);

             celkCena:= celkCena + PKosik[iVybratehoVPKosik].cenaKusPredaj * ziadaneMnozstvo;
             celkCenaL.Caption:= 'spolu cely nakup: ' +
                                 currToStrF(celkCena, ffFixed, 2) + ' €';

             if (novyTovar = true) then begin
                 inc(kupenychTovarov);
             end;
         end;

         1: begin
             oznamKlikMimoNazvu:= intToStr(Tovary[iVybratehoVTovary].kod) +
                  ' je kod ' + Tovary[iVybratehoVTovary].nazov +
                  '. Na sklade mame ' + intToStr(Tovary[iVybratehoVTovary].mnozstvo) +
                  ' kusov.';
            if (Tovary[iVybratehoVTovary].jeAktivny = false) then begin
                oznamKlikMimoNazvu:= oznamKlikMimoNazvu + ' Momentalne sa neda predat.'
            end;
            ShowMessage(oznamKlikMimoNazvu);
         end;
         2: begin
             oznamKlikMimoNazvu:= currToStrF(Tovary[iVybratehoVTovary].cenaKusPredaj, ffFixed, 2) +
                 ' je cena ' + Tovary[iVybratehoVTovary].nazov +
                 '. Na sklade mame ' + intToStr(Tovary[iVybratehoVTovary].mnozstvo)
                 + ' kusov.';
             if (Tovary[iVybratehoVTovary].jeAktivny = false) then begin
                 oznamKlikMimoNazvu:= oznamKlikMimoNazvu + ' Momentalne sa neda predat.'
             end;
             ShowMessage(oznamKlikMimoNazvu);
         end;
         3: begin
             oznamKlikMimoNazvu:= intToStr(Tovary[iVybratehoVTovary].mnozstvo) +
                 ' je mnozstvo ' + Tovary[iVybratehoVTovary].nazov +
                 ', ktore mame skladom.';
             if (Tovary[iVybratehoVTovary].jeAktivny = false) then begin
                 oznamKlikMimoNazvu:= oznamKlikMimoNazvu + ' Momentalne sa neda predat.'
             end;
             ShowMessage(oznamKlikMimoNazvu);
         end;
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

        celkCena:= celkCena - PKosik[iVPKosik].cenaSpolu;
        celkCenaL.Caption:= 'spolu cely nakup: ' + currToStrF(celkCena, ffFixed, 2) +
                    ' €';

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

procedure TForm1.zaplatitClick(Sender: TObject);
//prida kupeny tovar do STATISTIKY.txt, uberie zo SKLAD.txt, vytvori
//uctenka_[id_transakcie].txt a zrusi Kosik
var
   riadkov, statRiadkov, povMnozstvo, iVTovary,
     medzK1, medzK2, medzK3, sepLine, dlzCisla: integer;
   transID: qword;
   iPredaj, iTovaru: integer;
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
       transID:= qword(10000000) + qword(random(89999999));
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
        floatToStr(PKosik[iPredaj].cenaKusPredaj * 100) +';'+
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
    sepLine:= 35;
    medzK1:= 10;
    medzK2:= 4;
    medzK3:= 10;

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

    for iTovaru:=0 to kupenychTovarov-1 do begin
        //uctStrList.Add(PKosik[iTovaru].nazov +stringOfChar(' ',medzK1)+
        //intToStr(PKosik[iTovaru].cenaKusPredaj / 100) +' €'+)
        riadokUctu:= PKosik[iTovaru].nazov;
        //if (PKosik[iTovaru].cenaKusPredaj > 999)
        dlzCisla:= dlzkaCisla(Trunc(PKosik[iTovaru].cenaKusPredaj));
        if (dlzCisla < 5) then dlzCisla:= 5; //desatinne cisla typu 00.01
        riadokUctu:= riadokUctu + stringOfChar(' ',
                     medzK1+medzK3-dlzCisla-length(PKosik[iTovaru].nazov)) +
                     currToStrF(PKosik[iTovaru].cenaKusPredaj, ffFixed, 2) +' €';
        dlzCisla:= dlzkaCisla(PKosik[iTovaru].mnozstvo);
        riadokUctu:= riadokUctu + stringOfChar(' ',medzK2-dlzCisla) +
                     intToStr(PKosik[iTovaru].mnozstvo);
        dlzCisla:= dlzkaCisla(Trunc(PKosik[iTovaru].cenaKusPredaj *
                   PKosik[iTovaru].mnozstvo));
        if (dlzCisla < 5) then dlzCisla:= 5; //desatinne cisla typu 0.01
        riadokUctu:= riadokUctu + stringOfChar(' ',medzK3-dlzCisla) +
                     currToStrF(PKosik[iTovaru].cenaKusPredaj *
                     PKosik[iTovaru].mnozstvo, ffFixed, 2) +' €';
        uctStrList.Add(riadokUctu);
    end;

    //formatfloat('0.0000', float)

    uctStrList.SaveToFile('uctenka_' +intToStr(transID)+ '.txt');
    uctStrList.Free;
    //assignFile(uctenka, 'uctenka_' +intToStr(transID));
    //rewrite(uctenka);
    //closeFile(uctenka);

    //zrusenie nakupu
    nacitanieCelejDatabazy;
    for iPredaj:=0 to kupenychTovarov-1 do begin
        PKosik[iPredaj].mnozstvo:= -PKosik[iPredaj].mnozstvo;
    end;
    zrusitNakup;
end;

procedure TForm1.vyhlPodlaKoduEditClick(Sender: TObject);
begin
   vyhlPodlaKoduEdit.Clear;
end;

procedure TForm1.vyhlPodlaNazvuEditClick(Sender: TObject);
begin
     vyhlPodlaNazvuEdit.Clear;
end;

procedure TForm1.vyhlPodlaKodu(userInput: string; Sender: TObject);
//musi prist prir. cislo a: 100 <= a < 500
//zobrazuje do Ponuka (TStringGrid)
var
    iTovaru, mocnina, hladanyKod, najdenych: integer;
begin
     //inicializacia
     najdenych:= 0;

     //nezmyselne pripady
     //if  ((Sender = vyhlPodlaKoduEdit) and (vyhlPodlaKoduEdit.Text = '')) or
     //    ((Sender = vyhlPodlaKoduMenu) and (najdenych = 5)) //zatial blbost
     if (userInput = '') then begin
         zobrazVsetkoClick(vyhlPodlaKoduEdit);
         exit;
     end;

     VycistitPonuku;
     if tryStrToInt(userInput, hladanyKod) and
        (0 <= (hladanyKod div 100)) and ((hladanyKod div 100) < 5) then begin
         //hlada kod
         for iTovaru:=0 to tovarov-1 do begin
             for mocnina:=2 downto 0 do begin
                 if (Tovary[iTovaru].kod div Round(intPower(10, mocnina)) =
                    hladanyKod) then begin
                    inc(najdenych);
                    Ponuka.RowCount:= najdenych + 1;  //inc(Ponuka.RowCount)
                    Ponuka.Cells[0, najdenych]:= Tovary[iTovaru].nazov;
                    if (Tovary[iTovaru].jeAktivny = false) then begin
                       Ponuka.Cells[0, najdenych]:= Ponuka.Cells[0, najdenych] + '*';
                    end;
                    Ponuka.Cells[1, najdenych]:= intToStr(Tovary[iTovaru].kod);
                    Ponuka.Cells[2, najdenych]:= currToStrF(
                              Tovary[iTovaru].cenaKusPredaj, ffFixed, 2);
                    Ponuka.Cells[3, Ponuka.RowCount - 1]:=
                                    intToStr(Tovary[iTovaru].mnozstvo);
                    Tovary[iTovaru].iVPonuke:= najdenych;
                    continue;
                 end;
             end;
         end;
         if (najdenych = 0) then begin
            Ponuka.RowCount:= 2;
            Ponuka.Cells[0, 1]:= 'Tovar s kodom ' + intToStr(hladanyKod) +
                            ' neexistuje.';
            Ponuka.Cells[1, 1]:= 'XXX';
            Ponuka.Cells[2, 1]:= 'XX,XX €';
            Ponuka.Cells[3, 1]:= 'XXX';

         end;
     end else begin
         ShowMessage('Zadajte cislo 100 <= cislo < 500 (pre expertov: ' +
                              'Zadajte take kladne, cele cislo a, ' +
                              'pre ktore plati: ' + #13#10 + '0,2 < a/500 < 0,998)');
         vyhlPodlaKoduEdit.Clear;
         //umysel je dat kurzor prec, ale to sa nedari
         //vyhlPodlaKoduEdit.Invalidate;
         //Memo1.SelLength:= 0;
         //Memo1.SelStart:= Length(Memo1.Text);
     end;
end;

procedure TForm1.vyhlPodlaKoduEditChange(Sender: TObject);
var
    iTovaru, mocnina, hladanyKod, najdenych: integer;
begin
     vyhlPodlaNazvuEdit.Clear;
     if (vyhlPodlaKoduEdit.Text = 'vyhlPodlaKodu') then begin
         vyhlPodlaKoduEdit.Clear;
         exit;
     end;

     vyhlPodlaKodu(vyhlPodlaKoduEdit.Text, vyhlPodlaKoduEdit);
end;

procedure TForm1.vyhlPodlaKoduMenuClick(Sender: TObject);
var
   chceHladat: boolean;
   inputString: string;
begin
     chceHladat:= inputQuery('Hladanie kodu', 'Zadajte hladany kod', inputString);
     if not chceHladat then begin
         exit;
     end;
     vyhlPodlaKodu(inputString, vyhlPodlaKoduMenu);
end;

procedure TForm1.vyhlPodlaNazvu(userInput: string; Sender: TObject);
var
    hlSlovo, nazovTovaru: string;
    iTovaru, najdenych: integer;
begin
     //inicializacia
     najdenych:= 0;
     if (userInput = '') then begin
        exit;
     end;

     VycistitPonuku;
     if jeSlovo(userInput) then begin
         for iTovaru:=0 to tovarov-1 do begin
             nazovTovaru:= Tovary[iTovaru].nazov;
             if (length(userInput) > length(nazovTovaru)) then begin
                continue;
             end;
             //1. cast nazvov:
             nazovTovaru:= copy(nazovTovaru, 1, length(userInput));
             setLength(nazovTovaru, length(userInput));

             if (userInput = nazovTovaru) then begin
                 inc(najdenych);
                 Ponuka.RowCount:= najdenych + 1;  //inc(Ponuka.RowCount)
                 Ponuka.Cells[0, najdenych]:= Tovary[iTovaru].nazov;
                 if (Tovary[iTovaru].jeAktivny = false) then begin
                     Ponuka.Cells[0, najdenych]:= Ponuka.Cells[0, najdenych] + '*';
                 end;
                 Ponuka.Cells[1, najdenych]:= intToStr(Tovary[iTovaru].kod);
                 Ponuka.Cells[2, najdenych]:= currToStrF(
                              Tovary[iTovaru].cenaKusPredaj, ffFixed, 2);
                 Ponuka.Cells[3, Ponuka.RowCount - 1]:=
                                 intToStr(Tovary[iTovaru].mnozstvo);
                 Tovary[iTovaru].iVPonuke:= najdenych;
             end;
         end;
     end else begin
         ShowMessage('Zadajte 1. SLOVO nazvu.');
         vyhlPodlaNazvuEdit.Clear;
     end;
end;

procedure TForm1.vyhlPodlaNazvuEditChange(Sender: TObject);
var
    hlSlovo: string;
begin
     vyhlPodlaKoduEdit.Clear;
     hlSlovo:= vyhlPodlaNazvuEdit.Text;
     vyhlPodlaNazvu(hlSlovo, vyhlPodlaNazvuEdit);
end;

procedure TForm1.vyhlPodlaNazvuMenuClick(Sender: TObject);
var
   chceHladat: boolean;
   inputString: string;
begin
     chceHladat:= inputQuery('Hladanie nazvu', 'Zadajte hladany nazov', inputString);
     if not chceHladat then begin
         exit;
     end;
     vyhlPodlaNazvu(inputString, vyhlPodlaNazvuMenu);
end;

function TForm1.jeSlovo(inputString: string): boolean;
var
   iVString: integer;
begin
     for iVString:=1 to length(inputString) do begin
         if not (inputString[iVString] in ['a'..'z','A'..'Z']) then begin
            exit(false);
            end;
     end;

     exit(true);
end;

procedure TForm1.menoPokladnikaClick(Sender: TObject);
var
   noveMeno: string;
   chceZmenitMeno: boolean;
begin
     if (inputQuery('Zmena mena pokladnika', 'Zadajte nove meno pokladnika',
                     noveMeno)) then begin
         pokladnik:= noveMeno;
         menoPokladnika.Caption:= 'Meno pokladnika: ' + pokladnik;
     end;
end;

procedure TForm1.odhlasPokladnikaClick(Sender: TObject);
begin
    zrusitNakup;
    FormCreate(odhlasPokladnika);
end;

procedure TForm1.simpleReloadClick(Sender: TObject);
begin
     goto randomize;
end;

procedure TForm1.koniecClick(Sender: TObject);
begin
     close;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin

end;

end.
