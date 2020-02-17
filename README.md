# fpc-epub
FreePascal/Lazarus unit for pulling metadata out of ePub files

## Use
1. Add `epub_pk` package to your project
2. Add `epub` to your `uses` clause
3. Initialize `epub := TEpubHandler.Create;`
4. Load an ePub file ` epub.LoadFromFile('path/to/file');`
5. Extract some data `epub.MetaData.title`

## Available Metadata
* identifier
* title
* language
* creator
* date
* publisher
* rights
* subject
* coverImage

## Example application
Source folder contains a Lazarus example project.

<img src="epubInspector.PNG" />
