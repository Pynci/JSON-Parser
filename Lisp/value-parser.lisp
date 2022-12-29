;;; Funzione value-parser

; sdp = stringa da parsare
; sl = stringa letta
;numlet = numero letto

(defun value-parser (sdp)
  (cond ((zerop (length sdp)) (print "Non esiste nulla da analizzare."))
        ((equal (subseq sdp 0 1) "\"") 
         (let ((sl (concatenate 'string "\"" (leggi-stringa (subseq sdp 1)))))
           (cons sl (subseq sdp (length sl)))))
        ((numberp (digit-char-p (char sdp 0))) 
         (let ((numlet (leggi-numero sdp)))
           (cons (parse-float numlet) (subseq sdp (length numlet)))))
        ((equal (subseq sdp 0 1) "-") 
         (let ((numlet (concatenate 'string "-" (leggi-numero (subseq sdp 1)))))
           (cons (parse-float numlet) (subseq sdp (length numlet)))))
        ((equal (subseq sdp 0 4) "null") 
         (cons "null" (subseq sdp 4)))
        ((equal (subseq sdp 0 4) "true") 
         (cons "true" (subseq sdp 4)))
        ((equal (subseq sdp 0 5) "false") 
         (cons "false" (subseq sdp 5)))
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


#|
(defun leggi-numero (stringa)
  (let ((pe (subseq stringa 0 1)))
    (if (equal pe ".")
      )))
|#

;;; Fine funzione leggi-numero

