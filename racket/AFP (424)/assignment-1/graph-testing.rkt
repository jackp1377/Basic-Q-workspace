#lang racket

(require "graph-defs.rkt")
(require rackunit)

(define file-string1 (file->string "rep3.txt"))
(define file-text (with-input-from-string file-string1 read))

(define key-string1 (file->string "key3.txt"))
(define key-text1 (with-input-from-string key-string1 read))

(define file-string2 (file->string "rep.txt"))
(define file-text2 (with-input-from-string file-string2 read))

(define key-string2 (file->string "key1.txt"))
(define key-text2 (with-input-from-string key-string2 read))

(define file-string3 (file->string "rep2.txt"))
(define file-text3 (with-input-from-string file-string3 read))

(define key-string3 (file->string "key2.txt"))
(define key-text3 (with-input-from-string key-string3 read))

(define file-string4 (file->string "rep4.txt"))
(define file-text4 (with-input-from-string file-string4 read))

(define key-string4 (file->string "key4.txt"))
(define key-text4 (with-input-from-string key-string4 read))

(define new-g (read-graph file-text))
(graph-name new-g)
(graph-node-list new-g)
; (for/list ((node (graph-node-list new-g))) (node-edge-list node))

; (pretty-print (graph-node-list new-g))
(print-graph new-g)

; (spanning-tree new-g)


; test code for queue
; (queue-isempty?)
; (queue-viewqueue)
; (queue-enqueue 'n)
; (queue-viewqueue)
; (queue-isempty?)
; (queue-enqueue 'l)
; (queue-viewqueue)
; (queue-dequeue)
; (queue-viewqueue)
; (queue-viewqueue)
; (queue-enqueue '9)
; (queue-enqueue '0)
; (queue-touch)
; (queue-viewqueue)
; (queue-dequeue)
; (queue-dequeue)
; (queue-enqueue 'p)
; (queue-viewqueue)


(define new-g-3 (spanning-tree new-g))
(for/list ((n (graph-node-list new-g-3))) (node-name n))
; (define g-3-list (for/list ((n (graph-node-list new-g-3))) (for/list ((n2 (node-edge-list n))) (node-name (edge-node-two n2)))))

(define g-3-string (print-graph new-g-3))



(define g-1 (spanning-tree (read-graph file-text2)))
(print-graph g-1)
(define g-1-key (read-graph key-text2))
(print-graph g-1-key)

(define g-2 (spanning-tree (read-graph file-text3)))
(define g-2-key (read-graph key-text3))

(define g-3-key (read-graph key-text1))

(define g-4 (spanning-tree (read-graph file-text4)))
(define g-4-key (read-graph key-text4))

(check-equal? (graph->symbol g-1) (graph->symbol g-1-key))
(check-equal? (graph->symbol new-g-3) (graph->symbol g-3-key))
(check-equal? (graph->symbol g-2) (graph->symbol g-2-key))

(print-graph g-4)
(check-equal? (graph->symbol g-4) (graph->symbol g-4-key))