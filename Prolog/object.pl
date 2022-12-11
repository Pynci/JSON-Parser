%%% -*- Mode: Prolog -*-

pair(SequenzaChiave, SequenzaValore) :-
    parser_string(SequenzaChiave, _X, []),
    value_parser(SequenzaValore, _Y, []).

is_aperta_graffa('{').
is_chiusa_graffa('}').
is_double_point(':').

parser_object([Graffa | Sequenza], json_obj(), Resto) :-
    is_aperta_graffa(Graffa),
    trim_testa(Sequenza, GraffaAltro),
    nth0(0, GraffaAltro, ChiusaGraffa, Resto),
    is_chiusa_graffa(ChiusaGraffa).

parser_object([Graffa | Sequenza], json_obj(Coppie), Resto) :-
    is_aperta_graffa(Graffa),
    trim_testa(Sequenza, SequenzaSenzaSpazi),
    leggi_coppie(SequenzaSenzaSpazi, Coppie, Resto).

leggi_coppie(Sequenza, [pair(Chiave, ValoreLetto) | [CoppieLette]], Resto) :-
    parser_string(Sequenza, Chiave, Altro),
    trim_testa(Altro, AltroSenzaSpazi),
    nth0(0, AltroSenzaSpazi, DuePunti, Valore),
    is_double_point(DuePunti),
    value_parser(Valore, ValoreLetto, VirgolaAltraCoppia),
    nth0(0, VirgolaAltraCoppia, Virgola, SpazioAltraCoppia),
    is_virgola(Virgola),
    trim_testa(SpazioAltraCoppia, AltraCoppia),
    leggi_coppie(AltraCoppia, CoppieLette, Resto).

leggi_coppie(Sequenza, pair(Chiave, ValoreLetto), Resto) :-
    parser_string(Sequenza, Chiave, Altro),
    trim_testa(Altro, AltroSenzaSpazi),
    nth0(0, AltroSenzaSpazi, DuePunti, Valore),
    is_double_point(DuePunti),
    value_parser(Valore, ValoreLetto, GraffaChiusaResto),
    nth0(0, GraffaChiusaResto, Graffa, Resto),
    is_chiusa_graffa(Graffa).
    
    
    
    
    
