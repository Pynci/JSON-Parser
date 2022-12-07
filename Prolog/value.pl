%%% -*- Mode: Prolog -*-

%%% is_virgolette/1 dice che '"' è una virgoletta
is_virgolette('\"').


%%% is_space/1 dice che ' ' è uno spazio
is_spazio(' ').

%%% is_newline/1 dice che '\n' è un newline
is_newline('\n').

%%% is_whitespace/1 riconosce i caratteri di spaziatura accettati
is_whitespace(X) :-
    is_spazio(X).
is_whitespace(X) :-
    is_newline(X).


%%% parser_string/3 è definito da tre parametri:
%   Sequenza_caratteri, Stringa, Resto.
%   Sequenza_caratteri rappresenta la lista dei caratteri
%   Stringa rappresenta la stringa convertita
%   Resto rappresenta i caratteri rimanenti
%   Una stringa è definita da un'apertura di una virgoletta, una sequenza di caratteri
%   ed una chiusura di virgoletta.
%   leggi_stringa/3 serve a leggere i caratteri e le virgolette di chiusura.

parser_string([Virgolette | AltriCaratteri], Stringa, Resto) :-
    is_virgolette(Virgolette),
    leggi_stringa(AltriCaratteri, Letta, Resto),
    append([Virgolette], Letta, ListaStringa),
    atomic_list_concat(ListaStringa, Stringa).

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
is_n('n').
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


%%% value_parser/3 effettua il parser di un valore json. Mancano array ed objects

value_parser([Spazio1 , Spazio2 | Resto], Valore, Resto) :-
    is_whitespace(Spazio1),
    is_whitespace(Spazio2),
    atomic_list_concat([Spazio1, Spazio2], Valore).

value_parser([Spazio1 | AltriCaratteri], Valore, RestoSenzaSpazio) :-
    is_whitespace(Spazio1),
    parser_string(AltriCaratteri, Valore, Resto),
    nth0(0, Resto, Spazio2, RestoSenzaSpazio),
    is_whitespace(Spazio2),
    writeln("TROVATA STRINGA"),
    !.

value_parser([Spazio1 | AltriCaratteri], Valore, RestoSenzaSpazio) :-
    is_whitespace(Spazio1),
    parser_q(AltriCaratteri, Valore, Resto),
    nth0(0, Resto, Spazio2, RestoSenzaSpazio),
    is_whitespace(Spazio2),
    writeln("TROVATO NUMERO"),
    !.

value_parser([Spazio1 | AltriCaratteri], Valore, RestoSenzaSpazio) :-
    is_whitespace(Spazio1),
    parser_true(AltriCaratteri, Valore, Resto),
    nth0(0, Resto, Spazio2, RestoSenzaSpazio),
    is_whitespace(Spazio2),
    writeln("TROVATO TRUE"),
    !.

value_parser([Spazio1 | AltriCaratteri], Valore, RestoSenzaSpazio) :-
    is_whitespace(Spazio1),
    parser_false(AltriCaratteri, Valore, Resto),
    nth0(0, Resto, Spazio2, RestoSenzaSpazio),
    is_whitespace(Spazio2),
    writeln("TROVATO FALSE"),
    !.

value_parser([Spazio1 | AltriCaratteri], Valore, RestoSenzaSpazio) :-
    is_whitespace(Spazio1),
    parser_null(AltriCaratteri, Valore, Resto),
    nth0(0, Resto, Spazio2, RestoSenzaSpazio),
    is_whitespace(Spazio2),
    writeln("TROVATO NULL"),
    !.

value_parser([Spazio1 | AltriCaratteri], Valore, RestoSenzaSpazio) :-
    is_whitespace(Spazio1),
    array_parser(AltriCaratteri, Valore, Resto),
    nth0(0, Resto, Spazio2, RestoSenzaSpazio),
    is_whitespace(Spazio2),
    writeln("TROVATO ARRAY"),
    !.
    
%%% end of file 
