%%% -*- Mode: Prolog -*-

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