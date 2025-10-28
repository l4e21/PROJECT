:- module(project, [call_slot/1, slot/3]).

:- use_module(library(gensym)).

:- dynamic(slot/3).

%% This is needed to preserve caller module. Otherwise, within the scope of defining a slot body, you are in this module, rather than your caller, meaning you'd have to namespace all of your calls when defining slots.
:- meta_predicate(call_slot(:)).
:- meta_predicate(call_slot(?, :)).

%% call_slot is a dispatch shell, in the future we can flesh it out and provide more hooks, as well as allowing new metaobjects to define their own call_slot capabilities.
call_slot(SlotHead) :-
    strip_module(SlotHead, _, SlotHead0),
    SlotHead0 =.. [_, ID|_],
    call_slot(ID, SlotHead).
    
call_slot(CallerID, SlotHead) :-
    strip_module(SlotHead, M, SlotHead0),
    (slot(CallerID, SlotHead0, Body)
    -> M:call(Body)
    ; (slot(CallerID, inherits(CallerID, InheritsID), Body),
       M:call(Body),
       call_slot(InheritsID, SlotHead))).

%% The only starting object is root, a metaobject which determines how new objects are created.
slot(root, name(_Self, root), true).

slot(root, make_obj(Self, Slots, ID),
     (gensym(obj_, ID),
      asserta(slot(ID, metaobject(_, Self), true)),
      call_slot(make_slots(Self, ID, Slots)))).

slot(root, make_slots(_Self, _, []), true).
slot(root, make_slots(Self, ID, [(SlotHead, SlotBody)|Slots]),
     (asserta(slot(ID, SlotHead, SlotBody)),
      call_slot(make_slots(Self, ID, Slots)))).

% ?- qsave_program(mop, [stand_alone(true)]).
