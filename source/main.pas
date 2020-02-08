unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  epub;

type

  { TForm1 }

  TForm1 = class(TForm)
    LoadEpubButton: TButton;
    CoverImage: TImage;
    IdentifierEdit: TLabeledEdit;
    epubDialog: TOpenDialog;
    TitleEdit: TLabeledEdit;
    LanguageEdit: TLabeledEdit;
    CreatorEdit: TLabeledEdit;
    DateEdit: TLabeledEdit;
    PublisherEdit: TLabeledEdit;
    RightsEdit: TLabeledEdit;
    SubjectEdit: TLabeledEdit;
    epub: TEpubHandler;
    procedure LoadEpubButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UpdateFormData;
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  epub := TEpubHandler.Create(nil);
end;

procedure TForm1.UpdateFormData;
begin
  IdentifierEdit.Text := epub.MetaData.identifier;
  TitleEdit.Text := epub.MetaData.title;
  LanguageEdit.Text := epub.MetaData.language;
  CreatorEdit.Text := epub.MetaData.creator;
  DateEdit.Text := epub.MetaData.date;
  PublisherEdit.Text := epub.MetaData.publisher;
  RightsEdit.Text := epub.MetaData.rights;
  SubjectEdit.Text := epub.MetaData.subject;
  CoverImage.Picture.LoadFromFile(epub.coverImage);
end;

procedure TForm1.LoadEpubButtonClick(Sender: TObject);
begin
  if epubDialog.Execute then begin
    epub.loadFromFile(epubDialog.FileName);
    UpdateFormData;
  end;
end;

end.

