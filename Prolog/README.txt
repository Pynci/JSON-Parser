Tutti i predicati dovrebbero funzionare correttamente come richiesto dalle specifiche fornite.
Dal momento che prolog interpreta le virgolette sia come " che come \", per poter inserire delle
virgolette all'interno di una stringa bisogna esplicitarle con la combinazione di caratteri \\".
Sia la risposta dell'ambiente prolog che la stampa su file renderanno facilmente distinguibili
le virgolette che delimitano la stringa da quelle inserite all'interno di essa.

ESEMPIO:
?- jsonparse(' "Una volta il maestro Oogway disse: \\"il caso non esiste\\"" ', O).
O = "Una volta il maestro Oogway disse: \"il caso non esiste\"".
