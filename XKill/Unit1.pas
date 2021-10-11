unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, tlhelp32, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
  public
    { Public declarations }
  end;

const
  MyHotKey = ord(VK_F4);
  
var
  Form1: TForm1;

implementation

{$R *.dfm}

function ProcessTerminate(dwPID: Cardinal): Boolean;
var
  hToken:THandle;
  SeDebugNameValue:Int64;
  tkp:TOKEN_PRIVILEGES;
  ReturnLength:Cardinal;
  hProcess:THandle;
begin
  Result:=false;
  if not OpenProcessToken(GetCurrentProcess(),
           TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
           hToken)
  then exit;
  if not LookupPrivilegeValue(nil, 'SeDebugPrivilege', SeDebugNameValue) then begin
    CloseHandle(hToken);
    exit;
  end;
  tkp.PrivilegeCount:= 1;
  tkp.Privileges[0].Luid := SeDebugNameValue;
  tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
  AdjustTokenPrivileges(hToken,false,tkp,SizeOf(tkp),tkp,ReturnLength);
  if GetLastError()<> ERROR_SUCCESS then exit;
  hProcess := OpenProcess(PROCESS_TERMINATE, FALSE, dwPID);
  if hProcess = 0 then exit;
  if not TerminateProcess(hProcess, DWORD(-1)) then exit;
  CloseHandle( hProcess );
  tkp.Privileges[0].Attributes := 0;
  AdjustTokenPrivileges(hToken, FALSE, tkp, SizeOf(tkp), tkp, ReturnLength);
  if GetLastError() <>  ERROR_SUCCESS then exit;
  Result:=true;
end;

procedure TForm1.WMHotKey(var Msg: TWMHotKey);
var
 hWindow: HWnd;
 r: TRect;
 NIX: Hwnd;
 P: TPoint;
 X: Cardinal;
begin
 hWindow:=GetForegroundWindow;
 GetWindowThreadProcessId(hWindow, X);
 ProcessTerminate(X);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 RegisterHotKey(Form1.Handle, MyHotKey, 0, MyHotKey);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
 UnRegisterHotKey(Form1.Handle, MyHotKey);
end;

end.
