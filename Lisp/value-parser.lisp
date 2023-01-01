;;; Funzione value-parser

; sdp = stringa da parsare
; sl = stringa letta
;numlet = numero letto

(defun value-parser (stringa-non-trimmata)
  (let ((sdp (string-trim-whitespace stringa-non-trimmata)))
    (cond ((zerop (length sdp)) (print "Non esiste nulla da analizzare."))
        ((equal (subseq sdp 0 1) "[")
          (let ((array-letto (cons 'JSONARRAY (leggi-array (subseq sdp 1)))))
            (cons (butlast array-letto) (last array-letto))))
        ((equal (subseq sdp 0 1) "\"") 
          (let ((sl (concatenate 'string "\"" (leggi-stringa (subseq sdp 1)))))
            (cons sl (subseq sdp (length sl)))))
        ((numberp (digit-char-p (char sdp 0))) 
          (let ((numlet (leggi-numero sdp)))
            (cons (parse-float numlet) (subseq sdp (length numlet)))))
        ((equal (subseq sdp 0 1) "-") 
          (let ((numlet (concatenate 'string "-" (leggi-numero (subseq sdp 1)))))
           (cons (parse-float numlet) (subseq sdp (length numlet)))))
        ((> (length sdp) 3)
          (cond
            ((equal (subseq sdp 0 4) "null") 
              (cons "null" (subseq sdp 4)))
            ((equal (subseq sdp 0 4) "true") 
              (cons "true" (subseq sdp 4)))
            ((equal (subseq sdp 0 5) "false") 
              (cons "false" (subseq sdp 5)))
            (T
              (error "Input non valido"))))
        (T
          (error "Input non valido"))
        )))
;;; Fine funzione value-parser

;;; Funzione leggi-stringa

(defun leggi-stringa (stringa)
  (if (equal (subseq stringa 0 1) "\"")
      "\""
    (concatenate 'string (subseq stringa 0 1) (leggi-stringa (subseq stringa 1 (length stringa))))))

;;; Fine funzione leggi-stringa

;;; Funzione leggi-numero

;pe = primo elemento

(defun leggi-numero (stringa)
  (if (zerop (length stringa))
    ""
    (let ((pe (subseq stringa 0 1)))
      (if (not (numberp (digit-char-p (char pe 0))))
          (if (not(equal pe "."))
              ""
              (concatenate 'string pe (leggi-numero (subseq stringa 1 (length stringa)))))
          (concatenate 'string pe (leggi-numero (subseq stringa 1 (length stringa))))))))

;;; Fine funzione leggi-numero

;;; Funzione leggi-array

#| SPIEGAZIONE "RAPIDA"
Se la stringa in input è vuota allora restituisce la stringa vuota
Altrimenti va a guardare il primo elemento (pe):
  - se il primo elemento è ] allora restituisce (volutamente) una cons con dentro come car tutto il rimanente al di fuori
    dell'array racchiuso in una stringa, e come cdr invece NIL (infatti sarà la cons che chiude la lista)
  - se invece becca una virgola allora la salta e parsa ciò che si trova dopo la virgola e richiama la lettura dell'array
    sui possibili elementi rimanenti (infatti se vedi restituisce una cons con car ciò che ha parsato value-parser e cdr quello
    che manca da parsare per concludere l'array)
  - se invece trova una qualsiasi altra cosa (che non sia ] o virgola) allora significa che ha davanti l'elemento da parsare
Qual è il senso di restituire una lista del tipo (jsonarray elemento elemento ... robaFuoriArray) avente quindi come ultimo elemento
una lista contenente tutto quello che rimane?
In questo modo quando si torna indietro al value-parser è lui a occuparsi del resto: restituisce una cons con car tutta la lista escluso
l'ultimo elemento (che è proprio la stringa contenente tutto il testo rimanente) e con cdr l'ultimo elemento rimosso prima.
Se qualcosa non ti torna scrivimi e fammelo sapere! :D

~Pynci
 |#
(defun leggi-array (stringa-ricevuta)
  (let ((stringa (string-trim-whitespace stringa-ricevuta)))
    (if (zerop (length stringa))
      ""
      (let ((pe (subseq stringa 0 1)))
        (cond
          ((equal pe "]") (cons (subseq stringa 1 (length stringa)) NIL))
          ((equal pe ",")
            (let ((elementi-restanti (value-parser (subseq stringa 1 (length stringa)))))
              (cond ((listp (car elementi-restanti)) 
                      (cons (first elementi-restanti) (leggi-array (car (cdr elementi-restanti)))))
                    (t (cons (first elementi-restanti) (leggi-array (rest elementi-restanti)))))))
          (T
            (let ((primo-valore (value-parser stringa)))
              (cond ((listp (car primo-valore)) 
                      (cons (car primo-valore) (leggi-array (car (cdr primo-valore)))))
                    (t (cons (car primo-valore) (leggi-array (cdr primo-valore))))))))))))


;[1,2, 3] [1,2] resto , 3