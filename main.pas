unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, RxPascal;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

  public

  end;

  TFuncNoArgsString = function(): String;

var
  Form1: TForm1;

implementation


procedure ToEdit2(arg: string);
begin
  Form1.Edit2.Text := arg;
end;

procedure ToEdit(arg: string);
begin
  Form1.Edit1.Text := arg;
end;

procedure ToMemo(arg: string);
begin
  Form1.Memo1.Lines.Text := arg;
end;

function DelayedFunction: string;
begin
  Form1.Memo1.Lines.Add('delaying');
  sleep(1000);
  Result := 'Finally I returned';
end;

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  AObs: TObservable;
begin
  Label1.Caption := 'starting';
  AObs := TObservable.Create(@DelayedFunction);
  Aobs.Subscribe(@ToEdit);
  Aobs.Subscribe(@ToEdit2);
  AObs.Subscribe(@ToMemo);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Memo1.Lines.Add('A thread nao esta congelada');
end;


end.

