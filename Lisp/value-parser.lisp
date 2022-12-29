;;; Funzione value-parser

; sdp = stringa da parsare
; sl = stringa letta
;numlet = numero letto

(defun value-parser (sdp)
  (cond ((zerop (length sdp)) (print "Non esiste nulla da analizzare."))
        ((equal (subseq sdp 0 1) "[")
          (let ((array-letto (cons 'JSONARRAY (leggi-array (subseq sdp 1)))))
            array-letto))
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
        ))
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

(defun leggi-array (stringa)
  (if (zerop (length stringa))
      ""
      (let ((pe (subseq stringa 0 1)))
        (cond
          ((equal pe "]") NIL)
          ((equal pe ",")
            (let ((elementi-restanti (value-parser (subseq stringa 1 (length stringa)))))
              (cons (first elementi-restanti) (leggi-array (rest elementi-restanti)))))
          (T
            (cons (first (value-parser stringa)) (leggi-array (rest (value-parser stringa)))))))))


;(cons (first (value-parser (subseq 1 (length stringa)))) (leggi-array (rest (value-parser stringa))))