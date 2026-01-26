#lang racket

(require racket/pretty)
(require racket/trace)

(struct node (name edge-list) #:transparent)
(struct graph (name node-list) #:transparent)
(struct edge (node-one node-two) #:transparent)

(struct queue (q))
(define gen-queue (queue '()))


(define (queue-isempty?) 
    (if (empty? (queue-q gen-queue))
        #t
        #f))

(define (queue-enqueue item)
    (set! gen-queue (queue (append (queue-q gen-queue) (list item)))))

(define (queue-dequeue)
    (define ret (car (queue-q gen-queue)))
    (set! gen-queue (queue (cdr (queue-q gen-queue))))
    ret)

(define (queue-clearqueue)
    (set! gen-queue (queue '())))

(define (queue-viewqueue) 
    (queue-q gen-queue))

(define (queue-touch)
    (car (queue-q gen-queue)))



(define (read-graph input)
    (match input
        ((list `(,names ,neighbors) ...)
            (define node-list (for/list ((n names) (neighbor neighbors)) (node n neighbor)))
            (define new-node-list 
                (for/list ((n names) (neighbor neighbors)) 
                    (node n (for/list ((e neighbor)) (edge (find-node node-list n) (find-node node-list e))))))
            (define g (graph 'g new-node-list))
            g)))

(define (find-node node-list name)
    (cond 
        ((empty? node-list) 'node-not-found-here)
        (else 
            (if (eqv? name (node-name (car node-list)))
                (car node-list)
                (find-node (cdr node-list) name)))))
                
(define (print-graph graph) 
    (define node-list (graph-node-list graph))
    (define edges-list (for/list ((node node-list)) (node-edge-list node)))
    (pretty-print-columns 20)
    (pretty-print (for/list ((node node-list) (edges edges-list)) (list (node-name node) (for/list ((edge edges)) (node-name (edge-node-two edge)))))))

(define (node-member node list)
    (cond
        ((empty? list) #f)
        ((equal? (node-name node) (node-name (car list))) #t)
        (else 
            (node-member node (cdr list)))))

(define (graph->symbol g)
    (match g
        ((graph name nodes)
            `(,(for/list ((n nodes)) (graph->symbol n))))
        ((node name edges) 
            `(,name ,(for/list ((e edges)) (graph->symbol e))))
        ((edge e1 e2)
            (node-name e2))))

    
(define (edge-member? edge list)
    (cond 
        ((empty? list) #f)
        (else 
            (if (equal? (edge-node-two edge) (edge-node-two (car list))) 
                #t
                (edge-member? edge (cdr list))))))

(define (spanning-tree g)
    (queue-clearqueue)
    (define node-list (graph-node-list g))
    (define new-g (graph 'g '()))
    (queue-enqueue (car node-list))
    (define (spanning-inner visited-list marked-list)
        (cond 
            ((queue-isempty?) new-g)
            (else 
                (define curr-node (queue-dequeue))
                (define is-visited? (node-member curr-node visited-list))
                (cond 
                    ((equal? is-visited? #t) 
                        (spanning-inner visited-list marked-list))
                    (else 
                        (define curr-edges (node-edge-list curr-node))
                        (define new-node (node (node-name curr-node) (list)))
                        (define new-edge-list (for/list ((e curr-edges)) (edge new-node (edge-node-two e))))
                        (for ((e new-edge-list)) 
                            (when (or (edge-member? e marked-list) (node-member (edge-node-two e) visited-list))
                                (set! new-edge-list (remove e new-edge-list))))
                        (for ((e new-edge-list)) (queue-enqueue (find-node node-list (node-name (edge-node-two e)))))
                        (for ((n visited-list))
                            (for ((e (node-edge-list n))) 
                                (when (equal? (node-name new-node) (node-name (edge-node-two e))) (set! new-edge-list (cons (edge new-node (edge-node-one e)) new-edge-list)))))
                        (set! new-node (node (node-name curr-node) new-edge-list))
                        (set! new-g (graph 'g (append (graph-node-list new-g) (list new-node))))
                        (spanning-inner (cons new-node visited-list) (append new-edge-list marked-list)))))))
                        (spanning-inner '() '()))




(provide (all-defined-out))

; (println file-text)