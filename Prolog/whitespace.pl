%%% -*- Mode: Prolog -*-

trim(Atomo, ListaTrimmata) :-
    atom(Atomo),
    atom_chars(Atomo, ListaCaratteri),
    trim_testa(ListaCaratteri, TrimmataTesta),
    trim_coda(TrimmataTesta, ListaTrimmata).

%%% -- Implementazione trim_testa/2 e trim_coda/2 --

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


%%% DA FIXARE: trim_coda, così fa loop strani

%%% trim_coda/2 rimuove le spaziature superflue in coda
trim_coda(ListaDaTrimmare, ListaTrimmata) :-
    reverse(ListaDaTrimmare, ListaRibaltata),
    !,
    trim_testa(ListaRibaltata, TrimmataTesta),
    reverse(TrimmataTesta, ListaTrimmata).

%%% reverse/2 inverte una lista
reverse(Lista, ListaInvertita) :-
    reverse(Lista, [], ListaInvertita).

%%% reverse/3 fa da supporto a reverse/2
reverse([], ListaInvertita, ListaInvertita).
reverse([Carattere | Resto], Accumulatore, ListaInvertita) :-
    reverse(Resto, [Carattere | Accumulatore], ListaInvertita).

%%% -- Fine implementazione trim_testa/2 e trim_coda/2 --



    