%%%% -*- Mode: Prolog -*-

%% Questo cesso di software è stato realizzato da:
%% Luca Pinciroli 885969
%% Marco Ferioli 879277


%% MOLTO IMPORTANTE: controllare di non superare le 80 colonne di larghezza
%% e mettere SEMPRE gli "SPAZZZZI DOPO GLI OPERATOOHRI"

is_spazio(' ').
is_virgolette('\"').
is_newline('\n').
is_quadra_aperta('[').
is_quadra_chiusa(']').



% trasformo subito la stringa in una lista di codici di caratteri
% quanti e quali argomenti bisogna avere per poter parsare? 5 come gli interi?
jsonparse(JSONString, Object) :-
    atom_codes(JSONString, ListOfCodes),
    jsonparse(ListOfCodes, Object).

jsonparse([X | Xs], Object) :-
    %jsonarray...
