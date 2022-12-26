;;; Funzione value-parser

; sdp = stringa da parsare
; sl = stringa letta
(defun value-parser (sdp)
  (cond ((equal (subseq sdp 0 1) "\"") (let ((sl (concatenate 'string "\"" (leggi-stringa (subseq sdp 1)))))
    (cons sl (subseq sdp (length sl) (length sdp)))))))

;;; Fine funzione value-parser

;;; Funzione leggi-stringa

(defun leggi-stringa (stringa)
  (if (equal (subseq stringa 0 1) "\"")
      "\""
      (concatenate 'string (subseq stringa 0 1) (leggi-stringa (subseq stringa 1 (length stringa))))))

;;; Fine funzione leggi-stringa



