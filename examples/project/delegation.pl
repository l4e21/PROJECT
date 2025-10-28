:- module('examples/project/delegation', []).

:- use_module(library(project), [call_slot/1, slot/3]).

dog_init(DogID) :-
    call_slot(make_obj(root,
                       [(woof(Self), (print(Self), print(": woof!")))],
                       DogID)).

fido_init(DogID, FidoID) :-
    call_slot(make_obj(root,
                       [(inherits(_Self, DogID), true)],
                      FidoID)).


% ?- dog_init(DogID), fido_init(DogID, FidoID), call_slot(woof(FidoID)).

