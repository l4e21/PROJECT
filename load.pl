:- use_module(library(prolog_pack)).
:- attach_packs(packs, []).
   
:- prolog_load_context(directory, Here),
   directory_file_path(Here, src, Lib),
   directory_file_path(Here, examples, Examples),
   asserta(file_search_path(library, Lib)),
   asserta(file_search_path(examples, Examples)).
