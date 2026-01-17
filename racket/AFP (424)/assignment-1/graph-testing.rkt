#lang racket

(require "graph-defs.rkt")

(define file-string1 (file->string "rep3.txt"))
(define file-text (with-input-from-string file-string1 read))

(define new-g (read-graph file-text))
(graph-name new-g)
(graph-node-list new-g)
; (for/list ((node (graph-node-list new-g))) (node-edge-list node))

; (pretty-print (graph-node-list new-g))
(print-graph new-g)

; (spanning-tree new-g)

(queue-isempty?)
(queue-viewqueue)
(queue-enqueue 'n)
(queue-viewqueue)
(queue-isempty?)
(queue-enqueue 'l)
(queue-viewqueue)
(queue-dequeue)
(queue-viewqueue)
(queue-viewqueue)
(queue-enqueue '9)
(queue-enqueue '0)
(queue-touch)
(queue-viewqueue)
(queue-dequeue)
(queue-dequeue)
(queue-enqueue 'p)
(queue-viewqueue)


(define new-g-3 (spanning-tree new-g))
(for/list ((n (graph-node-list new-g-3))) (node-name n))
(for/list ((n (graph-node-list new-g-3))) (for/list ((n2 (node-edge-list n))) (node-name (edge-node-two n2))))