:- module(genserver_example, []).

:- use_module("../core/core.pl", [call_slot/1, slot/3]).

%% The sort of server we might want to produce via a genserver~
server_object_init(ServerID, Slots) :-
    call_slot(make_obj(root,
                       [(state(Self, 0), true),

                        (start(Self, Queue),
                         (message_queue_create(Queue),
                          thread_create(call_slot(server_loop(Self, Queue)), _, [detached]))),

                        (server_loop(Self, Queue),
                         (thread_get_message(Queue, Msg),
                          call_slot(state(Self, State0)),
                          call_slot(handle_message(Self, Msg, State0, State1)),
                          call_slot(make_slots(root, Self, [(state(_, State1), true)])),
                          call_slot(server_loop(Self, Queue)))),

                        (handle_message(Self, inc, N0, N1),
                         N1 is N0 + 1),

                        (handle_message(Self, print, N0, N0),
                         print(N0),
                         nl)],
                       ServerID)),
    findall(Head-Body, slot(ServerID, Head, Body), Slots).

server_object_test(ServerID) :-
    call_slot(start(ServerID, Queue)),
    thread_send_message(Queue, print),
    thread_send_message(Queue, inc),
    thread_send_message(Queue, print).


% ?- server_object_init(ServerID, Slots), server_object_test(ServerID).
%@ Correct to: "genserver_example:server_object_init(ServerID,Slots)"? yes
%@ Correct to: "genserver_example:server_object_test(ServerID)"? yes
%@ 0
%@ 1
%@ ServerID = obj_1,
%@ Slots = [handle_message(_, print, _A, _A)-(print(_A), nl), handle_message(_, inc, _B, _C)-(_C is _B+1), server_loop(_D, _E)-(thread_get_message(_E, _F), call_slot(state(_D, _G)), call_slot(handle_message(_D, _F, _G, _H)), call_slot(make_slots(..., ..., ...)), call_slot(server_loop(..., ...))), start(_I, _J)-(message_queue_create(_J), thread_create(call_slot(server_loop(_I, _J)), _, [detached])), state(_, 0)-true] ;
%@ false.


