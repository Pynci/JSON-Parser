;;; -*- Mode: Common-Lisp -*-

;; Progetto JSON PARSING realizzato da
;; Luca Pinciroli 885969
;; Marco Ferioli 879277



;;;;; --- INIZIO FILE jsonparse.lisp



;;; ---- inizio FUNZIONI DI SUPPORTO ----

;;; Funzione primo-carattere
;; ritorna la sottostringa contenente il primo carattere della stringa
;; passata come argomento.

(defun primo-carattere (stringa)
  (subseq stringa 0 1))

;;; Funzione rimuovi-carattere
;; ritorna una nuova stringa in cui viene rimosso il carattere passato
;; come argomento.

(defun rimuovi-carattere (carattere stringa)
  (cond ((equal stringa "") "")
        ((equal (primo-carattere stringa) carattere)
	 (concatenate 'string "" (rimuovi-carattere carattere (subseq stringa 1))))
        (T
	 (concatenate 'string (primo-carattere stringa)
		      (rimuovi-carattere carattere (subseq stringa 1))))))

;; -- inizio gestione virgolette --

;;; Funzione togli-virgolette
;; è una funzione di supporto che permette a jsonparse di convertire
;; le stringhe in input (passate nella forma "\"stringa\"") in semplici
;; stringhe lisp (espresse quindi nella forma "stringa").

(defun togli-virgolette (input)
  (if (listp input)
      (cond ((equal (first input) 'jsonarray) 
	     (cons 'jsonarray (scansiona-array (rest input))))
            ((equal (first input) 'jsonobj)
	     (cons 'jsonobj (scansiona-oggetto (rest input)))))
    (if (stringp input)
	(rimuovi-carattere "\\" (subseq input 1 (- (length input) 1)))
      input)))

(defun scansiona-array (array)
  (cond ((= (length array) 0) NIL)
        ((= (length array) 1) (cons (togli-virgolette (first array)) NIL))
        (T 
	 (cons (togli-virgolette (first array)) (scansiona-array (rest array))))))

(defun scansiona-oggetto (oggetto)
  (cond ((= (length oggetto) 0) NIL)
        ((= (length oggetto) 1)
	 (cons (cons (togli-virgolette (car (first oggetto)))
		     (cons (togli-virgolette (car (cdr (first oggetto)))) NIL)) NIL))
        (T
	 (cons (cons (togli-virgolette (car (first oggetto)))
		     (cons (togli-virgolette (car (cdr (first oggetto)))) NIL))
	       (scansiona-oggetto (rest oggetto))))))

;;; Funzione aggiungi-backslash
;; è una funzione di supporto che permette la corretta distinzione tra le
;; virgolette che delimitano la stringa ed eventuali virgolette poste
;; internamente alla stringa (aggiungendo il backslash alle virgolette
;; interne alla stringa)

(defun aggiungi-backslash (stringa)
  (cond ((equal stringa "") "")
        ((equal (primo-carattere stringa) "\"")
	 (concatenate 'string "\\\"" (aggiungi-backslash (subseq stringa 1))))
        (T
	 (concatenate 'string (primo-carattere stringa)
		      (aggiungi-backslash (subseq stringa 1))))))

;; -- fine gestione virgolette --

;;; Funzione scansiona-coppie
;; è una funzione di supporto utilizzata dalla funzione jsonaccess per poter
;; consultare i dati presenti all'interno delle coppie 'chiave:valore' di un
;; oggetto JSON

(defun scansiona-coppie (oggetto chiave)
  (if (null oggetto)
      NIL
    (if (equal (car (first oggetto)) chiave)
	(car (cdr (first oggetto)))
      (scansiona-coppie (rest oggetto) chiave))))

;;; Funzione appiattisci
;; è una funzione di supporto che prende una lista in input e la appiattisce.
;; Risulta particolarmente utile per operare con le liste all'interno della
;; funzione jsonaccess (evitando così errori generati dalla presenza di liste
;; innestate).

(defun appiattisci (input)
  (cond ((null input) input)
        ((atom input) (list input))
        (T (append (appiattisci (first input)) (appiattisci (rest input))))))

;;; --- fine FUNZIONI DI SUPPORTO ---



;;; --- inizio PARSING JSON ---

;;; Funzione jsonparse
;; è una funzione che riceve in input una stringa e sfrutta parser-value per
;; la struttura Lisp corrispondente alla stringa JSON specificata.

(defun jsonparse (stringa-da-parsare)
  (let ((JSON (parser-value stringa-da-parsare)))
    (if (listp (car JSON))
        (if (equal (car (cdr JSON)) "")
            (togli-virgolette (car JSON))
	  (error "[jsonparse] syntax error (invalid input)"))
      (if (equal (cdr JSON) "")
	  (togli-virgolette (car JSON))
	(error "[jsonparse] syntax error (invalid input)")))))

;;; Funzione parser-value
;; è una funzione che serve a parsare ricorsivamente i valori JSON contenuti
;; nella stringa passata in input.
;; Si occupa inoltre di costruire una struttura Lisp adeguata a memorizzare
;; tali valori.
;; sdp = stringa da parsare
;; sl = stringa letta
;; numlet = numero letto

(defun parser-value (stringa-non-trimmata)
  (let ((sdp (string-trim-whitespace stringa-non-trimmata)))
    (cond ((zerop (length sdp))
	   (error "[jsonparse] syntax error (empty input)"))
	  
	  ;; parsing oggetto
	  ((equal (primo-carattere sdp) "{")
	   (let ((oggetto-letto (cons 'jsonobj (leggi-oggetto (subseq sdp 1)))))
	     (cons (butlast oggetto-letto) (last oggetto-letto))))
	  
	  ;; parsing array
	  ((equal (primo-carattere sdp) "[")
	   (let ((array-letto (cons 'jsonarray (leggi-array (subseq sdp 1)))))
	     (cons (butlast array-letto) (last array-letto))))
	  
	  ;; parsing stringa
	  ((equal (primo-carattere sdp) "\"") 
	   (let ((sl (concatenate 'string "\"" (leggi-stringa (subseq sdp 1)))))
	     (cons sl (subseq sdp (length sl)))))
	  
	  ;; parsing numero positivo
	  ((numberp (digit-char-p (char sdp 0))) 
	   (let ((numlet (leggi-numero sdp)))
	     (let ((resto (subseq sdp (length numlet))))
	       (parser-numero numlet resto))))

	  ;; parsing numero negativo
	  ((equal (primo-carattere sdp) "-")
	   (let ((numlet (concatenate 'string "-" (leggi-numero (subseq sdp 1)))))
	     (let ((resto (subseq sdp (length numlet))))
	       (parser-numero numlet resto))))
	  
	  ;; parsing true, false e null
	  ((> (length sdp) 3)
	   (cond
            ((equal (subseq sdp 0 4) "null") 
	     (cons 'null (subseq sdp 4)))
            ((equal (subseq sdp 0 4) "true") 
	     (cons 'true (subseq sdp 4)))
            ((equal (subseq sdp 0 5) "false") 
	     (cons 'false (subseq sdp 5)))
            (T
	     (error "[jsonparse] syntax error (value not found)"))))
	  (T
	   (error "[jsonparse] syntax error (value not found)"))
	  )))

;;; --- fine PARSING JSON ---



;;; --- inizio ACCESSO JSON ---

;;; Funzione jsonaccess
;; consulta la struttura creata dalla funzione jsonparse secondo quanto
;; indicato dagli eventuali argomenti passati (il primo argomento è la
;; struttura, dal secondo argomento in poi bisogna specificare la lista di
;; campi  JSON da consultare), per poi restituire il dato individuato.

(defun jsonaccess (struttura &rest lista-non-flat)
  (let ((lista (appiattisci lista-non-flat)))
    (cond ((null (first lista)) struttura)    
	  ((numberp (first lista))
	   (if (listp struttura)
	       (if (equal (first struttura) 'jsonarray)
		   (if (< (first lista) (- (length struttura) 1))
		       (jsonaccess (nth (first lista) (rest struttura)) (rest lista))
		     (error "[jsonaccess] invalid input (index out of bounds)"))
		 (error "[jsonaccess] invalid parameter (array not found)"))
	     (error "[jsonaccess] invalid input")))
	  ((stringp (first lista))
	   (if (listp struttura)
	       (if (equal (first struttura) 'jsonobj)
		   (let ((valore (scansiona-coppie (rest struttura) (first lista))))
		     (if (not (null valore))
			 (jsonaccess valore (rest lista))
		       (error "[jsonaccess] invalid input (key not found)")))
		 (error "[jsonaccess] invalid parameter (object not found)"))
	     (error "[jsonaccess] invalid input"))))))

;;; --- fine ACCESSO JSON ---



;;; --- inizio STAMPA JSON SU FILE ---

;;; Funzione jsondump
;; come primo argomento riceve la struttura creata dalla funzione jsonparse,
;; mentre come secondo argomento riceve il nome di un file.
;; Si occupa di stampare la struttura JSON ricevuta sul file specificato
;; in sintassi JSON standard.

(defun jsondump (JSON nome-file)
  (with-open-file (stream nome-file
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
		  (write-string (inverti JSON) stream)))

;;; Funzione inverti
;; è una funzione di supporto che ritorna una stringa espressa in JSON standard
;; contenente il corrispettivo della struttura ricevuta in ingresso.

(defun inverti (valore)
  (cond ((equal valore 'true) "true")
	((equal valore 'false) "false")
	((equal valore 'null) "null")
	((numberp valore) (write-to-string valore))
	((stringp valore)
	 (concatenate 'string "\"" (aggiungi-backslash valore) "\""))
	((listp valore)
	 (if (equal (first valore) 'jsonarray)
	     (concatenate 'string "[" (inverti-array (rest valore)) "]")
	   (concatenate 'string "{" (inverti-oggetto (rest valore)) "}")))))

(defun inverti-array (array)
  (cond ((null array) "")
        ((null (rest array)) (inverti (first array)))
        (T
	 (concatenate 'string (inverti (first array)) ", "
		      (inverti-array (rest array))))))

(defun inverti-oggetto (oggetto)
  (cond ((null oggetto) "")
        ((null (rest oggetto)) (inverti-coppia (first oggetto)))
        (T
	 (concatenate 'string (inverti-coppia (first oggetto)) ", "
		      (inverti-oggetto (rest oggetto))))))

(defun inverti-coppia (coppia)
  (concatenate 'string (inverti (car coppia)) " : "
	       (inverti (car (cdr coppia)))))

;;; --- inizio STAMPA JSON SU FILE ---



;;; --- inizio LETTURA JSON DA FILE ---

;;; Funzione jsonread
;; riceve come argomento una stringa contenente il nome di un file e si occupa
;; di leggerne il contenuto e parsarlo utilizzando la funzione jsonparse

(defun jsonread (nome-file)
  (with-open-file (stream nome-file
                          :direction :input
                          :if-does-not-exist :error)
		  (jsonparse(leggi-da-file stream ""))))

(defun leggi-da-file (file contenuto)
  (let ((riga-letta (read-line file NIL)))
    (if (not (null riga-letta))
        (leggi-da-file file (concatenate 'string contenuto riga-letta))
      contenuto)))

;;; --- fine LETTURA JSON DA FILE ---



;; ----------------------------------------------------------------------------



;;; --- inizio PARSING STRINGHE ---

;;; Funzione leggi-stringa
;; è una funzione di supporto a parser-value che consente di individuare i 
;; caratteri facenti parte di una stringa JSON e il carattere \" di
;; terminazione della stringa JSON.

(defun leggi-stringa (stringa)
  (cond ((equal stringa "")
	 (error "[jsonparse] syntax error (missing \")"))
        ((equal (primo-carattere stringa) "\"")
	 "\"")
        ((equal (primo-carattere stringa) "\\")
	 (concatenate 'string (subseq stringa 0 2) (leggi-stringa (subseq stringa 2))))
        (T
	 (concatenate 'string (primo-carattere stringa)
		      (leggi-stringa (subseq stringa 1))))))

;;; --- fine PARSING STRINGHE ---



;;; --- inizio PARSING NUMERI ---

;;; Funzione parser-numero
;; è una funzione di supporto a parser-value che si occupa di effettuare
;; il parsing corretto tenendo conto di ciascun caso in cui può presentarsi
;; un numero: intero, virgola mobile, negativo, con esponente o senza ecc.
;; Viene impiegata per costruire correttamente l'output da far ritornare a
;; parser-value.

(defun parser-numero (numlet resto)
	(if (equal (primo-carattere resto) "e")
		   (if (equal (subseq resto 1 2) "-")
		       (let ((esponente (leggi-numero (subseq resto 2))))
			 (if (not (null (find #\. numlet)))
			     (cons (* (parse-float numlet)
				      (expt 10 (parse-integer (concatenate 'string "-" esponente))))
				   (subseq resto (+ 2 (length esponente))))
			   (cons (* (parse-integer numlet)
				    (expt 10 (parse-integer (concatenate 'string "-" esponente))))
				 (subseq resto (+ 2 (length esponente))))))
		     (let ((esponente (leggi-numero (subseq resto 1))))
		       (if (not (null (find #\. numlet)))
			   (cons (* (parse-float numlet)
				    (expt 10 (parse-integer esponente)))
				 (subseq resto (+ 1 (length esponente))))
			 (cons (* (parse-integer numlet)
				  (expt 10 (parse-integer esponente)))
			       (subseq resto (+ 1 (length esponente)))))))
		 (if (not (null (find #\. numlet)))
		     (cons (parse-float numlet) resto)
		   (cons (parse-integer numlet) resto))))

;;; Funzione leggi-numero
;; è una funzione di supporto a parser-numero che consente di individuare
;; le cifre facenti parte di un numero JSON.
;; pe = primo elemento

(defun leggi-numero (stringa)
  (if (zerop (length stringa))
      ""
    (let ((pe (primo-carattere stringa)))
      (if (not (numberp (digit-char-p (char pe 0))))
          (if (not(equal pe "."))
              ""
	    (concatenate 'string pe (leggi-numero (subseq stringa 1))))
	(concatenate 'string pe (leggi-numero (subseq stringa 1)))))))

;;; --- fine PARSING NUMERI ---



;;; --- inizio PARSING OGGETTO ---

;;; Funzione leggi-oggetto
;; è una funzione di supporto a parser-value che si occupa di leggere il
;; contenuto di un oggetto JSON e di creare la struttura lisp atta
;; ad ospitarlo.

(defun leggi-oggetto (stringa-ricevuta)
  (let ((stringa (string-trim-whitespace stringa-ricevuta)))
    (if (zerop (length stringa))
        (error "[jsonparse] jsonobj: syntax error (invalid object)")
      (let ((pe (primo-carattere stringa)))
	(cond 
	 ((equal pe "}") 
	  (cons (subseq stringa 1) NIL))
	 ((equal pe ",")
	  (let ((coppie-restanti (leggi-coppia (subseq stringa 1))))
	    (cons (car coppie-restanti) (leggi-oggetto (cdr coppie-restanti)))))
	 (T
	  (let ((prima-coppia (leggi-coppia stringa)))
	    (cons (car prima-coppia) (leggi-oggetto (cdr prima-coppia))))))))))

;;; Funzione leggi-coppia
;; è una funzione di supporto a leggi-oggetto che consente di costruire la
;; sotto-struttura (una lista di due elementi) atta a contenere una coppia
;; 'chiave:valore'.

(defun leggi-coppia (stringa-ricevuta)
  (let ((stringa (string-trim-whitespace stringa-ricevuta)))
    (if (equal (primo-carattere stringa) "\"")
	(let  ((chiave
		(concatenate 'string "\""
			     (leggi-stringa (subseq stringa 1)))))
	  (let ((resto
		 (string-trim-whitespace (subseq stringa (length chiave)
						 (length stringa)))))
	    (if (equal (primo-carattere resto) ":")
		(let ((valore
		       (parser-value (string-trim-whitespace (subseq resto 1)))))
		  (if (listp (car valore))
		      (cons (cons chiave (cons (car valore) NIL)) (car (cdr valore)))
		    (cons (cons chiave (cons (car valore) NIL)) (cdr valore))))
	      (error "[jsonparse] jsonobj: syntax error (missing ':')"))))
      (error "[jsonparse] jsonobj: syntax error (key is not a string)"))))

;;; --- fine PARSING OGGETTO ---



;;; --- inizio PARSING ARRAY ---

;;; Funzione leggi-array
;; è una funzione di supporto a parser-value che si occupa di leggere il
;; contenuto di un array JSON e di creare la struttura lisp atta ad ospitarlo.

(defun leggi-array (stringa-ricevuta)
  (let ((stringa (string-trim-whitespace stringa-ricevuta)))
    (if (zerop (length stringa))
	(error "[jsonparse] jsonarray: syntax error (invalid array)")
      (let ((pe (primo-carattere stringa)))
        (cond
	 ((equal pe "]") (cons (subseq stringa 1) NIL))
	 ((equal pe ",")
	  (let ((elementi-restanti (parser-value (subseq stringa 1))))
	    (if (listp (car elementi-restanti))
		(cons (car elementi-restanti)
		      (leggi-array (car (cdr elementi-restanti))))
	      (cons (car elementi-restanti)
		    (leggi-array (cdr elementi-restanti))))))
	 (T
	  (let ((primo-valore (parser-value stringa)))
	    (if (listp (car primo-valore))
		(cons (car primo-valore) (leggi-array (car (cdr primo-valore))))
	      (cons (car primo-valore) (leggi-array (cdr primo-valore)))))))))))

;;; --- fine PARSING ARRAY ---



;;;;; --- FINE FILE jsonparse.lisp