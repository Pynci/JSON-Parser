%%% -*- Mode: Prolog -*-

%%% Inizio implementazione inverti/2

inverti(Stringa, StringaAtomizzata) :-
    string(Stringa),
    atomic_list_concat(['"', Stringa, '"'], StringaAtomizzata),
    !.

inverti(Numero, Numero) :-
    number(Numero),
    !.

inverti(Null, Null) :-
    Null = null,
    !.

inverti(True, True) :-
    True = true,
    !.

inverti(False, False) :-
    False = false,
    !.

inverti(jsonobj([]), Risultato) :-
    atomic_list_concat(['{', '}'], Risultato),
    !.

/*
inverti(jsonobj([','(Chiave, Valore)]), Risultato) :-
    string(Chiave),
    string(Valore),
    !,
    atomic_list_concat(['{', '"', Chiave, '"', ':', '"', Valore, '"','}'], Risultato).
*/

inverti(jsonobj([','(Chiave, Valore)]), Risultato) :-
    string(Chiave),
    inverti(Valore, ValoreInvertito),
    !,
    atomic_list_concat(['{', '"', Chiave, '"', ':', ValoreInvertito,'}'], Risultato).
/*
inverti(jsonobj([','(Chiave, Valore) | Altro]), Risultato) :-
    string(Chiave),
    string(Valore),
    !,
    inverti(jsonobj(Altro), Risultato1),
    atom_chars(Risultato1, ListaCaratteriRisultato),
    nth0(0, ListaCaratteriRisultato, _Graffa, CaratteriRimanenti),
    atom_chars(AtomoCaratteriRimanenti, CaratteriRimanenti),
    atomic_list_concat(['{', '"', Chiave, '"', Valore, ',', AtomoCaratteriRimanenti], Risultato).
*/

inverti(jsonobj([','(Chiave, Valore) | Altro]), Risultato) :-
    string(Chiave),
    inverti(Valore, ValoreInvertito),
    !,
    inverti(jsonobj(Altro), Risultato1),
    atom_chars(Risultato1, ListaCaratteriRisultato),
    nth0(0, ListaCaratteriRisultato, _Graffa, CaratteriRimanenti),
    atom_chars(AtomoCaratteriRimanenti, CaratteriRimanenti),
    atomic_list_concat(['{', '"', Chiave, '"', ':', ValoreInvertito, ',', AtomoCaratteriRimanenti], Risultato).

inverti(jsonarray([]), Risultato) :-
    atomic_list_concat(['[', ']'], Risultato),
    !.

inverti(jsonarray([Valore]), Risultato) :-
    inverti(Valore, ValoreInvertito),
    !,
    atomic_list_concat(['[',ValoreInvertito,']'], Risultato).

inverti(jsonarray([Valore]), Risultato) :-
    string(Valore),
    !,
    atomic_list_concat(['[','"', Valore, '"', ']'], Risultato).

inverti(jsonarray([Valore | Altro]), Risultato) :-
    inverti(Valore, ValoreInvertito),
    !,
    inverti(jsonarray(Altro), Risultato1),
    atom_chars(Risultato1, ListaCaratteriRisultato),
    nth0(0, ListaCaratteriRisultato, _Quadra, CaratteriRimanenti),
    atom_chars(AtomoCaratteriRimanenti, CaratteriRimanenti),
    atomic_list_concat(['[', ValoreInvertito, ',', AtomoCaratteriRimanenti], Risultato).

inverti(jsonarray([Valore | Altro]), Risultato) :-
    string(Valore),
    !,
    inverti(jsonarray(Altro), Risultato1),
    atom_chars(Risultato1, ListaCaratteriRisultato),
    nth0(0, ListaCaratteriRisultato, _Quadra, CaratteriRimanenti),
    atom_chars(AtomoCaratteriRimanenti, CaratteriRimanenti),
    atomic_list_concat(['[', '"', Valore, '"', ',', AtomoCaratteriRimanenti], Risultato).


%%% Fine implementazione inverti/2
