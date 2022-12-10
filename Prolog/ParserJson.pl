%%% FILE DI TEST
% questo è un file di test in cui provare diverse combinazioni di ciò che
% abbiamo implementato fino ad adesso.
% Verrà usato per cercare di rispondere alle issue #9 e #10 senza pasticciare
% quello che è già stato sviluppato negli altri file

%%% DISCLAIMER
% prima di utilizzare questo file importare direttamente in SWI-PROLOG
% i file contenenti tutti i predicati di cui si ha bisogno (e che sono già
% implementati in altri file prolog)


%%% jsonparse/2
% riceve in input un atomo contenente JSON e una struttura da riconoscere
% in Object. Se Object non è istanziato il predicato risponde riconoscendo
% la prima struttura che incontra

% se in input arriva un atomo allora per prima cosa viene trasformato in una
% lista di caratteri
jsonparse(StringaJSON, Oggetto) :-
    atom(StringaJSON),
    atom_chars(StringaJSON, ListaCaratteri),
    jsonparse(ListaCaratteri, Oggetto).

%%% Continuo a fare dei testi qui la mattina dell' 11 DICEMBRE 2022 -Pinci
