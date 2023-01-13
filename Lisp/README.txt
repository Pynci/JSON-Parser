Tutte le funzioni dovrebbero funzionare correttamente come richiesto dalle specifiche fornite.
All'interno di una stringa Common Lisp le virgolette vanno esplicitate con la combinazione di caratteri \" e il backslash va invece esplicitato con la combinazione di caratteri \\: per questo motivo, per inserire delle virgolette all'interno di una stringa JSON sarà necessario esplicitarle con la combinazione di caratteri \\\".

ESEMPIO:
CL USER 42 > (jsonparse "\"Una volta il maestro Oogway disse: \\\"Il caso non esiste\\\"\"")
"Una volta il maestro Oogway disse: \"Il caso non esiste\""