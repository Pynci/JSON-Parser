%%% -*- Mode: Prolog -*-


pair(X, Y) :-
    parser_string(X, _Chiave, []),
    parser_value(Y, _Valore, []).

is_aperta_graffa('{').
is_chiusa_graffa('}').

parser_object([Graffa | Sequenza], Oggetto, Resto) :-
    is_aperta_graffa(Graffa),
    trim_testa(Sequenza, GraffaAltro),
    nth0(0, GraffaAltro, ChiusaGraffa, Resto),
    is_chiusa_graffa(ChiusaGraffa),
    atomic_list_concat(['{', '}'], Oggetto).

    
