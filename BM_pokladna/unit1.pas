unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
     Grids, Menus, ExtCtrls, EditBtn, LazFileUtils, LazUtf8, uPSComponent, Math,
     LCLType;
const
  preskokKod = 4;
  path = 'Z:\INFProjekt2019\TimA\';
  //path = '';

type
  tovarTyp = record
        //iVPonuke zatial nie je nutne, ale funguje a moze sa zist
        //asi je nutne ;)

        //povMnozstvo - ak chcel viac ako mnozstvo, tak povMnozstvo:= mnozstvo,
        //aby keby vratil, tak sme zistili, ci mame pisat na sklad
        //default - povMnozstvo = -1 (nemusim si nic pamatat, lebo
        //(ziadane mnostvo < Tovary[i].mnozstvo)
        kod, povMnozstvo, mnozstvo, iVPonuke, iVKosiku: integer; //iVPonuke = -1 => nie je v Ponuke
        cenaKusNakup, cenaKusPredaj, cenaSpolu: currency;
        jeAktivny: boolean;
        nazov: string;
  end;
  suborTyp = record
        trebaUpravit: boolean;
        verzia: integer;
        menoSuboru: string;
  end;


  { TPokladna }

  TPokladna = class(TForm)
    PokladnaLabel: TLabel;
    logo: TImage;
    nacitanieSuborov: TTimer;
    delayT: TTimer;
    upravaSuborov: TTimer;
    verziaPanel: TPanel;
    zobrazTOP: TButton;
    celkCenaL: TLabel;
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
    procedure delayTTimer(Sender: TObject);
    function jeSlovo(inputString: string): boolean;
    procedure menoPokladnikaClick(Sender: TObject);
    procedure nacitanieSuborovTimer(Sender: TObject);
    procedure odhlasPokladnikaClick(Sender: TObject);
    procedure PSScript1AfterExecute(Sender: TPSScript);
    procedure simpleReloadClick(Sender: TObject);
    procedure upravaSuborovTimer(Sender: TObject);
    procedure zobrazTOPClick(Sender: TObject);
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
    procedure zapisViacSKLADtxt(iVTovary: integer);
    //custom wait
    procedure Delay(dt: QWORD);
    function dlzkaCisla(cislo: integer): integer;
    //lockovanie
    function verziaSuboru(subor: string): integer;
  private

  public

  end;

var
  Pokladna: TPokladna;
  Tovary, PKosik: array [0..99] of tovarTyp;
  Subory: array [1..5] of suborTyp;
  //1 - SKLAD.txt
  //2 - TOVAR.txt
  //3 - CENNIK.txt
  //4 - STATISTIKY.txt
  //5 - TOP.txt
  prazdnyTovar: tovarTyp;
  sklad, tovar, cennik, statistiky: textFile;
  tovarov, kupenychTovarov: integer;
  pokladnik, ponukaStav: string;
  //stavy ponukaStav:
  // => pri nacitanieSuborov zobrazit znova
  { TODO : keyWord pre vyhl }
  //vyhlPodlaKodu, vyhlPodlaNazvu
  //0kat, 1kat, 2kat, 3kat
  //vsetko, TOP
  //nic (nic sa nezozbrazuje)
  //uprava (nezobrazuj, prave upravujem)
  prveNacitanie: boolean;
  timerRepeat: qWord;
  celkCena: currency;
  topStrList, addStatStrList, statStrList: TStringList;

implementation

{$R *.lfm}

{ TPokladna }

procedure TPokladna.FormCreate(Sender: TObject);
var
    i, iTovaru, iZnaku, BoxStyle: integer;
    odpadChar: char;
    odpadString, kodString, nazovString, kodNazovString: string;
    zadalMeno: boolean;
    katStrList: TStringList;
    statLock: textFile;

begin
    nacitanieSuborov.Enabled:= false;
    prveNacitanie:= false;

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
     for i:=0 to 99 do begin
         Tovary[i].iVPonuke:= -1;
         Tovary[i].iVKosiku:= -1;
         Tovary[i].jeAktivny:= false;
         Tovary[i].povMnozstvo:= -1;
     end;
     //1 - SKLAD.txt
     //2 - TOVAR.txt
     //3 - CENNIK.txt
     //4 - STATISTIKY.txt
     //5 - TOP.txt
     Subory[1].menoSuboru:= 'SKLAD';
     Subory[2].menoSuboru:= 'TOVAR';
     Subory[3].menoSuboru:= 'CENNIK';
     Subory[4].menoSuboru:= 'STATISTIKY';
     Subory[5].menoSuboru:= 'TOP';

     //nadpisy
     Kosik.RowCount:= 1;
     Ponuka.RowCount:= 1;

     //Ponuka.SelectedColor:= clBlue;
     Ponuka.Options:= Ponuka.Options + {[goDrawFocusSelected] +}
                      [goRelaxedRowSelect] {+ [goSmoothScroll]} +
                      [goHeaderHotTracking] + [goHeaderPushedLook] +
                      [goSelectionActive] + [goCellHints] + [goTruncCellHints] +
                      [goCellEllipsis] + [goRowHighlight] {+ [goEditing] +
                      [goRowSelect]};
     Kosik.Options:= Kosik.Options + {[goDrawFocusSelected] +}
                      [goRelaxedRowSelect] {+ [goSmoothScroll]} +
                      [goHeaderHotTracking] + [goHeaderPushedLook] +
                      [goSelectionActive] + [goCellHints] + [goTruncCellHints] +
                      [goCellEllipsis] + [goRowHighlight] {+ [goEditing] +
                      [goRowSelect]};
     celkCena:= 0;
     celkCenaL.Caption:= 'spolu cely nakup: ' +
                              currToStrF(celkCena, ffFixed, 2) + ' €';
     vyhlPodlaKoduEdit.Clear;
     vyhlPodlaNazvuEdit.Clear;
     topStrList:= TStringList.Create;
     topStrList.Clear;

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

     ////pociatocne priradenie
     //assignFile(sklad, path + 'SKLAD.txt');
     //assignFile(tovar, path + TOVAR.txt');
     //assignFile(cennik, path + 'CENNIK.txt');
     //assignFile(statistiky, path + 'STATISTIKY.txt');
     //
     ////ideme vyplnit TStringGrid Ponuka
     //nacitanieCelejDatabazy;

     for i:=1 to 5 do begin
         Subory[i].trebaUpravit:= false;
         Subory[i].verzia:= 0; //nacitam i verziu 1
         Memo1.Append(Subory[i].menoSuboru + ': ' + intToStr(Subory[i].verzia));
     end;

     ponukaStav:= 'vsetko';
     nacitanieSuborov.Enabled:= true;
     //delay(150);

     while (fileExists(path + 'STATISTIKY_LOCK.txt')) do begin
         BoxStyle:= MB_ICONQUESTION + MB_RETRYCANCEL;
         Application.MessageBox('Nacitavam stats...', '', BoxStyle);
         delay(10);
     end;

     assignFile(statLock, path + 'STATISTIKY_LOCK.txt');
     rewrite(statLock);
     closeFile(statLock);
     statStrList:= TStringList.Create;
     statStrList.LoadFromFile(path + 'STATISTIKY.txt');
     deleteFile(path + 'STATISTIKY_LOCK.txt');

     addStatStrList:= TStringList.Create;

     while (prveNacitanie = false) do begin
         //showMessage('Nacitavam...');
         //Application.MessageBox(Application.Handle,'Nacitavam...',PChar(Application.Title),
         //   MB_OK or MB_ICONINFORMATION or MB_SYSTEMMODAL);
         BoxStyle:= MB_ICONQUESTION + MB_RETRYCANCEL;
         Application.MessageBox('Nacitavam databazu...', '', BoxStyle);

         //MessageDlg('Test with no buttons',mtInformation,[],0);
         delay(30);
     end;

     logo.Picture.LoadFromFile(path + 'logo_transparent.bmp');

     //for i:=1 to 5 do begin
     //    Subory[i].trebaUpravit:= false;
     //    Subory[i].verzia:= verziaSuboru(Subory[i].menoSuboru);
     //    Memo1.Append(Subory[i].menoSuboru + ': ' + intToStr(Subory[i].verzia));
     //end;

     //testy
     //for sgStlpce:=0 to 3 do
     //    for sgRiadky:=1 to 9 do
     //        Ponuka.Cells[sgStlpce,sgRiadky]:= intToStr(sgStlpce+sgRiadky+1);
end;

procedure TPokladna.Delay(dt: QWORD);
var
  tc : QWORD;
begin
  //tc := GetTickCount64;
  //while (GetTickCount64 < tc + dt) and (not Application.Terminated) do
  //  Application.ProcessMessages;
  timerRepeat:= 0;
  delayT.Enabled:= true;
  while (dt < timerRepeat * delayT.Interval) do begin
     Application.ProcessMessages;
  end;
  timerRepeat:= 0;
end;

procedure TPokladna.delayTTimer(Sender: TObject);
begin
    inc(timerRepeat);
end;

procedure TPokladna.nacitanieCelejDatabazy;
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

     //Ponuka.RowCount:= tovarov + 1; //+nadpis

      //Memo1.Append(intToStr(odpadInt));
     for iTovaru:=0 to tovarov-1 do begin
         nacitaniePolozkyCENNIKtxt(iTovaru);
         NacitaniePolozkyTOVARtxt(iTovaru);
         //NacitaniePolozkySKLADtxt(iTovaru);
         //Tovary[iTovaru].iVPonuke:= iTovaru+1; //0. riadok - hlavicka tabulky
     end;

     NacitaniePoloziekSKLADtxtStrList;

     closeFile(sklad);
     closeFile(tovar);
     closeFile(cennik);
     nacitanieSuborov.Enabled:= true;
end;

procedure TPokladna.NacitaniePolozkyCENNIKtxt(iTovaru: integer);
var
   cennikRiadok, kodString, cenaKusNakupString, cenaKusPredajString: string;
   iZnaku, iRiadku, preskokCennik2: integer;
begin
    iRiadku:= iTovaru + 1;
    readLn(cennik, cennikRiadok);

    //ak tovar nema cenu, tak je neaktivny (nezvysujem pocRiadkov)
    if (length(cennikRiadok) = 3) then begin
        Tovary[iTovaru].jeAktivny:= false;
        Tovary[iTovaru].iVPonuke:= -1;
        Tovary[iTovaru].kod:= strToInt(cennikRiadok);
        //Ponuka.Cells[0, iRiadku]:= Ponuka.Cells[0,iRiadku] + '*';
        //Ponuka.Cells[2, iRiadku]:= '';
    end else begin
    //tovar ma cenu a treba ju nacitat a zobrazit v Ponuke (zvysujem pocRiadkov)
        Pokladna.Ponuka.RowCount:= Pokladna.Ponuka.RowCount + 1;
        Tovary[iTovaru].jeAktivny:= true;
        Tovary[iTovaru].iVPonuke:= Pokladna.Ponuka.RowCount - 1;
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

        Tovary[iTovaru].kod:= strToInt({copy(cennikRiadok, 1, iZnaku-1)}kodString);
        Tovary[iTovaru].cenaKusNakup:= strToCurr(cenaKusNakupString) / 100{{$IFDEF UNIX} / 100 {$ENDIF}};
        Tovary[iTovaru].cenaKusPredaj:= strToCurr(cenaKusPredajString) / 100{{$IFDEF UNIX} / 100 {$ENDIF}};

        Pokladna.Ponuka.Cells[0, Tovary[iTovaru].iVPonuke]:= intToStr(Tovary[iTovaru].kod);
        Pokladna.Ponuka.Cells[2, Tovary[iTovaru].iVPonuke]:= {floatToStr(Tovary[iTovaru].cenaKusPredaj);}
        CurrToStrF(Tovary[iTovaru].cenaKusPredaj, ffFixed, 2);
        //Pokladna.Ponuka.Cells[0, Tovary[iTovaru].iVPonuke]
    end;
end;

procedure TPokladna.NacitaniePolozkyTOVARtxt(iTovaru: integer);
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
    Pokladna.Memo1.Append(kodString +' '+ nazovString); //test

    //kod zapisany z cenniku
    //Tovary[iTovaru].kod:= strToInt(kodString);
    Tovary[iTovaru].nazov:= nazovString;

    //vypisujeme iba aktivne tovary
    if (Tovary[iTovaru].jeAktivny = true) then begin
        //Pokladna.Ponuka.Cells[1, iRiadku]:= intToStr(Tovary[iTovaru].kod);
        Pokladna.Ponuka.Cells[1, Tovary[iTovaru].iVPonuke]:= Tovary[iTovaru].nazov;
    end;
end;

procedure TPokladna.nacitaniePoloziekSKLADtxtStrList;
var
   skladStrList: TStringList;
   iTovaru: integer;
   skladRiadok, kodString, mnozstvoString: string;
   iZnaku, iRiadku, bcPoz: integer;
begin
    skladStrList:= TStringList.Create;
    skladStrList.LoadFromFile(path + 'SKLAD.txt');
    //for iTovaru:=0 to tovarov do begin
    //    skladRiadok:= skladStrList[iTovaru];
    //    Memo1.Append(skladRiadok);
    //    bcPoz:= pos(';',skladRiadok);
    //    Memo1.Append(intToStr(bcPoz));
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
        bcPoz:= pos(';',skladRiadok);
        iZnaku:= bcPoz;
        Memo1.Append(intToStr(iZnaku));

        for iZnaku:=preskokKod+1 to length(skladRiadok) do begin
            mnozstvoString[iZnaku-preskokKod]:= skladRiadok[iZnaku];
        end;
        delete(mnozstvoString, iZnaku-preskokKod+1, length(mnozstvoString) - (iZnaku-preskokKod));
        //Pokladna.Memo1.Append(kodString +' '+ mnozstvoString);

        Tovary[iTovaru].mnozstvo:= strToInt(mnozstvoString);
        if (Tovary[iTovaru].jeAktivny = true) then begin
            Pokladna.Ponuka.Cells[3, Tovary[iTovaru].iVPonuke]:= intToStr(Tovary[iTovaru].mnozstvo);
        end;
    end;
end;

procedure TPokladna.NacitaniePolozkySKLADtxt(iTovaru: integer);
//neaktualizovane na nezobrazovanie cien
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
    Pokladna.Memo1.Append(kodString +' '+ mnozstvoString);

    Tovary[iTovaru].mnozstvo:= strToInt(mnozstvoString);
    Pokladna.Ponuka.Cells[3, iRiadku]:= intToStr(Tovary[iTovaru].mnozstvo);
end;

procedure TPokladna.VycistitPonuku;
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

procedure TPokladna.ZobrazJedenDruh(druh: integer);
var
   iTovaru,iRiadku: integer;
begin
    //VycistitPonuku;
    Ponuka.RowCount:= 1;
    iRiadku:= 1;
    for iTovaru:=0 to tovarov-1 do begin
        if (Tovary[iTovaru].kod div 100 = druh) and
                (Tovary[iTovaru].jeAktivny = true) then begin
           Ponuka.RowCount:= Ponuka.RowCount + 1;
           Tovary[iTovaru].iVPonuke:= iRiadku;
           Ponuka.Cells[0, Tovary[iTovaru].iVPonuke]:=
                           intToStr(Tovary[iTovaru].kod);
           Ponuka.Cells[1, Tovary[iTovaru].iVPonuke]:= Tovary[iTovaru].nazov;
           //if (Tovary[iTovaru].jeAktivny = false) then begin
           //   Ponuka.Cells[0, iRiadku]:= Ponuka.Cells[0, iRiadku] + '*';
           //   Ponuka.Cells[2, iRiadku]:= '';
           //end;
           Ponuka.Cells[2, Tovary[iTovaru].iVPonuke]:=
                           CurrToStrF(Tovary[iTovaru].cenaKusPredaj, ffFixed, 2);
           Ponuka.Cells[3, Tovary[iTovaru].iVPonuke]:=
                           intToStr(Tovary[iTovaru].mnozstvo);
           inc(iRiadku);
        end;
    end;
end;

procedure TPokladna.zobraz0KatClick(Sender: TObject);
begin
    ponukaStav:= 'uprava';
    VycistitPonuku;
    ZobrazJedenDruh(1); //1 = ovocie
    ponukaStav:= '0kat';
end;

procedure TPokladna.zobraz1KatClick(Sender: TObject);
begin
    ponukaStav:= 'uprava';
    VycistitPonuku;
    ZobrazJedenDruh(2); //2 = zelenina
    ponukaStav:= '1kat';
end;

procedure TPokladna.zobraz2KatClick(Sender: TObject);
begin
    ponukaStav:= 'uprava';
    VycistitPonuku;
    ZobrazJedenDruh(3); //3 = pecivo
    ponukaStav:= '2kat';
end;

procedure TPokladna.zobraz3KatClick(Sender: TObject);
begin
    ponukaStav:= 'uprava';
    VycistitPonuku;
    ZobrazJedenDruh(4); //4 = ine
    ponukaStav:= '3kat';
end;

procedure TPokladna.zobrazVsetkoClick(Sender: TObject);
var
   iTovaru, iRiadku: integer;
begin
    ponukaStav:= 'uprava';

    //VycistitPonuku;
    Ponuka.RowCount:= 1;
    iRiadku:= -1;
    for iTovaru:=0 to tovarov-1 do begin
        iRiadku:= iTovaru + 1;
        if (Tovary[iTovaru].jeAktivny = true) then begin
            Ponuka.RowCount:= Ponuka.RowCount + 1;
            Tovary[iTovaru].iVPonuke:= Ponuka.RowCount - 1;
            Ponuka.Cells[0, Tovary[iTovaru].iVPonuke]:=
                            intToStr(Tovary[iTovaru].kod);
            Ponuka.Cells[1, Tovary[iTovaru].iVPonuke]:= Tovary[iTovaru].nazov;
            Ponuka.Cells[2, Tovary[iTovaru].iVPonuke]:=
                            CurrToStrF(Tovary[iTovaru].cenaKusPredaj, ffFixed, 2);
            Ponuka.Cells[3, Tovary[iTovaru].iVPonuke]:=
                            intToStr(Tovary[iTovaru].mnozstvo);
        end;
        //Ponuka.Cells[0, iRiadku]:= Ponuka.Cells[0, iRiadku] + '*';
        //Ponuka.Cells[2, iRiadku]:= '';
    end;

    ponukaStav:= 'vsetko';
end;

procedure TPokladna.zobrazTOPClick(Sender: TObject);
var
   iVTOP, iVTovary, iVPKosik, BoxStyle: integer;
   jeVPKosik: boolean;
   fileTopStrList: TStringList;
begin
     if not(fileExists('TOP.txt')) then begin
        ShowMessage('Primalo (<5) predanych tovarov na statistiku.');
        exit;
     end;

     while (fileExists('TOP_LOCK.txt')) do begin
         BoxStyle:= MB_ICONQUESTION + MB_RETRYCANCEL;
         Application.MessageBox('Nacitavam...', '', BoxStyle);
         delay(30);
     end;

     fileTopStrList:= TStringList.Create;
     fileCreate(path + 'TOP_LOCK.txt');
     fileTopStrList.LoadFromFile(path + 'TOP.txt');
     deleteFile(path + 'TOP_LOCK.txt');
     //ak je TOP rovnaky
     if (fileTopStrList = topStrList) then begin
        exit;
     end else begin
         topStrList:= fileTopStrList;
     end;

     ponukaStav:= 'uprava';
     vycistitPonuku;
     Ponuka.RowCount:= 6; //aj s nadpismi (1 Fixed row)
     for iVTOP:= 0 to 4 do begin
         iVTovary:= 0;
         while (Tovary[iVTovary].kod <> strToInt(topStrList[iVTOP])) do begin
             inc(iVTovary);
         end;
         Ponuka.Cells[0, iVTOP + 1]:= intToStr(Tovary[iVTovary].kod);
         Ponuka.Cells[1, iVTOP + 1]:= Tovary[iVTovary].nazov;
         Ponuka.Cells[2, iVTOP + 1]:= currToStrF(Tovary[iVTovary].cenaKusPredaj,
                                         ffFixed, 2);
         Ponuka.Cells[3, iVTOP + 1]:= intToStr(Tovary[iVTovary].mnozstvo);
         //if  not Tovary[iVTovary].jeAktivny then begin
         //    Ponuka.Cells[1, iVTOP + 1]:= Ponuka.Cells[0, iVTOP + 1] + '*';
         //    Ponuka.Cells[2, iVTOP + 1]:= '';
         //end;
         Tovary[iVTovary].iVPonuke:= iVTOP + 1;

         //indexy pridajme i do PKosik
         jeVPKosik:= false;
         iVPKosik:= 0;
         while {(not jevPKosik) and} (iVPKosik < kupenychTovarov) do begin
             if (PKosik[iVPKosik].kod <> strToInt(topStrList[iVTOP])) then begin
                inc(iVPKosik);
             end else begin
                 jeVPKosik:= true;
                 break;
             end;
         end;
         if (jeVPKosik) then begin
            PKosik[iVPKosik].iVPonuke:= iVTOP + 1;
         end;
     end;

     ponukaStav:= 'TOP';
end;

procedure TPokladna.zrusitNakup;
var
   iVPKosik, iVTovary: integer;
begin
     Kosik.RowCount:= 1; //legendarne nadpisy
     for iVPKosik:=0 to kupenychTovarov-1 do begin
         //Tovary[PKosik[iVPKosik].iVTovary].iVKosiku:= -1;
         iVTovary:= 0;
         while(PKosik[iVPKosik].nazov <> Tovary[iVTovary].nazov) do begin
             inc(iVTovary);
         end;

         Tovary[iVTovary].mnozstvo:= Tovary[iVTovary].mnozstvo
                                     + PKosik[iVPKosik].mnozstvo;

         //zapis do SKLAD.txt, ak si zobral viac ako tam bolo (=nasiel si)
         if (Tovary[iVTovary].povMnozstvo <> -1) then begin
             zapisViacSKLADtxt(iVTovary);
         end;

         Tovary[iVTovary].iVKosiku:= -1; //uz nie je v kosiku
         //zobraz rovno v Ponuka, ak tam je
         if (Tovary[iVTovary].iVPonuke <> -1) then begin
            Ponuka.Cells[3, Tovary[iVTovary].iVPonuke]:=
                            intToStr(Tovary[iVTovary].mnozstvo);
         end;
         PKosik[iVPKosik]:= prazdnyTovar;
     end;
     kupenychTovarov:= 0;
     celkCena:= 0;
     celkCenaL.Caption:= 'spolu cely nakup: ' +
                         currToStrF(celkCena, ffFixed, 2) + ' €';
end;

procedure TPokladna.zrusNakupClick(Sender: TObject);
var
   chceZrusit: integer;
begin
    chceZrusit := messageDlg('Naozaj chcete zrusit cely nakup?'
              ,mtCustom, mbOKCancel, 0);

    if (chceZrusit = mrOK) then begin
        zrusitNakup;
    end;
end;

procedure TPokladna.zrusitPolozkuClick(Sender: TObject);
begin

end;

//procedure TPokladna.zrusitPolozkuClick(Sender: TObject);
//var
//   keyWord: string;
//   zadalStr: boolean;
//begin
//
//end;

procedure TPokladna.PonukaClick(Sender: TObject);
var
   iStlpca, iRiadku, iVybratehoVTovary, iVybratehoVPKosik,
     ziadaneMnozstvo, chcemViac, chceZobrazitVsetko: Integer;
   inputRiadok, oznamKlikMimoNazvu: string;
   novyTovar, niecoZadal, zadalInt: boolean;
begin
     //testy
     //iStlpca:= Ponuka.Col;
     //iRiadku:= Ponuka.Row;
     //Memo1.Append(intToStr(iStlpca)+' '+intToStr(iRiadku));

     iRiadku:= Ponuka.Row;
     iStlpca:= Ponuka.Col;

     if (Ponuka.RowCount > 1) and (Ponuka.Cells[0, 1] = 'XXX') then begin
        chceZobrazitVsetko := messageDlg('Udaje, ktore hladate neexistuju. ' +
                          ' Chcete zobrazit Ponuku?'
                          ,mtCustom, mbOKCancel, 0);
        if (chceZobrazitVsetko = mrOK) then begin
           vyhlPodlaKoduEdit.Clear;
           vyhlPodlaNazvuEdit.Clear;
           zobrazVsetkoClick(Ponuka);
        end;
        exit;
        exit;
     end;

     //najdenie tovaru v Tovary[] a PKosik[]
     iVybratehoVTovary:= 0;
     while(Tovary[iVybratehoVTovary].iVPonuke <> iRiadku) do begin
         inc(iVybratehoVTovary);
     end;

     case iStlpca of
         1: begin
             //tovar je neaktivny (nema cenu)
             if (Tovary[iVybratehoVTovary].jeAktivny = false) then begin
                 showMessage(Tovary[iVybratehoVTovary].nazov +
                           ' sa momentalne nepredava.');
                 exit;
             end;

             //este nekupene
             if (Tovary[iVybratehoVTovary].iVKosiku = -1) then begin
                novyTovar:= true;
                iVybratehoVPKosik:= kupenychTovarov;
                Tovary[iVybratehoVTovary].iVKosiku:= iVybratehoVPKosik;
             end else begin
                novyTovar:= false;
                iVybratehoVPKosik:= Tovary[iVybratehoVTovary].iVKosiku;
             end;

             niecoZadal:= true;
             zadalInt:= false;
             while niecoZadal and not zadalInt do begin
                 inputRiadok:= '1';
                 niecoZadal:= inputQuery(Tovary[iVybratehoVTovary].nazov,
                          'Zadajte mnozstvo: '+Tovary[iVybratehoVTovary].nazov,
                          inputRiadok);
                 if not niecoZadal then begin
                    exit;
                    exit;
                    exit;
                 end;
                 zadalInt:= tryStrToInt(inputRiadok, ziadaneMnozstvo);
                 if not zadalInt or (ziadaneMnozstvo < 1) then begin
                   showMessage('zadaj CISLO. PRIRODZENE CISLO. Vies, ako ma stves?!');
                   exit;
                   exit;
                   exit;
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
                       exit;
                  end else if (chcemViac = mrOK) then begin
                       //ak uz mame povMnozstvo, tak ho tam nechame, lebo to je
                       //jedine povMnozstvo
                       if (Tovary[iVybratehoVTovary].povMnozstvo = -1) then begin
                           Tovary[iVybratehoVTovary].povMnozstvo:=
                                Tovary[iVybratehoVTovary].mnozstvo;
                       end;
                  end;
             end;

             //Tovary[iVybratehoVTovary] => PKosik[iVybratehoVPKosik]
             //osetreny pripad noveho i stareho tovaru
             PKosik[iVybratehoVPKosik].nazov:= Tovary[iVybratehoVTovary].nazov;
             PKosik[iVybratehoVPKosik].kod:= Tovary[iVybratehoVTovary].kod;
             PKosik[iVybratehoVPKosik].cenaKusPredaj:= Tovary[iVybratehoVTovary].cenaKusPredaj;
             PKosik[iVybratehoVPKosik].iVPonuke:= iRiadku{iVybratehoVPKosik + 1};
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

             if novyTovar then begin
                Kosik.RowCount:= Kosik.RowCount + 1;
             end;

             //hard hard verziaSuboru (2 rovnake tovar => 1 riadok)
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

             if (novyTovar = true) and (ziadaneMnozstvo > 0) then begin
                 inc(kupenychTovarov);
             end;
         end;

         0: begin
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

procedure TPokladna.KosikClick(Sender: TObject);
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

        //zapis do SKLAD.txt, ak si zobral viac ako tam bolo (=nasiel si)
        if (Tovary[iVTovary].povMnozstvo <> -1) then begin
             zapisViacSKLADtxt(iVTovary);
        end;

        //zapis rovno do Ponuky, ak tam ruseny tovar prave je
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

function TPokladna.dlzkaCisla(cislo: integer): integer;
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

procedure TPokladna.zaplatitClick(Sender: TObject);
//prida kupeny tovar do STATISTIKY.txt, uberie zo SKLAD.txt, vytvori
//uctenka_[id_transakcie].txt a zrusi Kosik
var
   riadkov, statRiadkov, povMnozstvoSKLADtxt, iVTovary,
     medzK1, medzK11, medzK2, medzE, sepLine, dlzCisla, chcePlatit,
     odsadenieLoga: integer;
   transID: qword;
   iPredaj, iTovaru: integer;
   aktDatum: TDateTime;
   skladStrList, uctStrList: TStringList;
   skladOldRiadok, skladNewRiadok, riadokUctu: string;
   uctenka: textFile;
begin
    chcePlatit := messageDlg('Naozaj chcete zaplatit cely nakup?'
             ,mtCustom, mbOKCancel, 0);
    if (chcePlatit = mrCancel) then begin
        exit;
        exit;
    end;

    //testy
    //Memo1.Append(DateToStr(Now));

    //append STATISTIKY.txt
    //priprava na pracu s statistiky
    repeat
       transID:= qword(10000000) + qword(random(89999999));
    until not fileExists(path + 'UCTENKY\' +  'uctenka_' +intToStr(transID));
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

    //statStrList.LoadFromFile(path + 'STATISTIKY.txt');
    //statRiadkov:= strToInt(statStrList[0]) + kupenychTovarov;
    //statStrList[0]:= intToStr(statRiadkov);

    for iPredaj:=0 to kupenychTovarov-1 do begin
        addStatStrList.Add('P;'+ intToStr(transID) +';'+
        intToStr(PKosik[iPredaj].kod) +';'+
        intToStr(PKosik[iPredaj].mnozstvo) +';'+
        floatToStr(PKosik[iPredaj].cenaKusPredaj * 100) +';'+
        FormatDateTime('YYMMDD', aktDatum));
    end;
    Subory[4].trebaUpravit:= true; //upravi Timer

    //ubratie tovaru zo SKLAD.txt
    skladStrList:= TStringList.Create;
    skladStrList.LoadFromFile(path + 'SKLAD.txt');
    for iPredaj:=0 to kupenychTovarov-1 do begin
        iVTovary:= 0;
        while (PKosik[iPredaj].kod <> Tovary[iVTovary].kod) do begin
            inc(iVTovary);
        end;
        if (Tovary[iVTovary].povMnozstvo = -1) then begin
            povMnozstvoSKLADtxt:= Tovary[iVTovary].mnozstvo +
                               PKosik[iPredaj].mnozstvo;
        end else begin
            povMnozstvoSKLADtxt:= Tovary[iVTovary].povMnozstvo;
        end;

        skladOldRiadok:= intToStr(PKosik[iPredaj].kod) +';'+ intToStr(povMnozstvoSKLADtxt);
        skladNewRiadok:= intToStr(PKosik[iPredaj].kod) +';'+
                    intToStr(Tovary[iVTovary].mnozstvo);
        skladStrList.Text := StringReplace(skladStrList.Text,
                          skladOldRiadok, skladNewRiadok, [rfIgnoreCase]);
    end;
    skladStrList.SaveToFile(path + 'SKLAD.txt');
    skladStrList.Free;

    //vytvorenie uctenka_[id_transakcie].txt
    odsadenieLoga:= 16;
    sepLine:= 44;
    medzK1:= 36;
    medzK11:= 12;
    medzK2:= 6;
    medzE:= 11;

    uctStrList:= TStringList.Create;
    uctStrList.Add(stringOfChar(' ', odsadenieLoga) + '╔═══╗');
    uctStrList.Add(stringOfChar(' ', odsadenieLoga) + '║   ║ |\  /|');
    uctStrList.Add(stringOfChar('_', odsadenieLoga) + '╠═══╣ | \/ |' +
                   stringOfChar('_', odsadenieLoga));
    uctStrList.Add(stringOfChar(' ', odsadenieLoga) + '║   ║ |    |');
    uctStrList.Add(stringOfChar(' ', odsadenieLoga) + '╚═══╝ |    |');
    uctStrList.Add('Jesenskeho 4/A, 811 02  Bratislava 1');
    uctStrList.Add(stringOfChar('_',sepLine));

    uctStrList.Add('Datum: ' +stringOfChar(' ',medzK1 - 7 + 1)+ dateToStr(now));
    uctStrList.Add('Cas: ' +stringOfChar(' ', medzK1 - 5)+ timeToStr(now));
    uctStrList.Add('Cislo uctenky: ' +stringOfChar(' ', medzK1 - 15)+
                          intToStr(transID));
    uctStrList.Add(stringOfChar('_',sepLine));

    for iTovaru:=0 to kupenychTovarov-1 do begin
        //uctStrList.Add(PKosik[iTovaru].nazov +stringOfChar(' ',medzK11)+
        //intToStr(PKosik[iTovaru].cenaKusPredaj / 100) +' €'+)
        riadokUctu:= PKosik[iTovaru].nazov;
        //if (PKosik[iTovaru].cenaKusPredaj > 999)
        dlzCisla:= dlzkaCisla(Trunc(PKosik[iTovaru].cenaKusPredaj * 100));
        inc(dlzCisla); //0.02 => bodka
        if (dlzCisla < 4) then dlzCisla:= 4; //desatinne cisla typu 0.01
        riadokUctu:= riadokUctu + stringOfChar(' ',
                     medzK11 + (medzE - dlzCisla) -
                     length(PKosik[iTovaru].nazov)) +
                     currToStrF(PKosik[iTovaru].cenaKusPredaj, ffFixed, 2) +' €';
        dlzCisla:= dlzkaCisla(PKosik[iTovaru].mnozstvo);
        riadokUctu:= riadokUctu + stringOfChar(' ',medzK2-dlzCisla) +
                     intToStr(PKosik[iTovaru].mnozstvo);
        dlzCisla:= dlzkaCisla(Trunc(PKosik[iTovaru].cenaKusPredaj *
                   PKosik[iTovaru].mnozstvo * 100));
        inc(dlzCisla); //0.02 => bodka
        if (dlzCisla < 4) then dlzCisla:= 4; //desatinne cisla typu 0.01
        riadokUctu:= riadokUctu + stringOfChar(' ',medzE-dlzCisla) +
                     currToStrF(PKosik[iTovaru].cenaKusPredaj *
                     PKosik[iTovaru].mnozstvo, ffFixed, 2) +' €';
        uctStrList.Add(riadokUctu);
    end;

    //formatfloat('0.0000', float)

    uctStrList.SaveToFile(path + 'UCTENKY\' + 'uctenka_' +intToStr(transID)+ '.txt');
    uctStrList.Free;
    //assignFile(uctenka, 'uctenka_' +intToStr(transID));
    //rewrite(uctenka);
    //closeFile(uctenka);

    //zrusenie nakupu
    //nacitanieCelejDatabazy;
    for iPredaj:=0 to kupenychTovarov-1 do begin
        PKosik[iPredaj].mnozstvo:= 0;
        PKosik[iPredaj].povMnozstvo:= -1;
    end;
    zrusitNakup;
end;

procedure TPokladna.zapisViacSKLADtxt(iVTovary: integer);
var
   skladStrList: TStringList;
   oldRiadok, newRiadok: string;
begin
      skladStrList:= TStringList.Create;
      skladStrList.LoadFromFile(path + 'SKLAD.txt');
      oldRiadok:= intToStr(Tovary[iVTovary].kod) + ';' +
                  intToStr(Tovary[iVTovary].povMnozstvo);
      newRiadok:= intToStr(Tovary[iVTovary].kod) + ';' +
                  intToStr(Tovary[iVTovary].mnozstvo);
      skladStrList.text:= stringReplace(skladStrList.text, oldRiadok,
                          newRiadok, [rfIgnoreCase]);
      skladStrList.SaveToFile(path + 'SKLAD.txt');
      skladStrList.Free;
      Tovary[iVTovary].povMnozstvo:= -1;
end;

procedure TPokladna.vyhlPodlaKoduEditClick(Sender: TObject);
begin
     vyhlPodlaNazvuEdit.Clear;
     vyhlPodlaKoduEdit.Clear;
end;

procedure TPokladna.vyhlPodlaNazvuEditClick(Sender: TObject);
begin
     vyhlPodlaNazvuEdit.Clear;
     vyhlPodlaKoduEdit.Clear;
end;

procedure TPokladna.vyhlPodlaKodu(userInput: string; Sender: TObject);
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

     ponukaStav:= 'uprava';

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
                    Ponuka.Cells[0, najdenych]:= intToStr(Tovary[iTovaru].kod);
                    Ponuka.Cells[1, najdenych]:= Tovary[iTovaru].nazov;
                    //if (Tovary[iTovaru].jeAktivny = false) then begin
                    //   Ponuka.Cells[0, najdenych]:= Ponuka.Cells[0, najdenych] + '*';
                    //end;
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
            Ponuka.Cells[0, 1]:= 'XXX';
            Ponuka.Cells[1, 1]:= 'Tovar s kodom ' + intToStr(hladanyKod) +
                            ' neexistuje.';
            Ponuka.Cells[2, 1]:= 'XX,XX €';
            Ponuka.Cells[3, 1]:= 'XXX';

         end;
     end else begin
         ShowMessage('Zadajte cislo 100 <= cislo < 500 (pre expertov: ' +
                              'Zadajte take kladne, cele cislo a, ' +
                              'pre ktore plati: ' + #13#10 + '0,2 < a/500 < 0,998)');
         vyhlPodlaKoduEdit.Clear;
         zobrazVsetkoClick(vyhlPodlaKoduEdit);
         //umysel je dat kurzor prec, ale to sa nedari
         //vyhlPodlaKoduEdit.Invalidate;
         //Memo1.SelLength:= 0;
         //Memo1.SelStart:= Length(Memo1.Text);
     end;

     ponukaStav:= 'vyhlPodlaKodu';
end;

procedure TPokladna.vyhlPodlaKoduEditChange(Sender: TObject);
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

procedure TPokladna.vyhlPodlaKoduMenuClick(Sender: TObject);
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

procedure TPokladna.vyhlPodlaNazvu(userInput: string; Sender: TObject);
var
    hlSlovo, nazovTovaru: string;
    iTovaru, najdenych: integer;
begin
     //inicializacia
     najdenych:= 0;
     if (userInput = '') then begin
         zobrazVsetkoClick(vyhlPodlaKoduEdit);
         exit;
     end;

     ponukaStav:= 'uprava';

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
                 Ponuka.Cells[0, najdenych]:= intToStr(Tovary[iTovaru].kod);
                 Ponuka.Cells[1, najdenych]:= Tovary[iTovaru].nazov;
                 //if (Tovary[iTovaru].jeAktivny = false) then begin
                 //    Ponuka.Cells[0, najdenych]:= Ponuka.Cells[0, najdenych] + '*';
                 //end;
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

     ponukaStav:= 'vyhlPodlaNazvu';
end;

procedure TPokladna.vyhlPodlaNazvuEditChange(Sender: TObject);
var
    hlSlovo: string;
begin
     vyhlPodlaKoduEdit.Clear;
     hlSlovo:= vyhlPodlaNazvuEdit.Text;
     vyhlPodlaNazvu(hlSlovo, vyhlPodlaNazvuEdit);
end;

procedure TPokladna.vyhlPodlaNazvuMenuClick(Sender: TObject);
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

function TPokladna.jeSlovo(inputString: string): boolean;
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

procedure TPokladna.menoPokladnikaClick(Sender: TObject);
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

procedure TPokladna.nacitanieSuborovTimer(Sender: TObject);
//++ al. -- tovar IBA podla CENNIK.txt
var
   lock, cennikLock, tovarLock, skladLock: textFile;
   tovarStrList, cennikStrList, skladStrList: TStringList;
   iTovaru, tovarAktVerzia, cennikAktVerzia, skladAktVerzia, iRiadku, bcPoz,
     iPosun, iVPonuke: integer;
   rTovar, rCennik, rSklad: string;
begin
   //nove easy nacitanie - lockujem vsetky naraz, predpokladam - rovnaky riadok
   //rovnaky kod
   cennikAktVerzia:= verziaSuboru('CENNIK');
   tovarAktVerzia:= verziaSuboru('TOVAR');
   skladAktVerzia:= verziaSuboru('SKLAD');

   if (Subory[3].verzia < cennikAktVerzia) or
      (Subory[2].verzia < tovarAktVerzia) or
      (Subory[1].verzia < skladAktVerzia) then begin
       verziaPanel.Caption:= 'Nemam akt. verziu.';
   end;

   if (
         (Subory[3].verzia < cennikAktVerzia) or
         (Subory[2].verzia < tovarAktVerzia) or
         (Subory[1].verzia < skladAktVerzia)
      ) and
      (
         not (fileExists(path + 'CENNIK_LOCK.txt')) and
         not (fileExists(path + 'TOVAR_LOCK.txt')) and
         not (fileExists(path + 'SKLAD_LOCK.txt'))
      ) and
      (
         kupenychTovarov = 0
      )
      then begin
          if (prveNacitanie = false) then begin
              prveNacitanie:= true;
          end;

          assignFile(cennikLock, (path + 'CENNIK_LOCK.txt'));
          rewrite(cennikLock);
          closeFile(cennikLock);

          assignFile(tovarLock, (path + 'TOVAR_LOCK.txt'));
          rewrite(tovarLock);
          closeFile(tovarLock);

          assignFile(skladLock, (path + 'SKLAD_LOCK.txt'));
          rewrite(skladLock);
          closeFile(skladLock);



          for iTovaru:=0 to tovarov-1 do begin
              Tovary[iTovaru]:= prazdnyTovar;
          end;

          //nacitanie CENNIK.txt
          cennikStrList:= TStringList.Create;
          cennikStrList.LoadFromFile(path + 'CENNIK.txt');
          tovarov:= strToInt(cennikStrList[0]);
          for iTovaru:=0 to tovarov-1 do begin
             iRiadku:= iTovaru + 1;
             rCennik:= cennikStrList[iRiadku];

             Tovary[iTovaru].kod:= strToInt(copy(rCennik, 1, 3));

             iVPonuke:= 1;

             while (iVPonuke < Ponuka.RowCount) and (Tovary[iTovaru].kod <>
                   strToInt(Ponuka.Cells[0,iVPonuke])) do begin
                 inc(iVPonuke);
             end;

             if (iVPonuke = Ponuka.RowCount) then begin
                Tovary[iTovaru].iVPonuke:= -1;
             end else begin
                Tovary[iTovaru].iVPonuke:= iVPonuke;
             end;


             //neaktivny tovar (v cenniku iba kod)
             if (length(rCennik) = 3) then begin
                 Tovary[iTovaru].jeAktivny:= false;
             end else begin
                 Tovary[iTovaru].jeAktivny:= true;
                 //kod
                 bcPoz:= pos(';', rCennik);
                 delete(rCennik, 1, bcPoz);

                 //cenaKusNakup (nepotrebna :) )
                 bcPoz:= pos(';',rCennik);
                 Tovary[iTovaru].cenaKusNakup:= strToCurr(copy(rCennik, 1,
                                                bcPoz - 1)) / 100;
                 delete(rCennik, 1, bcPoz);

                 //cenaKusPredaj
                 Tovary[iTovaru].cenaKusPredaj:= strToCurr(rCennik) / 100;

                 //if (Tovary[iTovaru].iVPonuke <> -1) then begin
                 //    Ponuka.Cells[1, Tovary[iTovaru].iVPonuke]:=
                 //                    intToStr(Tovary[iTovaru].kod);
                 //    Ponuka.Cells[2, Tovary[iTovaru].iVPonuke]:= currToStrF(
                 //                    Tovary[iTovaru].cenaKusPredaj, ffFixed, 2);
                 //end;
             end;
         end;
         Subory[3].verzia:= cennikAktVerzia;
         deleteFile(path + 'CENNIK_LOCK.txt');

         //nacitanie TOVAR.txt
         tovarStrList:= TStringList.Create;
         tovarStrList.LoadFromFile(path + 'TOVAR.txt');
         //tovarov:= strToInt(tovarStrList[0]);
         //nemoze sa mi stat, ze mam iny pocet tovarov
         for iTovaru:=0 to tovarov-1 do begin
             iRiadku:= iTovaru + 1;
             rTovar:= tovarStrList[iRiadku];
             //kod nacitany z cennika
             //Tovary[iTovaru].kod:= strToInt(copy(rTovar, 1, 3));
             delete(rTovar, 1, 4);
             Tovary[iTovaru].nazov:= rTovar;
             //if (Tovary[iTovaru].iVPonuke <> -1) then begin
             //    Ponuka.Cells[0, Tovary[iTovaru].iVPonuke]:=
             //                    Tovary[iTovaru].nazov;
             //end;
         end;
         Subory[2].verzia:= tovarAktVerzia;
         deleteFile(path + 'TOVAR_LOCK.txt');

         //nacitanie SKLAD.txt
         skladStrList:= TStringList.Create;
         skladStrList.LoadFromFile('SKLAD.txt');
         //skladov:= strToInt(skladStrList[0]);
         //nemoze sa mi stat, ze mam iny pocet skladov
         for iTovaru:=0 to tovarov-1 do begin
             iRiadku:= iTovaru + 1;
             rSklad:= skladStrList[iRiadku];
             //kod nacitany z cennika
             //Tovary[iTovaru].kod:= strToInt(copy(rSklad, 1, 3));
             delete(rSklad, 1, 4);
             Tovary[iTovaru].mnozstvo:= strToInt(rSklad);
             //if (Tovary[iTovaru].iVPonuke <> -1) then begin
             //    Ponuka.Cells[3, Tovary[iTovaru].iVPonuke]:=
             //                    intToStr(Tovary[iTovaru].mnozstvo);
             //end;
         end;
         Subory[1].verzia:= skladAktVerzia;
         deleteFile(path + 'SKLAD_LOCK.txt');

         //nacitaj Ponuku na zaklade ponukaStav
         while (ponukaStav = 'uprava') do begin
             delay(25);
         end;

         case ponukaStav of
             'vsetko': begin
                 zobrazVsetkoClick(nacitanieSuborov);
             end;
             '0kat': begin
                 zobraz0katClick(nacitanieSuborov);
             end;
             '1kat': begin
                 zobraz1katClick(nacitanieSuborov);
             end;
             '2kat': begin
                 zobraz2katClick(nacitanieSuborov);
             end;
             '3kat': begin
                 zobraz3katClick(nacitanieSuborov);
             end;
             'TOP': begin
                 zobrazTOPClick(nacitanieSuborov);
             end;

             else showMessage('CRASH! Zla ponukaStav.');
         end;

         verziaPanel.Caption:= 'Mam akt. verziu.';
   end;

   //speci nacitanie SKLAD.txt (moze aj pri neprazdnom kosiku)
   //nacitam, co sa da, zvysok ignorujem
end;

procedure TPokladna.upravaSuborovTimer(Sender: TObject);
var
   verzia: TStringList;
   iNewVerzie, iStatR, statRiadkov: integer;
   statLock: textFile;
begin
   if (Subory[4].trebaUpravit) and not fileExists(path + 'STATISTIKY_LOCK.txt') then
   begin
      Subory[4].trebaUpravit:= false;

      assignFile(statLock, (path + 'STATISTIKY_LOCK.txt'));
      rewrite(statLock);
      closeFile(statLock);

      statStrList.LoadFromFile(path + 'STATISTIKY.txt');
      statRiadkov:= strToInt(statStrList[0]) + addStatStrList.Count;
      statStrList[0]:= intToStr(statRiadkov);

      for iStatR:=0 to addStatStrList.Count-1 do begin
         statStrList.Add(addStatStrList[iStatR]);
      end;
      addStatStrList.Free;

      statStrList.SaveToFile(path + 'STATISTIKY.txt');

      verzia:= TStringList.Create;
      verzia.LoadFromFile(path + 'STATISTIKY_VERZIA.txt');
      iNewVerzie:= strToInt(verzia[0]) + 1;
      verzia[0]:= intToStr(iNewVerzie);
      verzia.SaveToFile(path + 'STATISTIKY_VERZIA.txt');

      deleteFile(path + 'STATISTIKY_LOCK.txt');
   end;


end;

function TPokladna.verziaSuboru(subor: string): integer;
//vrati verziu suboru
var
   suborStrList: TStringList;
begin
     suborStrList:= TStringList.Create;
     suborStrList.LoadFromFile(path + subor + '_VERZIA.txt');
     exit(strToInt(suborStrList[0]));
end;

procedure TPokladna.odhlasPokladnikaClick(Sender: TObject);
//very easy verziaPanel!!!
begin
    zrusitNakup;
    FormCreate(odhlasPokladnika);
end;

procedure TPokladna.PSScript1AfterExecute(Sender: TPSScript);
begin

end;

procedure TPokladna.simpleReloadClick(Sender: TObject);
begin

end;

procedure TPokladna.koniecClick(Sender: TObject);
begin
     close;
end;

procedure TPokladna.MenuItem2Click(Sender: TObject);
begin

end;

end.
