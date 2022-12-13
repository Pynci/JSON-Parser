%%% -*- Mode: Prolog -*-

% predicati is
is_virgolette('\"').
is_meno('-').
is_punto('.').
is_t(t).
is_r(r).
is_u(u).
is_e(e).
is_f(f).
is_a(a).
is_l(l).
is_s(s).
is_n(n).
is_quadra_aperta('[').
is_quadra_chiusa(']').
is_virgola(',').
is_aperta_graffa('{').
is_chiusa_graffa('}').
is_double_point(':').




%%%% ---- inizio PARSING JSON ----

%%% jsonparse/2
% riceve in input un atomo contenente JSON (StringaJSON) e una struttura da 
% riconoscere in Oggetto.
% Se Oggetto non è istanziato, il predicato risponde riconoscendo
% la prima struttura che incontra

% se in input arriva un atomo allora per prima cosa viene trasformato in una
% lista di caratteri
jsonparse(StringaJSON, Oggetto) :-
    atom(StringaJSON),
    atom_chars(StringaJSON, ListaCaratteri),
    !,
    jsonparse(ListaCaratteri, Oggetto).

jsonparse(ListaCaratteri, Oggetto) :-
    parser_value(ListaCaratteri, Oggetto, []),
    !.


%%% parser_value/3
% riceve in input una lista di caratteri e ne identifica un valore.
% Un valore può essere una stringa, un numero, un array, un oggetto,
% true, false, null.

parser_value(Stringa, Valore, Resto) :-
    trim(Stringa, StringaSenzaSpazi),
    parser_string(StringaSenzaSpazi, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    %writeln("TROVATA STRINGA"),
    !.

parser_value(Numero, Valore, Resto) :-
    trim(Numero, NumeroTrimmato),
    parser_q(NumeroTrimmato, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    %writeln("TROVATO NUMERO"),
    !.

parser_value(Oggetto, Valore, Resto) :-
    trim(Oggetto, OggettoTrimmato),
    parser_object(OggettoTrimmato, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    %writeln("TROVATO OGGETTO"),
    !.

parser_value(Array, Valore, Resto) :-
    trim(Array, ArrayTrimmato),
    parser_array(ArrayTrimmato, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    %writeln("TROVATO ARRAY"),
    !.

parser_value(True, Valore, Resto) :-
    trim(True, TrueTrimmato),
    parser_true(TrueTrimmato, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    %writeln("TROVATO TRUE"),
    !.

parser_value(False, Valore, Resto) :-
    trim(False, FalseTrimmato),
    parser_false(FalseTrimmato, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    %writeln("TROVATO FALSE"),
    !.

parser_value(Null, Valore, Resto) :-
    trim(Null, NullTrimmato),
    parser_null(NullTrimmato, Valore, RestoConSpazi),
    trim(RestoConSpazi, Resto),
    %writeln("TROVATO NULL"),
    !.

%%%% ---- fine PARSING JSON ----



%%%% ---- inizio ACCESSO JSON ----

jsonaccess(jsonobj(X), [], jsonobj(X)).

jsonaccess(jsonobj([','(Stringa, Risultato) | _]), [Stringa], Risultato) :- !.

jsonaccess(jsonobj([','(_Chiave, _Valore) | AltreCoppie]), [Stringa], Risultato) :-
    jsonaccess(jsonobj(AltreCoppie), [Stringa], Risultato).

jsonaccess(jsonobj([','(Stringa, jsonobj(AltreCoppie)) | _]), [Stringa | AltreStringhe], Risultato) :-
    jsonaccess(jsonobj(AltreCoppie), AltreStringhe, Risultato),
    !.

jsonaccess(jsonobj([','(_Chiave, _Valore) | AltreCoppie]), [Stringa | AltreStringhe], Risultato) :-
    jsonaccess(jsonobj(AltreCoppie), [Stringa | AltreStringhe], Risultato),
    !.

jsonaccess(jsonobj([','(Stringa, jsonarray(Lista)) | _]), [Stringa, Numero], Risultato) :-
    number(Numero),
    !,
    nth0(Numero, Lista, Risultato, _).

jsonaccess(jsonobj([','(_Chiave, _Valore) | AltreCoppie]), [Stringa, Numero], Risultato) :-
    number(Numero),
    !,
    jsonaccess(jsonbj(AltreCoppie), [Stringa, Numero], Risultato).


jsonaccess(jsonobj([','(Stringa, jsonarray(Lista)) | _]), 
            [Stringa, Numero | AltriCampi], Risultato) :-
    number(Numero),
    !,
    nth0(Numero, Lista, jsonobj(Altro)),
    jsonaccess(jsonobj(Altro), AltriCampi, Risultato).

jsonaccess(jsonobj(','(_Chiave, _Valore) | AltreCoppie),
            [Stringa, Numero | AltriCampi], Risultato) :-
    number(Numero),
    !,
    jsonaccess(jsonobj(AltreCoppie), [Stringa, Numero | AltriCampi], Risultato).


jsonaccess(jsonobj(X), Stringa, Risultato) :-
    string(Stringa),
    jsonaccess(jsonobj(X), [Stringa], Risultato),
    !.

%%%% ---- fine ACCESSO JSON ----



%%%% ---- inizio PARSING STRINGHE ----

parser_string([Virgolette | AltriCaratteri], Stringa, Resto) :-
    is_virgolette(Virgolette),
    leggi_stringa(AltriCaratteri, Letta, Resto),
    atomic_list_concat(Letta, AtomoStringa),
    atom_string(AtomoStringa, Stringa).

%%% leggi_stringa/3 serve a leggere i caratteri e le virgolette di chiusura

leggi_stringa([Virgolette | Resto], [], Resto) :-
    is_virgolette(Virgolette),
    !.

leggi_stringa([Carattere | Altro], [Carattere | LettiPrecedentemente], Resto) :-
    char_type(Carattere, ascii),
    leggi_stringa(Altro, LettiPrecedentemente, Resto).

%%%% ---- fine PARSING STRINGHE ----



%%%% ---- inizio PARSING NUMERI ----

%%% parser del numero naturale.

parse_n(Chars, I , MoreChars) :-
    parse_n(Chars, [], I, _, MoreChars).

parse_n([D | Ds], DsSoFar, I, ICs, Rest) :-
    is_digit(D),
    !,
    parse_n(Ds, [D | DsSoFar], I, ICs, Rest).

parse_n([C | Cs], DsR, I, Digits, [C | Cs]) :-
    !,
    reverse(DsR, Digits),
    number_string(I, Digits).

parse_n([], DsR, I, Digits, []) :-
    !,
    reverse(DsR, Digits),
    number_string(I, Digits).


%%% parser del numero intero (anche negativo)

parser_z(Caratteri, NumeroOttenuto, CaratteriRestanti) :-
    parser_z(Caratteri, [], NumeroOttenuto, _CifreDelNumero, CaratteriRestanti).

parser_z([Meno | CifreRimanenti], [], NumeroOttenuto, CifreDelNumero, CaratteriRestanti) :-
    is_meno(Meno),
    !,
    parser_z(CifreRimanenti, [Meno], NumeroOttenuto, CifreDelNumero, CaratteriRestanti).

parser_z([Cifra | CifreRimanenti], CifreLette, NumeroOttenuto, CifreDelNumero, CaratteriRestanti) :-
    is_digit(Cifra),
    !,
    parser_z(CifreRimanenti, [Cifra | CifreLette], NumeroOttenuto, CifreDelNumero, CaratteriRestanti).

parser_z([Carattere | CaratteriRestanti], CifreLette, NumeroOttenuto, CifreDelNumero, [Carattere | CaratteriRestanti]) :-
    %is_non_digit(Carattere),
    !,
    reverse(CifreLette, CifreDelNumero),
    number_string(NumeroOttenuto, CifreDelNumero).

parser_z([], CifreLette, NumeroOttenuto, CifreDelNumero, []) :-
    !,
    reverse(CifreLette, CifreDelNumero),
    number_string(NumeroOttenuto, CifreDelNumero).


%%% Parser numeri razionali

parser_q(Sequenza, NumeroOttenuto, CaratteriRimanenti) :-
    parser_q(Sequenza, [], NumeroOttenuto, _SequenzaLetta, CaratteriRimanenti).

parser_q(Sequenza, [], NumeroOttenuto, SequenzaLetta, Resto) :-
    parser_z(Sequenza, [], _Intero, ListaIntero, CaratteriRimanenti),
    parser_decimale(CaratteriRimanenti, ListaDecimali, Resto),
    append(ListaIntero, ListaDecimali, SequenzaLetta),
    number_string(NumeroOttenuto, SequenzaLetta).

parser_decimale([Punto | Altro], ['.' | ListaDecimali], Resto) :-
    is_punto(Punto),
    !,
    parse_n(Altro, [], _Decimale, ListaDecimali, Resto).

parser_decimale([Carattere | Altro], [], [Carattere | Altro]).

parser_decimale([], [], []).

%%%% ---- fine PARSING NUMERI ----



%%%% ---- inizio PARSING OGGETTO ----

parser_object([Graffa | Sequenza], jsonobj(), Resto) :-
    is_aperta_graffa(Graffa),
    trim_testa(Sequenza, GraffaAltro),
    nth0(0, GraffaAltro, ChiusaGraffa, Resto),
    is_chiusa_graffa(ChiusaGraffa).

parser_object([Graffa | Sequenza], jsonobj(Coppie), Resto) :-
    is_aperta_graffa(Graffa),
    trim_testa(Sequenza, SequenzaSenzaSpazi),
    leggi_coppie(SequenzaSenzaSpazi, Coppie, Resto).

leggi_coppie(Sequenza, [','(Chiave, ValoreLetto) | CoppieLette], Resto) :-
    parser_string(Sequenza, Chiave, Altro),
    trim_testa(Altro, AltroSenzaSpazi),
    nth0(0, AltroSenzaSpazi, DuePunti, Valore),
    is_double_point(DuePunti),
    parser_value(Valore, ValoreLetto, VirgolaAltraCoppia),
    nth0(0, VirgolaAltraCoppia, Virgola, SpazioAltraCoppia),
    is_virgola(Virgola),
    trim_testa(SpazioAltraCoppia, AltraCoppia),
    leggi_coppie(AltraCoppia, CoppieLette, Resto),
    !.

leggi_coppie(Sequenza, [','(Chiave, ValoreLetto)], Resto) :-
    parser_string(Sequenza, Chiave, Altro),
    trim_testa(Altro, AltroSenzaSpazi),
    nth0(0, AltroSenzaSpazi, DuePunti, Valore),
    is_double_point(DuePunti),
    parser_value(Valore, ValoreLetto, GraffaChiusaResto),
    nth0(0, GraffaChiusaResto, Graffa, Resto),
    is_chiusa_graffa(Graffa).

%%%% ---- fine PARSING OGGETTO ----



%%%% ---- inizio PARSING ARRAY ----

parser_array([ApertaQuadra | SpaziAltro], jsonarray([]), Resto) :-
    is_quadra_aperta(ApertaQuadra),
    trim_testa(SpaziAltro, Altro),
    nth0(0, Altro, ChiusaQuadra, Resto),
    is_quadra_chiusa(ChiusaQuadra),
    !.

parser_array([ApertaQuadra | Altro], jsonarray(ListaElementi), Resto) :-
    is_quadra_aperta(ApertaQuadra),
    leggi_elementi(Altro, ListaElementi, Resto).

% Legge un valore se poi trova la virgola allora deve richiamare
% il predicato ricorsivamente.
leggi_elementi(ListaCaratteri, [ValoreTrovato | ValoriLetti], Resto) :-
    parser_value(ListaCaratteri, ValoreTrovato, AltriCaratteri),
    nth0(0, AltriCaratteri, Virgola, AltroValore),
    is_virgola(Virgola),
    leggi_elementi(AltroValore, ValoriLetti, Resto),
    !.

% Legge un valore se poi trova la parentesi quadra chiusa allora
% si ferma.
leggi_elementi(ListaCaratteri, [ValoreTrovato], Resto) :-
    parser_value(ListaCaratteri, ValoreTrovato, AltriCaratteri),
    nth0(0, AltriCaratteri, QuadraChiusa, Resto),
    is_quadra_chiusa(QuadraChiusa).

%%%% ---- inizio PARSING ARRAY ----



%%%% ---- inizio PARSING TRUE ----

parser_true([Carattere1, Carattere2, Carattere3, Carattere4 | Resto],
            True, Resto) :-
    is_t(Carattere1),
    is_r(Carattere2),
    is_u(Carattere3),
    is_e(Carattere4),
    atomic_list_concat([Carattere1, Carattere2, Carattere3, Carattere4], True).

%%%% ---- fine PARSING TRUE ----



%%%% ---- inizio PARSING FALSE ----

parser_false([Carattere1, Carattere2, Carattere3, Carattere4, Carattere5
            | Resto], False, Resto) :-
    is_f(Carattere1),
    is_a(Carattere2),
    is_l(Carattere3),
    is_s(Carattere4),
    is_e(Carattere5),
    atomic_list_concat([Carattere1, Carattere2, Carattere3, 
                        Carattere4, Carattere5], False).

%%%% ---- fine PARSING FALSE ----



%%%% ---- inizio PARSING NULL ----

parser_null([Carattere1, Carattere2, Carattere3, Carattere4 | Resto],
            Null, Resto) :-
    is_n(Carattere1),
    is_u(Carattere2),
    is_l(Carattere3),
    is_l(Carattere4),
    atomic_list_concat([Carattere1, Carattere2, Carattere3, Carattere4], Null).

%%%% ---- fine PARSING NULL ----



%%%% ---- inizio libreria TRIM ----

trim(Atomo, ListaTrimmata) :-
    atom(Atomo),
    !,
    atom_chars(Atomo, ListaCaratteri),
    trim_testa(ListaCaratteri, TrimmataTesta),
    trim_coda(TrimmataTesta, ListaTrimmata).

trim(Lista, ListaTrimmata) :-
    atomic_list_concat(Lista, AtomoLista),
    !,
    trim(AtomoLista, ListaTrimmata).


%%% trim_testa/2 rimuove le spaziature superflue in testa

%%% se non ho caratteri il gioco finisce subito
trim_testa([], []).

%%% se il primo carattere non è di spaziatura sono a posto
trim_testa([Carattere | Altro], [Carattere | Altro]) :-
    not(char_type(Carattere, space)),
    !.

%%% caso base: non ci sono caratteri alfanumerici
trim_testa([Spazio | []], []) :-
    char_type(Spazio, space),
    !.

%%% caso base: solo il primo primo carattere è di spaziatura
trim_testa([Spazio, Carattere | Altro], [Carattere | Altro]) :-
    char_type(Spazio, space),
    not(char_type(Carattere, space)),
    !.

%%% se il primo carattere è di spaziatura lo scarto
trim_testa([Spazio | Altro], NuovaLista) :-
    char_type(Spazio, space),
    !,
    trim_testa(Altro, NuovaLista).

%%% trim_coda/2 rimuove le spaziature superflue in coda
trim_coda(ListaDaTrimmare, ListaTrimmata) :-
    reverse(ListaDaTrimmare, ListaRibaltata),
    !,
    trim_testa(ListaRibaltata, TrimmataTesta),
    reverse(TrimmataTesta, ListaTrimmata).

%%% reverse/2 inverte una lista
reverse(Lista, ListaInvertita) :-
    reverse(Lista, [], ListaInvertita),
    !.

%%% reverse/3 fa da supporto a reverse/2
reverse([], ListaInvertita, ListaInvertita).
reverse([Carattere | Resto], Accumulatore, ListaInvertita) :-
    reverse(Resto, [Carattere | Accumulatore], ListaInvertita),
    !.

%%%% ---- fine libreria TRIM ----