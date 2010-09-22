(use debug files pass test)

(let ((cipherfile (create-temporary-file))
      (cryptovariable "123456"))
  (pass-set! cipherfile "a" "b" "c" cryptovariable)
  (pass-set! cipherfile "d" "e" "f" cryptovariable)
  (test
   "two pass-set!s and a pass-ref"
   '(("d" "e" . "f") ("a" "b" . "c"))
   (pass-ref cipherfile "" cryptovariable)))
