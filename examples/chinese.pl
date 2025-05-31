:- module(chinese_example, []).

:- use_module("../core/core.pl", [call_slot/1, slot/3]).
:- use_module(library(clpfd)).

default_date(Stamp) :-
    date_time_stamp(date(2000, 1, 1, 0, 0, 0.0, 0, 'local', -), Stamp).

stamp_to_date9(Stamp, DateTime) :- stamp_date_time(Stamp, DateTime, local).

time_delta(Stamp1, Stamp2, Days) :-
    Delta is Stamp1 - Stamp2,
    Days is floor(Delta / 86400).

make_flashcard(English, Pinyin, Character, CardID) :-
    default_date(DefaultTimeStamp),
    call_slot(make_obj(root,
                       [
                           (english(Self, English), true),
                           (pinyin(Self, Pinyin), true),
                           (character(Self, Character), true),
                           
                           (last_shown(Self, DefaultTimeStamp), true),
                           (confidence(Self, 1), true),
                           (card(Self), true),

                           (needs_practice(Self),
                            get_time(NowStamp),
                            call_slot(confidence(Self, Confidence)),
                            call_slot(last_shown(Self, LastShownStamp)),
                            print("HI"),
                            chinese_example:time_delta(NowStamp, LastShownStamp, DaysSinceShown),
                            print(DaysSinceShown),
                            Limit is 2**Confidence,
                            print(Limit),
                            DaysSinceShown > Limit),

                           (answer(Self, RW),
                            (call_slot(confidence(Self, N)),
                             (RW == right, N1 is N + 1
                             ; RW == wrong, N1 is 1),
                             call_slot(make_slots(root, Self, [(confidence(SelfAux, N1), true)])))),
                           (show(Self),
                            (get_time(NowStamp),
                             call_slot(make_slots(root, Self, [(last_shown(SelfAux, NowStamp), true)]))))
                       ],
                       CardID)).

flashcards(FlashcardIDs) :-
    findall(FlashcardID,
            slot(FlashcardID, card(_Self), true),
            FlashcardIDs).



make_deck(DeckID, Name) :-
    call_slot(make_obj(root,
                       [
                           (name(Self, Name), true),
                           
                           (add_card(Self, CardID), call_slot(make_slots(root, Self, [(card(_SelfAux, CardID), true)]))),
                           (all_cards(Self, CardIDs), findall(CardID, call_slot(card(Self, CardID)), CardIDs))

                           %% Not a great algo, instead there should be some confidence-and-time ranking like Anki
                           %% (oldest_flashcard(Self, CardID), (call_slot(all_cards(Self, CardIDs)),
                           %%                                   call_slot(oldest_flashcard(Self, CardID, CardIDs)))),
                           %% (oldest_flashcard(Self, CardID, [F1|CardIDs]), (call_slot(oldest_flashcard(Self, F2, CardIDs)),
                           %%                                                   call_slot(last_shown(F1, LS1)),
                           %%                                                   call_slot(last_shown(F2, LS2)),
                           %%                                                   (chinese_example:before(LS1, LS2), CardID = F1
                           %%                                                   ; CardID = F2))),
                           %% (oldest_flashcard(Self, CardID, [CardID]), true),
                           
                           %% (show_next(Self, CardID, Char), (call_slot(oldest_flashcard(Self, CardID)), call_slot(chinese(CardID, Char)), call_slot(show(CardID))))
                           
                       ],
                       DeckID)).

deck_example(DeckID) :-
    make_flashcard(card1, pinyin1, char1, CardID),
    make_flashcard(card2, pinyin2, char2, CardID2),
    make_deck(DeckID, example),
    call_slot(add_card(DeckID, CardID)),
    call_slot(add_card(DeckID, CardID2)).

flashcard_answer_update_example(ID, LastShownDate, LastShownDate2) :-
    make_flashcard(person, rén, 人, ID),
    call_slot(last_shown(ID, LastShown)),
    call_slot(needs_practice(ID)),
    call_slot(show(ID)),
    call_slot(last_shown(ID, LastShown2)),
    %% not(call_slot(needs_practice(ID))),
    stamp_to_date9(LastShown, LastShownDate),
    stamp_to_date9(LastShown2, LastShownDate2).

% ?- slot(obj_3, A, B).
% ?- deck_example(DeckID).
% ?- call_slot(last_shown(obj_3, D)).

% ?- flashcard_answer_update_example(ID, Date1, Date2).
%@ ID = obj_1,
%@ Date1 = date(2000, 1, 1, 0, 0, 0.0, 0, 'GMT', false),
%@ Date2 = date(2025, 5, 26, 13, 5, 40.36020636558533, -3600, 'BST', true) ;
%@ ID = obj_1,
%@ Date1 = Date2, Date2 = date(2000, 1, 1, 0, 0, 0.0, 0, 'GMT', false) ;
%@ false.

% ?- qsave_program("../../chinese_flashcards", [stand_alone(true)]).


%% 2 kinds of slot
%% Immutable -> Backtracking available, monotonic, can have multiple existing for a given time poeriod
%% Faux-mutable -> Still Monotonic, but there's some concept of a 'latest' slot that must be fetched explicitly and not by control flow. E.G., get the max based on the timestamp associated with the slot... perhaps uses batch for this?
