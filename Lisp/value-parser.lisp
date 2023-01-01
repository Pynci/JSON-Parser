;;; Funzione value-parser

; sdp = stringa da parsare
; sl = stringa letta
;numlet = numero letto

(defun value-parser (stringa-non-trimmata)
  (let ((sdp (string-trim-whitespace stringa-non-trimmata)))
    (cond ((zerop (length sdp)) (print "Non esiste nulla da analizzare."))
        ((equal (subseq sdp 0 1) "{")
          (let ((oggetto-letto (cons 'jsonobj (leggi-oggetto (subseq sdp 1)))))
            (cons (butlast oggetto-letto) (last oggetto-letto))))
        ((equal (subseq sdp 0 1) "[")
          (let ((array-letto (cons 'jsonarray (leggi-array (subseq sdp 1)))))
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

;;; Funzione parser-stringa

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

(defun leggi-array (stringa-ricevuta)
  (let ((stringa (string-trim-whitespace stringa-ricevuta)))
    (if (zerop (length stringa))
      (error "leggi-array: hai fatto una cacata")
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

;;; Fine funzione leggi-array

;;; Funzione leggi-oggetto

(defun leggi-oggetto (stringa-ricevuta)
  (let ((stringa (string-trim-whitespace stringa-ricevuta)))
    (if (zerop (length stringa))
        (error "leggi-oggetto: hai fatto una cacata")
        (let ((pe (subseq stringa 0 1)))
          (if (equal pe "}")
              (cons (subseq stringa 1 (length stringa)) NIL)
              leggi-coppia(stringa))))))

(defun leggi-coppia (stringa-ricevuta)
  ; continua qui, me so cacato er cazzo dato che sono le 19:30
  )
;;; Fine funzione leggi-oggetto 

; ((JSONARRAY 1 2 3) ",[4,5]]")