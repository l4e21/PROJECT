:- module('examples/project/factory', []).

:- use_module(library(project), [call_slot/1, slot/3]).

flashcard_init(ID, Slots) :-
    call_slot(make_obj(root, [(card_name(_Self, ren), true)], ID)),
    findall(Head-Body, slot(ID, Head, Body), Slots),
    length(Slots, 1).

%% We can look up an object by seeing if it implements a given predicate.
flashcard_ids(Cards) :-
    findall(ID, (slot(ID, card_name(_, _), _)), Cards).

flashcard_factory_init(FactoryID, Slots) :-
    call_slot(make_obj(root,
                       [(make_card(_FactorySelf, CardID, CardName),
                         call_slot(make_obj(root,
                                            [(card_name(_CardSelf, CardName), true)],
                                            CardID)))],
                       FactoryID)),
    findall(Head-Body, slot(FactoryID, Head, Body), Slots).

make_card(FactoryID, CardID, CardSlots) :-
    call_slot(make_card(FactoryID, CardID, ren2)),
    findall(Head-Body, slot(CardID, Head, Body), CardSlots).

% ?- flashcard_init(CardID, CardSlots), flashcard_ids(Cards).

% ?- flashcard_factory_init(FactoryID, FactorySlots), make_card(FactoryID, CardID, CardSlots).
