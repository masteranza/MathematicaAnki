(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



(* ::Input::Initialization:: *)
BeginPackage["AnkiExporter`",{"PackageUtils`"}];
ExportToAnki::usage ="Function exporting selected sections of the notebook to Anki using cloze notes";
AnkiRequest::usage="Pass Action and param (Anki Connect)";
PrepareAnkiNote::usage="Deck name then for params and tags (opt)";
AddOrUpdateNotes::usage="Deck name then all notes";

Begin["`Private`"];
AnkiRequest[action_,params_:<||>]:=
Block[{req,json},
PrintToConsole[params];
json=ImportString[ExportString[<|"action"->action,"version"->6,"params"->params|>,"JSON","Compact"->False],"Text"];
PrintToConsole[json];
req=HTTPRequest[<|"Scheme"->"http","Domain"->"localhost","Port"->8765,Method -> "POST","Body"->json|>];
URLRead[req,"Body"]
];
PrepareAnkiNote[deckName_,cellID_,clozed_,title_,link_,tags_:{}]:={"deckName"->deckName,"modelName"->"MathematicaCloze","fields"->{"CellID"->ToString[cellID],"Text"->clozed,"Extra"->title,"Link"->link},"options"->{"allowDuplicate"->False},"tags"->tags};
AddOrUpdateNotes[deck_,rawNotes_]:=Block[{res,resi,toUpdate,ids,ankiIds},
res=(ImportString[AnkiRequest["addNotes",{"notes"->(PrepareAnkiNote[deck,#[[1]],#[[2]],#[[3]],#[[4]],#[[5]]]&/@rawNotes)}],"JSON"]);
(*PrintToConsole[ImportString[AnkiRequest["multi",{"actions"\[Rule]({"action"->"addNote","params"\[Rule]{"note"\[Rule]PrepareAnkiNote[deck,#[[1]],#[[2]],#[[3]],#[[4]],#[[5]]]}}&/@rawNotes)}],"JSON"]];*)
PrintToConsole[res];
res=("result"/.res);
toUpdate=#[[2]]&/@Select[Thread[{res,rawNotes}],#[[1]]==Null&];
PrintToConsole["Need to update "<>ToString[Length[toUpdate]]<> " notes"];
If[Length[toUpdate]>0,
res={"actions"->({"action"->"findNotes","params"->{"query"->"CellID:"<>ToString[#[[1]]]}}&/@toUpdate)};
ankiIds=#[[1]]&/@("result"/.ImportString[AnkiRequest["multi",res],"JSON"]);

toUpdate=Thread[{ankiIds,toUpdate}];
PrintToConsole[ankiIds];
PrintToConsole[toUpdate];
res={"actions"->({"action"->"updateNoteFields","params"->{"note"->{"id"->ToString[#[[1]]],"deckName"->deck,"modelName"->"MathematicaCloze","fields"->{"CellID"->ToString[#[[2,1]]],"Text"->#[[2,2]],"Extra"->#[[2,3]],"Link"->#[[2,4]]},"options"->{"allowDuplicate"->False}}}}&/@toUpdate)};
ImportString[AnkiRequest["multi",res],"JSON"]];
(*PrintToConsole[ImportString[AnkiRequest["updateNoteFields",{"note"\[Rule]{"id"\[Rule]#[[1]],"fields"\[Rule]{"CellID"\[Rule]ToString[#[[2,1]]],"Text"\[Rule]#[[2,2]],"Extra"\[Rule]#[[2,3]],"Link"\[Rule]#[[2,4]]}}}],"JSON"]]&/@toUpdate;*)
(*PrintToConsole[ImportString[AnkiRequest["notesInfo",{"notes"\[Rule]toUpdate[[All,1]]}],"JSON"]];*)
];

ExportToAnki[sync_:True]:=Module[{separator,styleTags,cells,sections,subsections,subsubsections,subsubsubsections,allinfo,cellids,celltags,data,ids,cloze,matchEq,encoding,eqCloze,GetTOC,exported,filtered,splited,marked,paths,fixed,final,threaded,deck,title, base,dat,ndir,tempPicPath, allspecial,npath},
separator="#";
ShowStatus["Export starts"];
PrintToConsole["Export starts"];
TeXForm[1];
(*System`Convert`TeXFormDump`maketex["\[LeftSkeleton]"]="\\ll ";
System`Convert`TeXFormDump`maketex["\[RightSkeleton]"]="\\gg ";*)
System`Convert`TeXFormDump`maketex["\[OAcute]"]="\[OAcute]";
System`Convert`TeXFormDump`maketex["\[CloseCurlyQuote]"]="'";
System`Convert`TeXFormDump`maketex["\:015b"]="\:015b";
System`Convert`TeXFormDump`maketex["\[CAcute]"]="\[CAcute]";
System`Convert`TeXFormDump`maketex["\:0119"]="\:0119";
System`Convert`TeXFormDump`maketex["\:0105"]="\:0105";
System`Convert`TeXFormDump`maketex["\[LSlash]"]="\[LSlash]";
System`Convert`TeXFormDump`maketex["\:017c"]="\:017c";
System`Convert`TeXFormDump`maketex["\:017a"]="\:017a";
(*System`Convert`TeXFormDump`maketex["&"]="\\$ ";*)
System`Convert`TeXFormDump`maketex["~"]="\\sim ";
(*nie zamieniaj zwyk\[LSlash]ego tekstu*)
System`Convert`CommonDump`ConvertTextData[contents_String,toFormat_,toFormatStream_,conversionRules_,opts___?OptionQ]:=Module[{fpre,frule,fpost,pstyle,popts,str=contents},System`Convert`CommonDump`DebugPrint["CONVERTCOMMON:ConvertTextData-general content: ",contents];
pstyle=System`Convert`CommonDump`ParentCellStyle/.{opts}/.System`Convert`CommonDump`ParentCellStyle->"";
popts=Flatten[System`Convert`CommonDump`ParentOptions/.List/@{opts}/.System`Convert`CommonDump`ParentOptions->{}];
System`Convert`CommonDump`DebugPrint["pstyle: ",pstyle];
{fpre,frule,fpost}=System`Convert`CommonDump`ConvertFormatRule[pstyle/.conversionRules,False];
System`Convert`CommonDump`DebugPrint["{fpre, frule, fpost}: ","InputForm"[{fpre,frule,fpost}]];
If[frule===Automatic,frule=System`Convert`CommonDump`ConvertText[#1,toFormat,opts]&];
If[!(System`Convert`CommonDump`ShowQuotesQ[pstyle]||TrueQ[System`Convert`CommonDump`ShowQuotes/.Flatten[{opts}]]||TrueQ[ShowStringCharacters/.popts]),str=System`Convert`CommonDump`RemoveQuotes[str]];
System`Convert`CommonDump`DebugPrint["str: ",frule];
(*If[!TrueQ[System`Convert`CommonDump`ConvertText/.Flatten[{opts}]],str=frule[str]];*)
System`Convert`CommonDump`DebugPrint["str: ",str];
System`Convert`CommonDump`DebugPrint["CONVERTCOMMON-ConvertTextData.  Writing the string. HIJACK"];
System`Convert`CommonDump`DebugPrint["------------------------------------------"];
WriteString[toFormatStream,str];];
(*przekieruj zwyk\[LSlash]y tekst*)
System`Convert`CommonDump`ConvertTextData[contents_,toFormat_,toFormatStream_,conversionRules_,others___]:=Module[{cell},
If[MatchQ[contents,Anki[_,_String]],WriteString[toFormatStream,contents/.{Anki[nr_,s_String]:>("{{c"<>ToString[nr]<>"::"<>StringReplace[s,"}}"->"} }"]<>" }} ")}];,
System`Convert`CommonDump`DebugPrint["CONVERTCOMMON-ConvertTextData of unknown content: ",contents];
cell=Cell[BoxData[contents],""];
System`Convert`CommonDump`PreConvertCell[cell,toFormat,toFormatStream,conversionRules,(*System`Convert`CommonDump`*)inlineCell->True,others];
System`Convert`CommonDump`ConvertCell[cell,toFormat,toFormatStream,conversionRules,(*System`Convert`CommonDump`*)inlineCell->True,others];
System`Convert`CommonDump`PostConvertCell[cell,toFormat,toFormatStream,conversionRules,(*System`Convert`CommonDump`*)inlineCell->True,others];]];
(*blokowanie zamiany na unicode wrappers - raczej nie potrzebne*)
(*System`Convert`TeXFormDump`maketex[str_String /; StringLength[str] === 1] := (System`Convert`CommonDump`DebugPrint["------------------------------------"];
    	System`Convert`CommonDump`DebugPrint["maketex[str_String/;(StringLength@str===1)]"];
    	System`Convert`CommonDump`DebugPrint["str: ", str];
  str  	
(*If[$Language === "Japanese" || 
        MemberQ[{"ShiftJIS", "EUC"}, $CharacterEncoding], str, 
      "\\unicode{" <> System`Convert`TeXFormDump`ToCharacterHexCode[str] <> "}"]*));*)

(*Anki markup*)
System`Convert`TeXFormDump`maketex[Anki[nr_,boxes_]]:=(System`Convert`CommonDump`DebugPrint["------------------------------------"];
System`Convert`CommonDump`DebugPrint["maketex[Anki[nr_, boxes__]]"];
System`Convert`CommonDump`DebugPrint["boxes: ",boxes];
If[StringQ[boxes],"{{c"<>ToString[nr]<>"::"<>StringReplace[boxes,"}}"->"} }"]<>" }} ",
"{{c"<>ToString[nr]<>"::"<>StringReplace[System`Convert`TeXFormDump`MakeTeX[boxes],"}}"->"} }"]<>" }} "]);

ShowStatus["Export to Anki begins..."];
If[NotebookDirectory[]===$Failed,ShowStatus["Nothing to export"]; Abort[]];
tempPicPath=Quiet@Check[CreateDirectory["~/Dropbox/Anki/Ranza/collection.media/",CreateIntermediateDirectories-> True],"~/Dropbox/Anki/Ranza/collection.media/",CreateDirectory::filex];

FixStrings[data_]:=StringReplace[data,{"\[Lambda]":>"\(\\lambda\)","\[Dash]":>"-","\[Rule]":>"\(\\rightarrow\)"}];
TeXFix[what_]:=StringReplace[what,{"\)}}\(\)"-> "\)}}",("\\text{"~~c:Except["}"]..~~"}"):>(ToString@c)}];
TeXFixPoor[what_]:=StringReplace[what,{"\)}}\(\)"-> "\)}}"}];
EncodingFix[what_]:=FromCharacterCode[ToCharacterCode[what],"UTF8"];
ToTex[what_,n_:1]:=Convert`TeX`BoxesToTeX[what, "BoxRules"->{
"\[Transpose]":>"^{\\mathsf{T}}",
"\[ConjugateTranspose]":>"^{\\dagger} ",
"\[HermitianConjugate]":>"^{\\dagger} ",
"\[Conjugate]":>"^{*} ",
"\[OAcute]":> "\[OAcute]",
"\[CapitalOAcute]":> "\[CapitalOAcute]",
"\:015b":> "\:015b",
"\:015a":> "\:015a",
"\[CAcute]":> "\[CAcute]",
"\[CapitalCAcute]":> "\[CapitalCAcute]",
"\:0119":> "\:0119",
"\:0118":> "\:0118",
"\:0105":> "\:0105",
"\:0104":> "\:0104",
"\[LSlash]":> "\[LSlash]",
"\[CapitalLSlash]":> "\[CapitalLSlash]",
"\:017c":> "\:017c",
"\:017b":> "\:017b",
"\:017a":>"\:017a",
"\:0179":>"\:0179",
"\:0144":>"\:0144",
"\:0143":>"\:0143",

FormBox[GraphicsBox[{C__},E___,ImageSize->D_],__]|GraphicsBox[{C__},E___,ImageSize->D_]:>("\\includegraphics[natwidth="<>ToString[(First@D)/4]<>",natheight="<>ToString[(First@D)/4]<>"]{"<>FileNameTake@Export[tempPicPath<>"f"<>ToString[Hash[Graphics[{C},E]]]<>".png",Graphics[{C},E],ImageSize->{First@D,First@D}]<>"} "),
FormBox[GraphicsBox[___],___]:> "",
GraphicsBox[___]:> "",

StyleBox[D_,Background->LightGreen]:>"\\color[HTML]{1111FF}{{c"<>ToString[n]<>"::"<>StringReplace[ToTex[D],{"{{":>" { { ","}}":>" } } "}]<>" }}\\color[HTML]{000000}"}];
cells=Cells[EvaluationNotebook[],CellStyle->{"Text","EquationNumbered","Equation","Figure","Item1","Item2","Item3","Item1Numbered","Item2Numbered","Item3Numbered","Example","Exercise","Solution","Question","Remark","Comment","Theorem","Proof","Axiom","Definition","Lemma","FunFact"}];
title=First@(Cases[NotebookGet@EvaluationNotebook[],Cell[name_,style:"Title",___]:>name,Infinity]/.{}-> {""});
ShowStatus["Gathering section info..."];
sections=CurrentValue[#,{"CounterValue","Section"}]&/@cells;
subsections=CurrentValue[#,{"CounterValue","Subsection"}]&/@cells;
subsubsections=CurrentValue[#,{"CounterValue","Subsubsection"}]&/@cells;
subsubsubsections=CurrentValue[#,{"CounterValue","Subsubsubsection"}]&/@cells;

celltags=Riffle[If[MatchQ[CurrentValue[#,{"CellTags"}],_String],{CurrentValue[#,{"CellTags"}]},CurrentValue[#,{"CellTags"}]]," "]&/@cells;

allinfo=DeleteCases[Replace[Thread[{sections,subsections,subsubsections,subsubsubsections}],{x___,0...}:>{x},1],0,2];
ShowStatus["Gathering table of contents"];
GetTOC=Cases[NotebookGet@EvaluationNotebook[],Cell[name_,style:"Section"|"Subsection"|"Subsubsection"|"Subsubsubsection",___]:>{style,Convert`TeX`BoxesToTeX[ name,"BoxRules"->{D_String:>D}]},Infinity]/.{"Subsubsubsection",x_}:>x[]//.
{x___,{"Subsubsection",y_},z:Except[_List]...,w:PatternSequence[{_,_},___]|PatternSequence[]}:>{x,y[z],w}//.{x___,{"Subsection",y_},z:Except[_List]...,w:PatternSequence[{_,_},___]|PatternSequence[]}:>{x,y[z],w}//.{x___,{"Section",y_},z:Except[_List]...,w:PatternSequence[{_,_},___]|PatternSequence[]}:>{x,y[z],w};
ShowStatus["Preparing paths..."];
paths=(title<>"/"<>Riffle[Head/@(GetTOC[[#/.List->Sequence]]&/@Reverse@NestList[Most,#,Length[#]-1]),"/"])&/@allinfo;
ShowStatus["Extracting data... (1/3)"];
base=StringReplace[StringReplace[ImportString[ExportString[n=0;Replace[NotebookRead[#],{StyleBox[C_String,Background->RGBColor[0.88, 1, 0.88]]:>(n+=1;Anki[n,C]),StyleBox[C___,Background->RGBColor[0.88, 1, 0.88],D___]:>(n+=1;Anki[n,StyleBox[C,D]]), Cell[C___,Background->RGBColor[0.88, 1, 0.88],D___]:>(n+=1;Anki[n,Cell[C,D]])},Infinity],"TeXFragment"],
"Text"],{"\\)\\("->""}],{"}}"~~WhitespaceCharacter...~~"{{c"~~Shortest[___]~~"::"->"","}}"~~WhitespaceCharacter...~~"\\({{c"~~Shortest[___]~~"::"~~Shortest[c__]~~"}}\\)":>("\\("<>c<>"\\)}}"),
(*enters in eqs*)"}}"~~WhitespaceCharacter...~~"\\)"~~WhitespaceCharacter...~~"
"~~WhitespaceCharacter...~~"\\("~~WhitespaceCharacter...~~"{{c"~~Shortest[__]~~"::"->" \\\\ "}]&/@cells;
(*PrintToConsole[base];*)
(*
dat=Block[{n=1},ReplaceRepeated[data,
{
ButtonBox[DynamicBox[C_,___],___]\[RuleDelayed] Evaluate@C,
ButtonBox[RowBox[C__],___]\[RuleDelayed] C,
CounterBox["FigureCaptionNumbered",N_]\[RuleDelayed] (First@Cases[data,Cell[TextData[name__],___,"Figure",___,CellTags\[Rule]N,___]\[RuleDelayed]name,Infinity]),
CounterBox["EquationNumbered",N_]\[RuleDelayed] ("\("<>ToTex[First@Cases[data,Cell[name_,___,CellTags\[Rule]N,___]\[RuleDelayed]name,Infinity]]<>"\) "),
CounterBox[___]\[RuleDelayed]"",
StyleBox[D__,Background\[Rule]None,E___]\[RuleDelayed]StyleBox[D,E],
StyleBox[D_String]\[RuleDelayed]D,
RowBox[{C__String}]\[RuleDelayed]StringJoin@C,
Cell[TextData[data_],style_,___, CellID\[Rule]Nr_Integer]\[RuleDelayed] {Nr ,data,style},
Cell[BoxData[data_],style_,___, CellID\[Rule]Nr_Integer]\[RuleDelayed] {Nr ,data,style},
Cell[data_,style_,___, CellID\[Rule]Nr_Integer]\[RuleDelayed] {Nr ,data,style},
Cell[BoxData[data_],___]\[RuleDelayed] data
}]];
ShowStatus["Extracting data... (2/3)"];
PrintToConsole["Identified Ank collection folder "<>tempPicPath];
dat=Block[{pic=0},ReplaceAll[dat,{
FormBox[GraphicsBox[{C__,{FaceForm[{RGBColor[0.88,1,0.88],Opacity[0.6]}],R__RectangleBox},D___},E___],__]|GraphicsBox[{C__,{FaceForm[{RGBColor[0.88,1,0.88],Opacity[0.6]}],R__RectangleBox},D___},E___]\[RuleDelayed]"{{c1::<img src=\""<>FileNameTake@Export[tempPicPath<>"f"<>ToString[++pic]<>ToString[Hash[Graphics[{C,{FaceForm[{RGBColor[0.88,1,0.88],Opacity[1.0]}],R},D},E]]]<>"a.png",Cell[BoxData[GraphicsBox[{C,D},E]]]]<>"\">::<img src=\""<>FileNameTake@Export[tempPicPath<>"f"<>ToString[pic]<>ToString[Hash[Graphics[{C,{FaceForm[{RGBColor[0.88,1,0.88],Opacity[1.0]}],R},D},E]]]<>".png",Cell[BoxData[GraphicsBox[{C,{FaceForm[{RGBColor[0.88,1,0.88],Opacity[1.0]}],R},D},E]]]]<>"\">}}",
FormBox[FormBox[C__],___]\[RuleDelayed] C,
(FormBox[C__, TraditionalForm]|FormBox[C__, TextForm])\[RuleDelayed]("\("<>ToTex[C]<>"\) "),
FormBox[GraphicsBox[___],___]\[RuleDelayed] "",GraphicsBox[___]\[RuleDelayed] "",
FormBox[RowBox[{E___,TraditionalForm}],___]\[RuleDelayed] FormBox[RowBox[{E}],TraditionalForm]
}]];
ShowStatus["Extracting data... (3/3)"];
dat=Block[{n=1},ReplaceAll[dat,{
(FormBox[RowBox[{C__String}],TextForm]|FormBox[RowBox[{C__String}],TraditionalForm])\[RuleDelayed]StringJoin@C,
(FormBox[C__, TraditionalForm]|FormBox[C__, TextForm])\[RuleDelayed]("\("<>ToTex[C]<>"\) "),
StyleBox[D_,E___ ,Background\[Rule]LightGreen,F___]\[RuleDelayed]("{{c"<>ToString[n]<>"::"<>
ReplaceAll[StyleBox[D,E,F],{
StyleBox[U_String,___,FontWeight\[Rule]"Bold",___]\[RuleDelayed] ("<b>"<>U<>"</b>"),
StyleBox[U_String,___,FontSlant\[Rule]"Italic",___]\[RuleDelayed] ("<i>"<>U<>"</i>"),
StyleBox[U_String,___,FontWeight\[Rule]"Plain",___]\[RuleDelayed] U,
StyleBox[U_String,___,FontVariations\[Rule]{___,"Underline"\[Rule]True,___},___]\[RuleDelayed] ("<u>"<>U<>"</u>"),
StyleBox[U_String,___,FontVariations\[Rule]__,___]\[RuleDelayed] U,
StyleBox[U_String,___]\[RuleDelayed]U
}]<>"}}"),
StyleBox[D_String,___,FontWeight\[Rule]"Bold",___]\[RuleDelayed] ("<b>"<>D<>"</b>"),
StyleBox[D_String,___,FontSlant\[Rule]"Italic",___]\[RuleDelayed] ("<i>"<>D<>"</i>"),
StyleBox[D_String,___,FontWeight\[Rule]"Plain",___]\[RuleDelayed] D,
StyleBox[D_String,___,FontVariations\[Rule]{___,"Underline"\[Rule]True,___},___]\[RuleDelayed] ("<u>"<>D<>"</u>"),
StyleBox[D_String,___,FontVariations\[Rule]__,___]\[RuleDelayed] D,
StyleBox[D_, Background\[Rule]_]\[RuleDelayed]ToString[n],
RowBox[{C___String}]\[RuleDelayed]StringJoin@C
}]];*)
ShowStatus["Fixing data... (1/2)"];
ids=CurrentValue[#,"CellID"]&/@ cells;
(*base=(StringReplace[StringJoin[#[[2]]],{"\n"\[Rule] "<br>","\[LineSeparator]"\[Rule] "<br>"}])&/@ dat;*)
(*styleTags=(" "<>#[[3]]<>"::"<> StringReplace[title," "\[Rule] ""])&/@dat;*)
ShowStatus["Fixing data... (2/2)"];
base=StringReplace[base,{
("}}\\color[HTML]{000000}\\color[HTML]{1111FF}{{c"~~Shortest[c__]~~"::")->"",
"}}{{c"~~Shortest[c__]~~"::"->"",
"\(\)"->"",
"{{c1::}}"->"",
"\n"->"<br>",
"\n"->"<br>",
"{{c1::<br>}}"->"<br>",
("^{"~~Shortest[c__]~~"}^{"~~WhitespaceCharacter...~~"\\dagger"~~WhitespaceCharacter...~~"}")/;StringFreeQ[c,"}"|"{"]:>"^{"<>c<>"\\dagger}",
("^"~~c_~~"^{"~~WhitespaceCharacter...~~"\\dagger"~~WhitespaceCharacter...~~"}")/;StringFreeQ[c,"}"|"{"]:>"^{"<>c<>"\\dagger}",

("^{"~~Shortest[c__]~~"}^{\\mathsf{T}"~~WhitespaceCharacter...~~"}")/;StringFreeQ[c,"}"|"{"]:>"^{"<>c<>"\\mathsf{T}}",
("^"~~c_~~"^{"~~WhitespaceCharacter...~~"\\mathsf{T}"~~WhitespaceCharacter...~~"}")/;StringFreeQ[c,"}"|"{"]:>"^{"<>c<>"\\mathsf{T}}",

("^{"~~Shortest[c__]~~"}^{"~~WhitespaceCharacter...~~"*"~~WhitespaceCharacter...~~"}")/;StringFreeQ[c,"}"|"{"]:>"^{"<>c<>"*}",
("^"~~c_~~"^{"~~WhitespaceCharacter...~~"*"~~WhitespaceCharacter...~~"}")/;StringFreeQ[c,"}"|"{"]:>"^{"<>c<>"*}",

"\\overset{"~~WhitespaceCharacter...~~"\\mathsym{"~~WhitespaceCharacter...~~"\\OverBracket"~~WhitespaceCharacter...~~"}"~~WhitespaceCharacter...~~"}":> "\\overbrace",
"\\underset{"~~WhitespaceCharacter...~~"\\mathsym{"~~WhitespaceCharacter...~~"\\UnderBracket"~~WhitespaceCharacter...~~"}"~~WhitespaceCharacter...~~"}":> "\\underbrace",
(*,("\\text{"~~Shortest[c__]~~"}")\[RuleDelayed]ToString@StringReplace[c,{"$"\[RuleDelayed]  ""}] *)
"\\left\\left|"~~Shortest[c__]~~"\\right\\right|":> "\\left|"~~c ~~"\\right|",
"\\right\\right| "~~WhitespaceCharacter...~~"{}_":> "\\right|_",
"\\right\\right| "~~WhitespaceCharacter...~~"_":> "\\right|_"
}];
ShowStatus["Preparing final structure..."];
npath=NotebookFileName[EvaluationNotebook[]];
filtered=Select[Thread[{ids,base,paths,NotebookFileName[EvaluationNotebook[]],celltags}],StringMatchQ[#[[2]],"*{{c@::*"] & ];
ndir=NotebookDirectory[EvaluationNotebook[]];
deck=StringReplace[StringReplace[ndir,e___~~"/Knowledge/" ~~ f___ ~~"/":> f],"/":>"::"];
PrintToConsole[deck];
PrintToConsole[AnkiRequest["createDeck",<|"deck"->deck|>]];
AddOrUpdateNotes[deck,filtered];
If[sync,PrintToConsole[AnkiRequest["sync"]]];
];
End[];
EndPackage[];
