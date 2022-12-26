%%% -*- Mode: Prolog -*-

jsondump(JSON, FileName) :-
    inverti(JSON, JSONInvertito),
    open(FileName, write, Out),
    put(Out, '\''),
    write(Out, JSONInvertito),
    put(Out, '\''),
    put(Out, '.'),
    nl(Out),
    close(Out).
    
