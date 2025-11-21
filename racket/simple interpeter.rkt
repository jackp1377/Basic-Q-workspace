#lang racket

; a very simple interpreter in racket, done as review before starting my compilers course
;   supports ints (and some simple math), strings (which are actually just symbols), variables, and functions

(require racket/match)
(require racket/trace)

(define e '())

(define (Lint exp env)
  (match exp
      (`(CheckEnv) env)
      (`(int ,n) n)
      (`(str ,s) s)
      (`(add ,n1 ,n2) (+ (Lint n1 env) (Lint n2 env)))
      (`(neg ,n) (- (Lint n env)))
      (`(bind ,x ,val ,body) (Lint body (cons x (cons (Lint val env) env))))
      (`(get ,x) (Lint (lookup x env) env))
      (`(eval ,x) (do-app (lookup x env) env '()))
      (`(eval ,x ,args) (do-app (lookup x env) env args))
      (`(def ,body) (make-closure '() body env))
      (`(def ,args ,body) (make-closure args body env))
      (`(closure ,args ,body ,env^) (Lint body env))
      (`(closure ,body ,env^) (Lint body env))))
;(trace Lint)


(define (do-app close env data)
  (match close
      (`(closure ,args ,body ,env) (Lint close (upload-args args data env)))
      (`(closure ,body ,env) (Lint close env))
      (else error close)))
  
;(trace do-app)

(define (make-closure args body env)
  (cond
    ((pair? args) `(closure ,args ,body ,(listmerge-shell args env)))
    (else `(closure ,args ,body ,(listmerge-shell args env)))))


(define (front-append i list)
  (cons i list))

(define (revlist list nl)
  (cond
    ((equal? list '()) nl)
    (else (revlist (cdr list) (front-append (car list) nl)))))

(define (listmerge-shell l1 l2)
  (listmerge-front (revlist l1 '()) l2))

(define (listmerge-front l1 l2)
  (cond
    ((equal? l1 '()) l2)
    ((pair? l1) (listmerge-front (cdr l1) (front-append (car l1) l2)))
    (else (listmerge-front '() (front-append l1 l2)))))


(define (upload-args args data env)
  (cond
    ((equal? args '()) env)
    ((pair? args) (upload-args (cdr args) (cdr data) (targeted-insert (car args) (car data) env '())))
    (else (upload-args '() '() (targeted-insert args `(,data) env '())))))
;(trace upload-args)

(define (targeted-insert target new list storage)
  (cond
    ((equal? list '()) (error "overshoot..."))
    ((and (equal? list target) (not (pair? list))) (full-append storage (cons list (cons `(,new) '()))))
    ((equal? target (car list)) (full-append storage (cons (car list) (cons `(,new) (cdr list)))))
    ((and (pair? list) (pair? new)) (targeted-insert target new (cdr list) (clean-append storage `(,(car list)))))
    ((pair? list) (targeted-insert target new (cdr list) (clean-append storage (car list))))
    (else (targeted-insert target new '() (clean-append storage list)))))
;(trace targeted-insert)

(define (full-append list1 list2)
  (cond
    ((equal? list2 '()) list1)
    (else (full-append (clean-append list1 (car list2)) (cdr list2)))))

(define (clean-append list insert)
  (cond
    ((equal? list '()) insert)
    ((pair? list) (cons (car list) (clean-append (cdr list) insert)))
    (else (cons list (clean-append '() insert)))))


(define (lookup name env)
  (cond
    ((empty? env) (error name " undefined!"))
    ((cons? env)
     (cond
       ((equal? name (car env)) (car (cdr env)))
       (else (lookup name (cdr env)))))))
