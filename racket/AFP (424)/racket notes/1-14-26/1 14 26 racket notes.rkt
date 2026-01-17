#lang racket

(require slideshow)

(list (circle 10) (circle 100))

(for/hash ((i (in-range 10))) (values i (circle (* (add1 i) 10))))

(define (circle-table k)
  (for/hash ((i (in-range k)))
    (values i (circle (* 10 (add1 i))))))

; allows this function to be provided
; accessed via a require at the top
(provide circle-table)