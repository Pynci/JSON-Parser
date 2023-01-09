%%% -*- Mode: Prolog -*-

jsonread(FileName, JSON) :-
    open(FileName, read, In),
    read(In, AtomLetto),
    close(In),
    atom_chars(AtomLetto, Lista),
    arricchisci_stringa_slash(Lista, ListaArricchita),
    atomic_list_concat(ListaArricchita, AtomoJSON),
    jsonparse(AtomoJSON, JSON).

arricchisci_stringa_slash([], []).

arricchisci_stringa_slash([Carattere1 | AltriCaratteri], [Carattere1 | Altro]) :-
    is_backslash(Carattere1),
    !,
    arricchisci_stringa_slash(AltriCaratteri, Altro).

arricchisci_stringa_slash([Carattere1 | AltriCaratteri], [Carattere1 | Risultato]) :-
    arricchisci_stringa_slash(AltriCaratteri, Risultato).
    
