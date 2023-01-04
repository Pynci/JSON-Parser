%%%% -*- Mode: Prolog -*-

%% Progetto JSON-Parser realizzato da
%% Luca Pinciroli 885969
%% Marco Ferioli 879277



%%%%% --- INIZIO FILE jsonparse.pl



% predicati base per il riconoscimento dei caratteri
is_virgolette('\"').
is_backslash('\\').
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
% la prima struttura che incontra.

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

%%% jsonaccess/3
% consulta la struttura composta creata da jsonparse/2 e risponde true se
% è in grado di trovare il dato specificato da Risultato percorrendo la
% struttura secondo quanto indicato dalla lista dei campi (passata come
% secondo argomento)

jsonaccess(jsonobj(X), [], jsonobj(X)) :- !.

jsonaccess(jsonarray(X), [], jsonarray(X)) :- !.

jsonaccess(jsonarray(X), Indice, Risultato) :-
    number(Indice),
    !,
    nth0(Indice, X, Risultato).

jsonaccess(jsonarray(X), [Indice], Risultato) :-
    number(Indice),
    !,
    nth0(Indice, X, Risultato).

jsonaccess(jsonarray(X), [Indice | Altro], Risultato) :-
    number(Indice),
    !,
    nth0(Indice, X, Accesso),
    jsonaccess(Accesso, Altro, Risultato).

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



%%%% ---- inizio STAMPA JSON SU FILE ----

%%% inverti/2
% è un predicato di supporto che serve ricavare i dati dagli oggetti JSON per
% comporre una stringa scritta in standard JSON (pronta da stampare su file)

inverti(Stringa, StringaFinale) :-
    string(Stringa),
    !,
    string_chars(Stringa, ListaDaArricchire),
    arricchisci_stringa(ListaDaArricchire, ListaArricchita),
    atom_chars(Atomo, ListaArricchita),
    atomic_list_concat(['"', Atomo, '"'], StringaFinale).

inverti(Numero, Numero) :-
    number(Numero),
    !.

inverti(Null, Null) :-
    Null = null,
    !.

inverti(True, True) :-
    True = true,
    !.

inverti(False, False) :-
    False = false,
    !.

inverti(jsonobj([]), Risultato) :-
    atomic_list_concat(['{', ' ', '}'], Risultato),
    !.

inverti(jsonobj([','(Chiave, Valore)]), Risultato) :-
    string(Chiave),
    string_chars(Chiave, ListaDaArricchireChiave),
    arricchisci_stringa(ListaDaArricchireChiave, ListaArricchitaChiave),
    atom_chars(AtomoChiave, ListaArricchitaChiave),
    inverti(Valore, ValoreInvertito),
    !,
    atomic_list_concat(['{', ' ', '"', AtomoChiave, '"', ' ', ':', ' ', ValoreInvertito, ' ', '}'], Risultato).

inverti(jsonobj([','(Chiave, Valore) | Altro]), Risultato) :-
    string(Chiave),
    string_chars(Chiave, ListaDaArricchireChiave),
    arricchisci_stringa(ListaDaArricchireChiave, ListaArricchitaChiave),
    atom_chars(AtomoChiave, ListaArricchitaChiave),
    inverti(Valore, ValoreInvertito),
    !,
    inverti(jsonobj(Altro), Risultato1),
    atom_chars(Risultato1, ListaCaratteriRisultato),
    nth0(0, ListaCaratteriRisultato, _Graffa, CaratteriRimanenti),
    atom_chars(AtomoCaratteriRimanenti, CaratteriRimanenti),
    atomic_list_concat(['{', ' ', '"', AtomoChiave, '"', ' ', ':', ' ', ValoreInvertito, ',', AtomoCaratteriRimanenti], Risultato).

inverti(jsonarray([]), Risultato) :-
    atomic_list_concat(['[', ' ', ']'], Risultato),
    !.

inverti(jsonarray([Valore]), Risultato) :-
    inverti(Valore, ValoreInvertito),
    !,
    atomic_list_concat(['[', ValoreInvertito, ']'], Risultato).

inverti(jsonarray([Valore]), Risultato) :-
    string(Valore),
    !,
    atomic_list_concat(['[', '"', Valore, '"', ']'], Risultato).

inverti(jsonarray([Valore | Altro]), Risultato) :-
    inverti(Valore, ValoreInvertito),
    !,
    inverti(jsonarray(Altro), Risultato1),
    atom_chars(Risultato1, ListaCaratteriRisultato),
    nth0(0, ListaCaratteriRisultato, _Quadra, CaratteriRimanenti),
    atom_chars(AtomoCaratteriRimanenti, CaratteriRimanenti),
    atomic_list_concat(['[', ValoreInvertito, ',', ' ', AtomoCaratteriRimanenti], Risultato).

inverti(jsonarray([Valore | Altro]), Risultato) :-
    string(Valore),
    !,
    inverti(jsonarray(Altro), Risultato1),
    atom_chars(Risultato1, ListaCaratteriRisultato),
    nth0(0, ListaCaratteriRisultato, _Quadra, CaratteriRimanenti),
    atom_chars(AtomoCaratteriRimanenti, CaratteriRimanenti),
    atomic_list_concat(['[', '"', Valore, '"', ',', ' ', AtomoCaratteriRimanenti], Risultato).


%%% arricchisci_stringa/2
% è un predicato di supporto necessario per poter gestire correttamente il caso
% in cui si presentino delle virgolette interne ad una stringa.
% Aggiunge i backslash necessari a distinguere le virgolette interne da quelle
% che delimitano la stringa per permettere al predicato inverti/2 di gestirle
% in maniera adeguata.

arricchisci_stringa([], []).

arricchisci_stringa([Carattere1 | AltriCaratteri], ['\\', Carattere1 | Altro]) :-
    is_virgolette(Carattere1),
    !,
    arricchisci_stringa(AltriCaratteri, Altro).

arricchisci_stringa([Carattere1 | AltriCaratteri], [Carattere1 | Risultato]) :-
    arricchisci_stringa(AltriCaratteri, Risultato).


%%% jsondump/2
% è un predicato che consente di stampare il contenuto di un oggetto JSON
% su file (trasformandolo in standard JSON).
% Per chiarimenti su questa parte si veda il file README.txt allegato.

jsondump(JSON, FileName) :-
    inverti(JSON, JSONInvertito),
    open(FileName, write, Out),
    %put(Out, '\''),
    write(Out, JSONInvertito),
    %put(Out, '\''),
    %put(Out, '.'),
    nl(Out),
    close(Out).

%%%% ---- fine STAMPA JSON SU FILE ----



%%%% ---- inizio LETTURA JSON DA FILE ----

%%% jsonread/2
% è un predicato che consente di leggere quanto stampato da jsondump/2 su file.

jsonread(FileName, JSON) :-
    %open(FileName, read, In),
    %read(In, AtomLetto),
    %close(In),
    read_file_to_string(FileName, Stringa, []),
    atom_string(Atomo, Stringa),
    atom_chars(Atomo, Lista),
    arricchisci_stringa_slash(Lista, ListaArricchita),
    atomic_list_concat(ListaArricchita, AtomoJSON),
    jsonparse(AtomoJSON, JSON).


%%% arricchisci_stringa_slash/2
% è un predicato di supporto che consente a jsonread/2 di distinguere le
% virgolette interne alla stringa da quelle che la delimitano, così che
% possa gestirle in maniera coerente.

arricchisci_stringa_slash([], []).

arricchisci_stringa_slash([Carattere1 | AltriCaratteri], [Carattere1 | Altro]) :-
    is_backslash(Carattere1),
    !,
    arricchisci_stringa_slash(AltriCaratteri, Altro).

arricchisci_stringa_slash([Carattere1 | AltriCaratteri], [Carattere1 | Risultato]) :-
    arricchisci_stringa_slash(AltriCaratteri, Risultato).

%%%% ---- fine LETTURA JSON DA FILE ----



%%%% ---- inizio PARSING STRINGHE ----

%%% parser_string/3
% è un predicato che consente di riconoscere una stringa a partire da una
% sequenza di caratteri

parser_string([Virgolette | AltriCaratteri], Stringa, Resto) :-
    is_virgolette(Virgolette),
    leggi_stringa(AltriCaratteri, Letta, Resto),
    atomic_list_concat(Letta, AtomoStringa),
    atom_string(AtomoStringa, Stringa).

%%% leggi_stringa/3
% è un predicato di supporto che permette a parser_string/3 di individuare
% i caratteri appartenenti alla stringa e le virgolette che indicano la fine
% della stringa stessa.

leggi_stringa([Virgolette | Resto], [], Resto) :-
    is_virgolette(Virgolette),
    !.

leggi_stringa([BackSlash, Carattere | Altro], [Carattere | LettiPrecedentemente], Resto) :-
    is_backslash(BackSlash),
    !,
    char_type(Carattere, ascii),
    leggi_stringa(Altro, LettiPrecedentemente, Resto).

leggi_stringa([Carattere | Altro], [Carattere | LettiPrecedentemente], Resto) :-
    char_type(Carattere, ascii),
    leggi_stringa(Altro, LettiPrecedentemente, Resto).

%%%% ---- fine PARSING STRINGHE ----



%%%% ---- inizio PARSING NUMERI ----

%%% parser_n/3
% è un predicato che consente di riconoscere un numero naturale a partire
% da una sequenza di caratteri.
% L'implementazione è tratta da quella presentata all'interno delle slide
% del corso.

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


%%% parser_z/3
% è un predicato che consente di riconoscere un numero intero (negativo) a
% partire da una sequenza di caratteri.

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


%%% parser_q/3
% è un predicato che consente di riconoscere un numero razionale (composto da
% una parte intera e una parte decimale) a partire da una sequenza di caratteri

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

%%% parser_object/3
% è un predicato che consente di riconoscere la struttura complessa di un
% object in JSON a partire da una sequenza di caratteri.
% Il predicato inoltre costruisce una struttura prolog composta che permette di
% immagazzinare al suo interno i dati che caratterizzano l'object riconosciuto.

parser_object([Graffa | Sequenza], jsonobj(), Resto) :-
    is_aperta_graffa(Graffa),
    trim_testa(Sequenza, GraffaAltro),
    nth0(0, GraffaAltro, ChiusaGraffa, Resto),
    is_chiusa_graffa(ChiusaGraffa).

parser_object([Graffa | Sequenza], jsonobj(Coppie), Resto) :-
    is_aperta_graffa(Graffa),
    trim_testa(Sequenza, SequenzaSenzaSpazi),
    leggi_coppie(SequenzaSenzaSpazi, Coppie, Resto).

%%% leggi_coppie/3
% è un predicato di supporto che consente a parser_object/3 di individuare
% tutte le coppie chiave:valore che fanno parte dell'object JSON.
% Individua inoltre la parentesi graffa che decreta la fine dell'object JSON.

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

%%% parser_array/3
% è un predicato che consente di riconoscere la struttura complessa di un
% array in JSON a partire da una sequenza di caratteri.
% Il predicato inoltre si occupa di costruire una struttura prolog composta in
% grado di immagazzinare la lista di elementi che caratterizzano l'array JSON.

parser_array([ApertaQuadra | SpaziAltro], jsonarray([]), Resto) :-
    is_quadra_aperta(ApertaQuadra),
    trim_testa(SpaziAltro, Altro),
    nth0(0, Altro, ChiusaQuadra, Resto),
    is_quadra_chiusa(ChiusaQuadra),
    !.

parser_array([ApertaQuadra | Altro], jsonarray(ListaElementi), Resto) :-
    is_quadra_aperta(ApertaQuadra),
    leggi_elementi(Altro, ListaElementi, Resto).

%%% leggi_elementi/3
% è un predicato di supporto che permette a parser_array/3 di individuare
% tutti gli elementi facenti parte dell'array JSON.
% Individua inoltre la partentesi quadra che decreta la fine dell'array JSON.

leggi_elementi(ListaCaratteri, [ValoreTrovato | ValoriLetti], Resto) :-
    parser_value(ListaCaratteri, ValoreTrovato, AltriCaratteri),
    nth0(0, AltriCaratteri, Virgola, AltroValore),
    is_virgola(Virgola),
    leggi_elementi(AltroValore, ValoriLetti, Resto),
    !.

leggi_elementi(ListaCaratteri, [ValoreTrovato], Resto) :-
    parser_value(ListaCaratteri, ValoreTrovato, AltriCaratteri),
    nth0(0, AltriCaratteri, QuadraChiusa, Resto),
    is_quadra_chiusa(QuadraChiusa).

%%%% ---- inizio PARSING ARRAY ----



%%%% ---- inizio PARSING TRUE ----

%%% parser_true/3
% è un predicato che permette di riconoscere il booleano true a partire da una
% sequenza di caratteri.

parser_true([Carattere1, Carattere2, Carattere3, Carattere4 | Resto],
            True, Resto) :-
    is_t(Carattere1),
    is_r(Carattere2),
    is_u(Carattere3),
    is_e(Carattere4),
    atomic_list_concat([Carattere1, Carattere2, Carattere3, Carattere4], True).

%%%% ---- fine PARSING TRUE ----



%%%% ---- inizio PARSING FALSE ----

%%% parser_false/3
% è un predicato che permette di riconoscere il booleano false a partire da una
% sequenza di caratteri.

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

%%% parser_null/3
% è un predicato che permette di riconoscere il tipo di dato null a partire 
% da una sequenza di caratteri.

parser_null([Carattere1, Carattere2, Carattere3, Carattere4 | Resto],
            Null, Resto) :-
    is_n(Carattere1),
    is_u(Carattere2),
    is_l(Carattere3),
    is_l(Carattere4),
    atomic_list_concat([Carattere1, Carattere2, Carattere3, Carattere4], Null).

%%%% ---- fine PARSING NULL ----



%%%% ---- inizio libreria TRIM ----

%%% trim/2
% è un predicato in grado di rimuovere gli spazi durante la procedura di
% parsing: in questo modo l'utente può inserire un numero indefinito di
% caratteri di spaziatura senza intaccare il funzionamento di jsonparse/2

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


%%% trim_testa/2
% è un predicato di supporto che consente a trim/2 di rimuovere le spaziature
% poteste in testa ad una lista di caratteri

trim_testa([], []).

trim_testa([Carattere | Altro], [Carattere | Altro]) :-
    not(char_type(Carattere, space)),
    !.

trim_testa([Spazio | []], []) :-
    char_type(Spazio, space),
    !.

trim_testa([Spazio, Carattere | Altro], [Carattere | Altro]) :-
    char_type(Spazio, space),
    not(char_type(Carattere, space)),
    !.

trim_testa([Spazio | Altro], NuovaLista) :-
    char_type(Spazio, space),
    !,
    trim_testa(Altro, NuovaLista).

%%% trim_coda/2
% è un predicato di supporto che sfrutta trim_testa/2 per rimuovere le
% spaziature poste in coda ad una lista di caratteri.
% NB: si fa uso del predicato di sistema reverse/2 per invertire la lista.

trim_coda(ListaDaTrimmare, ListaTrimmata) :-
    reverse(ListaDaTrimmare, ListaRibaltata),
    !,
    trim_testa(ListaRibaltata, TrimmataTesta),
    reverse(TrimmataTesta, ListaTrimmata).

%%%% ---- fine libreria TRIM ----



%%%%% --- FINE FILE jsonparse.pl