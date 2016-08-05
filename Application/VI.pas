unit VI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtDlgs, Menus, Vcl.OleCtrls, HALCONXLib_TLB, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    PrintSetup1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    Open1: TMenuItem;
    New1: TMenuItem;
    Edit1: TMenuItem;
    Object1: TMenuItem;
    Links1: TMenuItem;
    N3: TMenuItem;
    GoTo1: TMenuItem;
    Replace1: TMenuItem;
    Find1: TMenuItem;
    N4: TMenuItem;
    PasteSpecial1: TMenuItem;
    Paste1: TMenuItem;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    N5: TMenuItem;
    Repeatcommand1: TMenuItem;
    Undo1: TMenuItem;
    Window1: TMenuItem;
    Show1: TMenuItem;
    Hide1: TMenuItem;
    N6: TMenuItem;
    ArrangeAll1: TMenuItem;
    Cascade1: TMenuItem;
    ile1: TMenuItem;
    NewWindow1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    HowtoUseHelp1: TMenuItem;
    utorial1: TMenuItem;
    SearchforHelpOn1: TMenuItem;
    Keyboard1: TMenuItem;
    Procedures1: TMenuItem;
    Commands1: TMenuItem;
    Index1: TMenuItem;
    Contents1: TMenuItem;
    OpenPictureDialog: TOpenPictureDialog;
    SavePictureDialog: TSavePictureDialog;
    HWindowXCtrl: THWindowXCtrl;
    Opration: TMenuItem;
    Memo: TMemo;
    getPos: TMenuItem;
    Recognizition: TMenuItem;
    LoadPattern: TMenuItem;
    GetChars: TMenuItem;
    procedure Open1Click(Sender: TObject);
    procedure ile1Click(Sender: TObject);
    procedure Cascade1Click(Sender: TObject);
    procedure ArrangeAll1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure LoadPatternClick(Sender: TObject);
    procedure getPositionClick(Sender: TObject);
    procedure GetCharsClick(Sender: TObject);
    procedure RecognizitionClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  op: HOperatorSetX;
  SrcImage,RotatedImage, Pattern, DotImage, SrcImageReduced, ImageInvert: IHUntypedObjectX;
  Region, ConnectedRegion, RegionUnion, RegionClosing,RegionClosing1, RegionTrans, SelectedRegion: IHUntypedObjectX;
  Partitioned, RegionIntersection: IHUntypedObjectX;
  LettersIntermediate, Characters, FinalChars: IHUntypedObjectX;
  TemplateID, OCRHandle: OleVariant;
  Result,Confidence: OleVariant;
  I_Width, I_Height: OleVariant;
  P_Row, P_Column, P_Angle, Score: OleVariant;
  CharsRow, CharsColumn, CharsWidth, CharsHeight: OleVariant;
  Number1,Number2,Number3, NumberIntermediate: OleVariant;
// SaveFileName: OleVariant;
// Stopwatch: TStopwatch;
implementation

uses About;

{$R *.dfm}

procedure TMainForm.About1Click(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.ArrangeAll1Click(Sender: TObject);
begin
  ArrangeIcons;
end;

procedure TMainForm.Cascade1Click(Sender: TObject);
begin
  Cascade;
end;

procedure TMainForm.GetCharsClick(Sender: TObject);
var
   Char, ConnectedChar, Letters: IHUntypedObjectX;
   j: Integer;
   SelectedRegion1, SelectedRegion2: IHUntypedObjectX;
begin
    //按照字符大致高度和宽度分割字符框
    op.PartitionDynamic (RegionTrans, Partitioned, 35, 44);

    op.Intersection (Partitioned, SelectedRegion, RegionIntersection);
    op.ClosingCircle (RegionIntersection, LettersIntermediate, 3);
   // HWindowXCtrl.HalconWindow.SetColor('green');
   // HWindowXCtrl.HalconWindow.SetDraw('fill');
   // op.DispObj(LettersIntermediate,HWindowXCtrl.HalconWindow.HalconID);

   //下面的代码是将每个待识别的字符分别取出来进行筛选
    op.CountObj(LettersIntermediate, NumberIntermediate);
    op.GenEmptyObj(Letters);
    op.GenEmptyObj(Characters);
    for j := 1 to NumberIntermediate do
      begin
        op.SelectObj(LettersIntermediate, Char, j);
        op.Connection(Char,ConnectedChar);
        //select area
        op.SelectShape(ConnectedChar, SelectedRegion1, 'area', 'and', 400, 1000);
        //concat the obj we need. Attention, one obj cannot be used as input and output
        //at the same time, and the input pra cannot be nil
        op.Union1(SelectedRegion1,Char);
        op.ConcatObj(Char, Letters, Characters);
        Letters := Characters;
      end;
    //select heihgt
    op.SelectShape(Characters, SelectedRegion2, 'height', 'and', 40, 50);
    //sort the order of the obj
    op.SortRegion(SelectedRegion2,FinalChars,'character','true','row');
    HWindowXCtrl.HalconWindow.SetColor('green');
    HWindowXCtrl.HalconWindow.SetDraw('fill');
    op.DispObj(FinalChars,HWindowXCtrl.HalconWindow.HalconID);
end;

procedure TMainForm.getPositionClick(Sender: TObject);
var
  Rectangle: IHUntypedObjectX;
begin
  //初步处理
  op.DotsImage(RotatedImage,DotImage,9,'light',2);
  //这些参数是为了便于调试设成变量，这是带识别的字符的区域的中心坐标，以及长和宽
  CharsRow := P_Row - 45;
  CharsColumn := P_Column + 420;
  CharsWidth := 740;
  CharsHeight := 324;
  op.GenRectangle2(Rectangle, CharsRow, CharsColumn, 0, CharsWidth/2, CharsHeight/2);
  op.ReduceDomain(DotImage,Rectangle,SrcImageReduced);
  op.DispObj(SrcImageReduced,HWindowXCtrl.HalconWindow.HalconID);
  //阈值分割
  op.Threshold(SrcImageReduced,Region,30,256);
  op.Connection(Region, ConnectedRegion);
  op.Union1(ConnectedRegion,RegionUnion);
  //形态学处理
  op.ClosingGolay (RegionUnion, RegionClosing1, 'm', 6);
  op.ClosingCircle(RegionClosing1,RegionClosing,3.5);
  op.Connection(RegionClosing,ConnectedRegion);
  op.SelectShape (ConnectedRegion, SelectedRegion, 'area', 'and', 149.96, 4000);
  op.ShapeTrans (SelectedRegion, RegionTrans, 'rectangle1');
  op.DispObj(RegionTrans,HWindowXCtrl.HalconWindow.HalconID);
end;

procedure TMainForm.ile1Click(Sender: TObject);
begin
  Tile;
end;

procedure TMainForm.Open1Click(Sender: TObject);
begin
  if OpenPictureDialog.Execute then
  begin
  Memo.Lines.Clear;
  //实例化op对象
  op := CoHOperatorSetX.Create;
  op.GenEmptyObj(SrcImage);
  op.ReadImage(SrcImage, OpenPictureDialog.FileName);
  op.GetImageSize(SrcImage, I_Width, I_Height);
  HWindowXCtrl.HalconWindow.SetPart(0, 0, I_Height - 1, I_Width - 1);
  op.DispObj(SrcImage, HWindowXCtrl.HalconWindow.HalconID);
  end;
end;
procedure TMainForm.RecognizitionClick(Sender: TObject);
var
   RecognizeResult: OleVariant;
   j: Integer;
   SelectedRegion1,SelectedRegion2,SelectedRegion3: IHUntypedObjectX;
begin
//将区域分成三份， 字符必须在三份区域内才有效
  op.SelectShape(FinalChars,SelectedRegion1,'row1','and',CharsRow - CharsHeight/2,CharsRow - CharsHeight/6);
  op.SelectShape(FinalChars,SelectedRegion2,'row1','and',CharsRow - CharsHeight/6,CharsRow + CharsHeight/6);
  op.SelectShape(FinalChars,SelectedRegion3,'row1','and',CharsRow + CharsHeight/6,CharsRow + CharsHeight/2);

  op.CountObj (SelectedRegion1, Number1);
  op.CountObj (SelectedRegion2, Number2);
  op.CountObj (SelectedRegion3, Number3);

  //key part of the recognize
  op.InvertImage(RotatedImage,ImageInvert);
  op.ReadOcrClassMlp ('DotPrint_0-9.omc', OCRHandle);
  op.DoOcrMultiClassMlp (SelectedRegion1, ImageInvert, OCRHandle, Result, Confidence);
  //生产批号
  RecognizeResult := '生产批号为';
  if Number1 > 0 then
  begin
    for j := 1 to Number1 do
      if Number1 = 1 then
      begin
        RecognizeResult := RecognizeResult + Result;
      end
      else
        RecognizeResult := RecognizeResult + Result[j-1];
    if Number1 = 8 then
    begin
      RecognizeResult := RecognizeResult + '，合格。';
    end
    else
      RecognizeResult := RecognizeResult + '，字符不完整或打印模糊。';
  end
  else
     RecognizeResult := RecognizeResult + '空,未打印此项或字符模糊。';
  Memo.Lines.Add(RecognizeResult);
  //生产日期
  RecognizeResult := '生产日期为';
  op.DoOcrMultiClassMlp (SelectedRegion2, ImageInvert, OCRHandle, Result, Confidence);
  if Number2 > 0 then
  begin
    for j := 1 to Number2 do
      if Number2 = 1 then
      begin
        RecognizeResult := RecognizeResult + Result;
      end
      else
        RecognizeResult := RecognizeResult + Result[j-1];
    if Number2 = 8 then
    begin
      RecognizeResult := RecognizeResult + '，合格。';
    end
    else
      RecognizeResult := RecognizeResult + '，字符不完整或打印模糊。';
  end
  else
     RecognizeResult := RecognizeResult + '空,未打印此项或字符模糊。';
  Memo.Lines.Add(RecognizeResult);
  //有效期
  RecognizeResult := '有效期至';
  op.DoOcrMultiClassMlp (SelectedRegion3, ImageInvert, OCRHandle, Result, Confidence);
  if Number3 > 0 then
  begin
    for j := 1 to Number3 do
      if Number3 = 1 then
      begin
        RecognizeResult := RecognizeResult + Result;
      end
      else
        RecognizeResult := RecognizeResult + Result[j-1];
    if Number3 = 6 then
    begin
      RecognizeResult := RecognizeResult + '，合格。';
    end
    else
      RecognizeResult := RecognizeResult + '，字符不完整或打印模糊。';
  end
  else
     RecognizeResult := RecognizeResult + '为空,未打印此项或字符模糊。';
  Memo.Lines.Add(RecognizeResult);
end;

procedure TMainForm.LoadPatternClick(Sender: TObject);
var
  ModelID: OleVariant;
  OrientationAngle,Hommat2DIdentity,HomMat2DRotate: OleVariant;
begin
  if op <> nil then
  begin
    //orientation correction
    op.TextLineOrientation (SrcImage, SrcImage, 44, -0.523599, 0.523599, OrientationAngle);
    op.HomMat2dIdentity (HomMat2DIdentity);
    op.HomMat2dRotate(HomMat2DIdentity, -OrientationAngle, 0, 0, HomMat2DRotate);
    op.AffineTransImage (SrcImage, RotatedImage, HomMat2DRotate, 'constant', 'false');
    op.DispObj(RotatedImage,HWindowXCtrl.HalconWindow.HalconID);

//    op.ReadImage(Pattern,'pattern.bmp');
//    op.CreateTemplate(Pattern, 255, 4, 'sort', 'original', TemplateID);
    //改用Ncc模板匹配方式，比灰度匹配效果更好
    op.ReadImage(Pattern,'NccPattern.bmp');
    op.CreateNccModel(Pattern,'auto', -0.39, 0.79, 'auto', 'use_polarity', ModelID);

//    op.BestMatch(RotatedImage, TemplateID, 20, 'flase', P_Row, P_Column, Error);
    op.FindNccModel(RotatedImage, ModelID, -0.39, 0.78, 0.8, 1, 0.5, 'true', 0, P_Row, P_Column, P_Angle, Score);
//    if Error < 255 then
    if Score > 0.5 then
    begin
      HWindowXCtrl.HalconWindow.SetColor('red');
      HWindowXCtrl.HalconWindow.SetDraw('margin');
      op.DispRectangle1(HWindowXCtrl.HalconWindow.HalconID, P_Row - 100, P_Column - 45, P_Row + 100, P_Column + 45);
    end;

  end
  else
  begin
    Memo.Lines.Clear;
    Memo.Lines.Add('Please open a Pic first!!');
  end;

end;


end.
