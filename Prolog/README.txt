Sebbene tutti i predicati funzionino come descritto nelle specifiche, abbiamo
dovuto ricorrere ad alcuni compromessi per poter parsare correttamente le
virgolette interne ad una stringa.

In particolare occorre sapere che:

-	per inserire delle virgolette all’interno della stringa bisogna
	esplicitarle tramite la sequenza di caratteri \\” (dal momento
	che prolog interpreta \” direttamente come	delle virgolette
	senza backslash “).
	ESEMPIO:	jsonparse(‘{ “citazione” : “\\”hello there\”” }’, O).
	RISPOSTA: 	O = jsonobj([(“citazione”, “\”hello there\””)]).

-	il predicato di stampa su file jsondump/2 stampa su file ciò che riceve
	convertendolo in JSON standard, tuttavia per poterne facilitare la lettura
	tramite SWI-Prolog senza rinunciare al riconoscimento delle virgolette
	interne alla stringa abbiamo deciso di circondare il JSON con apici.
	ESEMPIO:	jsondump(O, ‘prova.txt’).
	NEL FILE:	'{"citazione":"\\"hello there\\""}'.

Senza “atomizzare” il contenuto del file non risultava possibile distinguere e
riconoscere in maniera corretta le virgolette interne da quelle che delimitano la
stringa, dal momento che SWI-Prolog e alcuni predicati di sistema
(come atomic_list_concat) manipolano le virgolette e i backslash in maniera
automatica, senza permettere di gestire i vari casi singolarmente.