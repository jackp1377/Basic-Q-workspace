#lang racket

(require 2htdp/image)

(define img-map (bitmap "wall_e.jpg"))
(define img-colors (image->color-list img-map))

