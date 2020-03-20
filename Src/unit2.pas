unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons;

type

  { TfrmNewFig }

  TfrmNewFig = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblPoleWidth: TLabel;
    lblPoleHeight: TLabel;
    lblTopHeight: TLabel;
    lblLeftWidth: TLabel;
    UpDownPoleWidth: TUpDown;
    sbtOK: TSpeedButton;
    UpDownPoleHeight: TUpDown;
    UpDownTopHeight: TUpDown;
    UpDownLeftWidth: TUpDown;
    procedure UpDownPoleWidthClick(Sender: TObject; Button: TUDBtnType);
    procedure sbtOKClick(Sender: TObject);
    procedure UpDownPoleHeightClick(Sender: TObject; Button: TUDBtnType);
    procedure UpDownTopHeightClick(Sender: TObject; Button: TUDBtnType);
    procedure UpDownLeftWidthClick(Sender: TObject; Button: TUDBtnType);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNewFig: TfrmNewFig;

implementation

uses Unit1;

{$R *.LFM}

//ИЗМЕНИТЬ ШИРИНУ ПОЛЯ
procedure TfrmNewFig.UpDownPoleWidthClick(Sender: TObject;
  Button: TUDBtnType);
begin
  lblPoleWidth.Caption:= inttostr(UpDownPoleWidth.Position);
end;
//ИЗМЕНИТЬ ВЫСОТУ ПОЛЯ
procedure TfrmNewFig.UpDownPoleHeightClick(Sender: TObject;
  Button: TUDBtnType);
begin
  lblPoleHeight.Caption:= inttostr(UpDownPoleHeight.Position);
end;
//ИЗМЕНИТЬ ВЫСОТУ ВЕРХНЕГО ЧИСЛОВОГО ПОЛЯ
procedure TfrmNewFig.UpDownTopHeightClick(Sender: TObject;
  Button: TUDBtnType);
begin
  lblTopHeight.Caption:= inttostr(UpDownTopHeight.Position);
end;
//ИЗМЕНИТЬ ШИРИНУ ЛЕВОГО ЧИСЛОВОГО ПОЛЯ
procedure TfrmNewFig.UpDownLeftWidthClick(Sender: TObject;
  Button: TUDBtnType);
begin
  lblLeftWidth.Caption:= inttostr(UpDownLeftWidth.Position);
end;
//УСТАНОВИТЬ НОВЫЕ РАЗМЕРЫ ПОЛЕЙ
procedure TfrmNewFig.sbtOKClick(Sender: TObject);
begin
  Unit1.POLE_WIDTH:= UpDownPoleWidth.Position;
  Unit1.POLE_HEIGHT:= UpDownPoleHeight.Position;
  Unit1.TOP_POLE_HEIGHT:= UpDownTopHeight.Position;
  Unit1.LEFT_POLE_WIDTH:= UpDownLeftWidth.Position;
  form1.Prepare(POLE_WIDTH, POLE_HEIGHT, TOP_POLE_HEIGHT, LEFT_POLE_WIDTH);
  Close;
end;

end.




