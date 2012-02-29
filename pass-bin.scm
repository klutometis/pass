#!/usr/local/bin/csi -s
(use args pass debug)

(define default-cipherfile "~/var/pass")

(define options
  (list (args:make-option
         (f file)
         (required: "FILE")
         (format "Use cipherfile FILE [default: ~a]"
                 default-cipherfile))
        (args:make-option
         (h help)
         #:none
         "Display this text"
         (usage))))

(define (usage)
  (with-output-to-port
      (current-error-port)
    (lambda ()
      (print "Usage: "
             (car (argv))
             (string-append " [options...] (get DOMAIN-SUBSTRING |"
                            " set DOMAIN USER PASS | list)"))
      (newline)
      (print (args:usage options))
      (exit 1))))

(define (dispatch-set cipherfile domain user pass)
  (pass-set! cipherfile domain user pass))

(define (dispatch-get cipherfile domain)
  (pp-host-username-passwords (pass-ref cipherfile domain)))

(define (dispatch-list cipherfile)
  (pp-host-username-passwords (host-username-passwords cipherfile)))

(define (default-dispatcher . args)
  (usage))

(define dispatchers
  `(("set" . ,dispatch-set)
    ("get" . ,dispatch-get)
    ("list" . ,dispatch-list)))

(call-with-values
    (lambda ()
      (args:parse
       (command-line-arguments)
       options))
  (lambda (options operands)
    (let ((cipherfile (or (alist-ref 'f options)
                          (alist-ref 'file options)
                          default-cipherfile))
          (command (and (pair? operands)
                        (car operands))))
      (let ((dispatcher
             (if command
                 (alist-ref command
                            dispatchers
                            string-contains-ci
                            default-dispatcher)
                 (usage))))
        (condition-case
         (apply dispatcher (cons (normalize-pathname cipherfile)
                                 (cdr operands)))
         ((exn arity) (usage)))))))
