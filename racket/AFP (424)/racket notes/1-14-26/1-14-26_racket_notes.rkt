#lang racket

(require slideshow)
(require rackunit)

(list (circle 10) (circle 100))

(for/hash ((i (in-range 10))) (values i (circle (* (add1 i) 10))))

(define (circle-table k)
  (for/hash ((i (in-range k)))
    (values i (circle (* 10 (add1 i))))))

; allows this function to be provided
; accessed via a require at the top
(provide circle-table)


(struct shape ())
(struct cir shape (rad col))
(struct rec shape (len hi col))

; gives all definitions 
(provide (all-defined-out))


; match on structures via the structure itself
(define (draw-shape c)
  (match c
    ((cir r col) (colorize (circle r) col))
    ((rec len hi col) (colorize (rectangle len hi) col))))

;find some documentation for rackunit defs

(check-equal? (circle-table 0) (hash))
