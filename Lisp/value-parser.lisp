
(defun primo-carattere (stringa)
  (subseq stringa 0 1))

;;; Funzione parser-value

; sdp = stringa da parsare
; sl = stringa letta
;numlet = numero letto

(defun parser-value (stringa-non-trimmata)
  (let ((sdp (string-trim-whitespace stringa-non-trimmata)))
    (cond ((zerop (length sdp)) (print "Non esiste nulla da analizzare."))
        ((equal (primo-carattere sdp) "{")
          (let ((oggetto-letto (cons 'jsonobj (leggi-oggetto (subseq sdp 1)))))
            (cons (butlast oggetto-letto) (last oggetto-letto))))
        ((equal (primo-carattere sdp) "[")
          (let ((array-letto (cons 'jsonarray (leggi-array (subseq sdp 1)))))
            (cons (butlast array-letto) (last array-letto))))
        ((equal (primo-carattere sdp) "\"") 
          (let ((sl (concatenate 'string "\"" (leggi-stringa (subseq sdp 1)))))
            (cons sl (subseq sdp (length sl)))))
        ((numberp (digit-char-p (char sdp 0))) 
          (let ((numlet (leggi-numero sdp)))
            (cons (parse-float numlet) (subseq sdp (length numlet)))))
        ((equal (primo-carattere sdp) "-") 
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
;;; Fine funzione parser-value

;;; Funzione parser-stringa

(defun leggi-stringa (stringa)
  (if (equal (primo-carattere stringa) "\"")
      "\""
    (concatenate 'string (primo-carattere stringa) (leggi-stringa (subseq stringa 1)))))

;;; Fine funzione leggi-stringa

;;; Funzione leggi-numero

;pe = primo elemento

(defun leggi-numero (stringa)
  (if (zerop (length stringa))
    ""
    (let ((pe (primo-carattere stringa)))
      (if (not (numberp (digit-char-p (char pe 0))))
          (if (not(equal pe "."))
              ""
              (concatenate 'string pe (leggi-numero (subseq stringa 1))))
          (concatenate 'string pe (leggi-numero (subseq stringa 1)))))))

;;; Fine funzione leggi-numero

;;; Funzione leggi-array


;; REMINDER: rimanere coerenti con l'utilizzo di first/rest e di car/cdr
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
                (cons (car elementi-restanti) (leggi-array (car (cdr elementi-restanti))))
                (cons (car elementi-restanti) (leggi-array (cdr elementi-restanti))))))
          (T
            (let ((primo-valore (parser-value stringa)))
              (if (listp (car primo-valore))
                (cons (car primo-valore) (leggi-array (car (cdr primo-valore))))
                (cons (car primo-valore) (leggi-array (cdr primo-valore)))))))))))

;;; Fine funzione leggi-array

;;; Funzione leggi-oggetto

; REMINDER: sostituire i cond con if ove possibile
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

(defun leggi-coppia (stringa-ricevuta)
  (let ((stringa (string-trim-whitespace stringa-ricevuta)))
    (if (equal (primo-carattere stringa) "\"")
      (let  ((chiave (concatenate 'string "\"" (leggi-stringa (subseq stringa 1)))))
        (let ((resto (string-trim-whitespace (subseq stringa (length chiave) (length stringa)))))
          (if (equal (primo-carattere resto) ":")
            (let ((valore (parser-value (string-trim-whitespace (subseq resto 1)))))
              (if (listp (car valore))
                (cons (cons chiave (cons (car valore) NIL)) (car (cdr valore)))
                (cons (cons chiave (cons (car valore) NIL)) (cdr valore))))
            (error "[jsonparse] jsonobj: syntax error (missing ':')"))))
      (error "[jsonparse] jsonobj: syntax error (key is not a string)"))))
;;; Fine funzione leggi-oggetto 

