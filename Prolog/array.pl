%%% -*- Mode: Prolog -*-

%%% is_quadra_aperta/2 e is_quadra_chiusa/2 dicono che '[' e ']' sono le quadre
is_quadra_aperta('[').
is_quadra_chiusa(']').

%%% is_spazio/2 e is_newline/2 determinano i caratteri di spaziatura accettati
is_spazio(' ').
is_newline('\n'). % non so se il newline si fa così (?)

%%% is_whitespace/2 verifica che X sia un carattere di spaziatura accettato
is_whitespace(X) :-
    is_spazio(X).
is_whitespace(X) :-
    is_newline(X).

%%% is_virgola/2 dice che ',' è una virgola
is_virgola(',').

%%% continua...