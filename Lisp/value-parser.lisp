;;; Funzioni di supporto

(defun primo-carattere (stringa)
  (subseq stringa 0 1))

(defun togli-virgolette (input)
  (if (listp input)
      (cond ((equal (first input) 'jsonarray) 
              (cons 'jsonarray (scansiona-array (rest input))))
            ((equal (first input) 'jsonobj)
              (cons 'jsonobj (scansiona-oggetto (rest input)))))
      (if (stringp input)
          (subseq input 1 (- (length input) 1))
          input)))

(defun scansiona-array (array)
  (cond ((= (length array) 0) NIL)
        ((= (length array) 1) (cons (togli-virgolette (first array)) NIL))
        (T (cons (togli-virgolette (first array)) (scansiona-array (rest array))))))

(defun scansiona-oggetto (oggetto)
  (cond ((= (length oggetto) 0) NIL)
        ((= (length oggetto) 1)
          (cons (cons (togli-virgolette (car (first oggetto))) (cons (togli-virgolette (car (cdr (first oggetto)))) NIL)) NIL))
        (T
          (cons (cons (togli-virgolette (car (first oggetto))) (cons (togli-virgolette (car (cdr (first oggetto)))) NIL)) (scansiona-oggetto (rest oggetto))))))

;;; fine funzioni di supporto


;;; funzione jsonparse

(defun jsonparse (stringa-da-parsare)
  (let ((JSON (parser-value stringa-da-parsare)))
    (if (listp (car JSON))
        (if (equal (car (cdr JSON)) "")
            (togli-virgolette (car JSON))
            (error "[jsonparse] syntax error (invalid input)"))
        (if (equal (cdr JSON) "")
            (togli-virgolette (car JSON))
            (error "[jsonparse] syntax error (invalid input)")))))

;;; fine funzione jsonparse



;;; funzione jsonaccess

;;; fine funzione jsonaccess



;;; Funzione parser-value

; sdp = stringa da parsare
; sl = stringa letta
; numlet = numero letto

(defun parser-value (stringa-non-trimmata)
  (let ((sdp (string-trim-whitespace stringa-non-trimmata)))
    (cond ((zerop (length sdp)) (error "[jsonparse] syntax error (empty input)"))
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
            (if (not (null (find #\. numlet)))
                (cons (parse-float numlet) (subseq sdp (length numlet)))
                (cons (parse-integer numlet) (subseq sdp (length numlet))))))
        ((equal (primo-carattere sdp) "-") 
          (let ((numlet (concatenate 'string "-" (leggi-numero (subseq sdp 1)))))
            (if (not (null (find #\. numlet)))
                (cons (parse-float numlet) (subseq sdp (length numlet)))
                (cons (parse-integer numlet) (subseq sdp (length numlet))))))
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
;;; Fine funzione parser-value

;;; Funzione parser-stringa

(defun leggi-stringa (stringa)
  (cond ((equal stringa "")
          (error "[jsonparse] syntax error (missing \")"))
        ((equal (primo-carattere stringa) "\"")
          "\"")
        ((equal (primo-carattere stringa) "\\")
          (concatenate 'string (subseq stringa 0 2) (leggi-stringa (subseq stringa 2))))
        (T
          (concatenate 'string (primo-carattere stringa) (leggi-stringa (subseq stringa 1))))))

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

#|
(if (= (length array) 1)
      (cons (togli-virgolette (first array)) NIL)
      (cons (togli-virgolette (first array)) (scansiona-array (rest array))))
 |#