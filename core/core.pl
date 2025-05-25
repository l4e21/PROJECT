:- module(core, [call_slot/1, slot/3]).

:- use_module(library(gensym)).

:- dynamic(slot/3).

%% call_slot is a dispatch shell, in the future we can flesh it out and provide more hooks, as well as allowing new metaobjects to define their own call_slot capabilities.
call_slot(SlotHead) :-
    SlotHead =.. [_, ID|_],
    call_slot(ID, SlotHead).
    
call_slot(CallerID, SlotHead) :-
    (slot(CallerID, SlotHead, Body),
     call(Body)
    ; (slot(CallerID, inherits(CallerID, InheritsID), Body),
       Body,
       call_slot(InheritsID, SlotHead))).

%% The only starting object is root, a metaobject which determines how new objects are created.
slot(root, make_obj(Self, Slots, ID),
     (gensym(obj_, ID),
      call_slot(make_slots(Self, ID, Slots)))).

slot(root, make_slots(_Self, _, []), true).
slot(root, make_slots(Self, ID, [(SlotHead, SlotBody)|Slots]),
     (asserta(slot(ID, SlotHead, SlotBody)),
      call_slot(make_slots(Self, ID, Slots)))).

% ?- qsave_program(mop, [stand_alone(true)]).
