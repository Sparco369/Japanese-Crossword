unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,Forms ,Dialogs,
  ExtCtrls, StdCtrls, Grids, ComCtrls, Buttons, mmsystem, ExtDlgs;
const
  NAME_PROG = 'ЯПОНСКИЙ РИСУНОК';
  MAX_POLE_WIDTH = 70;   //макс. ширина поля в клетках
  MAX_POLE_HEIGHT = 50;  //макс. высота поля в клетках
  ROW_HEIGHT = 14;       //высота клетки в пикселах
  ROW_WIDTH = 14;        //ширина клетки в пикселах
  NUM_WHITE = 2{-1};   //пустая клетка в masPole
  NUM_BLACK = 1;       //чёрная клетка в masPole
  NUM_GRAY= 0;         //клетка серая в masPole (фон)
  COLOR_WHITE: TColor= $FFFFFF;  //белая клетка на поле
  COLOR_BLACK: TColor= $0;       //чёрная клетка на поле
  COLOR_GRAY: TColor= $7F7F7F;   //серая клетка на поле
  MAX_CELLNUM = 14;      //макс. ширина/высота числовых полей  10
  MAX_ALL_CELLS_HEIGHT = 30;//макс. высота игрового и числового полей
                            //(видимая часть)
  MAX_ALL_CELLS_WIDTH = 46; //макс. ширина игрового и числового полей
  //курсоры:
  crHand :integer= 4;
  crMove :integer= 5;
  crKistj :integer= 7;
  MAX_LEVEL= 20;       //макс. сложность задачи (число предположений)

//данные игрового поля
type TPole = array[0..MAX_POLE_WIDTH-1, 0..MAX_POLE_HEIGHT-1]of Integer;
//статус групп в числовых полях:
//stWhite - группа не решена,
//stYellow - группа решена,
//stGreen - ряд решён
type TStatusGroup=(stWhite, stYellow, stGreen);
//данные в каждой клетке числовых полей:
type TCell = Record
  sNum: String; //строковое представление числа в клетке
   Num: integer;//число в клетке
   StatusGroup: TStatusGroup; //статус группы
end;
//положение числового поля: слева, сверху
type TPoleLocation= (plLEFT, plTOP);
//данные уровня
type TSaveLevel = Record
  //статус рядов верхнего числового поля:
  TopStatus: array[0..MAX_POLE_WIDTH-1]of TStatusGroup;
  //статус рядов левого числового поля:
  LeftStatus: array[0..MAX_POLE_HEIGHT-1]of TStatusGroup;
  //копия поля:
  masPole: TPole;
  //коорд. "сомнительной" клетки
  XCell: integer;
  YCell: integer;
  //число разгаданных клеток:
  ReadyCells: integer;
end;

var
  //массив, в котором хранится копия поля
  masPole : TPole;
  POLE_WIDTH: integer = 28;     //ширина поля в клетках
  POLE_HEIGHT: integer = 28;    //высота поля в клетках
  //массив, в котором хранятся верхние числа:
  masColsNum : array[0..MAX_POLE_WIDTH-1, -1..MAX_CELLNUM-1]of TCell;
  //массив, в котором хранятся левые числа:
  masRowsNum : array[-1..MAX_CELLNUM-1, 0..MAX_POLE_HEIGHT-1]of TCell;
  LEFT_POLE_WIDTH: integer = 2; //ширина левого числового поля в клетках
  TOP_POLE_HEIGHT: integer = 2; //высота верхнего числового поля в клетках
  status: string='';
  NameFig: string= 'temp';
  //координаты клетки с курсором:
  cellMouse: TPoint;     //игровое поле
  cellMouseTop: TPoint;  //верхнее числовое поле
  cellMouseLeft: TPoint; //левое числовое поле
  AllCells: Integer=0;   //всего клеток на поле
  ReadyCells: Integer=0; //разгадано клеток
  flgExit: boolean= False;
  Level: Integer=0;      //уровень сложности задачи (число предположений)
  //массив, в котором хранятся данные предыдущих уровней:
  SaveLevel: array[0..MAX_LEVEL] of TSaveLevel;

type

  { TForm1 }

  TForm1 = class(TForm)
    dgColsNum: TDrawGrid;
    lblReady: TLabel;
    lblLevel: TLabel;
    SavePictureDialog1: TSavePictureDialog;
    sbVert: TScrollBar;
    sbHorz: TScrollBar;
    dgPole: TDrawGrid;
    dgRowsNum: TDrawGrid;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    StatusBar1: TStatusBar;
    sbtNewFig: TSpeedButton;
    sbtClearPole: TSpeedButton;
    sbtLoadFig: TSpeedButton;
    OpenDialog1: TOpenDialog;
    sbtSaveFig: TSpeedButton;
    sbtExit: TSpeedButton;
    sbtStart: TSpeedButton;
    SaveDialog1: TSaveDialog;
    sbtStop: TSpeedButton;
    sbtWhiteGrid: TSpeedButton;
    sbtNumbers: TSpeedButton;
    sbtSavePic: TSpeedButton;
    sbtMove: TSpeedButton;
    sbtDraw: TSpeedButton;
    OpenPictureDialog1: TOpenPictureDialog;
    sbtOpenPicture: TSpeedButton;
    procedure dgColsNumDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure dgPoleDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure dgPolePrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure FormActivate(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure sbHorzScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure sbVertScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure dgRowsNumDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure sbtLoadFigClick(Sender: TObject);
    procedure sbtClearPoleClick(Sender: TObject);
    procedure sbtExitClick(Sender: TObject);
    procedure sbtSaveFigClick(Sender: TObject);
    procedure sbtStartClick(Sender: TObject);
    procedure sbtStopClick(Sender: TObject);
    procedure sbtNewFigClick(Sender: TObject);
    procedure Prepare(ColCount, RowCount, TopCount, LeftCount: Integer);
    procedure dgPoleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dgPoleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure dgPoleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sbtWhiteGridClick(Sender: TObject);
    procedure sbtNumbersClick(Sender: TObject);
    procedure sbtSavePicClick(Sender: TObject);
    procedure sbtDrawClick(Sender: TObject);
    procedure dgColsNumMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dgColsNumKeyPress(Sender: TObject; var Key: Char);
    procedure dgColsNumDblClick(Sender: TObject);
    procedure dgRowsNumMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dgRowsNumKeyPress(Sender: TObject; var Key: Char);
    procedure dgRowsNumDblClick(Sender: TObject);
    procedure sbtMoveClick(Sender: TObject);
    procedure sbtOpenPictureClick(Sender: TObject);
    procedure dgColsNumClick(Sender: TObject);
    procedure dgRowsNumClick(Sender: TObject);
    procedure StatusBar1Hint(Sender: TObject);
  private
    { Private declarations }
    procedure Clear_masColsNum;
    procedure Clear_masRowsNum;
    procedure InvalidateGrids;
    procedure MoveNums;
    function GetNumGroup(Location: TPoleLocation; nLine: integer): integer;
    function GetLenGroup(Location: TPoleLocation; nLine, nGroup: integer)
             : integer;
    procedure SetStatus (s: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Unit2,MemoUnit;

{$R *.LFM}
{$R MyCursors.res}

//СОЗДАТЬ ФОРМУ
procedure TForm1.FormCreate(Sender: TObject);
begin
  //очистить поля:
  sbtClearPoleClick(self);
  //вывести сетки заданных размеров:
  Prepare(POLE_WIDTH,POLE_HEIGHT, TOP_POLE_HEIGHT, LEFT_POLE_WIDTH);
  //загрузить курсоры:
  Screen.Cursors[crKistj] := LoadCursor(hinstance,'kistj');
  Screen.Cursors[crHand] := LoadCursor(hinstance,'hand');
  Screen.Cursors[crMove] := LoadCursor(hinstance,'move');
  //установить курсор для игрового поля:
  dgPole.Cursor :=crHand;
end;

//ОЧИСТИТЬ МАССИВ ВЕРХНЕГО ЧИСЛОВОГО ПОЛЯ
procedure TForm1.Clear_masColsNum;
var
  i,j: integer;
begin
  For i := 0 To MAX_POLE_WIDTH-1 do
    for j := -1 to  MAX_CELLNUM - 1 do
    begin
      masColsNum[i,j].sNum:='';             // - числа нет
      masColsNum[i,j].StatusGroup:= stWhite;// - ряд не решён
    end
end;
//ОЧИСТИТЬ МАССИВ ЛЕВОГО ЧИСЛОВОГО ПОЛЯ
procedure TForm1.Clear_masRowsNum;
var
  i,j: integer;
begin
  For i := -1 To MAX_CELLNUM-1 do
    for j := 0 to  MAX_POLE_HEIGHT - 1 do
    begin
      masRowsNum[i,j].sNum:='';             // - числа нет
      masRowsNum[i,j].StatusGroup:= stWhite;// - ряд не решён
    end
end;

//ОБНОВИТЬ ПОЛЯ
procedure TForm1.InvalidateGrids;
begin
  dgPole.Invalidate;
  dgColsNum.Invalidate;
  dgRowsNum.Invalidate;
end;

//ОЧИСТИТЬ ПОЛЯ
procedure TForm1.sbtClearPoleClick(Sender: TObject);
var
  i,j: integer;
begin
  if status='ПОИСК' then exit;
  //все клетки поля - серые:
  For i := 0 To POLE_WIDTH-1 do
    for j := 0 to  POLE_HEIGHT - 1 do
      masPole[i,j]:= NUM_GRAY;
  //очистить цифровые поля:
  Clear_masColsNum;
  Clear_masRowsNum;
  InvalidateGrids;
  //фигура не загружена:
  NameFig:='temp';
  //вывести в заголовке формы имя временного файла:
  caption:= NAME_PROG + '  [' + NameFig + ']';
  //координаты мыши:
  cellmouse.x:=-1; cellmouse.y:=-1;
end;
//ОЧИСТИТЬ ПОЛЕ ДЛЯ РИСОВАНИЯ
procedure TForm1.sbtWhiteGridClick(Sender: TObject);
var
  i,j: integer;
begin
  if status='ПОИСК' then exit;
  //все клетки - белые:
  dgPole.Canvas.Brush.Color:=COLOR_WHITE;
  For i := 0 To MAX_POLE_WIDTH-1 do
    for j := 0 to  MAX_POLE_HEIGHT - 1 do
      masPole[i,j]:= NUM_WHITE;
  //очистить цифровые поля:
Clear_masColsNum;
Clear_masRowsNum;
 InvalidateGrids;
  //фигура не загружена:
  NameFig:='temp1';
  //вывести в заголовке формы имя загруженного файла:
  caption:= NAME_PROG + '  [' + NameFig + ']';
  //координаты мыши:
  cellmouse.x:=-1; cellmouse.y:=-1;
end;

//ПОДГОТОВИТЬ НОВУЮ ИГРУ
procedure TForm1.Prepare(ColCount, RowCount, TopCount, LeftCount: Integer);
//ColCount - число колонок на игровом поле
//RowCount - число строк на игровом поле
//TopCount - число строк на гориз. полоске с номерами
//LeftCount - число колонок на верт. полоске с номерами
var
  w,h,lw: integer;
  i,j,n: integer;
begin
  //скорректировать размеры полей:
  if ColCount< 2 then ColCount:= 2;
  if RowCount< 2 then RowCount:= 2;
  if TopCount< 1 then TopCount:= 1;
  if LeftCount< 1 then LeftCount:= 1;
  //=============  игровое поле  ===============
  //
  //размер клетки в пикселах:
  w:= dgPole.DefaultColWidth;
  h:= dgPole.DefaultRowHeight;
  //толщина линий:
  lw:= dgPole.GridLineWidth;
  //размеры игрового поля в клетках:
  dgPole.ColCount:= ColCount;
  dgPole.RowCount:= RowCount;
  i:= ColCount;
  j:= RowCount;
  //если ширина игрового поля + ширина левого числового поля
  //превышают MAX_ALL_CELLS_WIDTH клеток,
  //то поставить вертикальную полосу прокрутки:
  if ColCount > MAX_ALL_CELLS_WIDTH  - LeftCount then begin
    i:= MAX_ALL_CELLS_WIDTH  - LeftCount;
    sbHorz.Visible:= true
    end
  else sbHorz.Visible:= false;
  //если высота игрового поля + высота верхнего числового поля
  //превышают MAX_ALL_CELLS_HEIGHT клеток,
  //то поставить горизонтальную полосу прокрутки:
  if RowCount > MAX_ALL_CELLS_HEIGHT  - TopCount then begin
    j:= MAX_ALL_CELLS_HEIGHT  - TopCount;
    //sbVert.max:= 50;
    sbVert.Visible:= true
    end
  else sbVert.Visible:= false;
  //размеры в пикселах видимой части игрового поля:
  dgPole.Width:= 3 + (w + lw)* i+1;
  dgPole.Height:= 3 + (h + lw)* j+1;
  //
  //====================  числовые поля  =========================
  //
  //размеры клеток числовых полей = размерам клеток игрового поля:
  dgColsNum.DefaultColWidth:= w;
  dgColsNum.DefaultRowHeight:= h;
  dgRowsNum.DefaultColWidth:= w;
  dgRowsNum.DefaultRowHeight:= h;
  //размеры числовых полей:
  dgColsNum.ColCount:= ColCount; // = ширине игрового поля
  dgColsNum.Width:= dgPole.Width;
  dgColsNum.RowCount:= TopCount; // задаётся
  //высота верхнего числового поля в пикселах:
  dgColsNum.Height:= 3 + (h + lw)* TopCount;
   //высота левого числового поля в клетках = высоте игрового поля:
  dgRowsNum.RowCount:= dgPole.RowCount;
  //высота левого числового поля в пикселах:
  dgRowsNum.Height:= dgPole.Height;
  dgRowsNum.ColCount:= LeftCount; // задаётся
  //ширина левого числового поля в пикселах::
  dgRowsNum.Width:=3 + (h + lw)* LeftCount;
  //положение на форме:
  dgColsNum.left:= dgRowsNum.Left + dgRowsNum.Width;
  dgRowsNum.top:=  dgColsNum.top +  dgColsNum.Height;
  dgPole.top:= dgRowsNum.top;
  dgPole.Left:=dgColsNum.Left;
  //
  //==============  полосы прокрутки  =================
  //
  //разместить полосы прокрутки рядом с игровым полем:
  if sbVert.visible then
  begin
  //коорд. левой стороны верт. полосы прокрутки:
  sbVert.Left:= dgPole.Left+ dgPole.Width+ 5;
  //её высота:
  sbVert.Height:= dgPole.Height;
  //коорд. верхней стороны:
  sbVert.Top := dgPole.top;
  //макс. позиция:
  n:= dgPole.RowCount - (MAX_ALL_CELLS_HEIGHT-dgColsNum.RowCount);
  //showmessage(inttostr(n));
  if n< sbVert.LargeChange then n:= sbVert.LargeChange;
  sbVert.Max := n+4;
  //sbVert.Max := 50;
  //showmessage(inttostr(sbVert.Max));
  end;

  if sbHorz.visible then
  begin
  //коорд. верхней стороны гориз. полосы прокрутки:
  sbHorz.Top := dgPole.top+ dgPole.Height+ 5;
  //ширина:
  sbHorz.Width:= dgPole.Width;
  //коорд. левой стороны:
  sbHorz.Left:= dgPole.Left;
  //макс. позиция:
  n:= dgPole.ColCount - (MAX_ALL_CELLS_WIDTH-dgRowsNum.ColCount);
  if n< sbHorz.LargeChange then n:= sbHorz.LargeChange;
  sbHorz.Max:= n;
  end;
  //вывести размеры фигуры в панели:
  statusbar1.Panels[1].text:= inttostr(ColCount)+ ' x ' + inttostr(RowCount);
  //подсчитать число клеток в фигуре:
  AllCells:= ColCount * RowCount;
  statusbar1.Panels[2].text:='Клеток: '+inttostr(AllCells);
end; //Prepare

//ИЗМЕНИТЬ РАЗМЕРЫ ПОЛЕЙ
procedure TForm1.sbtNewFigClick(Sender: TObject);
begin
  frmNewFig.lblPoleWidth.Caption:= inttostr(POLE_WIDTH);
  frmNewFig.lblPoleHeight.Caption:= inttostr(POLE_HEIGHT);
  frmNewFig.lblLeftWidth.Caption:= inttostr(LEFT_POLE_WIDTH);
  frmNewFig.lblTopHeight.Caption:= inttostr(TOP_POLE_HEIGHT);
  frmNewFig.UpDownPoleWidth.Position:= POLE_WIDTH;
  frmNewFig.UpDownPoleWidth.Max:= MAX_POLE_WIDTH;
  frmNewFig.UpDownPoleHeight.Position:= POLE_HEIGHT;
  frmNewFig.UpDownPoleHeight.Max:= MAX_POLE_HEIGHT;
  frmNewFig.UpDownLeftWidth.Position:= LEFT_POLE_WIDTH;
  frmNewFig.UpDownLeftWidth.Max:= MAX_CELLNUM;
  frmNewFig.UpDownTopHeight.Position:= TOP_POLE_HEIGHT;
  frmNewFig.UpDownTopHeight.Max:= MAX_CELLNUM;
  frmNewFig.showmodal;
end;

//НАРИСОВАТЬ КЛЕТКУ ИГРОВОГО ПОЛЯ
procedure TForm1.dgPoleDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var  area: tRect;
begin
  //закрасить клетку нужным цветом:
  area:=dgPole.CellRect(ACol, ARow);
  case masPole[ACol, ARow] of
    NUM_WHITE: dgPole.Canvas.Brush.Color:=COLOR_WHITE;
    NUM_BLACK: dgPole.Canvas.Brush.Color:=COLOR_BLACK;
    NUM_GRAY: dgPole.Canvas.Brush.Color:=COLOR_GRAY;
  end;
  dgPole.Canvas.FillRect(area);
  //проводим красные линии через 5 клеток:
  if (ACol>0) and (ACol mod 5 = 0) then begin
    dgPole.Canvas.Pen.Color:= clRed;
    dgPole.Canvas.MoveTo(Rect.Left,Rect.Top);
    dgPole.Canvas.LineTo(Rect.Left,Rect.Bottom)
  end;
  if (ARow>0) and (ARow mod 5 = 0) then begin
    dgPole.Canvas.Pen.Color:= clRed;
    dgPole.Canvas.MoveTo(Rect.Left,Rect.Top);
    dgPole.Canvas.LineTo(Rect.Right,Rect.Top)
  end;
end; //dgPoleDrawCell

procedure TForm1.dgPolePrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin

end;

procedure TForm1.FormActivate(Sender: TObject);
begin

end;

procedure TForm1.FormClick(Sender: TObject);
begin

end;
 //ЗАКРЫТЬ ПРОГРАММУ   (МОЯ)
procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  flgExit:= true;
end;

//СИНХРОННО СДВИГАТЬ ПОЛЯ ПО ГОРИЗОНТАЛИ
procedure TForm1.sbHorzScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  dgPole.LeftCol:= ScrollPos; dgColsNum.LeftCol:= dgPole.LeftCol;
end;
//СИНХРОННО СДВИГАТЬ ПОЛЯ ПО ВЕРТИКАЛИ
procedure TForm1.sbVertScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  dgPole.TopRow := ScrollPos; dgRowsNum.TopRow:= dgPole.TopRow;
end;

//ЗАГРУЗИТЬ НОВУЮ ФИГУРУ
procedure TForm1.sbtLoadFigClick(Sender: TObject);
var
  s: string;
  F: TextFile;
  ss: array[1..MAX_POLE_WIDTH + MAX_POLE_HEIGHT] of string;
  nLines: integer;  //счётчик считанных строк фигуры
  maxLen: integer;
  i,j:integer;
  flgComm: boolean; //= TRUE, если считываем комментарий к фигуре
  w,h: integer;

  //ЗАГРУЗИТЬ ФАЙЛ JC {файл картинки программы Gun's Japanese Crossword)
  procedure LoadJcFile;
  var
    F: file of Byte;
    w,h: integer;
    b: byte;
    i,j:integer;
  begin
    {$i-}
    AssignFile(F, NameFig);
    Reset(F);
    {$i+}
    if IOResult<>0 then begin   {ошибка при загрузке файла}
      application.MessageBox ('Такой фигуры нет!',NAME_PROG, MB_OK);
      exit
    end;
    //вывести в заголовке формы имя загруженного файла:
    form1.caption:= NAME_PROG + '  [' + NameFig + ']';
    //начинаем считывать файл
    //считываем размеры поля
    //ширина поля - 4-ый байт:
    Seek(F, 4); Read(F, b); w:= b;
    //высота поля - 6-ой байт:
    Seek(F, 6); Read(F, b); h:= b;
    //проверить размеры фигуры:
    if (h > MAX_POLE_HEIGHT) or (w > MAX_POLE_WIDTH)then begin
      application.MessageBox('Слишком большая фигура!',NAME_PROG, MB_OK);
      CloseFile(F); exit
    end;
    POLE_WIDTH:= w; POLE_HEIGHT:= h;
    //проверяем длину файла:
    i:= FileSize(f);
    j:= 8 + POLE_HEIGHT * POLE_WIDTH;
    if i < j then begin
      application.MessageBox('Неверный размер файла!',NAME_PROG, MB_OK);
      CloseFile(F); exit
    end;
    //загружаем данные для поля:
    for j:= 0 to POLE_HEIGHT-1 do
      for i:= 0 to POLE_WIDTH-1 do begin
        Seek(F, POLE_WIDTH*j+i + 8); Read(F, b);
         if b=0 then masPole[i,j]:= NUM_WHITE
        else masPole[i,j]:= NUM_BLACK;
      end;
    //закрыть файл - всё загружено:
    CloseFile(F);
    //оцифровать рисунок:
    sbtNumbersClick(Self);
    //очистить поле:
    for j:= 0 to POLE_HEIGHT-1 do
      for i:= 0 to POLE_WIDTH-1 do masPole[i,j]:= NUM_GRAY;
    Prepare(POLE_WIDTH,POLE_HEIGHT, TOP_POLE_HEIGHT, LEFT_POLE_WIDTH);
  end; //LoadJcFile

  //ЗАГРУЗИТЬ ФАЙЛ JCW
  procedure LoadJcwFile;
  var
    F: file of Byte;
    i,j,n:integer;
    w,h: integer;
    b, pred: byte;
    bi, predi: integer;
    off: integer;
    ng: integer; //число групп в ряду
    p: TPole;
  begin
    {$i-}
    AssignFile(F, NameFig);
    Reset(F);
    {$i+}
    if IOResult<>0 then begin   {ошибка при загрузке файла}
      application.MessageBox ('Такой фигуры нет!',NAME_PROG, MB_OK);
      exit
    end;
    //вывести в заголовке формы имя загруженного файла:
    form1.caption:= NAME_PROG + '  [' + NameFig + ']';
    //начинаем считывать файл
    //считываем размеры поля
    //ширина поля - первый байт:
    Seek(F, 0); Read(F, b); w:= b;
    //высота поля - второй байт:
    Seek(F, 1); Read(F, b); h:= b;
    //проверить размеры фигуры:
    if (h > MAX_POLE_HEIGHT) or (w > MAX_POLE_WIDTH)then begin
      application.MessageBox('Слишком большая фигура!',NAME_PROG, MB_OK);
      CloseFile(F); exit
    end;
    POLE_WIDTH:= w; POLE_HEIGHT:= h;
    //проверяем длину файла:
    i:= FileSize(f);
    j:= 2 + POLE_HEIGHT * POLE_WIDTH;
    if i < j then begin
      application.MessageBox('Неверный размер файла!',NAME_PROG, MB_OK);
      CloseFile(F); exit
    end;
    //считываем данные для верхнего числового поля:
    off:= 2;
    h:=0; //высота верхнего числового поля
    for i := 0 to POLE_WIDTH -1 do //- по длине поля
    begin
      ng:= 0;   //число групп в ряду
      n:= 0;    //- длина группы
      pred:= 0; //- предыдущий байт
      //в каждом ряду должно быть хотя бы одно число:
      masColsNum[i,0].sNum:= '0';
      //для каждого столбца:
      for j := 0 to POLE_HEIGHT -1 do
      begin
        Seek(F, POLE_HEIGHT*i+j + off);
        //считать очередной байт:
        Read(F, b);
        //cохранить его:
        p[i,j]:= b;
        if b=2 then begin       //- чёрная клетка
          if pred<>2 then begin //- предыдущая клетка не чёрная -->
            //записать группу:
            masColsNum[i,ng-1].sNum:= inttostr(n);
            //начинается новая группа:
            inc(ng);
            n:= 0;
          end;
          //увеличить длину группы:
          inc(n);
        end;
        pred:= b;
      end;
      masColsNum[i,ng-1].sNum:= inttostr(n);
      masColsNum[i,-1].Num:= ng;
      if ng> h then h:= ng;
    end;
    //закрыть файл - всё загружено:
    CloseFile(F);
    //формируем данные для левого числового поля:
    w:=0; //ширина левого числового поля
    for j := 0 to POLE_HEIGHT -1 do //- по всем строкам поля
    begin
      ng:= 0;    //число групп в ряду
      n:= 0;     //- длина группы
      predi:= 0; //- предыдущий байт
      //в каждом ряду должно быть хотя бы одно число:
      masRowsNum[0,j].sNum:= '0';
      for i := 0 to POLE_WIDTH -1 do //- по длине строки
      begin
        //считать очередное число:
        bi:= p[i,j];
        if bi=2 then begin //- чёрная клетка
          if predi<>2 then begin //- предыдущая клетка не чёрная -->
            //записать группу:
            masRowsNum[ng-1,j].sNum:= inttostr(n);
            //начинается новая группа:
            inc(ng);
            n:= 0;
          end;
          //увеличить длину группы:
          inc(n);
        end;
        predi:= bi;
      end; // i
      masRowsNum[ng-1,j].sNum:= inttostr(n);
      masRowsNum[-1,j].Num:= ng;
      if ng> w then w:= ng;
    end; //j
    //проверить число групп:
    if (w > MAX_CELLNUM) or (h > MAX_CELLNUM) then begin
      application.MessageBox('Слишком много групп!',NAME_PROG, MB_OK);
      CloseFile(F); exit
    end;
    TOP_POLE_HEIGHT:= h;
    LEFT_POLE_WIDTH:= w;
    //вывести картинку на игровое поле:
    for j:= 0 to POLE_HEIGHT-1 do
      for i:= 0 to POLE_WIDTH-1 do
        case p[i,j] of
          2: masPole[i,j]:= NUM_BLACK;
          else masPole[i,j]:= NUM_WHITE;
        end;
    //вывести поля заданных размеров с числами:
    Prepare(POLE_WIDTH,POLE_HEIGHT, TOP_POLE_HEIGHT, LEFT_POLE_WIDTH);
  end;// LoadJcwFile

  //ЗАГРУЗИТЬ ФАЙЛ JPN
  procedure LoadJpnFile;
  var
    F: TextFile;
    i:integer;
    w,h: integer;
    ng: integer;   //число групп в ряду
    s: string;
    pos: integer;  //позиция в строке
    sNum: string;  //число
    //получить число из заданной строки
    function GetNumber(s: string; var pos: integer; var s2: string): boolean;
    //= FALSE, если строка ещё не кончилась
    begin
      s2:= '';
      if pos> Length(s) then Result:= TRUE else Result:= FALSE;
      while (pos<= Length(s)) and (s[pos]<> ' ') do begin
        s2:= s2 + s[pos]; inc(pos)
      end;
      //пропустить пробелы:
      while (pos< Length(s)) and (s[pos]= ' ') do inc(pos);
      if (pos= Length(s)) and (s[pos]= ' ') then Result:= TRUE;
    end;
  begin
    {$i-}
    AssignFile(F, NameFig);
    Reset(F);
    {$i+}
    if IOResult<>0 then begin   {ошибка при загрузке файла}
      application.MessageBox ('Такой фигуры нет!',NAME_PROG, MB_OK);
      exit
    end;
    //вывести в заголовке формы имя загруженного файла:
    form1.caption:= NAME_PROG + '  [' + NameFig + ']';
    //начинаем считывать файл
    //считываем размеры поля
    //ширина поля - первое число
    //высота поля - второе:
    Readln(F, S);
    pos:= 1;
    GetNumber(S, pos, sNum); w:= strtoint(sNum);
    GetNumber(S, pos, sNum); h:= strtoint(sNum);
    //проверить размеры фигуры:
    if (h > MAX_POLE_HEIGHT) or (w > MAX_POLE_WIDTH)then begin
      application.MessageBox('Слишком большая фигура!',NAME_PROG, MB_OK);
      CloseFile(F);
      exit
    end;
    POLE_WIDTH:= w; POLE_HEIGHT:= h;
    //считываем размеры числовых полей
    //высота верхнего числового поля первое число,
    //ширина левого числового поля - второе:
    Readln(F, S);
    pos:= 1;
    GetNumber(S, pos, sNum); h:= strtoint(sNum);
    GetNumber(S, pos, sNum); w:= strtoint(sNum);
    //проверить число групп:
    if (w > MAX_CELLNUM) or (h > MAX_CELLNUM) then begin
      application.MessageBox('Слишком много групп!',NAME_PROG, MB_OK);
      CloseFile(F); exit
    end;
    TOP_POLE_HEIGHT:= h;
    LEFT_POLE_WIDTH:= w;
    //считываем данные для верхнего числового поля:
    For i:= 0 to POLE_WIDTH-1 do begin
      if eof(f) then begin
        s:='Не хватает данных!';
        application.MessageBox(PChar(s),NAME_PROG,MB_OK );
        exit
      end;
      //считать строку из файла:
      Readln(F, S);
      //выделить числа из строки:
      pos:= 1; ng:= -1;
      while GetNumber(S, pos, sNum)= FALSE do begin
        inc(ng);
        masColsNum[i, ng].sNum:= sNum;
      end;
    end;
    //считываем данные для левого числового поля:
    For i:= 0 to POLE_HEIGHT-1 do begin
      if eof(f) then begin
        s:='Не хватает данных!';
        application.MessageBox(PChar(s),NAME_PROG,MB_OK );
        exit
      end;
      //считать строку из файла:
      Readln(F, S);
      //выделить числа из строки:
      pos:= 1; ng:= -1;
      while GetNumber(S, pos, sNum)= FALSE do begin
        inc(ng);
        masRowsNum[ng,i].sNum:= sNum;
      end;
    end;
  //закрыть файл - всё загружено:
  CloseFile(F);
  //вывести поля заданных размеров с числами:
  Prepare(POLE_WIDTH,POLE_HEIGHT, TOP_POLE_HEIGHT, LEFT_POLE_WIDTH);
end;// LoadJpnFile

  //ЗАГРУЗИТЬ ФАЙЛ JPC из программы JpcWin Матвея Ильяшенко
  procedure LoadJpcFile;
  var
    F: file of Byte;
    i,j,n:integer;
    w,h: integer;
    b: byte;
    off: integer;
    function ReadWord(index: Longint): word;
    var
      b1, b2: byte;
    begin
      //считать первый байт:
      Seek(F, index); Read(F, b1);
      //считать второй байт:
      Seek(F, index+1); Read(F, b2);
      //вычислить слово:
      Result:= 256*b2+b1;
    end;
  begin
    //загрузить файл:
    {$i-}
    AssignFile(F, NameFig);
    Reset(F);
    {$i+}
    if IOResult<>0 then begin   {ошибка при загрузке файла}
      application.MessageBox ('Такой фигуры нет!',NAME_PROG, MB_OK);
      exit
    end;
    //вывести в заголовке формы имя загруженного файла:
    form1.caption:= NAME_PROG + '  [' + NameFig + ']';
    //начинаем считывать файл -
    //считываем размеры поля:
    w:= ReadWord(0);
    h:= ReadWord(2);
    //проверить размеры фигуры:
    if (h > MAX_POLE_HEIGHT) or (w > MAX_POLE_WIDTH)then begin
      application.MessageBox('Слишком большая фигура!',NAME_PROG, MB_OK);
      CloseFile(F); exit
    end;
    POLE_WIDTH:= w; POLE_HEIGHT:= h;
     //считываем размеры числовых полей:
    h:= ReadWord(4);
    w:= ReadWord(6);
    //проверить число групп:
    if (w > MAX_CELLNUM) or (h > MAX_CELLNUM) then begin
      application.MessageBox('Слишком много групп!',NAME_PROG, MB_OK);
      CloseFile(F); exit
    end;
    TOP_POLE_HEIGHT:= h;
    LEFT_POLE_WIDTH:= w;
    //проверяем длину файла:
    i:= FileSize(f);
    j:= 8+POLE_HEIGHT*LEFT_POLE_WIDTH + POLE_WIDTH* TOP_POLE_HEIGHT;
    if i<>j then begin
      application.MessageBox('Неверный размер файла!',NAME_PROG, MB_OK);
      CloseFile(F); exit
    end;
    //считываем данные для левого числового поля:
    off:= 8;
    for j := 0 to POLE_HEIGHT -1 do //сверху
    begin
      n:= 0;
      //в каждом ряду должно быть хотя бы одно число:
      masRowsNum[0,j].sNum:= '0';
      for i := LEFT_POLE_WIDTH - 1 downto 0 do //справа налево
      begin
        Seek(F, POLE_HEIGHT*i+j+ off);
        Read(F, b);
        if b<>0 then begin
          masRowsNum[n,j].sNum:= inttostr(b);
          inc(n);
        end;
      end;
    end;
    //считываем данные для верхнего числового поля:
    off:= LEFT_POLE_WIDTH * POLE_HEIGHT + 8;
    for i := 0 to POLE_WIDTH -1 do
    begin
      n:= 0;
      //в каждом ряду должно быть хотя бы одно число:
      masColsNum[i,0].sNum:= '0';
      for j := TOP_POLE_HEIGHT - 1 downto 0 do //снизу вверх
      begin
        Seek(F, POLE_WIDTH* j+ i+ off);
        Read(F, b);
        if b<>0 then begin
          masColsNum[i,n].sNum:= inttostr(b);
          inc(n);
        end;
      end;
    end;
    //закрыть файл - всё загружено:
    CloseFile(F);
    //вывести поля заданных размеров с числами:
    Prepare(POLE_WIDTH,POLE_HEIGHT, TOP_POLE_HEIGHT, LEFT_POLE_WIDTH);
  end;// LoadJpcFile

  //ЗАГРУЗИТЬ ФАЙЛ JCR из программы "Японский кроссворд 2000"
  //Егоркина И.В.
  procedure LoadJcrFile;
  var
    F: file of Byte;
    i,j,n:integer;
    w,h: integer;
    b: byte;
    off: integer;
  begin
    //загрузить файл:
    {$i-}
    AssignFile(F, NameFig);
    Reset(F);
    {$i+}
    if IOResult<>0 then begin   //ошибка при загрузке файла
      application.MessageBox ('Такой фигуры нет!',NAME_PROG, MB_OK);
      exit
    end;
    //вывести в заголовке формы имя загруженного файла:
    form1.caption:= NAME_PROG + '  [' + NameFig + ']';
    //начинаем считывать файл -
    //считываем размеры поля:
    Seek(F, 0); Read(f,b); w:= b;
    Seek(F, 1); Read(f,b); h:= b;
    //проверить размеры фигуры:
    if (h > MAX_POLE_HEIGHT) or (w > MAX_POLE_WIDTH)then begin
      application.MessageBox('Слишком большая фигура!',NAME_PROG, MB_OK);
      CloseFile(F); exit
    end;
    POLE_WIDTH:= w; POLE_HEIGHT:= h;
    //считываем размеры числовых полей:
    Seek(F, 2); Read(f,b); w:= b;
    Seek(F, 3); Read(f,b); h:= b;
    //проверить число групп:
    if (w > MAX_CELLNUM) or (h > MAX_CELLNUM) then begin
      application.MessageBox('Слишком много групп!',NAME_PROG, MB_OK);
      CloseFile(F); exit
    end;
    TOP_POLE_HEIGHT:= h;
    LEFT_POLE_WIDTH:= w;
    //проверяем длину файла:
    i:= FileSize(f);
    j:= 4+POLE_HEIGHT*LEFT_POLE_WIDTH + POLE_WIDTH* TOP_POLE_HEIGHT;
    if i<>j then begin
      application.MessageBox('Неверный размер файла!',NAME_PROG, MB_OK);
      CloseFile(F); exit
    end;
    //считываем данные для верхнего числового поля:
    off:= 4;
    for i := 0 to POLE_WIDTH -1 do
    begin
      n:= 0;
      //в каждом ряду должно быть хотя бы одно число:
      masColsNum[i,0].sNum:= '0';
      for j := TOP_POLE_HEIGHT - 1 downto 0 do //снизу вверх
      begin
        Seek(F, TOP_POLE_HEIGHT*i+j+ off);
        Read(F, b);
        if b<>0 then begin
          masColsNum[i,n].sNum:= inttostr(b);
          inc(n);
        end;
      end;
    end;
    //считываем данные для левого числового поля:
    off:= TOP_POLE_HEIGHT * POLE_WIDTH + 4;
    for j := 0 to POLE_HEIGHT -1 do //сверху вниз
    begin
      n:= 0;
      for i := LEFT_POLE_WIDTH - 1 downto 0 do
      begin
        Seek(F, LEFT_POLE_WIDTH *j+i+ off);
        Read(F, b);
        if b<>0 then begin
          masRowsNum[n,POLE_HEIGHT -1-j].sNum:= inttostr(b);
          inc(n);
        end;
      end;
    end;
    //закрыть файл - всё загружено:
    CloseFile(F);
    Prepare(POLE_WIDTH,POLE_HEIGHT, TOP_POLE_HEIGHT, LEFT_POLE_WIDTH);
  end;// LoadJcrFile

begin
  if status='ПОИСК' then exit;
  //"прокручиваем" все поля в начало:
  dgPole.LeftCol:= 0; dgPole.TopRow:= 0;
  dgColsNum.LeftCol:= 0; dgColsNum.TopRow:= 0;
  dgRowsNum.LeftCol:= 0; dgRowsNum.TopRow:= 0;
  //число разгаданных клеток = 0:
  lblReady.Caption:='0';
  //начнём решение задачи с нулевого уровня:
  lblLevel.Caption:='0';
  flgComm:= false;
  frmMemo.memo1.Clear;
  //frmMemo.memo1.SetFocus;
  //файлы по умолчанию имеют расширение jcp:
  OpenDialog1.DefaultExt:='jcp';
  OpenDialog1.Filter:= 'Japan puzzle(*.jcp, *.jpc, *.jcw, *.jpn, *.jc, *.jcr)|'+
    '*.JCP;*.JPC;*.JCW; *.JPN; *.JC; *.JCR';
  //ищем файлы в каталоге 'FIGURE':
  s:=extractfilepath(application.exename)+'FIGURE';
  OpenDialog1.InitialDir:= s;
  OpenDialog1.Title:='Загрузите новую фигуру';
  if opendialog1.Execute then begin
    //очистить игровое и числовые поля:
    sbtClearPoleClick(self);
    //выбрали файл с именем NameFig=s:
    s:= opendialog1.filename;
    NameFig:=s;
    //файл формата JPC
    s:= ExtractFileExt(NameFig);
    if s= '.jpc' then begin LoadJpcFile; exit end
      //файл формата JCW - задания для самостоятельного решения
      //из программы Романа Гантверга и Дмитрия Самсонова Japan Crossword
      //Soluter (Японский кроссворд - Решатель), 1999
    else if s= '.jcw' then begin LoadJcwFile; exit end
      //обычный текстовый файл:
    else if s= '.jpn' then begin LoadJpnFile; exit end
      //файл картинки программы Gun's Japanese Crossword:
    else if s= '.jc' then begin LoadJcFile; exit end
    //файл задачи из программы "Японский кроссворд 2000":
    else if s= '.jcr' then begin LoadJcrFile; exit end;
    {$i-}
    AssignFile(F,NameFig);
    Reset(F);
    {$i+}
    if IOResult<>0 then begin  //ошибка при загрузке файла
      application.MessageBox ('Такой фигуры нет!',NAME_PROG, MB_OK);
      exit
      end;
    //начинаем считывать файл:
    nLines:=0; //считано строк фигуры
    while not eof(f) do begin
      //считать строку из файла:
      Readln(F, S);
      //комментарий к фигуре?
      if ((length(s)>1) and (s[1]='/') and (s[2]='/')) or
        (flgComm= true) then    //- комментарий
      begin
        if flgComm=false then   //- начало комментария
        begin
          flgComm:= true;
          s:=copy(s,3,length(s));
        frmMemo.memo1.Lines.Text:=s;
        end
        else
         frmMemo.memo1.Lines.Text:=frmMemo.memo1.Lines.Text+#10+s;
      end
      else begin //- строка фигуры
        inc(nLines);
        //сохранить строку в массиве:
        ss[nLines]:=s;
      end
    end;
    //закрыть файл - всё загружено:
    CloseFile(F);
    //размеры игрового поля -
    //высота поля в клетках:
    h:= ord(ss[1][1])-ord('0');
    //ширина поля в клетках:
    w:= ord(ss[1][2])-ord('0');
    //проверить размеры фигуры:
    if (h > MAX_POLE_HEIGHT) or (w > MAX_POLE_WIDTH)then begin
      application.MessageBox('Слишком большая фигура!',NAME_PROG, MB_OK);
      exit
    end;
    //количество строк для числовых полей должно соответствовать
    //размерам поля:
    if nLines-1 <> h + w then begin
      application.MessageBox('Неверное количество данных!',NAME_PROG, MB_OK);
      exit
    end;
    //занести данные в masColsNum, masRowsNum:
    maxLen:=0;
    for j:=2 to h+1 do begin
      s:=ss[j];  //- очередная строка из массива
      //по длине очередной строки -
      for i:=1 to length(s) do begin
        if length(s)> maxLen then maxLen:= length(s);
        //проверить количество групп чисел в строке:
        if maxLen > MAX_CELLNUM then begin
          application.MessageBox('Слишком много групп!',NAME_PROG, MB_OK);
          //очистить masRowsNum[]:
          Clear_masRowsNum;
          exit
        end;
        //занести число в массив:
        masRowsNum[i-1,j-2].sNum:= inttostr(ord(s[i])-ord('0'));
      end;
    end;
    //макс. число групп в левом числовом поле:
    LEFT_POLE_WIDTH:= maxLen;
    //начинаем заполнение массива верхнего числового поля:
    maxLen:=0;
    for j:=h+2 to nLines do begin
      //очередная строка:
      s:=ss[j];
      //по длине очередной строки -
      for i:=1 to length(s) do begin
        if length(s)> maxLen then maxLen:= length(s);
        //проверить количество групп чисел в строке:
        if maxLen > MAX_CELLNUM then begin
          application.MessageBox('Слишком много групп!',NAME_PROG, MB_OK);
          //очистить masColsNum[]:
          Clear_masColsNum;
          exit
        end;
        //занести число в массив:
        masColsNum[j-h-2,i-1].sNum:= inttostr(ord(s[i])-ord('0'));
      end;
    end;
    //макс. число групп в верхнем числовом поле:
    TOP_POLE_HEIGHT:= maxLen;
    //размеры поля:
    POLE_WIDTH:= w; POLE_HEIGHT:= h;
    //вывести в заголовке формы имя загруженного файла:
    form1.caption:= NAME_PROG + '  [' + NameFig + ']';
    //вывести поля заданных размеров с числами:
    Prepare(POLE_WIDTH,POLE_HEIGHT, TOP_POLE_HEIGHT, LEFT_POLE_WIDTH);
  end; //opendialog1.Execute
end;//sbtLoadFigClick

//ОЦИФРОBАТЬ РИСУНОК
procedure TForm1.sbtNumbersClick(Sender: TObject);
var
  i,j: integer;
  h,w: integer;
  n,ng: integer;
  Pred, len: integer;
begin
  //очистить цифровые поля:
  Clear_masColsNum;
  Clear_masRowsNum;
  //считываем данные для верхнего числового поля:
  h:=0; //- высота верхнего числового поля
  for i := 0 to POLE_WIDTH -1 do //- по длине поля
  begin
    ng:= 0;  //число групп в ряду
    len:= 0; //- длина группы
    Pred:= NUM_WHITE; //- предыдущaя клетка
    //в каждом ряду должно быть хотя бы одно число:
    masColsNum[i,0].sNum:= '0';
    //для каждого столбца:
    for j := 0 to POLE_HEIGHT -1 do
    begin
      //считать очередной число:
      n:= masPole[i,j];
      if n= NUM_BLACK then begin //- чёрная клетка
          if pred<>NUM_BLACK then begin //- предыдущая клетка не чёрная -->
            //записать группу:
            masColsNum[i,ng-1].sNum:= inttostr(len);
            //начинается новая группа:
            inc(ng);
            len:= 0;
          end;
          //увеличить длину группы:
          inc(len);
        end;
        pred:= n;
      end;
      masColsNum[i,ng-1].sNum:= inttostr(len);
      masColsNum[i,-1].Num:= ng;
      if ng> h then h:= ng;
    end;

    //формируем данные для левого числового поля:
    w:=0; //ширина левого числового поля
    for j := 0 to POLE_HEIGHT -1 do //- по всем строкам поля
    begin
      ng:= 0;   //- число групп в ряду
      len:= 0;  //- длина группы
      pred:= 0; //- предыдущee число
      //в каждом ряду должно быть хотя бы одно число:
      masRowsNum[0,j].sNum:= '0';
      for i := 0 to POLE_WIDTH -1 do //- по длине строки
      begin
        //считать очередное число:
        n:= masPole[i,j];
        if n= NUM_BLACK then begin //- чёрная клетка
          if pred<> NUM_BLACK then begin //- предыдущая клетка не чёрная -->
            //записать группу:
            masRowsNum[ng-1,j].sNum:= inttostr(len);
            //начинается новая группа:
            inc(ng);
            len:= 0;
          end;
          //увеличить длину группы:
          inc(len);
        end;
        pred:= n;
      end; // i
      masRowsNum[ng-1,j].sNum:= inttostr(len);
      masRowsNum[-1,j].Num:= ng;
      if ng> w then w:= ng;
    end; //j
    //проверить число групп:
    if (w > MAX_CELLNUM) or (h > MAX_CELLNUM) then begin
      application.MessageBox('Слишком много групп!',NAME_PROG, MB_OK);
      exit
    end;
    TOP_POLE_HEIGHT:= h;
    LEFT_POLE_WIDTH:= w;
    //вывести поля заданных размеров с числами:
    Prepare(POLE_WIDTH,POLE_HEIGHT, TOP_POLE_HEIGHT, LEFT_POLE_WIDTH);
end; // TForm1.sbtNumbersClick

//НАЖАТЬ КНОПКУ МЫШКИ
procedure TForm1.dgPoleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ACol,ARow: integer;
  area: tRect;
begin
  if status='ПОИСК' then exit;
  //изменить форму курсора
  //передвигаем картинку:
  if sbtMove.down then begin
    screen.Cursor:=TCursor(crMove);
    dgPole.Cursor :=TCursor(crMove);
    screen.Cursor:=TCursor(crDefault);
    exit end;
  //рисуем на поле:
  if not sbtDraw.Down then exit;
  screen.Cursor:=TCursor(crKistj);
  dgPole.Cursor :=TCursor(crKistj);
  screen.Cursor:=TCursor(crDefault);

  //координаты мыши:
  dgPole.MouseToCell(x,y,ACol,ARow);
  cellmouse.x:=ACol;
  cellmouse.y:=ARow;
  area:= dgPole.CellRect(ACol, ARow);
  //если кнопка мыши нажата вместе с клавишей Shift,
  //то поставить серую клетку:
  if ssShift in shift then begin
    masPole[ACol, ARow]:=NUM_GRAY;
    //закрасить клетку:
    dgPoleDrawCell(self, ACol, ARow, area, []);
    exit
  end;
  //если нажата только левая кнопка - чёрная клетка:
  if ssLeft in shift then
  begin
    //занести в массив цвет клетки
    masPole[ACol, ARow]:=NUM_BLACK;
    //закрасить клетку:
    dgPoleDrawCell(self, ACol, ARow, area, []);
 end;
  //если нажата правая кнопка - белая клетка:
  if ssRight in shift then
  begin
    //занести в массив цвет клетки:
    masPole[ACol, ARow]:= NUM_WHITE;
    //закрасить клетку:
    dgPoleDrawCell(self, ACol, ARow, area, []);
  end;
end; // TForm1.dgPoleMouseDown

//ОТПУСТИТЬ КНОПКУ МЫШИ
procedure TForm1.dgPoleMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //изменить форму курсора:
  screen.Cursor:=TCursor(crHand);
  dgPole.Cursor :=TCursor(crHand);
  screen.Cursor:=TCursor(crDefault);
end;

//ПЕРЕМЕЩАТЬ МЫШКУ ПО ПОЛЮ
procedure TForm1.dgPoleMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ACol,ARow: integer;
  area: TRect;

  //прокрутить поле влево
  procedure PoleLeft;
  var
    n, x, y: Integer;
  begin
    //сдвигаем:
    For y := 0 To POLE_HEIGHT-1 do begin
      //запомнить цвет первой клетки:
      n:= masPole[0,y];
      For x := 0 To POLE_WIDTH - 2 do
        masPole[x,y] := masPole[x+1,y];
      //последний ряд <-- первый ряд:
      masPole[POLE_WIDTH-1,y]:= n;
    end
  end; //PoleLeft
  //Сдвинуть поле вправо
  procedure PoleRight;
  var
    n, x,y: Integer;
    XR: Integer; //правый столбец
  begin
    XR:= POLE_WIDTH-1;
    For y := 0 To POLE_HEIGHT-1 do begin
      n:= masPole[XR, y];
      For x := XR downTo 1 do
        masPole[x,y]:= masPole[x-1,y];
      //первый ряд <-- последний ряд
      masPole[0, y]:=n;
    end
  End; //PoleRight
  //Сдвинуть поле вверх
  procedure PoleUp;
  var
    n, x, y: Integer;
  begin
    For x := 0 To POLE_WIDTH-1 do begin
      n:= masPole[x,0];
      For y := 1 To POLE_HEIGHT-1 do
        masPole[x,y-1] := masPole[x,y];
      //нижняя строка <-- верхняя строка:
      masPole[x, POLE_HEIGHT-1]:= n;
    end
  End; //PoleUp
  //Сдвинуть поле вниз
  procedure PoleDown;
  var
    n, x, y: Integer;
  begin
    For x := 0 To POLE_WIDTH-1 do begin
      n:= masPole[x, POLE_WIDTH-1];
      For y := POLE_HEIGHT-1 downTo 1  do
        masPole[x,y] := masPole[x,y-1];
      //верхняя строка <-- нижняя строка:
      masPole[x, 0]:= n;
    end
  End; //PoleDown

begin
  if status='ПОИСК' then exit;
  dgPole.SetFocus;
  //координаты мыши:
  dgPole.MouseToCell(x,y,ACol,ARow);
  statusbar1.Panels[3].text:='X= '+inttostr(ACol+1);
  statusbar1.Panels[4].text:='Y= '+inttostr(ARow+1);
  //циклически сдвигаем картинку:
  if (sbtMove.Down) and (ssLeft in shift)  then begin
    if cellmouse.x>ACol then PoleLeft;
    if cellmouse.x<ACol then PoleRight;
    if cellmouse.y>ARow then PoleUp;
    if cellmouse.y< ARow then PoleDown;
    dgPole.Invalidate;
    cellmouse.x:=ACol;
    cellmouse.y:=ARow;
  end;
  //рисуем:
  if not sbtDraw.Down then exit;
  area:= dgPole.CellRect(ACol, ARow);
  //если кнопка мыши нажата вместе с клавишей Shift,
  //то поставить серую клетку:
  if (ssShift in shift) and (ssLeft in shift) and
     ((cellmouse.x<>ACol) or (cellmouse.y<>ARow)) then
  begin
    //занести в массив цвет клетки:
    masPole[ACol, ARow]:=NUM_GRAY;
    //закрасить клетку:
    dgPoleDrawCell(Self, ACol, ARow, area, []);
    cellmouse.x:=ACol;
    cellmouse.y:=ARow;
    exit
  end;
  //если нажата левая кнопка - чёрная клетка
  if (ssLeft in shift) and
     ((cellmouse.x<>ACol) or (cellmouse.y<>ARow))then
  begin
    //занести в массив цвет клетки:
    masPole[ACol, ARow]:=NUM_BLACK;
    //закрасить клетку:
    dgPoleDrawCell(Self, ACol, ARow, area, []);
  end;
  if (ssRight in shift) and
     ((cellmouse.x<>ACol) or (cellmouse.y<>ARow))then
  begin
    //занести в массив цвет клетки:
    masPole[ACol, ARow]:= NUM_WHITE;
    //закрасить клетку:
    dgPoleDrawCell(Self, ACol, ARow, area, []);
  end;
  //новые координаты мыши:
  cellmouse.x:=ACol;
  cellmouse.y:=ARow;
end; // TForm1.dgPoleMouseMove

//ЗАПИСАТЬ ЗАДАЧУ
procedure TForm1.sbtSaveFigClick(Sender: TObject);
var
  F: textfile;
  fn,s: string;
  i,j: integer;
begin
  if status='ПОИСК' then exit;
  //расширение файлов фигур:
  savedialog1.DefaultExt:='jcp';
  savedialog1.Filter:='Japan puzzle (*.jcp)|*.JCP';
  //записываем в каталог 'FIGURE':
  s:=extractfilepath(application.exename)+'FIGURE\';
  savedialog1.InitialDir:= s;
  savedialog1.Title:='Запишите фигуру на диск';
  savedialog1.filename:= NameFig;
  if not savedialog1.Execute then exit;
  //имя конечного файла:
  fn:= savedialog1.filename;
  //изменить расширение файла, если при записи было выбрано другое имя:
  fn:=ChangeFileExt(fn, '.jcp');
  NameFig:=fn;
  assignfile(f,fn);
  rewrite(f);
  //записать фигуру -
  //высота и ширина фигуры:
  writeln (f, chr(POLE_HEIGHT + ord('0')) + chr(POLE_WIDTH+ ord('0')));
  //данные из левого числового поля-
  //очередная строка:
  for j:= 0 to POLE_HEIGHT-1 do begin
    for i:= 0 to LEFT_POLE_WIDTH-1 do
      if masRowsNum[i,j].sNum<>'' then
        write (f, chr(strtoint(masRowsNum[i,j].sNum) + ord('0')));
    writeln(f, '');
  end;
  //данные из верхнего числового поля -
  //очередная строка:
  for j:=0 to POLE_WIDTH-1 do begin
    for i:= 0 to TOP_POLE_HEIGHT-1 do
      if masColsNum[j,i].sNum<>'' then
        write (f, chr(strtoint(masColsNum[j,i].sNum) + ord('0')));
    writeln(f, '');
  end;

  //записать комментарий к фигуре:
 s:=frmMemo.memo1.Lines.Text;
  if s<>'' then begin
    s:='//'+s;
    writeln (f,s)
  end;
  closefile(f);
  //вывести в заголовке формы новое название файла:
  form1.caption:= NAME_PROG + '  [' + NameFig + ']';
  form1.Refresh ;
end; //Save

//ПЕРЕНЕСТИ ЧИСЛА В ЧИСЛОВЫХ ПОЛЯХ
procedure TForm1.MoveNums;
var
  i, j, n: integer;
  s: string;
begin
  //переносим все числа к верхней границе сетки
  for i:= 0 to POLE_WIDTH-1 do
  begin
    n:= 0;
    //каждый столбец:
    for j:= 0 to TOP_POLE_HEIGHT-1 do
    begin
      s:= masColsNum[i,j].sNum;
      if s <> '' then begin
        masColsNum[i,j].sNum:= '';
        masColsNum[i,n].sNum:= s;
        inc(n);
      end;
    end;
  end;
  //левое числовое поле:
  for i:= 0 to POLE_HEIGHT-1 do
  begin
    n:= 0;
    //в каждой строке:
    for j:= 0 to LEFT_POLE_WIDTH-1 do
    begin
      s:= masRowsNum[j,i].sNum;
      if s <> '' then begin
        masRowsNum[j,i].sNum:= '';
        masRowsNum[n,i].sNum := s;
        inc(n);
      end;
    end;
  end;
  Invalidategrids;
end; //TForm1.MoveNums;


//ПОЛУЧИТЬ КОЛИЧЕСТВО ГРУПП В РЯДУ nLine левого (LEFT) или
//верхнего (TOP) числового поля
function TForm1.GetNumGroup(Location: TPoleLocation; nLine: integer): integer;
begin
  case Location of
    plLEFT: Result:= masRowsNum[-1, nLine].Num;
    plTOP:  Result:= masColsNum[nLine, -1].Num;
    else Result:= -1;
  end;
end;
//ПОЛУЧИТЬ ДЛИНУ ГРУППЫ nGroup В РЯДУ nLine левого (LEFT) или
//верхнего (TOP) числового поля
function TForm1.GetLenGroup(Location: TPoleLocation; nLine, nGroup: integer)
         : integer;
begin
  case Location of
    plLEFT: Result:= masRowsNum[nGroup, nLine].Num;
    plTOP:  Result:= masColsNum[nLine, nGroup].Num;
    else Result:= -1;
  end;
end;

//УСТАНОВИТЬ СТАТУС ПРОГРАММЫ
procedure TForm1.SetStatus (s: string);
begin
  status:= s;
  StatusBar1.Panels[5].text := s;
  application.ProcessMessages;
end;

//===============================================
//=============== РЕШИТЬ ЗАДАЧУ =================
//===============================================
procedure TForm1.sbtStartClick(Sender: TObject);
label again;
var
  i, j: integer;
  s: string;
  NoVar: boolean;
  numVar: integer;   //число найденных вариантов решения задачи
  maxLevel: integer; //сложность решения задачи

  //проверить данные задачи
  function Testing(): Boolean ;
  var
    sumL, sumT: integer;
    i, j, n: integer;
  begin
    Result:= False;
    //если задача не загружена, то нечего решать:
    if NameFig='temp' then
    begin
      application.MessageBox('Вы не загрузили задачу!',NAME_PROG, MB_OK);
      exit
    end;
    //нормализовать запись чисел:
    MoveNums;
    //записать число групп в каждом ряду в массив
    //и подсчитать сумму чисел -
    //верхнее числовое поле:
    sumT:= 0;
    for i:= 0 to POLE_WIDTH-1 do
    begin
      n:= 0;
      //считаем в каждом столбце:
      for j:= 0 to TOP_POLE_HEIGHT-1 do
      begin
        if masColsNum[i,j].sNum = '' then break; //- числа кончились
        inc(n);
        //записать соотв. число:
        masColsNum[i,j].Num := strtoint(masColsNum[i,j].sNum);
        sumT:= sumT + masColsNum[i,j].Num
      end;
      //записать число групп:
      masColsNum[i,-1].Num:= n;
    end;
    //левое числовое поле:
    sumL:= 0;
    for i:= 0 to POLE_HEIGHT-1 do
    begin
      n:= 0;
      //считаем в каждой строке:
      for j:= 0 to LEFT_POLE_WIDTH-1 do
      begin
        if masRowsNum[j,i].sNum = '' then break; //- числа кончились
        inc(n);
        //записать соотв. число:
        masRowsNum[j,i].Num := strtoint(masRowsNum[j,i].sNum);
        sumL:= sumL + masRowsNum[j,i].Num
      end;
      //записать число групп:
      masRowsNum[-1,i].Num:= n;
    end;
    //проверить суммы чисел:
    if sumT + sumL= 0 then begin
      application.MessageBox('Вы не оцифровали рисунок!',NAME_PROG, MB_OK);
      exit
    end;
    if sumT <> sumL then
    begin
      s:= 'Сумма чисел сверху (' +inttostr(sumT)+
      ')'#10#13'не равна сумме чисел слева (' +inttostr(sumL)+')!';
      application.MessageBox(PChar(s),NAME_PROG, MB_OK);
      exit;
    end;

    //если в ряду есть нулевая группа, то других быть не должно
    //верхнее числовое поле:
    for i:= 0 to POLE_WIDTH-1 do
      //проверяем каждый столбец:
      for j:= 0 to TOP_POLE_HEIGHT-1 do
      begin
        if masColsNum[i,j].sNum = '' then break; //- числа кончились
        if (masColsNum[i,j].sNum = '0') and (masColsNum[i,-1].Num>1)
        then begin
          s:='Неверные данные в столбце '+ inttostr(i+1)+'!';
          application.MessageBox(PChar(s),NAME_PROG, MB_OK);
          exit
        end;
      end;
    //левое числовое поле:
    for i:= 0 to POLE_HEIGHT-1 do
    //проверяем каждую строку:
      for j:= 0 to LEFT_POLE_WIDTH-1 do
      begin
        if masRowsNum[j,i].sNum = '' then break; //- числа кончились
        if (masRowsNum[j,i].sNum = '0') and (masRowsNum[-1,i].Num>1)
        then begin
          s:='Неверные данные в строке '+ inttostr(i+1)+'!';
          application.MessageBox(PChar(s),NAME_PROG, MB_OK);
          exit
        end;
      end;
    //всё нормально:
    Result:= True;
  end; // Testing

  //проверить, не все ли клетки разгаданы:
  function IsReady(): Boolean;
  begin
    lblReady.Caption:= inttostr(ReadyCells);
    Result:= False;
    if ReadyCells= AllCells then Result:= TRUE; //готово!
  end;

  //отмечаем пустые строки
  procedure TestingZero;
  var
    i, j, n: integer;
  begin
    //проверяем верхнее числовое поле:
    for i:= 0 to POLE_WIDTH-1 do
      //проверяем каждый столбец:
      for j:= 0 to masColsNum[i,-1].Num-1 do
      begin
        if (masColsNum[i,j].sNum = '0') then //- нашли
        begin
          {s:='Есть 0 в столбце '+ inttostr(i+1)+'!';
          application.MessageBox(PChar(s),NAME_PROG, MB_OK);}
          //этот столбец решён:
          masColsNum[i,-1].StatusGroup:= stGreen;
          //закрашиваем столбец поля белым цветом:
          for n:= 0 to POLE_HEIGHT-1 do
          begin
            if masPole[i,n]=NUM_GRAY then //- эти клетки разгаданы?
            begin
              masPole[i,n]:= NUM_WHITE;
              inc(ReadyCells)
            end;
          end;
        end;
      end;
    //проверяем левое числовое поле:
    for i:= 0 to POLE_HEIGHT-1 do
    //проверяем каждую строку:
      for j:= 0 to masRowsNum[-1,i].num-1 do
      begin
        if (masRowsNum[j,i].sNum = '0')then //- ашли
        begin
          //эта строка решена:
          masRowsNum[-1,i].StatusGroup:= stGreen;
          {s:='Есть 0 в строке '+ inttostr(i+1)+'!';
          application.MessageBox(PChar(s),NAME_PROG, MB_OK);}
          //закрашиваем строку поля белым цветом:
          for n:= 0 to POLE_WIDTH-1 do
          begin
            if masPole[n,i]=NUM_GRAY then //- эти клетки разгаданы?
            begin
              masPole[n,i]:= NUM_WHITE;
              inc(ReadyCells)
            end;
          end;
        end;
      end;
    InvalidateGrids;
  end; // TestingZero

  {//отмечаем полные строки
  function TestingFullLine(): Boolean;
  var
    i, n: integer;
  begin
    Result:= TRUE;
    //проверяем верхнее числовое поле:
    for i:= 0 to POLE_WIDTH-1 do
      if masColsNum[i,0].Num = POLE_HEIGHT then //нашли
      begin
        //s:='Есть полный столбец '+ inttostr(i+1)+'!';
        //application.MessageBox(PChar(s),NAME_PROG, MB_OK);
        //закрашиваем столбец поля чёрным цветом:
        for n:= 0 to POLE_HEIGHT-1 do
        begin
          if masPole[i,n]<>NUM_GRAY then //- эти клетки уже разгаданы?
          begin
            s:='Неверные числа в столбце '+ inttostr(i+1)+#10#13+
            'и строке ' + inttostr(n+1) +'!';
            application.MessageBox(PChar(s),NAME_PROG, MB_OK);
            Result:= FALSE;
            exit
          end
          else
          begin
            masPole[i,n]:= NUM_BLACK;
            inc(ReadyCells)
          end;
        end;
    //этот столбец решён:
    masColsNum[i,-1].StatusGroup:= stGreen;
    end;
    //проверяем левое числовое поле:
    for i:= 0 to POLE_HEIGHT-1 do
      if masRowsNum[0,i].Num = POLE_WIDTH then //- нашли
      begin
        //s:='Есть полная строка '+ inttostr(i+1)+'!';
        //application.MessageBox(PChar(s),NAME_PROG, MB_OK);
          //закрашиваем строку поля чёрным цветом:
          for n:= 0 to POLE_WIDTH-1 do
          begin
            if masPole[n,i]=NUM_WHITE then //- эта клетка белая?
            begin
              s:='Неверные числа в строке '+ inttostr(i+1)+#10#13+
              'и столбце ' + inttostr(n+1) +'!';
              application.MessageBox(PChar(s),NAME_PROG, MB_OK);
              Result:= FALSE;
              exit
            end
            else if masPole[n,i]=NUM_GRAY then//эта клетка серая?
            begin
              masPole[n,i]:= NUM_BLACK;
             inc(ReadyCells)
            end;
          end;
      //эта строка решена:
      masRowsNum[-1,i].StatusGroup:= stGreen;
      end;
    InvalidateGrids;
  end; // TestingFullLine}

  //отмечаем строки с полными суммами
  function TestingFullSum(): Boolean;
  var
    i, j, n, k, sum: integer;
  begin
    Result:= TRUE;
    //проверяем верхнее числовое поле:
    for i:= 0 to POLE_WIDTH-1 do
      if masColsNum[i,-1].StatusGroup<> stGreen then //- столбец ещё не решён
      begin
        sum:= 0;
        //проверяем каждый столбец
        //находим сумму для каждого столбца:
        for j:= 0 to masColsNum[i,-1].Num-1 do
          sum:= sum + masColsNum[i,j].Num;
        sum:= sum + masColsNum[i,-1].Num-1;
        if sum= POLE_HEIGHT then //- нашли
        begin
          {s:='Есть полная сумма в столбце '+ inttostr(i+1)+'!';
          application.MessageBox(PChar(s),NAME_PROG, MB_OK);}
          //этот столбец решён:
          masColsNum[i,-1].StatusGroup:= stGreen;
          //закрашиваем столбец поля:
          k:= 0;
          for n:= 0 to masColsNum[i,-1].Num-1 do //-по всем группам
          begin
            //закрасить группу чёрным:
            for j:= k to k+ masColsNum[i,n].Num-1 do
            begin
              if masPole[i,j]= NUM_WHITE then //эта клетка белая?
              begin
                s:='Неверные числа в столбце '+ inttostr(i+1)+#10#13+
                'и строке ' + inttostr(j+1) +'!';
                application.MessageBox(PChar(s),NAME_PROG, MB_OK);
                Result:= FALSE;
                exit
              end
              else if masPole[i,j]=NUM_GRAY then//- эта клетка серая?
              begin
                masPole[i,j]:= NUM_BLACK;
                inc(ReadyCells)
              end;
            end; // for j
            //поставить белую клетку между группами:
            if n < GetNumGroup(plTOP, i)-1 then
            begin
              k:= k+ masColsNum[i,n].Num;
              if masPole[i,k]= NUM_BLACK then //эта клетка чёрная?
              begin
                s:='Неверные числа в столбце '+ inttostr(i+1)+#10#13+
                'и строке ' + inttostr(k+1) +'!';
                application.MessageBox(PChar(s),NAME_PROG, MB_OK);
                Result:= FALSE;
                exit
              end
              else if masPole[i,k]=NUM_GRAY then//- эта клетка серая?
              begin
                masPole[i,k]:= NUM_WHITE;
                inc(ReadyCells);
              end;
              inc(k);
            end; //n < GetNumGroup(plTOP, i)-1
          end; // for
        end; //if sum= POLE_HEIGHT
      end; //if masColsNum[i,-1].StatusGroup<> stGreen

    //проверяем левое числовое поле:
    for i:= 0 to POLE_HEIGHT-1 do
      if masRowsNum[-1,i].StatusGroup<> stGreen then //- строка ещё не решена
      begin
        sum:= 0;
        //проверяем каждый строку
        //находим сумму для каждой строки:
        for j:= 0 to masRowsNum[-1,i].Num-1 do
          sum:= sum + masRowsNum[j,i].Num;
        sum:= sum + masRowsNum[-1,i].Num-1;
        if sum= POLE_WIDTH then //нашли
        begin
          {s:='Есть полная сумма в строке '+ inttostr(i+1)+'!';
          application.MessageBox(PChar(s),NAME_PROG, MB_OK);}
          //эта строка решена:
          masRowsNum[-1,i].StatusGroup:= stGreen;
          //закрашиваем строку поля:
          k:= 0;
          for n:= 0 to masRowsNum[-1,i].Num-1 do //- по всем группам
          begin
            //закрасить группу чёрным:
            for j:= k to k+ masRowsNum[n,i].Num-1 do
            begin
              if masPole[j,i]= NUM_WHITE then //- эта клетка белая?
              begin
                s:='Неверные числа в строке '+ inttostr(i+1)+#10#13+
                'и столбце ' + inttostr(j+1) +'!';
                application.MessageBox(PChar(s),NAME_PROG, MB_OK);
                Result:= FALSE;
                exit
              end
              else if masPole[j,i]=NUM_GRAY then//- эта клетка серая?
              begin
                masPole[j,i]:= NUM_BLACK;
                inc(ReadyCells)
              end;
            end; // for j
            //поставить белую клетку между группами:
            if n< GetNumGroup(plLEFT, i)-1 then
            begin
              k:= k+ masRowsNum[n,i].Num;
              if masPole[k,i]= NUM_BLACK then //- эта клетка чёрная?
              begin
                s:='Неверные числа в строке '+ inttostr(i+1)+#10#13+
                'и  столбце' + inttostr(k+1) +'!';
                application.MessageBox(PChar(s),NAME_PROG, MB_OK);
                Result:= FALSE;
                exit
              end
              else if masPole[k,i]=NUM_GRAY then//- эта клетка серая?
              begin
                masPole[k,i]:= NUM_WHITE;
                inc(ReadyCells);
              end;
              inc(k);
            end; //n< GetNumGroup(plLEFT, i)-1
          end; // for
        end; //if sum= POLE_HEIGHT
      end; //if masRowsNum[i,-1].StatusGroup<> stGreen
      InvalidateGrids;
  end; //TestingFullSum

  //отмечаем длинные строки
  function TestingLongLine(): Boolean;
  var
    i, j, sum: integer;
  begin
    Result:= TRUE;
    //проверяем верхнее числовое поле:
    for i:= 0 to POLE_WIDTH-1 do
      if masColsNum[i,-1].StatusGroup<> stGreen then //- столбец ещё не решён
      begin
        //в ряду должна быть одна группа:
        if GetNumGroup(plTOP, i)=1 then
        begin
          sum:= GetLenGroup(plTOP, i, 0)*2;
          if sum - POLE_HEIGHT >0 then //нашли
          begin
            {s:='Длинный столбец '+ inttostr(i+1)+'!';
            s:= s+'beg= '+inttostr((POLE_HEIGHT-GetLenGroup(plTOP, i, 0)));
            application.MessageBox(PChar(s),NAME_PROG, MB_OK);}
            //закрашиваем часть столбца поля чёрным:
            for j:= (POLE_HEIGHT- GetLenGroup(plTOP, i, 0))
                                        to GetLenGroup(plTOP, i, 0)-1 do
            begin
              if masPole[i,j]= NUM_WHITE then //- эта клетка белая?
              begin
                s:='Неверные числа в столбце '+ inttostr(i+1)+#10#13+
                'и строке ' + inttostr(j+1) +'!';
                application.MessageBox(PChar(s),NAME_PROG, MB_OK);
                Result:= FALSE;
                exit
              end
              else if masPole[i,j]=NUM_GRAY then//- эта клетка серая?
              begin
                masPole[i,j]:= NUM_BLACK;
                inc(ReadyCells)
              end;
            end; // for j
          end; // sum - POLE_HEIGHT >0
        end; // if GetNumGroup(TOP, i)=1
      end; //if masColsNum[i,-1].StatusGroup<> stGreen
    //проверяем левое числовое поле:
    for i:= 0 to POLE_HEIGHT-1 do
      if masRowsNum[-1,i].StatusGroup<> stGreen then //- столбец ещё не решён
      begin
        //в ряду должна быть одна группа:
        if GetNumGroup(plLEFT, i)=1 then
        begin
          sum:= GetLenGroup(plLEFT, i, 0)*2;
          if sum - POLE_WIDTH >0 then //нашли
          begin
            {s:='Длинная строка '+ inttostr(i+1)+'!';
            s:= s+'beg= '+inttostr((POLE_WIDTH-GetLenGroup(plLEFT, i, 0)));
            application.MessageBox(PChar(s),NAME_PROG, MB_OK);}
            //закрашиваем часть строки поля чёрным:
            for j:= (POLE_WIDTH- GetLenGroup(plLEFT, i, 0))
                                        to GetLenGroup(plLEFT, i, 0)-1 do
            begin
              if masPole[j,i]= NUM_WHITE then //эта клетка белая?
              begin
                s:='Неверные числа в строке '+ inttostr(i+1)+#10#13+
                'и столбце ' + inttostr(j+1) +'!';
                application.MessageBox(PChar(s),NAME_PROG, MB_OK);
                Result:= FALSE;
                exit
              end
              else if masPole[j,i]=NUM_GRAY then//- эта клетка серая?
              begin
                masPole[j,i]:= NUM_BLACK;
                inc(ReadyCells)
              end;
            end; // for j
          end; // sum - POLE_WIDTH >0
        end; // if GetNumGroup(TOP, i)=1
      end; //if masRowsNum[i,-1].StatusGroup<> stGreen
     InvalidateGrids;
  end; // TestingLongLine

  //------ ищем подходящие комбинации клеток в ряду --------
  function TestingOneLine(nGroup: integer;
                          LenGroup: array of integer;
                          LenLine: integer;
                          masSource: array of integer;
                          var masResult: array of integer): integer;
  //функция возвращает количество возможных расстановок групп в заданном ряду
  //nGroup: integer;                              // число (0..) групп в ряду
  //LenGroup: array[0..MAX_CELLNUM-1] of integer; //длина группы
  //LenLine: integer;                             //длина ряда
  //masSource: array[0..100] of integer;          //исходная полоска
  //masResult: array[0..100] of integer;          //итоговая полоска
  label MoveLastGroup, NextMove, PredMove;
  var
    ptr: integer; // номер (0..nGroup-1) сдвигаемой группы
    pos: array[0..MAX_CELLNUM-1] of integer; //позиция первой клетки группы
    nVar: integer;                    //число найденых вариантов полосок
    masVar: array[0..100] of integer; //очередная полоска
    i: integer;
    //проверить, может ли группа разместиться в ряду
    function ExaminePos(n: integer): Boolean;
    //n - номер (0..) группы
    begin
      Result:= FALSE;
      if pos[n]+LenGroup[n]<=LenLine then Result:= TRUE;
    end;
    //записать расстановку:
    function WriteVariant(): Boolean;
    var i, j: integer;
    begin
      Result:= TRUE;
      //выставить белые клетки по длине ряда:
      for i:= 0 to LenLine-1 do masVar[i]:= NUM_WHITE;
      //расставить все группы чёрных клеток:
      for i:= 0 to nGroup-1 do
        for j:= pos[i] to pos[i]+LenGroup[i]-1 do
          masVar[j]:= NUM_BLACK;

      //скопировать первую расстановку в итоговую полоску:
      if nVar= 1 then
       for i:= 0 to LenLine-1 do masResult[i]:= masVar[i];
      //проверить, ложится ли полоска на уже имеющуюся на поле -
      //чёрная клетка текущей полоски не должна накладываться на
      //белую клетку поля, а белая - на чёрную:
      for i:= 0 to LenLine-1 do
        if (masVar[i]<> masSource[i]) and (masSource[i]<> NUM_GRAY) then
        begin
          Result:= False; exit;//- не ложится!
        end;
      //скорректировать итоговую полоску - если цвета клеток итоговой
      //и текущей полосок в одинаковых позициях разные, то
      //цвет клетки серый, иначе - без изменений
      //сравниваем полоски по всей длине:
      for i:= 0 to LenLine-1 do
        if (masVar[i]<> masResult[i]) then masResult[i]:= NUM_GRAY;
    end; // WriteVariant

  begin
    //номера начальных клеток полосок записываем
    //в массив pos:
    pos[0]:= 0;
    For i:= 1 to nGroup-1 do pos[i]:= pos[i-1]+ LenGroup[i-1]+1;
    //начальная расстановка групп:
    nVar:=1;
    if WriteVariant= FALSE then nVar:= 0;
  //начинаем сдвигать последнюю группу -
  MoveLastGroup:
    ptr:= nGroup-1;
  //передвигаем группу в след. клетку -
  NextMove:
    Inc(pos[ptr]);
    if ExaminePos(ptr) then //можно сдвигать
    begin
      inc(nVar);
      //записать расстановку:
      if WriteVariant= FALSE then dec(nVar);
      goto NextMove; //- сдвигаем до края
    end;
    //сдвигать нельзя -->
//переходим к предыдущей группе:
PredMove:
    dec (ptr);
    if ptr<0 then //- все группы сдвинуты до края
    begin
      {s:='Все варианты: '+ inttostr(nVar);
      application.MessageBox(PChar(s),NAME_PROG, MB_OK);}
      Result:= nVar;
      exit
    end;
    //ищем дальше -->
    //перемещаем начало текущей группы:
    inc(pos[ptr]);
    //проверяем:
    if ExaminePos(ptr)= FALSE then
    begin
      {s:='Все варианты: '+ inttostr(nVar);
      application.MessageBox(PChar(s),NAME_PROG, MB_OK);}
      Result:= nVar;
      exit
    end;
    //расставляем следующие группы сразу после текущей:
    For i:= ptr+1 to nGroup-1 do
    begin
      pos[i]:= pos[i-1]+LenGroup[i-1]+1;
      //проверить:
      if ExaminePos(i)= FALSE then //- для след. групп не хватает места
        goto PredMove;
    end;
    //всё нормально - записать новую расстановку:
      inc(nVar);
      if WriteVariant= FALSE then dec(nVar);
    //ищем след. растановку:
    Goto MoveLastGroup;
  end; // function TestingOneLine()

  //проверить, можно ли ещё поставить белые и чёрные клетки в ряд
  function TestingBrain(): Boolean;
  //= TRUE, если разгадана хотя бы одна клетка
  var
    i, j, n: integer;
    ng: integer;
    LG: array[0..MAX_CELLNUM-1] of integer; //длина групп
    masSrc: array[0..100] of integer;       //исходная полоска
    masResult: array[0..100] of integer;    //итоговая полоска
  begin
    Result:= FALSE;

    //проверяем верхнее числовое поле:
    for i:= 0 to POLE_WIDTH-1 do //- по ширине поля
      //если столбец ещё не решён -->
      if masColsNum[i,-1].StatusGroup<> stGreen then
      begin
        //число групп в ряду:
        ng:= GetNumGroup(plTOP, i);
        //длина групп в ряду:
        for j:= 0 to ng-1 do lg[j]:= masColsNum[i,j].num;
        //скопировать ряд поля -> исходная полоска:
        for j:= 0 to POLE_HEIGHT-1 do masSrc[j]:= masPole[i,j];
        //получить новую полоску (ряд) на поле:
        n:= TestingOneLine(ng, lg, POLE_HEIGHT, masSrc, masResult);
        //s:='n= ' + inttostr(n)+ ' (Столбец: '+ inttostr(i);
        //application.MessageBox(PChar(s),NAME_PROG, MB_OK);
        //если нет ни одной подходящей растановки групп в ряду -->
        if n=0 then begin
          Result:= FALSE;
          NoVar:= TRUE;
          exit
        end;
        //если имеется единственная расстановка групп в ряду -->
        //ряд решён:
        if n= 1 then masColsNum[i,-1].StatusGroup:= stGreen;
        //вывести итоговую полоску на поле:
        for j:= 0 to POLE_HEIGHT-1 do
        begin
          if (masPole[i,j]= NUM_GRAY) and (masResult[j]<> NUM_GRAY) then
          begin
            Result:= TRUE;
            //ещё 1 клетка разгадана:
            inc(ReadyCells);
            masPole[i,j]:= masResult[j];
          end
        end;
        InvalidateGrids;
      end; // if masColsNum[i,-1].StatusGroup<> stGreen

    //проверяем левое числовое поле:
    for i:= 0 to POLE_HEIGHT-1 do
      //- столбец ещё не решён ->
      if masRowsNum[-1,i].StatusGroup<> stGreen then
      begin
        //число групп в ряду:
        ng:= GetNumGroup(plLEFT, i);
        for j:= 0 to ng-1 do lg[j]:= masRowsNum[j,i].num;
        for j:= 0 to POLE_WIDTH-1 do masSrc[j]:= masPole[j,i];
        n:= TestingOneLine(ng, lg, POLE_WIDTH, masSrc, masResult);
        //если нет ни одной подходящей растановки групп в ряду -->
        if n=0 then begin
          Result:= FALSE;
          NoVar:= TRUE;
          exit
        end;
        //если имеется единственная расстановка групп в ряду -->
        //ряд решён:
        if n= 1 then masRowsNum[-1,i].StatusGroup:= stGreen;
        //вывести итоговую полоску на поле:
        for j:= 0 to POLE_WIDTH-1 do
        begin
          if (masPole[j,i]= NUM_GRAY) and (masResult[j]<> NUM_GRAY) then
            begin
              Result:= TRUE;
              //ещё 1 клетка разгадана:
              inc(ReadyCells);
              masPole[j,i]:= masResult[j];
            end
        end;
        InvalidateGrids;
      end; // if masRowsNum[-1,i].StatusGroup<> stGreen
  end; //function TestingBrain()

  //сохранить данные заданного уровня
  procedure SaveDataLevel(n: integer);
  //n - номер уровня (0..)
  var i, j: integer;
  begin
    //сохранить статус рядов верхнего числового поля:
    for i:= 0 to POLE_WIDTH-1 do
      SaveLevel[n].TopStatus[i]:= masColsNum[i,-1].StatusGroup;
    //сохранить статус рядов левого числового поля:
    for i:= 0 to POLE_WIDTH-1 do
      SaveLevel[n].LeftStatus[i]:= masRowsNum[-1,i].StatusGroup;
    //сохранить копию поля:
    SaveLevel[n].masPole:= masPole;
    //заменить первую серую клетку на чёрную:
    inc(ReadyCells);
    //сохранить число разгаданных клеток:
    SaveLevel[n].ReadyCells:= ReadyCells;
    for j:= 0 to POLE_HEIGHT-1 do
    for i:= 0 to POLE_WIDTH-1 do
      if masPole[i,j]= NUM_GRAY then begin
        masPole[i,j]:= NUM_BLACK;
        //сохранить координаты "сомнительной" клетки:
        SaveLevel[n].XCell:= i;
        SaveLevel[n].YCell:= j;
        exit
      end;
  end;  //SaveDataLevel

  //загрузить данные заданного уровня
  procedure LoadDataLevel(n: integer);
  //n - номер уровня (0..)
  var i: integer;
  begin
    //загрузить статус рядов верхнего числового поля:
    for i:= 0 to POLE_WIDTH-1 do
      masColsNum[i,-1].StatusGroup:= SaveLevel[n].TopStatus[i];
    //загрузить статус рядов левого числового поля:
    for i:= 0 to POLE_WIDTH-1 do
      masRowsNum[-1,i].StatusGroup:= SaveLevel[n].LeftStatus[i];
    //загрузить копию поля:
    masPole:= SaveLevel[n].masPole;
    //заменить чёрную клетку на белую:
    masPole[SaveLevel[n].XCell,SaveLevel[n].YCell]:= NUM_WHITE;
    //загрузит число разгаданных клеток:
    ReadyCells:= SaveLevel[n].ReadyCells;
  end;  //LoadDataLevel

//
//===================== Р Е Ш А Е М  З А Д А Ч У =======================
//
begin
  if status='ПОИСК' then exit; //- задача уже решается
  SetStatus('ПОИСК');
  //выключить режимы перемещения и рисования при решении задачи:
  sbtDraw.Down:= FALSE;
  sbtMove.Down:= FALSE;

  numVar:=0;
  maxLevel:= 0;

  //проверить данные фигуры:
  if Testing=FALSE then begin SetStatus('ОЖИДАНИЕ'); exit end;// - ошибка!

  //ни одна клетка пока не разгадана:
  ReadyCells:= 0;
  //подсчитать число уже разгаданных клеток:
  for j:= 0 to POLE_HEIGHT-1 do
    for i:= 0 to POLE_WIDTH-1 do
      if masPole[i,j]<>NUM_GRAY then inc(ReadyCells);
  lblReady.Caption:= inttostr(ReadyCells);

  //начинаем решение задачи с нулевого уровня:
  Level:= 0; lblLevel.Caption:= inttostr(Level);

  //ряды, в которых есть нулевые группы, можно сразу закрасить белым:
  TestingZero;

  //ряды, в которых есть число, равное размеру поля, можно сразу
  //закрасить чёрным:
 // if TestingFullLine=FALSE then begin SetStatus('ОЖИДАНИЕ'); exit end;

  //если (сумма клеток в группах) + (сумма клеток в группах-1) =
  //длине ряда, то этот ряд разгадан:
  if TestingFullSum=FALSE then begin SetStatus('ОЖИДАНИЕ'); exit end;

  //если единственная группа в ряду длиннее половины ряда,
  //то часть ряда можно закрасить чёрным:
  if TestingLongLine=FALSE then begin SetStatus('ОЖИДАНИЕ'); exit end;

again:
  NoVar:= FALSE;
  //пока в TestingBrain будет закрашена хотя бы одна клетка,
  //продолжаем решение задачи:
  while TestingBrain do begin
    application.ProcessMessages;
    if flgExit=true then begin
      flgExit:=false;
      SetStatus('ОЖИДАНИЕ'); exit
    end;
    if IsReady then //- все клетки закрашены!
    begin
      //проверить, все ли ряды решены
      //если не все - продолжить:
      for i:= 0 to POLE_WIDTH-1 do
        if masColsNum[i,-1].StatusGroup<> stGreen then goto again;
        break; // - все ряды решены
    end;
  end;

  if IsReady and (NoVar=FALSE) then //- готово!
  begin
    inc(numVar);
    s:='Задача решена!';
    if numVar> 1 then s:= s+ #10#13+ ' Вариант - ' + inttostr(numVar);
    //сложность решения задачи:
    s:= s+ #10#13+ ' Сложность = ' + inttostr(maxLevel+1);
    application.MessageBox(PChar(s),NAME_PROG,MB_OK );
    if Level = 0 then begin
      SetStatus('ОЖИДАНИЕ'); exit
    end;
    //могут быть варианты:
    if application.MessageBox('Ищем варианты?',NAME_PROG, MB_YESNO)= IDNO
    then begin
      SetStatus('ОЖИДАНИЕ'); exit
    end
    else NoVar:= TRUE
  end;
  //не удалось решить задачу на этом уровне
  if NoVar= TRUE then begin
    dec(Level);
    if Level< 0 then begin
      if numVar= 0 then
        s:='Задача решений не имеет!'
      else
        s:='Найдены все варианты решения задачи - '+ inttostr(numVar);
      application.MessageBox(PChar(s),NAME_PROG,MB_OK );
      SetStatus('ОЖИДАНИЕ'); exit
    end;
    //уровень сложности:
    lblLevel.Caption:= inttostr(Level);
    //загружаем данные предыдущего уровня:
    LoadDataLevel(Level);
    lblReady.Caption:= inttostr(ReadyCells);
    goto again
  end;

  //переходим на следующий уровень -
  //запомнить данные текущего уровня и
  //заменить первую серую клетку на чёрную:
  SaveDataLevel(Level);

  inc(Level);
  if Level > MAX_LEVEL then begin
    s:='Слишком сложная задача!';
    application.MessageBox(PChar(s),NAME_PROG,MB_OK );
    SetStatus('ОЖИДАНИЕ');
    exit
  end;
  lblLevel.Caption:= inttostr(Level);
  if Level > maxLevel then maxLevel:= Level;
  goto again
end; // sbtStartClick

//ОСТАНОВИТЬ РЕШЕНИЕ ЗАДАЧИ
procedure TForm1.sbtStopClick(Sender: TObject);
begin
  if status<>'ПОИСК' then exit;
  flgExit:=true
end;


//ЗАКРЫТЬ ПРОГРАММУ
procedure TForm1.sbtExitClick(Sender: TObject);
begin
  close
end;
//НЕ ВКЛЮЧАТЬ РЕЖИМ ПЕРЕМЕЩЕНИЯ ПРИ РЕШЕНИИ ЗАДАЧИ
procedure TForm1.sbtMoveClick(Sender: TObject);
begin
  if status='ПОИСК' then sbtMove.Down:= FALSE;
end;

//ЗАПИСАТЬ КАРТИНКУ
procedure TForm1.sbtSavePicClick(Sender: TObject);
var
  F: file of byte;
  fn,s: string;
  i,j: integer;
  b: byte;
begin
  if status='ПОИСК' then exit;
  //расширение файлов рисунков:
  savedialog1.Defaultext:='jcw';  //tExt
  savedialog1.Filter:='Japan puzzle (*.jcw)|*.JCW';
  //записываем в каталог 'FIGURE\':
  s:=extractfilepath(application.exename)+'FIGURE\';
  savedialog1.InitialDir:= s;
  savedialog1.Title:='Запишите рисунок на диск';
  savedialog1.filename:= NameFig;
  if not savedialog1.Execute then exit;
  //имя конечного файла:
  fn:= savedialog1.filename;
  //изменить его, если при записи было выбрано другое имя:
  fn:=ChangeFileExt(fn, '.jcw');
  NameFig:=fn;
  assignfile(f,fn);
  rewrite(f);
  //записать фигуру -
  //высота и ширина фигуры:
  write (f, POLE_WIDTH);
  write (f, POLE_HEIGHT);
  for i:= 0 to POLE_WIDTH-1 do
    for j:= 0 to POLE_HEIGHT-1 do
    begin
      if masPole[i,j]= NUM_BLACK then b:= 2 else b:= 0;
      write (f, b);
    end;
  //закрыть файл:
  closefile(f);
  form1.caption:= NAME_PROG + '  [' + NameFig + ']';
  form1.Refresh ;
  messagebeep(0)
end; // sbtSavePicClick

//ПЕРЕКЛЮЧИТЬ РЕЖИМ: ВВОД ЗАДАЧИ - РЕШЕНИЕ ЗАДАЧИ
procedure TForm1.sbtDrawClick(Sender: TObject);
begin
  if status='ПОИСК' then sbtDraw.Down:= FALSE;
end;

//
// ==================== ВЕРХНЕЕ ЧИСЛОВОЕ ПОЛЕ ===========================
//
//ПРОРИСОВАТЬ ЯЧЕЙКУ
procedure TForm1.dgColsNumDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  sNum: string;
begin
  //если столбец решён, отмечаем его зелёным цветом:
  case masColsNum[ACol,-1].StatusGroup of
    stGreen: dgColsNum.Canvas.Brush.Color:= RGB(0,255,0);
    else begin  //- столбец не решён
      //если группа решена, выделить её жёлтым цветом:
      if masColsNum[ACol,ARow].StatusGroup= stYellow then
        dgColsNum.Canvas.Brush.Color:= clYellow
      else dgColsNum.Canvas.Brush.Color:= clWhite; //- иначе белым
    end
  end;
  dgColsNum.Canvas.FillRect(Rect);
  //выводим число в клетке (ACol, ARow):
  sNum:= masColsNum[ACol, ARow].sNum;
  with Rect, dgColsNum.Canvas do
    textrect(Rect, left+(right-left-textwidth(sNum)) div 2,
             top+(bottom-top-textheight(sNum)) div 2, sNum);
  //нарисовать красные линии через 5 клеток:
  if (ACol>0) and (ACol mod 5 = 0) then begin
    dgColsNum.Canvas.Pen.Color:= clRed;
    dgColsNum.Canvas.MoveTo(Rect.Left,Rect.Top);
    dgColsNum.Canvas.LineTo(Rect.Left,Rect.Bottom)
  end;
  if (ARow>0) and (ARow mod 5 = 0) then begin
    dgColsNum.Canvas.Pen.Color:= clRed;
    dgColsNum.Canvas.MoveTo(Rect.Left,Rect.Top);
    dgColsNum.Canvas.LineTo(Rect.Right,Rect.Top)
  end;
end; // dgColsNumDrawCell

//ПЕРЕМЕЩАТЬ ПОЗИЦИЮ ВВОДА В ВЕРХНЕМ ЧИСЛОВОМ ПОЛЕ
procedure TForm1.dgColsNumMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var ACol, ARow: Integer;
  r: TRECT;
  text1: string;
begin
  //ACol, ARow <-- клетка с курсором
  dgColsNum.MouseToCell(x,y,ACol, ARow);
  //если курсор переместился на другую клетку -
  if (ACol<>cellMouseTop.x) or (ARow<>cellMouseTop.y) then
  begin
    //установить фокус ввода на верхнем поле:
    dgColsNum.SetFocus;
    //перерисовать предыдущую клетку с курсором:
    r:= dgColsNum.CellRect(cellMouseTop.x, cellMouseTop.y);
    dgColsNumDrawCell(self, cellMouseTop.x, cellMouseTop.y, R, []);
    //выделить красным цветом текущую клетку:
    if not sbtDraw.Down then begin
      r:= dgColsNum.CellRect(ACol, ARow);
      InflateRect(r,-1,-1);
      dgColsNum.Canvas.Brush.Color:= RGB(255,0,0);
      dgColsNum.Canvas.FillRect(R);
      //восстановить число в клетке:
      text1:= masColsNum[ACol, ARow].sNum;
      with R, dgColsNum.Canvas do
       textrect(R, left+(right-left-textwidth(text1)) div 2,
                top+(bottom-top-textheight(text1)) div 2, text1);
    end;
  end;
  //новая позиция ввода:
  cellMouseTop.x:= ACol;
  cellMouseTop.y:= ARow;
end; // dgColsNumMouseMove

//ВВЕСТИ ЧИСЛО В ТЕКУЩУЮ КЛЕТКУ
procedure TForm1.dgColsNumKeyPress(Sender: TObject; var Key: Char);
var
  s, text1: string;
  rect: TRect;
begin
  if sbtDraw.Down then exit;
  //if not dgColsNum.Focused  then exit;
  if not(key in['0'..'9']) then exit;
  text1:= Key;
  //если что-то уже есть в этой клетке -
  s:= masColsNum[cellMouseTop.x, cellMouseTop.y].sNum;
  //числа могут быть только однозначные и двузначные:
  if length(s)>=2 then exit;
  //записать число в клетку:
  masColsNum[cellMouseTop.x, cellMouseTop.y].sNum:= s+Key;
  rect:= dgColsNum.CellRect(cellMouseTop.x, cellMouseTop.y);
  dgColsNumDrawCell(self, cellMouseTop.x, cellMouseTop.y, Rect, []);
end; // dgColsNumKeyPress

//ОЧИСТИТЬ ТЕКУЩУЮ КЛЕТКУ
procedure TForm1.dgColsNumDblClick(Sender: TObject);
var Rect: TRECT;
begin
  if sbtDraw.Down then exit;
  masColsNum[cellMouseTop.x, cellMouseTop.y].sNum:='';
  rect:= dgColsNum.CellRect(cellMouseTop.x, cellMouseTop.y);
  dgColsNumDrawCell(self, cellMouseTop.x, cellMouseTop.y, Rect, []);
end;

//ИЗМЕНИТЬ СТАТУС ГРУППЫ
procedure TForm1.dgColsNumClick(Sender: TObject);
var ACol, ARow: Integer;
  r: TRECT;
begin
  if not sbtDraw.Down then exit;
  ACol:= cellMouseTop.x; ARow:= cellMouseTop.y;
  case masColsNum[ACol, ARow].StatusGroup of
    stYellow: masColsNum[ACol, ARow].StatusGroup:= stWhite;
    stWhite: masColsNum[ACol, ARow].StatusGroup:= stYellow;
  end;
  r:= dgColsNum.CellRect(ACol, ARow);
  dgColsNumDrawCell(self, ACol, ARow, R, []);
end;
//
// ====================== ЛЕВОЕ ЧИСЛОВОЕ ПОЛЕ ===========================
//
//ПРОРИСОВАТЬ ЯЧЕЙКУ
procedure TForm1.dgRowsNumDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState);
var
  sNum: string;
begin
  //если столбец решён, отмечаем его зелёным цветом:
  case masRowsNum[-1,ARow].StatusGroup of
    stGreen: dgRowsNum.Canvas.Brush.Color:= RGB(0,255,0);
    else begin  //- столбец не решён
      //если группа решена, выделить её жёлтым цветом:
      if masRowsNum[ACol,ARow].StatusGroup= stYellow then
        dgRowsNum.Canvas.Brush.Color:= clYellow
      else dgRowsNum.Canvas.Brush.Color:= clWhite; //- иначе белым
    end
  end;
  dgRowsNum.Canvas.FillRect(Rect);
  sNum:= masRowsNum[ACol, ARow].sNum;
    with Rect, dgRowsNum.Canvas do
    textrect(Rect, left+(right-left-textwidth(sNum)) div 2,
             top+(bottom-top-textheight(sNum)) div 2, sNum);
  //нарисовать красные линии через 5 клеток:
  if (ACol>0) and (ACol mod 5 = 0) then begin
    dgRowsNum.Canvas.Pen.Color:= clRed;
    dgRowsNum.Canvas.MoveTo(Rect.Left,Rect.Top);
    dgRowsNum.Canvas.LineTo(Rect.Left,Rect.Bottom)
  end;
  if (ARow>0) and (ARow mod 5 = 0) then begin
    dgRowsNum.Canvas.Pen.Color:= clRed;
    dgRowsNum.Canvas.MoveTo(Rect.Left,Rect.Top);
    dgRowsNum.Canvas.LineTo(Rect.Right,Rect.Top)
  end;
end; // dgRowsNumDrawCell


//ПЕРЕМЕЩАТЬ ПОЗИЦИЮ ВВОДА В ЛЕВОМ ЧИСЛОВОМ ПОЛЕ
procedure TForm1.dgRowsNumMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var ACol, ARow: Integer;
  r: TRECT;
  text1: string;
begin
  //ACol, ARow <-- клетка с курсором
  dgRowsNum.MouseToCell(x,y,ACol, ARow);
  if (ACol<>cellMouseLeft.x) or (ARow<>cellMouseLeft.y) then
  begin
    //установить фокус на левом поле:
    dgRowsNum.SetFocus;
    //перерисовать предыдущую клетку с курсором:
    r:= dgRowsNum.CellRect(cellMouseLeft.x, cellMouseLeft.y);
    dgRowsNumDrawCell(self, cellMouseLeft.x, cellMouseLeft.y, R, []);
    //выделить красным цветом текущую клетку:
    if not sbtDraw.Down then begin
      r:= dgRowsNum.CellRect(ACol, ARow);
      InflateRect(r,-1,-1);
      dgRowsNum.Canvas.Brush.Color:= RGB(255,0,0);
      dgRowsNum.Canvas.FillRect(R);
      text1:= masRowsNum[ACol, ARow].sNum;
      with R, dgRowsNum.Canvas do
       textrect(R, left+(right-left-textwidth(text1)) div 2,
                top+(bottom-top-textheight(text1)) div 2, text1);
    end;
  end;
  cellMouseLeft.x:= ACol;
  cellMouseLeft.y:= ARow;
end; // dgRowsNumMouseMove

//ВВЕСТИ ЧИСЛО В ЯЧЕЙКУ ЛЕВОГО ЧИСЛОВОГО ПОЛЯ
procedure TForm1.dgRowsNumKeyPress(Sender: TObject; var Key: Char);
var
  s, text1: string;
  rect: TRect;
begin
  if sbtDraw.Down then exit;
  //if not dgRowsNum.Focused  then exit;
  if not(key in['0'..'9']) then exit;
  text1:= Key;
  s:= masRowsNum[cellMouseLeft.x, cellMouseLeft.y].sNum;
  if length(s)>=2 then exit;
  masRowsNum[cellMouseLeft.x, cellMouseLeft.y].sNum:= s+Key;
  rect:= dgRowsNum.CellRect(cellMouseLeft.x, cellMouseLeft.y);
  dgRowsNumDrawCell(self, cellMouseLeft.x, cellMouseLeft.y, Rect, []);
end; // dgRowsNumKeyPress

//ОЧИСТИТЬ ТЕКУЩУЮ КЛЕТКУ
procedure TForm1.dgRowsNumDblClick(Sender: TObject);
var Rect: TRECT;
begin
  if sbtDraw.Down then exit;
  masRowsNum[cellMouseLeft.x, cellMouseLeft.y].sNum:='';
  rect:= dgRowsNum.CellRect(cellMouseLeft.x, cellMouseLeft.y);
  dgRowsNumDrawCell(self, cellMouseLeft.x, cellMouseLeft.y, Rect, []);
end;

//ИЗМЕНИТЬ СТАТУС ГРУППЫ
procedure TForm1.dgRowsNumClick(Sender: TObject);
var ACol, ARow: Integer;
  r: TRECT;
begin
  if not sbtDraw.Down then exit;
  ACol:= cellMouseLeft.x; ARow:= cellMouseLeft.y;
  case masRowsNum[ACol, ARow].StatusGroup of
    stYellow: masRowsNum[ACol, ARow].StatusGroup:= stWhite;
    stWhite: masRowsNum[ACol, ARow].StatusGroup:= stYellow;
  end;
  r:= dgRowsNum.CellRect(ACol, ARow);
  dgRowsNumDrawCell(self, ACol, ARow, R, []);
end;

procedure TForm1.StatusBar1Hint(Sender: TObject);
begin

end;


//ЗАГРУЗИТЬ РАСТРОВУЮ КАРТИНКУ ИЛИ ЗНАЧОК
procedure TForm1.sbtOpenPictureClick(Sender: TObject);
var
  w, h: integer;
  i, j: integer;
  bmp: TBITMAP;
begin
  frmMemo.Image1.Visible:= FALSE;
  OpenPictureDialog1.DefaultExt:= 'BMP';
  OpenPictureDialog1.InitialDir:= extractfilepath(application.exename);
  OpenPictureDialog1.Title:='Загрузите картинку';
  OpenPictureDialog1.Filter:= GraphicFilter(TBitmap)+'|'+GraphicFilter(TIcon);
  if not OpenPictureDialog1.Execute then exit;
  //имя файла:
  NameFig:= OpenPictureDialog1.FileName;
  //загрузить картинку:
  frmMemo.Image1.Picture.LoadFromFile(NameFig);
  if OpenPictureDialog1.FilterIndex= 2 then begin //- значок
    bmp:= TBitmap.Create;
    bmp.Width:= frmMemo.Image1.Picture.icon.Width;
    bmp.Height:= frmMemo.Image1.Picture.icon.Height;
    bmp.Canvas.Draw(0,0,frmMemo.Image1.Picture.icon);
   frmMemo.Image1.Picture.Bitmap.Assign(bmp);
    bmp.Free;
  end;
 w:= frmMemo.Image1.Picture.Width;
 h:= frmMemo.Image1.Picture.Height;
  //проверить размеры картинки:
  if (h > MAX_POLE_HEIGHT) or (w > MAX_POLE_WIDTH)then begin
    application.MessageBox('Слишком большая картинка!',NAME_PROG, MB_OK);
    exit
  end;
  frmMemo.Image1.Visible:= TRUE;
  POLE_WIDTH:= w; POLE_HEIGHT:= h;
  TOP_POLE_HEIGHT:= 2; LEFT_POLE_WIDTH:= 2;
  Prepare(POLE_WIDTH,POLE_HEIGHT, TOP_POLE_HEIGHT, LEFT_POLE_WIDTH);
  //очистить цифровые поля:
  Clear_masColsNum;
  Clear_masRowsNum;
  for j:= 0 to POLE_HEIGHT-1 do
    for i:= 0 to POLE_WIDTH - 1 do begin
     case frmMemo.Image1.Picture.Bitmap.Canvas.Pixels[i,j] of
       clBlack: masPole[i,j]:= NUM_BLACK;
       clWhite: masPole[i,j]:= NUM_WHITE;
        else masPole[i,j]:= NUM_GRAY;
      end;
  end;
  //вывести в заголовке формы имя загруженного файла:
  form1.caption:= NAME_PROG + '  [' + NameFig + ']';
  dgPole.Invalidate
end; // sbtOpenPictureClick

end.

