#lang racket

(require racket/pretty)
(require racket/trace)

(struct node (name edge-list))
(struct graph (name node-list))
(struct edge (node-two))

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
                    (node n (for/list ((e neighbor)) (edge (find-node node-list e))))))
            (define g (graph 'g new-node-list))
            g)))

(define (find-node node-list name)
    (cond 
        ((empty? node-list) 'node-not-found-here)
        (else 
            (if (equal? name (node-name (car node-list)))
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


(define (spanning-tree g)
    (queue-clearqueue)
    (define node-list (graph-node-list g))
    (define new-g (graph 'g '()))
    (for ((n node-list)) (queue-enqueue n))
    (define (span-inner marked-list visited-list)
        (cond 
            ((queue-isempty?) new-g)
            (else 
                (define curr-node (queue-dequeue))
                (define is-visited? (node-member curr-node visited-list))
                (cond
                    ((equal? is-visited? #t) 
                        (span-inner marked-list visited-list))
                    (else 
                        (define edges (for/list ((e (node-edge-list curr-node))) 
                            (println (node-name (edge-node-two e)))
                            (edge-node-two e)))
                        (for ((e edges)) (queue-enqueue e)) ; these r node structs not edges
                        (define new-node (node (node-name curr-node) (list)))
                        (define new-edge-list (for/list ((e edges)) (edge e)))
                        (for ((e new-edge-list)) 
                            (when (node-member (edge-node-two e) marked-list)
                                (set! new-edge-list (remove e new-edge-list))))
                        (set! new-node (node (node-name curr-node) new-edge-list))
                        ; (define new-node (node (node-name curr-node) (for/list ((edge edges)) (edge (find-node  (node-name curr-node)) edge))))
                        (set! new-g (graph 'g (append (graph-node-list new-g) (list new-node))))
                        (span-inner (append marked-list (for/list ((e (node-edge-list new-node))) (edge-node-two e))) (append visited-list (list new-node))))))))
    (span-inner '() '()))





(provide (all-defined-out))

; (println file-text)