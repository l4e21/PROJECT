:- module(chinese_example, []).

:- use_module("../core/core.pl", [call_slot/1, slot/3]).
:- use_module(library(clpfd)).

month_name(1, "January").
month_name(2, "February").
month_name(3, "March").
month_name(4, "April").
month_name(5, "May").
month_name(6, "June").
month_name(7, "July").
month_name(8, "August").
month_name(9, "September").
month_name(10, "October").
month_name(11, "November").
month_name(12, "December").

days_in_month(1, 31).
days_in_month(2, 28).
days_in_month(3, 31).
days_in_month(4, 30).
days_in_month(5, 31).
days_in_month(6, 30).
days_in_month(7, 31).
days_in_month(8, 31).
days_in_month(9, 30).
days_in_month(10, 31).
days_in_month(11, 30).
days_in_month(12, 31).

valid_time(Hr:Min) :-
    Hr in 0..23,
    Min in 0..59.

valid_date(_Yr/Month/Day) :-
    Month in 1..12,
    days_in_month(Month, DaysInMonth),
    between(1, DaysInMonth, Day).

make_time(Yr/Month/Day, Hr:Min, ID) :-
    valid_date(Yr/Month/Day),
    valid_time(Hr:Min),
    call_slot(make_obj(root,
                       [
                           (year(Self, Yr), true),
                           (month(Self, Month), true),
                           (day(Self, Day), true),
                           
                           (hour(Self, Hr), true),
                           (min(Self, Min), true),
                           (time_term(Self, Yr/Month/Day, Hr:Min),
                            (call_slot(year(Self, Yr)),
                             call_slot(month(Self, Month)),
                             call_slot(day(Self, Day)),
                             call_slot(hour(Self, Hr)),
                             call_slot(min(Self, Min))))
                       ],
                       ID)).

now(ID) :-
    get_time(Stamp),
    stamp_date_time(Stamp, DateTime, local),
    date_time_value(year, DateTime, Yr),
    date_time_value(month, DateTime, Month),
    date_time_value(day, DateTime, Day),
    date_time_value(hour, DateTime, Hr),
    date_time_value(minute, DateTime, Min),
    make_time(Yr/Month/Day, Hr:Min, ID).

% ?- chinese_example:now(ID), call_slot(year(ID, Yr)).

make_flashcard(English, Pinyin, Character, CardID) :-
    make_time(2000/1/1, 0:0, DefaultTimeID),
    call_slot(make_obj(root,
                       [
                           (english(Self, English), true),
                           (pinyin(Self, Pinyin), true),
                           (character(Self, Character), true),
                           
                           (last_answered(Self, DefaultTimeID), true),
                           (correct_answers(Self, 0), true),
                           (card(Self, true), true),

                           (answer(Self),
                            (chinese_example:now(NowID),
                             call_slot(make_slots(root, Self, [(last_answered(_SelfAux, NowID), true)]))))
                       ],
                      CardID)).



% ?- make_flashcard(person, rén, 人, ID), call_slot(last_answered(ID, LastAnsweredTimeID)), call_slot(time_term(LastAnsweredTimeID, Date, Time)).

% ?- call_slot(answer(obj_2)).

% ?- call_slot(last_answered(obj_2, A)), call_slot(time_term(A, Date, Time)).


% ?- qsave_program("../../chinese_flashcards", [stand_alone(true)]).
%@ % Disabled autoloading (loaded 39 files)
%@ % Disabled autoloading (loaded 0 files)
%@ true.
