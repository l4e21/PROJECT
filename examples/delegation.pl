:- module(delegation_example, []).

:- use_module("../core/core.pl", [call_slot/1, slot/3]).

dog_init(DogID) :-
    call_slot(make_obj(root,
                       [(woof(Self), (print(Self), print(": woof!")))],
                       DogID)).

fido_init(DogID, FidoID) :-
    call_slot(make_obj(root,
                       [(inherits(_Self, DogID), true)],
                      FidoID)).


% ?- dog_init(DogID), fido_init(DogID, FidoID), call_slot(woof(FidoID)).
%@ Correct to: "delegation_example:dog_init(DogID)"? yes
%@ Correct to: "delegation_example:fido_init(DogID,FidoID)"? yes
%@ Correct to: "core:call_slot(woof(FidoID))"? yes
%@ obj_2": woof!"
%@ DogID = obj_1,
%@ FidoID = obj_2.

