{
  Author    Marcus Fernström
  Version   0.1
  License   Apache 2.0
  GitHub    https://github.com/MFernstrom/fpc-epub
}

unit epub;

{$mode objfpc}{$H+}{$J-}

interface

uses
  Classes, SysUtils, Zipper, StdCtrls, laz2_DOM, laz2_XMLRead;

type

  { TMetaDataClass }

  TMetaDataClass = class(TComponent)
    private
      Fidentifier: String;
      Ftitle: String;
      Flanguage: String;
      Fcreator: String;
      Fdate: String;
      Fpublisher: String;
      Frights: String;
      Fsubject: String;
    public
      property identifier: String read Fidentifier write Fidentifier;
      property title: String read Ftitle write Ftitle;
      property language: String read Flanguage write Flanguage;
      property creator: String read Fcreator write Fcreator;
      property date: String read Fdate write Fdate;
      property publisher: String read Fpublisher write Fpublisher;
      property rights: String read Frights write Frights;
      property subject: String read Fsubject write Fsubject;
  end;

  { TEpubClass }

  TEpubClass = class(TComponent)
    private
      FFilePath: String;
      FUnpackedFilePath: String;
      FRootFile: String;
      FMetaData: TMetaDataClass;
      FcoverImage: String;
      FDoc: TXMLDocument;
      RootFileNode: TDOMNode;
      procedure unpackEpub(path:String);
      procedure setMetaData;
      procedure clearData;
      function setRootFile:Boolean;
    public
      property MetaData:TMetaDataClass read FMetaData write FMetaData;
      procedure load(path:String);
      property coverImage: String read FcoverImage write FcoverImage;
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
  end;

implementation

{ TEpubClass }

procedure TEpubClass.unpackEpub(path: String);
var
  UnZipper: TUnZipper;
begin
  try
    FFilePath := path;
    UnZipper := TUnZipper.Create;
    UnZipper.FileName := FFilePath;
    UnZipper.OutputPath := FUnpackedFilePath;
    UnZipper.Examine;
    UnZipper.UnZipAllFiles;
  finally
    UnZipper.Free;
  end;
end;


procedure TEpubClass.setMetaData;
var
  Child: TDOMNode;
begin
  ReadXMLFile(FDoc, FUnpackedFilePath + DirectorySeparator + FRootFile);

  RootFileNode := FDoc.DocumentElement.FirstChild;
  Child := RootFileNode.FirstChild;

  while Assigned(child) do begin
    if Child.HasChildNodes then begin
      case Child.NodeName of
        'dc:identifier': MetaData.identifier := Child.FirstChild.NodeValue;
        'dc:title': MetaData.title := Child.FirstChild.NodeValue;
        'dc:language': MetaData.language := Child.FirstChild.NodeValue;
        'dc:creator': MetaData.creator := Child.FirstChild.NodeValue;
        'dc:date': MetaData.date := Child.FirstChild.NodeValue;
        'dc:publisher': MetaData.publisher := Child.FirstChild.NodeValue;
        'dc:rights': MetaData.rights := Child.FirstChild.NodeValue;
        'dc:subject': MetaData.subject := Child.FirstChild.NodeValue;
      end;
    end;
    Child := Child.NextSibling;
  end;

  RootFileNode := RootFileNode.NextSibling;
  Child := RootFileNode.FirstChild;

  while Assigned(child) do begin
    if Child.Attributes.GetNamedItem('id').NodeValue = 'cover-image' then
      coverImage := FUnpackedFilePath + DirectorySeparator + 'OEBPS' + DirectorySeparator + Child.Attributes.GetNamedItem('href').NodeValue;

    Child := Child.NextSibling;
  end;
end;


procedure TEpubClass.clearData;
begin
  FFilePath := '';
  FRootFile := '';
  FcoverImage := '';
  MetaData.identifier := '';
  MetaData.title := '';
  MetaData.language := '';
  MetaData.creator := '';
  MetaData.date := '';
  MetaData.publisher := '';
  MetaData.rights := '';
  MetaData.subject := '';
end;


function TEpubClass.setRootFile:Boolean;
begin
  try
    ReadXMLFile(FDoc, FUnpackedFilePath + '/META-INF/container.xml');
    RootFileNode := FDoc.DocumentElement.FirstChild;
    RootFileNode := RootFileNode.FirstChild;

    if RootFileNode.Attributes.Item[0].NodeName = 'full-path' then
      FRootFile := RootFileNode.Attributes.Item[0].NodeValue;

    Result := true;

  except
    on E:Exception do
      Result := false;
  end;
end;


procedure TEpubClass.load(path: String);
begin
  clearData;
  unpackEpub(path);
  setRootFile;
  setMetaData;
end;

constructor TEpubClass.Create(AOwner: TComponent);
begin
  inherited;
  FUnpackedFilePath := GetTempDir(true) + 'fpepub';
  MetaData := TMetaDataClass.Create(nil);
end;

destructor TEpubClass.Destroy;
begin
  FreeAndNil(FMetaData);
  inherited Destroy;
end;

end.

