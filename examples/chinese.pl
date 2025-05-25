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

before(T1, T2) :-
    call_slot(time_term(T1, Date1, Time1)),
    call_slot(time_term(T2, Date2, Time2)),
    before(Date1, Time1, Date2, Time2).

before(Yr1/_/_, _:_, Yr2/_/_, _:_) :-
    Yr1 #< Yr2.
before(Yr1/Month1/_, _:_, Yr2/Month2/_, _:_) :-
    Yr1 #= Yr2,
    Month1 #< Month2.
before(Yr1/Month1/Day1, _:_, Yr2/Month2/Day2, _:_) :-
    Yr1 #= Yr2,
    Month1 #= Month2,
    Day1 #< Day2.
before(Yr1/Month1/Day1, Hr1:_, Yr2/Month2/Day2, Hr2:_) :-
    Yr1 #= Yr2,
    Month1 #= Month2,
    Day1 #= Day2,
    Hr1 #< Hr2.
before(Yr1/Month1/Day1, Hr1:Min1, Yr2/Month2/Day2, Hr2:Min2) :-
    Yr1 #= Yr2,
    Month1 #= Month2,
    Day1 #= Day2,
    Hr1 #= Hr2,
    Min1 #< Min2.

% ?- chinese_example:now(ID), call_slot(year(ID, Yr)).

make_flashcard(English, Pinyin, Character, CardID) :-
    make_time(2000/1/1, 0:0, DefaultTimeID),
    call_slot(make_obj(root,
                       [
                           (english(Self, English), true),
                           (pinyin(Self, Pinyin), true),
                           (character(Self, Character), true),
                           
                           (last_answered(Self, DefaultTimeID), true),
                           (last_shown(Self, DefaultTimeID), true),
                           (correct_answers(Self, 0), true),
                           (card(Self), true),

                           (answer(Self),
                            (chinese_example:now(NowID1),
                             call_slot(correct_answers(Self, N)),
                             N1 is N + 1,
                             call_slot(make_slots(root, Self, [(last_answered(SelfAux, NowID1), true),
                                                               (correct_answers(SelfAux, N1), true)])))),
                           (show(Self, ToShow),
                            (call_slot(character(Self, ToShow)),
                             chinese_example:now(NowID2),
                             call_slot(make_slots(root, Self, [(last_shown(_SelfAux, NowID2), true)]))))
                       ],
                      CardID)).

flashcards(FlashcardIDs) :-
    findall(FlashcardID,
            slot(FlashcardID, card(_Self), true),
            FlashcardIDs).

oldest_flashcard(FlashcardID) :-
    flashcards(FlashcardIDs),
    oldest_flashcard(FlashcardID, FlashcardIDs).

oldest_flashcard(FlashcardID, [FlashcardID]).
oldest_flashcard(Oldest, [FlashcardID|Flashcards]) :-
    oldest_flashcard(FlashcardID2, Flashcards),
    call_slot(last_shown(FlashcardID, LastShownID)),
    call_slot(last_shown(FlashcardID2, LastShownID2)),
    (before(LastShownID, LastShownID2)
    -> Oldest = FlashcardID
    ; Oldest = FlashcardID2).
    

% ?- make_flashcard(person, rén, 人, ID), call_slot(last_answered(ID, LastAnsweredTimeID)), call_slot(time_term(LastAnsweredTimeID, Date, Time)).
%@ Correct to: "chinese_example:make_flashcard(person,rén,人,ID)"? yes
%@ Correct to: "core:call_slot(last_answered(ID,LastAnsweredTimeID))"? yes
%@ Correct to: "core:call_slot(time_term(LastAnsweredTimeID,Date,Time))"? yes
%@ ID = obj_2,
%@ LastAnsweredTimeID = obj_1,
%@ Date = 2000/1/1,
%@ Time = 0:0.

% ?- call_slot(show(obj_2, Hanzi)).
%@ Correct to: "core:call_slot(show(obj_2,Hanzi))"? yes
%@ Hanzi = 人.

% ?- call_slot(answer(obj_2)).

% ?- call_slot(last_answered(obj_2, A)), call_slot(time_term(A, Date, Time)).
%@ Correct to: "core:call_slot(last_answered(obj_2,A))"? yes
%@ Correct to: "core:call_slot(time_term(A,Date,Time))"? yes
%@ A = obj_1,
%@ Date = 2000/1/1,
%@ Time = 0:0.

% ?- call_slot(last_shown(obj_2, A)), call_slot(time_term(A, Date, Time)).
%@ Correct to: "core:call_slot(last_shown(obj_2,A))"? yes
%@ Correct to: "core:call_slot(time_term(A,Date,Time))"? yes
%@ A = obj_3,
%@ Date = 2025/5/25,
%@ Time = 21:35.

% ?- flashcards(FlashcardIDs).

% ?- oldest_flashcard(ID).

% ?- qsave_program("../../chinese_flashcards", [stand_alone(true)]).
%@ % Disabled autoloading (loaded 48 files)
%@ % Disabled autoloading (loaded 4 files)
%@ % Disabled autoloading (loaded 0 files)
%@ true.
