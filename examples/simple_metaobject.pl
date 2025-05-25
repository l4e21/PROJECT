
:- module(simple_metaobject_example, []).

:- use_module("../core/core.pl", [call_slot/1, slot/3]).

%% A simple counter metaobject
simple_metaobject_init(MetaObjectID, Slots) :-
    call_slot(make_obj(root,
                       [(make_obj(Self, Slots, ObjID),
                         (call_slot(make_obj(root,
                                             Slots,
                                             ObjID)),
                          call_slot(counter(Self, N)),
                          N1 is N + 1,
                          call_slot(make_slots(Self,
                                               Self,
                                               [(counter(_S, N1), true)])))),
                        (inherits(Self, root), true),
                        (counter(Self, 0), true)],
                       MetaObjectID)),
    findall(Head-Body, slot(MetaObjectID, Head, Body), Slots).

%% Metaobject increases its counter slot whenever it creates a new object, otherwise inheriting from the root object
simple_metaobject_make_object(MetaObjectID, NewObj, OldCounter, NewCounter) :-
    call_slot(counter(MetaObjectID, OldCounter)),
    call_slot(make_obj(MetaObjectID, [], NewObj)),
    call_slot(counter(MetaObjectID, NewCounter)).

% ?- simple_metaobject_init(MetaID, Slots), simple_metaobject_make_object(MetaID, NewObj, OldCounter, NewCounter).
%@ Correct to: "simple_metaobject_example:simple_metaobject_init(MetaID,Slots)"? yes
%@ Correct to: "simple_metaobject_example:simple_metaobject_make_object(MetaID,NewObj,OldCounter,NewCounter)"? yes
%@ MetaID = obj_1,
%@ Slots = [counter(_, 0)-true, inherits(_, root)-true, make_obj(_A, _B, _C)-(call_slot(make_obj(root, _B, _C)), call_slot(counter(_A, _D)), _E is _D+1, call_slot(make_slots(_A, _A, [...])))],
%@ NewObj = obj_2,
%@ OldCounter = 0,
%@ NewCounter = 1 ;
%@ false.
