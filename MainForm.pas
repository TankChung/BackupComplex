unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Buttons,Vcl.FileCtrl,
  Vcl.StdCtrls, Vcl.Mask,System.IOUtils,StrUtils,Winapi.ShellAPI;

type
  TMF = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    Label1: TLabel;
    ListBox1: TListBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    LabeledEdit1: TLabeledEdit;
    Button1: TButton;
    ComboBox1: TComboBox;
    Label2: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    SpeedButton3: TSpeedButton;
    Panel2: TPanel;
    Timer1: TTimer;
    TabSheet3: TTabSheet;
    Button5: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Timer2: TTimer;
    LabeledEdit2: TLabeledEdit;
    Button6: TButton;
    ListBox2: TListBox;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Label3: TLabel;
    LabeledEdit3: TLabeledEdit;
    Button7: TButton;
    LabeledEdit4: TLabeledEdit;
    Button8: TButton;
    SpeedButton6: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private
    { Private declarations }
    function MoveData(sSourceFile,sTargetFile:String):Boolean;
    function CopyData(sSourceFile,sTargetFile:String):Boolean;
    function ActionAllFile(sSourceFile,sTargetFile,sNum:String):Boolean;
    procedure WriteTxT(sMessage:String);
    function IsEmptyDir(sDir: String): Boolean;
    procedure FindAllFiles(const APath:String;AFiles:TStrings;const APropty:String='*.*';IsAddPath:Boolean=False);
    function DeleteAssignFile(sDir:String):Boolean;
  public
    { Public declarations }
    iStateCount:Integer; // 跑系統狀態用
    sCurrentDate:String; // 紀錄日期
    iPageCount:Integer;  // 判斷當前頁簽
  end;

var
  MF: TMF;

implementation

{$R *.dfm}

// -刪除指定資料夾內所有檔案(包含資料夾)- //
function TMF.DeleteAssignFile(sDir:String):Boolean;
var
  i:Integer;
  Files, Directories: TArray<string>;
begin
  // 抓取檔案名稱
  Files := TDirectory.GetFiles(sDir);
  // 抓取次資料夾名稱
  Directories := TDirectory.GetDirectories(sDir);
  // 刪除檔案
  for i := 0 to Length(Files)-1 do
    TFile.Delete(Files[i]);
  // 刪除資料夾
  for i := 0 to Length(Directories)-1 do
    TDirectory.Delete(Directories[i],true);
  // 在抓一次檔案與資料夾判斷是否為0
  Files := TDirectory.GetFiles(sDir);
  Directories := TDirectory.GetDirectories(sDir);
  if (Length(Files) = 0) and (Length(Directories) = 0) then
    Result:=true
  else
    Result:=false;
end;

// -找指定目錄下所有檔案(好像有點問題,次目錄下的檔案無法完全讀出)- //
procedure TMF.FindAllFiles(const APath:String;AFiles:TStrings;const APropty:String='*.*';IsAddPath:Boolean=False);
var
  FS:TSearchRec;
  FPath:String;
  AddPath:String;
begin
  FPath:=IncludeTrailingPathDelimiter(APath);
  AddPath:=IfThen(IsAddPath,FPath,'');
  if FindFirst(FPath+Apropty,faAnyFile,FS)=0 then
  begin
    repeat
      if (FS.Name <> '.') and (FS.Name <> '..') then
        if ((FS.Attr and faDirectory)=faDirectory) then
          FindAllFiles(FPath+FS.Name,AFiles,APropty,IsAddPath)
        else
          AFiles.Add(AddPath+FS.Name);
    until FindNext(FS)<>0;
    System.SysUtils.FindClose(FS);
  end;
end;

// -複製or搬移所有檔案- //
function TMF.ActionAllFile(sSourceFile,sTargetFile,sNum:String):Boolean;
begin
  //if sNum='1' then TDirectory.Move(sSourceFile,sTargetFile);  // 會出錯
  TDirectory.Copy(sSourceFile,sTargetFile);
  if sNum='1' then DeleteAssignFile(sSourceFile);
  //if sNum='2' then TDirectory.Copy(sSourceFile,sTargetFile);
  if IsEmptyDir(sTargetFile) then  Result:=false else Result:=false;
end;

// -判斷資料夾是否為null : null為true,有檔案為false- //
function TMF.IsEmptyDir(sDir: String): Boolean;
var
  sr: TsearchRec;
begin
  Result := True;
  if Copy(sDir, Length(sDir) - 1, 1) <> '\' then sDir := sDir + '\';
  if FindFirst(sDir + '*.*', faAnyFile, sr) = 0 then
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        Result := False;
        break;
      end;
    until FindNext(sr) <> 0;
  FindClose(sr);
end;

// -紀錄log檔- //
procedure TMF.WriteTxT(sMessage:String);
var
  wText:TextFile;
begin
  AssignFile(wText,ExtractFilePath(Application.Exename) + 'BackupLog.txt');
  if not FileExists(ExtractFilePath(Application.Exename) + 'BackupLog.txt') then
    Rewrite(wText);              // Rewwrite 更改文件內容,[文件不存在會新增]
  Append(wText);               // Append 向文本內追加文本,[文件不存在會報錯]
  Writeln(wText,FormatDateTime('yyyy-mm-dd hh:nn:ss',now)+' '+sMessage);     // 第二個參數為 修改/追加 的內容
  CloseFile(wText);
end;

// -搬移檔案- //
function TMF.MoveData(sSourceFile,sTargetFile:String):Boolean;
begin
  if FileExists(sTargetFile) then
    DeleteFile(PWideChar(sTargetFile));
  MoveFile(PWideChar(sSourceFile), PWideChar(sTargetFile));
  if FileExists(sTargetFile) then
    Result:=true
  else
    Result:=false;
end;

// -複製檔案- //
function TMF.CopyData(sSourceFile,sTargetFile:String):Boolean;
begin
  copyfile(pchar(sSourceFile),pchar(sTargetFile),false);
  if FileExists(sTargetFile) then
    Result:=true
  else
    Result:=false;
end;

procedure TMF.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage=TabSheet1 then
  begin
    iPageCount:=1;
    CheckBox1.Enabled:=true;
  end;
  if PageControl1.ActivePage=TabSheet2 then
  begin
    iPageCount:=2;
    CheckBox1.Enabled:=false;
    CheckBox1.State:=cbUnchecked;
    CheckBox2.State:=cbChecked;
  end;
  if PageControl1.ActivePage=TabSheet3 then
  begin
    iPageCount:=3;
    CheckBox1.Enabled:=true;
  end;

end;

// -選擇目的資料夾- //
procedure TMF.Button1Click(Sender: TObject);
var
  dir:String;
begin
  if not SelectDirectory('請選擇備份位置','',dir) then
    abort;
  LabeledEdit1.Text	:=dir;
end;

// -啟動自動備份- //
procedure TMF.Button2Click(Sender: TObject);
begin
  if (CheckBox1.Checked=false) and (CheckBox2.Checked=false) then
  begin
    Application.Messagebox('請選取欲執行之動作..','提示',MB_OK+MB_ICONINFORMATION);
    exit;
  end;
  if ComboBox1.Text='' then
  begin
    Application.Messagebox('請選取自動執行之時間..','提示',MB_OK+MB_ICONINFORMATION);
    exit;
  end;
  if iPageCount=1 then
  begin
    if (ListBox1.Items.Count=0) or (LabeledEdit1.Text='') then
    begin
      Application.Messagebox('請添加檔案與選擇擺放位置..','提示',MB_OK+MB_ICONINFORMATION);
      exit;
    end;
    SpeedButton1.Enabled:=false;
    SpeedButton2.Enabled:=false;
    Button1.Enabled:=false;
  end;
  if iPageCount=2 then
  begin
    if (ListBox2.Items.Count=0) or (LabeledEdit2.Text='') then
    begin
      Application.Messagebox('請添加檔案與選擇擺放位置..','提示',MB_OK+MB_ICONINFORMATION);
      exit;
    end;
    SpeedButton4.Enabled:=false;
    SpeedButton5.Enabled:=false;
    Button6.Enabled:=false;
  end;
  if iPageCount=3 then
  begin
    if (LabeledEdit3.Text='') or (LabeledEdit4.Text='') then
    begin
      Application.Messagebox('請添加檔案資料夾與存放資料夾..','提示',MB_OK+MB_ICONINFORMATION);
      exit;
    end;
    Button7.Enabled:=false;
    Button8.Enabled:=false;
  end;
  PageControl1.Enabled:=false;
  ComboBox1.Enabled:=false;
  CheckBox1.Enabled:=false;
  CheckBox2.Enabled:=false;
  Button2.Enabled:=false;
  Button4.Enabled:=false;
  Timer1.Enabled:=true;
  Timer2.Enabled:=true;
  Panel2.Color:=clLime;
  Panel2.Caption:='稍等';
  iStateCount:=1;
  Button3.Enabled:=true;
end;

// -關閉自動備份- //
procedure TMF.Button3Click(Sender: TObject);
begin
  if iPageCount=1 then
  begin
    SpeedButton1.Enabled:=true;
    SpeedButton2.Enabled:=true;
    Button1.Enabled:=true;
  end;
  if iPageCount=2 then
  begin
    SpeedButton4.Enabled:=true;
    SpeedButton5.Enabled:=true;
    Button6.Enabled:=true;
  end;
  if iPageCount=3 then
  begin
    Button7.Enabled:=true;
    Button8.Enabled:=true;
  end;
  PageControl1.Enabled:=true;
  ComboBox1.Enabled:=true;
  CheckBox1.Enabled:=true;
  CheckBox2.Enabled:=true;
  Button2.Enabled:=true;
  Button4.Enabled:=true;
  Timer1.Enabled:=false;
  Timer2.Enabled:=false;
  Panel2.Color:=clRed;
  Panel2.Caption:='【停止】';
  Button3.Enabled:=false;
end;

// -單次備份- //
procedure TMF.Button4Click(Sender: TObject);
var
  i:Integer;
begin
  if (CheckBox1.Checked=false) and (CheckBox2.Checked=false) then
  begin
    Application.Messagebox('請選取欲執行之動作..','提示',MB_OK+MB_ICONINFORMATION);
    exit;
  end;
  if iPageCount=1 then
  begin
    if (ListBox1.Items.Count=0) or (LabeledEdit1.Text='') then
    begin
      Application.Messagebox('請添加檔案與選擇擺放位置..','提示',MB_OK+MB_ICONINFORMATION);
      exit;
    end;
    if CheckBox1.State=cbChecked then
    begin
      for i := 0 to ListBox1.Items.Count-1 do
      begin
        if not MoveData(PWideChar(ListBox1.Items[i]), PWideChar(LabeledEdit1.Text+'\'+ExtractFileName(ListBox1.Items[i]))) then
        begin
          WriteTxT('Move Files Once : Fail');
          exit;
        end;
      end;
      WriteTxT('Action Once : Success');
      ShowMessage('Success');
    end;
    if CheckBox2.State=cbChecked then
    begin
      for i := 0 to ListBox1.Items.Count-1 do
      begin
        if not CopyData(PWideChar(ListBox1.Items[i]), PWideChar(LabeledEdit1.Text+'\'+ExtractFileName(ListBox1.Items[i]))) then
        begin
          WriteTxT('Copy Files Once : Fail');
          exit;
        end;
      end;
      WriteTxT('Action Once : Success');
      ShowMessage('Success');
    end;
  end;
  if iPageCount=2 then
  begin
    if (ListBox2.Items.Count=0) or (LabeledEdit2.Text='') then
    begin
      Application.Messagebox('請添加檔案與選擇擺放位置..','提示',MB_OK+MB_ICONINFORMATION);
      exit;
    end;
    for i := 0 to ListBox2.Items.Count-1 do
    begin
      if CheckBox1.State=cbChecked then
      begin
        if not MoveData(PWideChar(LabeledEdit2.Text), PWideChar(ListBox2.Items[i]+'\'+ExtractFileName(LabeledEdit2.Text))) then
        begin
          WriteTxT('Move Files Once : Fail');
          ShowMessage('單次搬移 : Fail');
          exit;
        end;
      end else
      begin
        if not CopyData(PWideChar(LabeledEdit2.Text), PWideChar(ListBox2.Items[i]+'\'+ExtractFileName(LabeledEdit2.Text))) then
        begin
          WriteTxT('Copy Files Once : Fail');
          ShowMessage('單次複製 : Fail');
          exit;
        end;
      end;
    end;
    WriteTxT('Action Once : Success');
    ShowMessage('Success');
  end;
  if iPageCount=3 then
  begin
    if (LabeledEdit3.Text='') or (LabeledEdit4.Text='') then
    begin
      Application.Messagebox('請添加檔案資料夾與選擇擺放資料夾..','提示',MB_OK+MB_ICONINFORMATION);
      exit;
    end;
    if CheckBox1.State=cbChecked then
    begin
      if ActionAllFile(PWideChar(LabeledEdit3.Text+'\'), PWideChar(LabeledEdit4.Text+'\'),'1') then
      begin
        WriteTxT('Move Files Once : Fail');
        ShowMessage('單次搬移 : Fail');
        exit;
      end;
    end else
    begin
      if ActionAllFile(PWideChar(LabeledEdit3.Text+'\'), PWideChar(LabeledEdit4.Text+'\'),'2') then
      begin
        WriteTxT('Copy Files Once : Fail');
        ShowMessage('單次複製 : Fail');
        exit;
      end;
    end;
    WriteTxT('Backup Folder Once : Success');
    ShowMessage('單次資料夾備份 : Success');
  end;
end;

// -測試用- //
procedure TMF.Button5Click(Sender: TObject);
var
  Files, Directories: TArray<string>;
begin
  Files := TDirectory.GetFiles(LabeledEdit1.Text+'\');
  Directories := TDirectory.GetDirectories(LabeledEdit1.Text+'\');
  if (Length(Files) = 0) and (Length(Directories) = 0) then
    ShowMessage('資料夾內沒檔案!')
  else
  begin
    ShowMessage('File 有'+IntToStr(Length(Files))+'個,資料夾有'+IntToStr(Length(Directories))+'個');
  end;
  if not DeleteAssignFile(LabeledEdit1.Text+'\') then
    ShowMessage('Delete files Fail..')
  else
    ShowMessage('Delete files Success!');

end;

// -選擇檔案- //
procedure TMF.Button6Click(Sender: TObject);
var
  openDialog: TOpenDialog;
begin
  openDialog := TOpenDialog.Create(nil);
  if not openDialog.Execute then
    abort;
  LabeledEdit2.Text:= openDialog.FileName;
  FreeAndNil(openDialog);
end;

// -選擇欲copy/move之資料夾- //
procedure TMF.Button7Click(Sender: TObject);
var
  dir:String;
begin
  if not SelectDirectory('請選擇備份位置','',dir) then
    abort;
  LabeledEdit3.Text	:=dir;
end;

// -選擇目的資料夾(整個資料夾做move or copy)- //
procedure TMF.Button8Click(Sender: TObject);
var
  dir:String;
begin
  if not SelectDirectory('請選擇備份位置','',dir) then
    abort;
  LabeledEdit4.Text	:=dir;
end;

// -選搬移- //
procedure TMF.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.State=cbChecked then
  begin
    CheckBox2.State:=cbUnchecked;
  end;

end;

// -選複製- //
procedure TMF.CheckBox2Click(Sender: TObject);
begin
  if CheckBox2.State=cbChecked then
  begin
    CheckBox1.State:=cbUnchecked;
  end;
end;

// -初始化狀態- //
procedure TMF.FormCreate(Sender: TObject);
begin
  iStateCount:=0;
  sCurrentDate:='';
  iPageCount:=1;

end;

// -選擇欲copy/move的檔案- //
procedure TMF.SpeedButton1Click(Sender: TObject);
var
  openDialog: TOpenDialog;
begin
  openDialog := TOpenDialog.Create(nil);
  if not openDialog.Execute then
    abort;
  ListBox1.Items.Add(openDialog.FileName);
  FreeAndNil(openDialog);
end;

// -刪除所選取之檔案- //
procedure TMF.SpeedButton2Click(Sender: TObject);
begin
  ListBox1.DeleteSelected;
end;

// -程式說明- //
procedure TMF.SpeedButton3Click(Sender: TObject);
begin
  ShellExecute(0, pchar('open'), pchar(ExtractFilePath(Application.Exename) + 'OperationManual.txt'), nil, nil, SW_SHOWNORMAL);
end;

// -同上(ListBox2)- //
procedure TMF.SpeedButton4Click(Sender: TObject);
begin
  ListBox2.DeleteSelected;
end;

// -添加存放資料夾位置- //
procedure TMF.SpeedButton5Click(Sender: TObject);
var
  dir:String;
begin
  if not SelectDirectory('請選擇備份位置','',dir) then
    abort;
  ListBox2.Items.Add(dir);
end;

// -路徑交換- //
procedure TMF.SpeedButton6Click(Sender: TObject);
var
  a,b:String;
begin
  a:=LabeledEdit3.Text;
  b:=LabeledEdit4.Text;
  LabeledEdit3.Text:=b;
  LabeledEdit4.Text:=a;
end;

// -顯示程式狀態用- //
procedure TMF.Timer1Timer(Sender: TObject);
begin
  case iStateCount of
    1:
    begin
      Panel2.Caption:='.【運作中】.';
      inc(iStateCount);
    end;
    2:
    begin
      Panel2.Caption:='..【運作中】..';
      inc(iStateCount);
    end;
    3:
    begin
      Panel2.Caption:='...【運作中】...';
      iStateCount:=1;
    end;
  end;

end;

// -自動備份相關動作- //
procedure TMF.Timer2Timer(Sender: TObject);
var
  i:Integer;
begin
  if FormatDateTime('yyyy-mm-dd',now)<>sCurrentDate then
  begin
    if (FormatDateTime('hh',now)=ComboBox1.Text) then
    begin
      case iPageCount of
        1:
        begin
          for i := 0 to ListBox1.Items.Count-1 do
          begin
            if CheckBox1.State=cbChecked then
            begin
              if not MoveData(PWideChar(ListBox1.Items[i]), PWideChar(LabeledEdit1.Text+'\'+ExtractFileName(ListBox1.Items[i]))) then
              begin
                WriteTxT('Auto Move Files : Fail');
                exit;
              end;
            end else
            begin
              if not CopyData(PWideChar(ListBox1.Items[i]), PWideChar(LabeledEdit1.Text+'\'+ExtractFileName(ListBox1.Items[i]))) then
              begin
                WriteTxT('Auto Copy Files : Fail');
                exit;
              end;
            end;
          end;
          WriteTxT('Auto Backup : Success');
          sCurrentDate:=FormatDateTime('yyyy-mm-dd',now);
        end;
        2:
        begin
          for i := 0 to ListBox2.Items.Count-1 do
          begin
            if not CopyData(PWideChar(LabeledEdit2.Text), PWideChar(ListBox2.Items[i]+'\'+ExtractFileName(LabeledEdit2.Text))) then
            begin
              WriteTxT('Auto Backup : Fail');
              exit;
            end;
          end;
          WriteTxT('Auto Backup : Success');
          sCurrentDate:=FormatDateTime('yyyy-mm-dd',now);
        end;
        3:
        begin
          if CheckBox1.State=cbChecked then
          begin
            if ActionAllFile(PWideChar(LabeledEdit3.Text+'\'), PWideChar(LabeledEdit4.Text+'\'),'1') then
            begin
              WriteTxT('Auto Move Files : Fail');
              exit;
            end;
          end else
          begin
            if ActionAllFile(PWideChar(LabeledEdit3.Text+'\'), PWideChar(LabeledEdit4.Text+'\'),'2') then
            begin
              WriteTxT('Auto Copy Files : Fail');
              exit;
            end;
          end;
          WriteTxT('Auto Backup Folder : Success');
          sCurrentDate:=FormatDateTime('yyyy-mm-dd',now);
        end;
      end;
    end;
  end;

end;

end.
