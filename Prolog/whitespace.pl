%%% -*- Mode: Prolog -*-

trim(Atomo, ListaTrimmata) :-
    atom(Atomo),
    atom_chars(Atomo, ListaCaratteri),
    trim_testa(ListaCaratteri, ListaTrimmata).



%%% trim_testa/2 rimuove le spaziature superflue in testa

%%% se il primo carattere non è di spaziatura sono a posto
trim_testa([Carattere | Altro], [Carattere | Altro]) :-
    not(char_type(Carattere, space)),
    !.

%%% se i primi 2 caratteri sono di spaziatura scarto il primo
trim_testa([Spazio1, Spazio2 | Altro], NuovaLista) :-
    char_type(Spazio1, space),
    char_type(Spazio2, space),
    !,
    trim_testa([Spazio2 | Altro], NuovaLista).

%%% caso base: solo il primo primo carattere è di spaziatura
trim_testa([Spazio, Carattere | Altro], [Spazio, Carattere | Altro]) :-
    char_type(Spazio, space),
    not(char_type(Carattere, space)).


%%% trim_coda/2 rimuove le spaziature superflue in coda
% continua




    