:- module('examples/project/relational_model', []).

:- use_module(library(project), [call_slot/1, slot/3]).

%% I heard you like relational models
%% so I put a simplified relational model (this example)
%% inside of an object-oriented relational model (PROJECT)
%% inside of a purely relational model (PROLOG)

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

table_factory_init(FactoryID) :-
    call_slot(make_obj(root, [
                           (make_obj(Self, Attributes, TableID),
                            (gensym(table_obj_, TableID),
                             asserta(slot(TableID, metaobject(_, Self), true)),
                             ValidateRow = (validate_row(TableSelf, Row),
                                                       not((call_slot(attribute(TableSelf, Name, Type)),
                                                            (get_dict(Name, Row, Val) -> not(relational_model_example:validate_type(Type, Val))
                                                            ; true)))),
                             PutRow = (put(TableSelf, Row), (call_slot(validate_row(TableSelf, Row)),
                                                             call_slot(make_slots(Self, TableSelf, [(row(_, Row), true)])))),
                             relational_model_example:attributes_to_methods(Attributes, AttrMethods),
                             call_slot(make_slots(Self, TableID, [ValidateRow, PutRow|AttrMethods])))),
                           (inherits(Self, root), true)
                       ],
                      FactoryID)).

% ?- table_factory_init(ID), call_slot(make_obj(ID, [_{name: id, type: integer, key: true}], TableID)), call_slot(put(TableID, _{id: 3})), slot(TableID, row(_, Row), _).
%@ Correct to: "relational_model_example:table_factory_init(ID)"? yes
%@ Correct to: "core:call_slot(make_obj(ID,[_{key:true,name:id,type:integer}],TableID))"? yes
%@ Correct to: "core:call_slot(put(TableID,_{id:3}))"? yes
%@ Correct to: "core:slot(TableID,row(_,Row),_)"? yes
%@ ID = obj_1,
%@ TableID = table_obj_1,
%@ Row = _{id:3} 

% ?- table_init(ID, [_{name: id, type: integer, key: true}]), call_slot(put(ID, _{id: 3})).

% ?- call_slot(attribute(obj_1, Name, Type)).
% ?- call_slot(key(obj_1, Name)).

% ?- slot(obj_1, Y, Z).

% ?- call_slot(metaobject(A, root)).
