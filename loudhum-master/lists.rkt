#lang racket

;;; File:
;;;   lists.rkt
;;; Summary:
;;;   A variety of procedure associated with lists.
;;; Author:
;;;   Samuel A. Rebelsky

(provide
  (contract-out
    [reduce (-> (-> any/c any/c any) list? any/c)]
    [reduce-left (-> (-> any/c any/c any) list? any/c)]
    [reduce-right (-> (-> any/c any/c any) list? any/c)]
    [take-random (-> list? integer? list?)]
    [tally (-> list? (-> any/c any) integer?)]
    [tally-value (-> list any/c integer?)]
    ))

; +-------------------------------+----------------------------------
; | Private procedures and values |
; +-------------------------------+

;;; Constant:
;;;   FIRST-FIRST-ODDS
;;; Type:
;;;   real
;;; Summary:
;;;   The odds that we process the first element first when mapping
;;;   through a list.
(define FIRST-FIRST-ODDS 0.4)

; +---------------------+--------------------------------------------
; | Exported procedures |
; +---------------------+

;;; Package:
;;;   loudhum/lists
;;; Procedure:
;;;   reduce
;;; Parameters:
;;;   op, a binary procedure
;;;   lst, a list of values of the form (val1 val2 ... valn)
;;; Purpose:
;;;   Creates a new value by repeatedly applying op to the values
;;;   in lst.
;;; Produces:
;;;   result, a value
;;; Preconditions:
;;;   op must be applicable to pairs of elements of lst.
;;;   op must return the same types that it takes as input
;;; Postconditions:
;;;   In infix notation, result is val1 op val2 op val3 ... op valn
;;;   the order of the evalution of the operations is undefined
(define reduce
  (lambda (fun lst)
    (cond
      [(null? (cdr lst))
       (car lst)]
      [(< (random) FIRST-FIRST-ODDS)
       (reduce fun (cons (fun (car lst) (cadr lst))
                         (cddr lst)))]
      [else
       (fun (car lst) (reduce fun (cdr lst)))])))

;;; Package:
;;;   loudhum/lists
;;; Procedure:
;;;   reduce-left
;;; Parameters:
;;;   op, a binary procedure
;;;   lst, a list of values of the form (val1 val2 ... valn)
;;; Purpose:
;;;   Creates a new value by repeatedly applying op to the values
;;;   in lst.
;;; Produces:
;;;   result, a value
;;; Preconditions:
;;;   op must be applicable to pairs of elements of lst.
;;;   op must return the same types that it takes as input
;;; Postconditions:
;;;   result is (op (op (op val1 val2) val3) ... valn)
(define reduce-left
  (lambda (fun lst)
    (cond
      [(null? (cdr lst))
       (car lst)]
      [else
       (reduce-left fun (cons (fun (car lst) (cadr lst))
                              (cddr lst)))])))

;;; Package:
;;;   loudhum/lists
;;; Procedure:
;;;   reduce-right
;;; Parameters:
;;;   op, a binary procedure
;;;   lst, a list of values of the form (val1 val2 ... valn)
;;; Purpose:
;;;   Creates a new value by repeatedly applying op to the values
;;;   in lst.
;;; Produces:
;;;   result, a value
;;; Preconditions:
;;;   op must be applicable to pairs of elements of lst.
;;;   op must return the same types that it takes as input
;;; Postconditions:
;;;   result is (op val1 (op val2 (op val3 ... (op valn-1 valn))))
(define reduce-right
  (lambda (fun lst)
    (cond
      [(null? (cdr lst))
       (car lst)]
      [else
       (fun (car lst) (reduce-right fun (cdr lst)))])))

;;; Procedure:
;;;   take-random
;;; Parameters:
;;;   lst, a list
;;;   n, a non-negative integer
;;; Purpose:
;;;   Grab n "randomly selected elements" from lst
;;; Produces:
;;;   elements, a list
;;; Preconditions:
;;;   n <= (length lst)
;;; Postconditions:
;;;   (length elements) = n
;;;   Every element in elements appears in lst.
;;;   Every element in elements represents a separate element of lst.
(define take-random
  (lambda (lst n)
    (let kernel ([remaining lst]
                 [len (length lst)]
                 [n n])
      (cond
        [(or (= n 0) (= len 0))
         null]
        [(<= (random) (/ n len))
         (cons (car remaining)
               (kernel (cdr remaining)
                       (- len 1)
                       (- n 1)))]
        [else        
         (kernel (cdr remaining)
                 (- len 1)         
                 n)]))))


;;; Procedure:
;;;   tally
;;; Parameters:
;;;   lst, a list
;;;   pred?, a unary predicate
;;; Purpose:
;;;   Count the number of values in lst for which pred? holds.
;;; Produces:
;;;   count, a non-negative integer
;;; Preconditions:
;;;   pred? can be applied to all elements of lst.
;;; Postconditions:
;;;   count represents the number of values in lst for which
;;;   (pred? val) holds.
(define tally
  (lambda (lst pred?)
    (let kernel ([remaining lst]
                 [count 0])
      (cond
        [(null? remaining)
         count]
        [(pred? (car remaining))
         (kernel (cdr remaining) (+ 1 count))]
        [else
         (kernel (cdr remaining) count)]))))

;;; Procedure:
;;;   tally-value
;;; Parameters:
;;;   lst, a list
;;;   val, a value
;;; Purpose:
;;;   Count the number values in lst equal to val
;;; Produces:
;;;   count, a non-negative integer
;;; Preconditions:
;;;   [No additional]
;;; Postconditions:
;;;   count represents the number of values, v, in lst for which
;;;   (equal? val v) holds.
(define tally-value
  (lambda (lst val)
    (tally lst (lambda (v) (equal? v val)))))