{
  Author    Marcus Fernström
  Version   0.2
  License   Apache 2.0
  GitHub    https://github.com/MFernstrom/fpc-epub
}

unit epub;

{$mode objfpc}{$H+}{$J-}{$M+}

interface

uses
  Classes, SysUtils, Zipper, laz2_DOM, laz2_XMLRead;

type

  { TEpubMetaData }

  TEpubMetaData = class(TObject)
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

  { TEpubHandler }

  TEpubHandler = class(TObject)
    private
      FFilePath: String;
      FUnpackedFilePath: String;
      FRootFile: String;
      FMetaData: TEpubMetaData;
      FcoverImage: String;
      FDoc: TXMLDocument;
      RootFileNode: TDOMNode;
      procedure unpackEpub(const path:String);
      procedure setMetaData;
      procedure clearData;
      function setRootFile:Boolean;
    public
      property MetaData:TEpubMetaData read FMetaData write FMetaData;
      procedure loadFromFile(const path:String);
      property coverImage: String read FcoverImage write FcoverImage;
      constructor Create;
      destructor Destroy; override;
  end;

implementation

{ TEpubHandler }

procedure TEpubHandler.unpackEpub(const path: String);
var
  UnZipper: TUnZipper;
begin
  FFilePath := path;
  UnZipper := TUnZipper.Create;

  try
    UnZipper.FileName := FFilePath;
    UnZipper.OutputPath := FUnpackedFilePath;
    UnZipper.Examine;
    UnZipper.UnZipAllFiles;
  finally
    UnZipper.Free;
  end;
end;


procedure TEpubHandler.setMetaData;
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


procedure TEpubHandler.clearData;
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


function TEpubHandler.setRootFile:Boolean;
begin
  Result := false;

  try
    ReadXMLFile(FDoc, FUnpackedFilePath + DirectorySeparator + 'META-INF' + DirectorySeparator + 'container.xml');
    RootFileNode := FDoc.DocumentElement.FirstChild;
    RootFileNode := RootFileNode.FirstChild;

    if RootFileNode.Attributes.Item[0].NodeName = 'full-path' then
      FRootFile := RootFileNode.Attributes.Item[0].NodeValue;

    Result := true;
  except
  end;
end;


procedure TEpubHandler.loadFromFile(const path: String);
begin
  clearData;
  unpackEpub(path);
  setRootFile;
  setMetaData;
end;

constructor TEpubHandler.Create;
begin
  FUnpackedFilePath := GetTempDir(true) + 'fpepub';
  MetaData := TEpubMetaData.Create;
end;

destructor TEpubHandler.Destroy;
begin
  FreeAndNil(FMetaData);
  inherited Destroy;
end;

end.

