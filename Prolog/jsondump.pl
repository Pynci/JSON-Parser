%%% -*- Mode: Prolog -*-

jsondump(JSON, FileName) :-
    inverti(JSON, JSONInvertito),
    open(FileName, write, Out),
    write(Out, JSONInvertito),
    put(Out, '.'),
    nl(Out),
    close(Out).
    
