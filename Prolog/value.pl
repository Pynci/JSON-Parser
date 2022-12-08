%%% -*- Mode: Prolog -*-

%%% trim/2 serve a scartare gli spazi in testa ed in coda.
%Questo prende in ingresso un atomo
trim(Atomo, ListaTrimmata) :-
    atom(Atomo),
    !,
    atom_chars(Atomo, ListaCaratteri),
    trim_testa(ListaCaratteri, TrimmataTesta),
    trim_coda(TrimmataTesta, ListaTrimmata).

%%% trim/2 prende in ingresso un lista 
trim(Lista, ListaTrimmata) :-
    atomic_list_concat(Lista, AtomoLista),
    !,
    trim(AtomoLista, ListaTrimmata).


%%% --- Implementazione trim_testa/2 e trim_coda/2 ---

%%% trim_testa/2 rimuove le spaziature superflue in testa

%%% se non ho caratteri il gioco finisce subito
trim_testa([], []).

%%% se il primo carattere non è di spaziatura sono a posto
trim_testa([Carattere | Altro], [Carattere | Altro]) :-
    not(char_type(Carattere, space)),
    !.

%%% caso base: non ci sono caratteri alfanumerici
trim_testa([Spazio | []], []) :-
    char_type(Spazio, space),
    !.

%%% caso base: solo il primo primo carattere è di spaziatura
trim_testa([Spazio, Carattere | Altro], [Carattere | Altro]) :-
    char_type(Spazio, space),
    not(char_type(Carattere, space)),
    !.

%%% se il primo carattere è di spaziatura lo scarto
trim_testa([Spazio | Altro], NuovaLista) :-
    char_type(Spazio, space),
    !,
    trim_testa(Altro, NuovaLista).

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

%%% --- Fine implementazione trim_testa/2 e trim_coda/2 ---

%%% is_virgolette/1 dice che '"' è una virgoletta
is_virgolette('\"').


%%% parser_string/3 è definito da tre parametri:

parser_string([Virgolette | AltriCaratteri], Stringa, Resto) :-
    is_virgolette(Virgolette),
    leggi_stringa(AltriCaratteri, Letta, Resto),
    append([Virgolette], Letta, ListaStringa),
    atomic_list_concat(ListaStringa, Stringa).

%%% leggi_stringa/3 serve a leggere i caratteri e le virgolette di chiusura

leggi_stringa([Virgolette | Resto], [Virgolette], Resto) :-
    is_virgolette(Virgolette),
    !.

leggi_stringa([Carattere | Altro], [Carattere | LettiPrecedentemente], Resto) :-
    char_type(Carattere, ascii),
    leggi_stringa(Altro, LettiPrecedentemente, Resto).


%%% parser del numero intero (anche negativo)

parser_z(Caratteri,
	 NumeroOttenuto,
	 CaratteriRestanti) :-
    parser_z(Caratteri, [], NumeroOttenuto, _CifreDelNumero, CaratteriRestanti).

parser_z([Meno | CifreRimanenti],
	 [],
	 NumeroOttenuto,
	 CifreDelNumero,
	 CaratteriRestanti) :-
    is_meno(Meno),
    !,
    parser_z(CifreRimanenti, [Meno], NumeroOttenuto, CifreDelNumero, CaratteriRestanti).

parser_z([Cifra | CifreRimanenti],
	 CifreLette,
	 NumeroOttenuto,
	 CifreDelNumero,
	 CaratteriRestanti) :-
    is_digit(Cifra),
    !,
    parser_z(CifreRimanenti, [Cifra | CifreLette], NumeroOttenuto, CifreDelNumero, CaratteriRestanti).

parser_z([Carattere | CaratteriRestanti],
	 CifreLette,
	 NumeroOttenuto,
	 CifreDelNumero,
	 [Carattere | CaratteriRestanti]) :-
    %is_non_digit(Carattere),
    !,
    reverse(CifreLette, CifreDelNumero),
    number_string(NumeroOttenuto, CifreDelNumero).

parser_z([],
	 CifreLette,
	 NumeroOttenuto,
	 CifreDelNumero,
	 []) :-
    !,
    reverse(CifreLette, CifreDelNumero),
    number_string(NumeroOttenuto, CifreDelNumero).

is_meno('-').

is_punto('.').


%%% parser del numero intero.

parse_integer(Chars, I , MoreChars) :-
    parse_integer(Chars, [], I, _, MoreChars).

parse_integer([D | Ds], DsSoFar, I, ICs, Rest) :-
    is_digit(D),
    !,
    parse_integer(Ds, [D | DsSoFar], I, ICs, Rest).

parse_integer([C | Cs], DsR, I, Digits, [C | Cs]) :-
    !,
    reverse(DsR, Digits),
    number_string(I, Digits).

parse_integer([], DsR, I, Digits, []) :-
    !,
    reverse(DsR, Digits),
    number_string(I, Digits).


%%% Parser da lista caratteri a q

parser_q(Sequenza,
	 NumeroOttenuto,
	 CaratteriRimanenti) :-
    parser_q(Sequenza, [], NumeroOttenuto, _SequenzaLetta, CaratteriRimanenti).

parser_q(Sequenza,
	 [],
	 NumeroOttenuto,
	 SequenzaLetta,
	 Resto) :-
    parser_z(Sequenza, [], _Intero, ListaIntero, CaratteriRimanenti),
    parser_decimale(CaratteriRimanenti, ListaDecimali, Resto),
    append(ListaIntero, ListaDecimali, SequenzaLetta),
    number_string(NumeroOttenuto, SequenzaLetta).

parser_decimale([Punto | Altro],
		['.' | ListaDecimali],
		Resto) :-
    is_punto(Punto),
    !,
    parse_integer(Altro, [], _Decimale, ListaDecimali, Resto).

parser_decimale([Carattere | Altro], ['.' , '0'], [Carattere | Altro]).

parser_decimale([], ['.' , '0'], []).


/* 
Da qui in poi ho cercato di creare i parser per i valori predefiniti
true, false, null. Fammi sapere se è una merda poi cancella questo commento.
*/

%%% parser che riconosce il valore "true"
is_t(t).
is_r(r).
is_u(u).
is_e(e).

parser_true([Carattere1, Carattere2, Carattere3, Carattere4 | Resto],
            True, Resto) :-
    is_t(Carattere1),
    is_r(Carattere2),
    is_u(Carattere3),
    is_e(Carattere4),
    atomic_list_concat([Carattere1, Carattere2, Carattere3, Carattere4], True).


%%% parser che riconosce il valore "false"
is_f(f).
is_a(a).
is_l(l).
is_s(s).
% is_e/1 è già sopra

parser_false([Carattere1, Carattere2, Carattere3, Carattere4, Carattere5
            | Resto], False, Resto) :-
    is_f(Carattere1),
    is_a(Carattere2),
    is_l(Carattere3),
    is_s(Carattere4),
    is_e(Carattere5),
    atomic_list_concat([Carattere1, Carattere2, Carattere3, 
                        Carattere4, Carattere5], False).


%%% parser che riconosce il valore "null"
is_n(n).
% is_u/1 è già sopra
% is_l/1 è già sopra
% is_l/1 è già sopra

parser_null([Carattere1, Carattere2, Carattere3, Carattere4 | Resto],
            Null, Resto) :-
    is_n(Carattere1),
    is_u(Carattere2),
    is_l(Carattere3),
    is_l(Carattere4),
    atomic_list_concat([Carattere1, Carattere2, Carattere3, Carattere4], Null).


%%% is_quadra_aperta/2 e is_quadra_chiusa/2 dicono che '[' e ']' sono le quadre
is_quadra_aperta('[').
is_quadra_chiusa(']').

%%% is_virgola/2 dice che ',' è una virgola
is_virgola(',').

%%% array_parser/3 è il parser che riconosce se una lista di
%   caratteri è un array

% Se trova [ ] allora va bene
array_parser([ApertaQuadra | Altro],
	     Risultato,
	     Resto) :-
    is_quadra_aperta(ApertaQuadra),
    trim_testa(Altro, ChiusaQuadraResto),
    nth0(0, ChiusaQuadraResto, ChiusaQuadra, Resto),
    is_quadra_chiusa(ChiusaQuadra),
    atomic_list_concat([ApertaQuadra, ChiusaQuadra], Risultato),
    !.

% Se fallisce il caso di prima allora l'array non è vuoto
array_parser([ApertaQuadra | AltriCaratteri],
	     Risultato,
	     Resto) :-
    is_quadra_aperta(ApertaQuadra),
    leggi_valori(AltriCaratteri, ValoriLetti, Resto),
    atomic_list_concat([ApertaQuadra, ValoriLetti], Risultato),
    !.

% leggi_valori/3 serve a leggere i valori presenti nell'array

% Legge un valore se poi trova la virgola allora deve richiamare
% il predicato ricorsivamente.
leggi_valori(ListaCaratteri, Risultato, Resto) :-
    value_parser(ListaCaratteri, ValoreTrovato, AltriCaratteri),
    nth0(0, AltriCaratteri, Virgola, AltroValore),
    is_virgola(Virgola),
    leggi_valori(AltroValore, ValoriLetti, Resto),
    atomic_list_concat([ValoreTrovato, Virgola, ValoriLetti], Risultato).

% Legge un valore se poi trova la parentesi quadra chiusa allora
% si ferma.
leggi_valori(ListaCaratteri, Risultato, Resto) :-
    value_parser(ListaCaratteri, ValoreTrovato, AltriCaratteri),
    nth0(0, AltriCaratteri, QuadraChiusa, Resto),
    is_quadra_chiusa(QuadraChiusa),
    atomic_concat(ValoreTrovato, QuadraChiusa, Risultato).


%%% value_parser/3 effettua il parser di un valore json. Mancano objects

value_parser(Stringa, Valore, Resto) :-
    trim(Stringa, StringaSenzaSpazi),
    parser_string(StringaSenzaSpazi, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    writeln("TROVATA STRINGA"),
    !.

value_parser(Numero, Valore, Resto) :-
    trim(Numero, NumeroTrimmato),
    parser_q(NumeroTrimmato, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    writeln("TROVATO NUMERO"),
    !.

value_parser(True, Valore, Resto) :-
    trim(True, TrueTrimmato),
    parser_true(TrueTrimmato, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    writeln("TROVATO TRUE"),
    !.

value_parser(False, Valore, Resto) :-
    trim(False, FalseTrimmato),
    parser_false(FalseTrimmato, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    writeln("TROVATO FALSE"),
    !.

value_parser(Null, Valore, Resto) :-
    trim(Null, NullTrimmato),
    parser_null(NullTrimmato, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    writeln("TROVATO NULL"),
    !.

value_parser(Array, Valore, Resto) :-
    trim(Array, ArrayTrimmato),
    array_parser(ArrayTrimmato, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    writeln("TROVATO ARRAY"),
    !.
    
%%% end of file 
