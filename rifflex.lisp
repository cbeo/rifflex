;;;; rifflex.lisp

(in-package #:rifflex)

(defparameter *dict* (make-hash-table :test 'equal))

(defun load-cmu-dict ()
  (with-open-file (input "cmudict" :external-format :latin-1)
    (loop
       :for line = (read-line input nil nil)
       :while line :do
         (destructuring-bind (key _ . value) (split-sequence #\Space line)
           (declare (ignore _))
           (setf (gethash key *dict*) value)))))

(defun  lookup-word (word)
  (gethash (string-upcase word) *dict*))

(defun anagrams-of (word)
  (flet ((sort-word (w) (sort (copy-seq (string-upcase w)) #'char-lessp)))
    (let ((sorted (sort-word word)))
      (loop
         :for key :being :the :hash-key :of *dict*
         :when (equal sorted (sort-word key))
         :collect key))))

(defun rhymes-of (word)
  (when-let (phon (lookup-word word))
    (loop
       :for w :being :the :hash-key :of *dict*
       :for ph :being :the :hash-value :of *dict*
       :when (rhyme-p phon ph) :collect w)))

(defun rhyme-p (w1 w2)
  (perfect-rhyme-p w1 w2))

(defun vowel-p (ph)
  (not (equal "" (remove-if 'alpha-char-p ph))))

(defun unstressed-vowel-p (ph)
  (find #\0 ph))

(defun syllables (w)
  (let ((count 0))
    (dolist (ph w)
      (when (vowel-p ph) 
        (incf count)))
    (loop :for (ph . phs) :on w
       :when (and phs
                  (unstressed-vowel-p ph)
                  (unstressed-vowel-p (car phs)))
         :do (decf count)) ;; two unstressed vowels in a row are "like" one syllable
    count))

(defun drop-initial-consonants (w)
  (if (and w (vowel-p (car w))) w
      (drop-initial-consonants (cdr w))))

(defun perfect-rhyme-p (w1 w2)
  (let ((w1 (drop-initial-consonants w1))
        (w2 (drop-initial-consonants w2)))
    
    (when (= (length w1) (length w2))
      (loop
         :for ph1 :in w1
         :for ph2 :in w2
         :unless (phonetically-compatible-p ph1 ph2)  :do (return nil)
         :finally (return t)))))

(defparameter +weak-compatibilities+
  '(("ER" "R")))

(defun weakly-compatible (ph1 ph2)
  (dolist (ph-set +weak-compatibilities+)
    (when (and
           (member ph2 ph-set :test #'equal)
           (member ph1 ph-set :test #'equal))
      (return t))))

(defun phonetically-compatible-p (ph1 ph2)
  (let ((ph1 (remove-if-not #'alpha-char-p ph1))
        (ph2 (remove-if-not #'alpha-char-p ph2)))
    (or (equal ph1 ph2)
        
        (weakly-compatible ph1 ph2))))


#+sbcl
(defun exit ()
  (sb-ext:exit))

#+ecl
(defun exit ()
  (ext:exit))

#+sbcl
(defun cli-args ()
  sb-ext:*posix-argv*)


(defun main ()
  (when-let (word (second (cli-args)))
    (when-let (anagrams (anagrams-of word))
      (unless (= 1 (length anagrams))
        (format t "~%ANAGRAMS of ~a~%~%" word)
        (loop
           :for i :from 1
           :for a :in anagrams
           :do (princ (string-downcase a)) (princ " ")
           :when (zerop (mod i 5)) :do (terpri)))
      (terpri))
    (when-let (rhymes (rhymes-of word))
      (unless (= 1 (length rhymes))
        (format t "~%RHYMES of ~a~%~%" word)
        (let ((format-str (concatenate 'string
                                       "~"
                                       (format nil "~a" (+ 4 (length word)))
                                       "a ")))
          (loop :for i :from 1
             :for r :in rhymes
             :do (format t format-str (string-downcase r)) 
             :when (zerop (mod i 3)) :do (terpri))))
      (terpri))
    (exit))
  (format t "~%USAGE: rifflex <word>~%")
  (exit))
