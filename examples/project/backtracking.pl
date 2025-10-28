:- module('examples/project/backtracking', [backtracking_object_init/1]).

:- use_module(library(project), [call_slot/1, slot/3]).

backtracking_object_init(ObjID) :-
    call_slot(make_obj(root,
                       [(val(_Self, X), member(X, [1, 2, 3]))],
                       ObjID)).


% ?- backtracking_object_init(_ObjID), call_slot(val(_ObjID, X)).
