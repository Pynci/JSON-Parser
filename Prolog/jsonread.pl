%%% -*- Mode: Prolog -*-

jsonread(FileName, JSON) :-
    open(FileName, read, In),
    read(In, ContenutoFile),
    close(In),
    term_to_atom(ContenutoFile, JSON).
    %jsonparse(ContenutoAtomizzato, JSON).
    
