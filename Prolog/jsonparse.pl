%%%% -*- Mode: Prolog -*-

%% Questo cesso di software è stato realizzato da:
%% Luca Pinciroli 885969
%% Marco Ferioli 879277


%% MOLTO IMPORTANTE: controllare di non superare le 80 colonne di larghezza
%% e mettere SEMPRE gli "SPAZZZZI DOPO GLI OPERATOOHRI"


% trasformo subito la stringa in una lista di codici di caratteri
% jsonparse/2 chiama direttamente jsonparse/5 sulla lista di codici di caratteri

% quanti e quali argomenti bisogna avere per poter parsare? 5 come gli interi?

jsonparse(JSONString, Object) :-
    string_codes(JSONString, ListOfCodes),
    jsonparse(ListOfCodes, Accumulator, OtherCodes, Elements, Object). % (?)

jsonparse(JSONString, Object) :-
    % predicato per controllare se JSONString è una stringa

jsonparse(JSONString, Object) :-
    % predicato per controllare se JSONString è un numero

jsonparse(JSONString, Object) :-
    % predicato per controllare se JSONString è un oggetto JSON

jsonparse(JSONString, Object) :-
    % predicato per controllare se JSONString è un array JSON
