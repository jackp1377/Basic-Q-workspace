#lang racket

(require racket/trace)
;; An Expression is one of:
;; - (if Expression Expression Expression)
;; - (lambda (Var) Expression)
;; - Variable -- just symbols
;; - Number
;; - (Expression Expression ...)
;; - (MACRO S-Expression ...)

;; - An S-Expression is one of:
;; - Number
;; - Symbol
;; - (S-Expression ...)

(define the-macros (make-hash))
(define (macro? m) (hash-ref the-macros m #f))
(define (get-macro m) (hash-ref the-macros m))
(struct closure (args body))
(define gen-env '())

(define (extend-syntax! m proc)
  (hash-set! the-macros m proc))

(define (car-helper list)
  (match list
    (`(/ ,l ... )
      (car l))
    (_ (car list))))

(define (cdr-helper list)
(match list
    (`(/ ,l ... )
      (cons '/ (cdr l)))
    (_ (cdr list))))

(define (cons-helper a1 a2)
  (match a2
    (`(/ ,l ... )
      (cons '/ (cons a1 l)))
    (_ (cons a1 a2))
  )
)


(define (interp s)
  (let loop ([s (expand s)])
    ; (println s)
    (match s
      (`(/ ) '(/ ))
      (`(/ ,l ... )
        s)
      (`(car ,l)
        (car-helper (loop l)))
      (`(cdr ,l)
        (cdr-helper (loop l)))
      (`(cons ,i1 ,i2)
        (cons-helper (loop i1) (loop i2)))
      (`(list-empty? ,l)
        (if (equal? l `(/ )) 1 0))
      [`(if ,(app loop 0) ,e1 ,e2) (loop e2)]
      [`(if ,(app loop x) ,e1 ,e2) (loop e1)]
      (`(symbol=? ,v1 ,v2) (if (eq? (loop v1) (loop v2)) 1 0))
      [`(lambda (,x) ,body)
        ; (println s)
        (lambda (v) (loop (subst x v body)))]
      #;[`(,(? macro? m) ,operand ...)
       (interp ((get-macro m) s))]
      [`(,f ,e ...) 
          (apply (loop f) (map loop e))]
      ((? symbol?) s)
      ((? procedure?) s)
      [(? number?) s])))

; '(lambda (c) (if (!list-empty? (!list 1 3 5)) (!list) (cons (car c) (#<procedure:...expression-defs.rkt:45:8> (cdr c)))))

(define (subst x v s)
  (match s
    [(== x) v]
    [`(if ,e1 ,e2 ,e3) `(if ,(subst x v e1)
                            ,(subst x v e2)
                            ,(subst x v e3))]
    [`(lambda (,x0) ,b)
     (if (eq? x0 x)
         s
         `(lambda (,x0)
            ,(subst x v b)))]
    [`+ +]
    (`- -)
    [(list e ...) (map (lambda (e) (subst x v e)) e)]
    [_ s]))

;; expand : S-Expression -> Expression
;; expand all the macros
(define (expand s)
  ; (println s)
  (match s
    [(? number?) s]
    [(? symbol?) s]
    [`(lambda (,v) ,body)
     `(lambda (,v) ,(expand body))]
    [`(if ,tst ,thn ,els)
     `(if ,(expand tst) ,(expand thn) ,(expand els))]
    [`(,(? macro? m) ,operand ...)
     (expand ((get-macro m) s))]
    ; ((clo/)
    [`(,op ,operand ...)
     `(,(expand op) ,@(map expand operand))]))

(extend-syntax! 'or
                (lambda (s)
                  (match s
                    [`(or ,a ,b)
                     `(let ([x ,a])
                        (if x
                            x
                            ,b))]
                    [`(or ,a ,b ,c)
                     `(or ,a (or ,b ,c))])))



(extend-syntax! 'let
                (λ (s)
                  (match s
                     [`(let ((,x ,v)) ,b)
                      `((lambda (,x) ,b) ,v)])))

(extend-syntax! 'cond
  (lambda (s-express)
    (letrec ((loop 
      (lambda (s) 
        (match s
          (`(cond ,se ...) (loop se))
          ('() '(void))
          (`((else ,se)) se)
          (`((,se1 ,se2) ...)
            `(if ,(car se1) 
                ,(car se2)
                ,(loop (cdr s))))
          (_ (error "unhandled " s)))))) 
      (loop s-express))))

; (extend-syntax! 'Yv
;   (lambda (f)
;     ((lambda (x) (f (lambda v (apply (x x) v))))
;       (lambda (x) (f (lambda v (apply (x x) v)))))))

(extend-syntax! 'case
  (lambda (s-express)
    (define tmp (gensym 'tmp-var))
    (define (gen-cmp cmp-whole)
      (match cmp-whole
         (`(,var ,outcome)
          `((symbol=? ,tmp ,var) ,outcome))))
    (letrec ((loop 
      (lambda (s)
        (match s
          (`(case ,val ,cmps ...) 
            ; (println "hello")
            ; (set! tmp val)
            `(let ([,tmp ,val]) ,(loop cmps)))
            ; (loop cmps))
          
          (`((,se1 ,se2) ...)
            (cons 'cond (for/list ((s1 se1) (s2 se2)) (gen-cmp `(,s1 ,s2)))))))))
    (loop s-express))))




; needs to take some indefinite number of args
(define Yv 
  (lambda (f)
    ((lambda (x) (f (lambda v (apply (x x) v))))
      (lambda (x) (f (lambda v (apply (x x) v)))))))

'((lambda (loop) (loop 6)) (lambda (f) ((lambda (x) (f (lambda (v) ((x x) v)))) (lambda (x) (f (lambda (v) ((x x) v))))))) 

(define fact-y (Yv (lambda (f) 
  (lambda (x y)
    (if (<= x 0)
      1
      (* x (f (- x y) y)))))))


(fact-y 5 2)


(extend-syntax! 'Yv
  (lambda (k)
    (match k
      (`(Yv ,k)
        `((lambda (f)
          ((lambda (x) (f (lambda (v) ((x x) v))))
            (lambda (x) (f (lambda (v) ((x x) v)))))) ,k)))))



(extend-syntax! 'letrec
  (lambda (expr)
    ; (println expr)
    (match expr
      (`(letrec ((,var1 ,expr1)) ,body)
        `(let ((,var1 
                (Yv (lambda (,var1) ,expr1)))) ,body))
      (_ (error "unhandled " ~s)))))

(extend-syntax! 'loop
  (lambda (expr)
    (match expr
      (`(loop ,v1 (,v2 ,body) ,call)
        `(letrec ((,v1 (lambda (,v2) ,body))) ,call)))))


(extend-syntax! 'for/list 
  (lambda (expr) 
    (define func-name (gensym 'for-list))
    (match expr
      (`(for/list ((,v1 ,list)) ,operations)
        `(letrec ((,func-name (lambda (,v1) 
          (if (list-empty? ,v1) 
            (/ )
            (cons 
              (let ((,v1 (car ,v1))) ,operations) 
              (,func-name (cdr ,v1))))))) (,func-name ,list))))))



(interp '(let ([x 1]) (or x (+ x 2))))

(interp '((lambda (x) (or x 2 y)) 0))

(interp `(let ([x 10]) (or 0 x)))

(expand `(let ([x 10]) (or 0 x)))

(interp '(cond (0 0) ((or 0 4) 9) (else 67)))

(expand '(cond (0 0) ((or 0 1) 9) (else 67)))

(expand '(case 7 (1 8) (0 4) (7 1) (9 6)))


(letrec 
  ((g 
    (lambda (x)
      (if (> x 0)
        (* 10 (g (sub1 x)))
        1))))
  (g 6))

(expand '(letrec 
  ((g
    (lambda (x)
      (if x
        (+ 1 (g (- x 1)))
        x)))) (g 5)))

(interp (expand '(letrec 
  ((g
    (lambda (x)
      (if x
        (+ 1 (g (- x 1)))
        x)))) (g 5))))

(expand `(loop x (y (if y (+ 2 (x (- y 1))) y))
  (x 5)))

(interp (expand `(loop x (y (if y (+ 2 (x (- y 1))) y))
  (x 5))))


; (for/list ((v (list a b c))) v)
; ; ==>
; (letrec ((for-list (lambda (x) x))) 
;   (for-list '(a b c)))

; (expand '(for/list ((c {1 2 3})) c))
; ; (interp (expand '(for/list ((c (!list 1 3 5))) c)))
; (interp '(for/list ((c {1 2 3})) (+ c 1)))

(interp `( / 1 2 3 ))
(interp `(car (/ 1 2 3 )))
(interp `(car (cdr (/ 1 2 3 ))))
(interp `(cdr (/ 1 2 3 )))
(interp `(cdr (cdr (/ 1 2 3 ))))
(interp `(cons (car (/ 1 2 3 )) (/ 2 4 )))

(interp  `(list-empty? (/ 1 2 3 )))
(interp `(list-empty? (/ )))

(interp  `(for/list ((c (/ 1 2 3 ))) (+ 4 c)))