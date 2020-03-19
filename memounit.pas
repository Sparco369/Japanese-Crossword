unit MemoUnit;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ExtDlgs;

type

  { TfrmMemo }

  TfrmMemo = class(TForm)
    Memo1: TMemo;
    sbtClear: TSpeedButton;
    sbtMinimize: TSpeedButton;
    Image1: TImage;
    procedure sbtClearClick(Sender: TObject);
    procedure sbtMinimizeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMemo: TfrmMemo;

implementation

uses Unit1;

{$R *.LFM}

procedure TfrmMemo.sbtClearClick(Sender: TObject);
begin
  frmMemo.Memo1.Clear;
  frmMemo.Memo1.SetFocus
end;

procedure TfrmMemo.sbtMinimizeClick(Sender: TObject);
begin
  frmMemo.WindowState:=wsMinimized
end;

end.


