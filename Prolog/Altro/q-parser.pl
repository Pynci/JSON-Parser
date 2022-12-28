%%% -*- Mode: Prolog -*-

%%% Posso leggere un - oppure direttamente un numero,
%%% ma se leggo il meno, allora lo devo successivamente concatenare in testa
%%% al numero che leggo. Posso leggere il meno solo se non ho letto nient'altro.

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


