:- module(backtracking_example, []).

:- use_module("../core/core.pl", [call_slot/1, slot/3]).

backtracking_object_init(ObjID) :-
    call_slot(make_obj(root,
                       [(val(_Self, X), member(X, [1, 2, 3]))],
                       ObjID)).


% ?- backtracking_object_init(ObjID), call_slot(val(ObjID, X)).
%@ Correct to: "backtracking_example:backtracking_object_init(ObjID)"? yes
%@ Correct to: "core:call_slot(val(ObjID,X))"? yes
%@ ObjID = obj_1,
%@ X = 1 ;
%@ ObjID = obj_1,
%@ X = 2 ;
%@ ObjID = obj_1,
%@ X = 3.
