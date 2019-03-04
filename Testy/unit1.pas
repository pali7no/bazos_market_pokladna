unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    stringCase: TButton;
    desatMiesta: TButton;
    zadavanieTovaru: TButton;
    forceInput: TButton;
    procedure desatMiestaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure forceInputClick(Sender: TObject);
    procedure stringCaseClick(Sender: TObject);
    procedure zadavanieTovaruClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  value: string;
  odpadInt: integer;
  odpadBool, odpadBool2: boolean;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.desatMiestaClick(Sender: TObject);
var
     salary: currency;
     amount : real;
begin
     salary:= 10000.000000000000;
     ShowMessage(CurrToStrF(salary, ffFixed, 2));

      ThousandSeparator := ' ';
      amount := 1234.567;
      // Display the amount using the default decimal digits (2)
      ShowMessage('Amount = '+Format('%m', [amount]));

      // Redisplay the amount with 4 decimal digits
      CurrencyDecimals := 4;
      ShowMessage('Amount = '+Format('%m', [amount]));
end;

procedure TForm1.forceInputClick(Sender: TObject);
begin
  // Keep asking the user for their name
   //repeat
   //  if not InputQuery('Test program', 'Please type your name', value)
   //  then ShowMessage('User cancelled the dialog');
   //until value <> '';
   //
   //while not inputQuery('Test program', 'Please type your name', value)
   //      do odpadInt:= 1;

   repeat
     value:= '1';
     odpadbool:= inputQuery('test moj', 'toto pis', value);
     odpadbool2:= tryStrToInt(value, odpadInt);
   until (odpadbool = true) and (odpadBool2 = true);

   // Show their name
   ShowMessage('Hello '+intToStr(odpadInt));
end;

procedure TForm1.stringCaseClick(Sender: TObject);
var
     r, stav: string;
begin
    stav:= inputbox('','',r);
    case stav of
    'vyhlPodlaKodu': showMessage('vyhlPodlaKodu');
    'vyhlPodlaNazvu': showMessage('vyhlPodlaNazvu');

    else showMessage('Blbost input.')
    end;
end;

procedure TForm1.zadavanieTovaruClick(Sender: TObject);
begin
  odpadBool:= inputQuery('test zadavania', 'tovaru', value);
  if odpadBool then begin
    odpadBool2:= tryStrToInt(value, odpadInt);
    if not odpadBool2 then begin
      showMessage('zadaj CISLO. CELE CISLO. A ne*er ma.');
    end else begin
      showMessage('Som zadany (' +intToStr(odpadInt)+')');
    end;
  end;
end;

end.

