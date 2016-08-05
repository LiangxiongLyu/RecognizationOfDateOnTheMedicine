unit MDIChild;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TChild = class(TForm)
    Image: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Child: TChild;

implementation

{$R *.dfm}

procedure TChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Action := caFree;
end;

end.
