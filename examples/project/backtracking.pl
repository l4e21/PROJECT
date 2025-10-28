:- module('project/examples/backtracking', []).

:- use_module(project, [call_slot/1, slot/3]).

backtracking_object_init(ObjID) :-
    call_slot(make_obj(root,
                       [(val(_Self, X), member(X, [1, 2, 3]))],
                       ObjID)).


% ?- backtracking_object_init(_ObjID), call_slot(val(_ObjID, X)).
%@ Correct to: "backtracking_example:backtracking_object_init(_ObjID)"? yes
%@ Correct to: "core:call_slot(val(_ObjID,X))"? 
%@ Please answer 'y' or 'n'? yes
%@ _ObjID = obj_1,
%@ X = 1 ;
%@ _ObjID = obj_1,
%@ X = 2 ;
%@ _ObjID = obj_1,
%@ X = 3 ;
%@ false.
