
:- module(relational_model, []).

:- use_module("../core/core.pl", [call_slot/1, slot/3]).

%% Tables should really just be metaobjects
%% Then rows would be objects created by the table metaobject.

attributes_to_methods([], []).
attributes_to_methods([AttrDict|Attributes], AttrMethods) :-
    get_dict(name, AttrDict, AttrName),
    get_dict(type, AttrDict, AttrType),
    AttrMethod = attribute(Self, AttrName, AttrType),
    (get_dict(key, AttrDict, _IsKey) ->
     AttrMethods1 = [(AttrMethod, true), (key(Self, AttrName), true)]
    ; AttrMethods1 = [(AttrMethod, true)]),
    attributes_to_methods(Attributes, AttrMethods2),
    append(AttrMethods1, AttrMethods2, AttrMethods).
    
validate_type(Type, Val) :-
    call(Type, Val).

table_init(ID, Attributes) :-
    attributes_to_methods(Attributes, AttrMethods),
    call_slot(make_obj(root, [
                           (put(Self, Row),
                            (call_slot(validate_row(Self, Row)),
                             call_slot(make_slots(root, Self, [(row(_, Row), true)])))),
                           (validate_row(Self, Row),
                               (not((call_slot(attribute(Self, Name, Type)),
                                     (get_dict(Name, Row, Val) -> not(relational_model:validate_type(Type, Val))
                                     ; true)))))
                           |AttrMethods],
                       ID)).


% ?- table_init(ID, [_{name: id, type: integer, key: true}]), call_slot(put(ID, _{id: 3})).
%@ Correct to: "relational_model:table_init(ID,[_{key:true,name:id,type:integer}])"? yes
%@ Correct to: "core:call_slot(put(ID,_{id:3}))"? yes
%@ ID = obj_1 ;
%@ false.

% ?- call_slot(attribute(obj_1, Name, Type)).
% ?- call_slot(key(obj_1, Name)).

% ?- slot(obj_1, Y, Z).
%@ Correct to: "core:slot(obj_1,Y,Z)"? yes
%@ Y = row(_, _{id:3}),
%@ Z = true ;
%@ Y = key(_, id),
%@ Z = true ;
%@ Y = attribute(_, id, integer),
%@ Z = true ;
%@ Y = validate_row(_A, _B),
%@ Z = not((call_slot(attribute(_A, _C, _D)), (get_dict(_C, _B, _E)->not(relational_model:validate_type(_D, _E));true))) ;
%@ Y = put(_A, _B),
%@ Z = (call_slot(validate_row(_A, _B)), call_slot(make_slots(root, _A, [(row(_, _B), true)]))).

