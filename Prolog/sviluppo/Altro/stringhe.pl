%%% -*- Mode: prolog -*-

is_virgolette('\"').
is_backslash('\\').

parser_string([Virgolette | AltriCaratteri], Stringa, Resto) :-
    is_virgolette(Virgolette),
    leggi_stringa(AltriCaratteri, Letta, Resto),
    append([Virgolette], Letta, ListaStringa),
    atomic_list_concat(ListaStringa, Stringa).

leggi_stringa([Virgolette | Resto], [Virgolette], Resto) :-
    is_virgolette(Virgolette),
    !.

leggi_stringa([BackSlash, Carattere | Altro], [Significato | LettiPrecedentemente], Resto) :-
    is_backslash(BackSlash),
    !,
    char_type(Carattere, ascii),
    atom_concat('\\', Carattere, Significato),
    leggi_stringa(Altro, LettiPrecedentemente, Resto).

leggi_stringa([Carattere | Altro], [Carattere | LettiPrecedentemente], Resto) :-
    char_type(Carattere, ascii),
    leggi_stringa(Altro, LettiPrecedentemente, Resto).


    
