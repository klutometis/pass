(module
 pass
 (pass-ref
  pass-set!
  host
  username
  password
  host-username-passwords
  pp-host-username-passwords)

 (import scheme chicken)

 (use posix
      format
      debug
      with-encrypted-file
      (srfi 1 13))

 (define host car)
 (define username cadr)
 (define password cddr)

 (define (number-of-base-10-digits n)
   (inexact->exact (floor (/ (log n) (log 10)))))

 (define (pp-host-username-passwords host-username-passwords)
   (for-each
    (lambda (host-username-password)
      (format #t
              "~a\t~a\t~a~%"
              (host host-username-password)
              (username host-username-password)
              (password host-username-password)))
    host-username-passwords))

 (define host-username-passwords
   (case-lambda
    ((cipherfile) (host-username-passwords cipherfile (read-password)))
    ((cipherfile cryptovariable)
     (let ((file-size (file-size cipherfile)))
       (if (zero? file-size)
           '()
           (with-input-from-encrypted-file/password
            cipherfile
            read
            cryptovariable))))))

 (define pass-ref
   (case-lambda
    ((cipherfile partial-host)
     (pass-ref cipherfile partial-host (read-password)))
    ((cipherfile partial-host cryptovariable)
     (let ((host-username-passwords
            (host-username-passwords cipherfile cryptovariable)))
       (filter
        (lambda (host-username-password)
          (string-contains-ci (host host-username-password)
                              partial-host))
        host-username-passwords)))))

 (define pass-set!
   (case-lambda
    ((cipherfile host username password)
     (pass-set! cipherfile host username password (read-password)))
    ((cipherfile host username password cryptovariable)
     (let ((host-username-passwords
            (host-username-passwords cipherfile cryptovariable)))
       (with-output-to-encrypted-file/password
        cipherfile
        (lambda ()
          (write (alist-cons host
                             (cons username password)
                             host-username-passwords)))
        cryptovariable))))))
