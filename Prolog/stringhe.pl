%%% -*- Mode: prolog -*-

is_virgolette('\"').

parser_string([Virgolette | AltriCaratteri], Stringa, Resto) :-
    is_virgolette(Virgolette),
    leggi_stringa(AltriCaratteri, Letta, Resto),
    append([Virgolette], Letta, ListaStringa),
    atomics_to_string(ListaStringa, Stringa).

leggi_stringa([Virgolette | Resto], [Virgolette], Resto) :-
    is_virgolette(Virgolette),
    !.

leggi_stringa([Carattere | Altro], [Carattere | LettiPrecedentemente], Resto) :-
    char_type(Carattere, ascii),
    leggi_stringa(Altro, LettiPrecedentemente, Resto).
    
