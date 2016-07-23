(cond-expand
  (chicken (use test srfi-133))
  (chibi (import (scheme base) (chibi test) (vectors))))
(test-group "vectors"
  (test-group "vectors/basics"
    (define v (make-vector 3 3))
    (test-assert (vector? #(1 2 3)))
    (test-assert (vector? (make-vector 10)))
    (test 3 (vector-ref v 0))
    (test 3 (vector-ref v 1))
    (test 3 (vector-ref v 2))
    (test-error (vector-ref v -1))
    (test-error (vector-ref v 3))
    (vector-set! v 0 -32)
    (test -32 (vector-ref v 0))
    (test 3 (vector-length v))
    (test 0 (vector-length '#()))
  ) ; end vectors/basics

  (test-group "vectors/constructors"
    (test '#(0 1 2 3 4) (vector 0 1 2 3 4))
    (test '#(0 -1 -2 -3 -4 -5 -6 -7 -8 -9)
          (vector-unfold (lambda (i x) (values x (- x 1))) 10 0))
    (test '#(0 1 2 3 4 5 6) (vector-unfold values 7))
    (test '#((0 . 4) (1 . 3) (2 . 2) (3 . 1) (4 . 0))
          (vector-unfold-right (lambda (i x) (values (cons i x) (+ x 1))) 5 0))
    (define a2i '#(a b c d e f g h i))
    (test a2i (vector-copy a2i))
    (test-assert (not (eqv? a2i (vector-copy a2i))))
    (test '#(g h i) (vector-copy a2i 6))
    (test '#(d e f) (vector-copy a2i 3 6))
    (test '#(1 2 3 4) (vector-reverse-copy '#(5 4 3 2 1 0) 1 5))
    (test '#(x y) (vector-append '#(x) '#(y)))
    (test '#(a b c d) (vector-append '#(a) '#(b c d)))
    (test '#(a #(b) #(c)) (vector-append '#(a #(b)) '#(#(c))))
    (test '#(a b c d) (vector-concatenate '(#(a b) #(c d))))
    (test '#(a b h i) (vector-append-subvectors '#(a b c d e) 0 2 '#(f g h i j) 2 4))
  ) ; end vectors/constructors

  (test-group "vectors/predicates"
    (test #f (vector-empty? '#(a)))
    (test #f (vector-empty? '#(())))
    (test #f (vector-empty? '#(#())))
    (test-assert (vector-empty? '#()))
    (test-assert (vector= eq? '#(a b c d) '#(a b c d)))
    (test #f (vector= eq? '#(a b c d) '#(a b d c)))
    (test #f (vector= = '#(1 2 3 4 5) '#(1 2 3 4)))
    (test-assert (vector= eq?))
    (test-assert (vector= eq? '#(a)))
    (test #f (vector= eq? (vector (vector 'a)) (vector (vector 'a))))
    (test-assert (vector= equal? (vector (vector 'a)) (vector (vector 'a))))
  ) ; end vectors/predicates

  (test-group "vectors/iteration"
    (define vos '#("abc" "abcde" "abcd"))
    (define vec '#(0 1 2 3 4 5))
    (define vec2 (vector 0 1 2 3 4))
    (define vec3 (vector 1 2 3 4 5))
    (define result '())
    (define (sqr x) (* x x))
    (test 5 (vector-fold (lambda (len str) (max (string-length str) len))
                         0 vos))
    (test '(5 4 3 2 1 0)
          (vector-fold (lambda (tail elt) (cons elt tail)) '() vec))
    (test 3 (vector-fold (lambda (ctr n) (if (even? n) (+ ctr 1) ctr)) 0 vec))
    (test '(a b c d) (vector-fold-right (lambda (tail elt) (cons elt tail))
                     '() '#(a b c d)))
    (test '#(1 4 9 16) (vector-map sqr '#(1 2 3 4)))
    (test '#(5 8 9 8 5) (vector-map * '#(1 2 3 4 5) '#(5 4 3 2 1)))
    (vector-map! sqr vec2)
    (test '#(0 1 4 9 16) (vector-copy vec2))
    (vector-map! * vec2 vec3)
    (test '#(0 2 12 36 80) (vector-copy vec2))
    (vector-for-each (lambda (x) (set! result (cons x result))) vec)
    (test '(5 4 3 2 1 0) (cons (car result) (cdr result)))
    (test 3 (vector-count even? '#(3 1 4 1 5 9 2 5 6)))
    (test 2 (vector-count < '#(1 3 6 9) '#(2 4 6 8 10 12)))
    (test '#(3 4 8 9 14 23 25 30 36) (vector-cumulate + '#(3 1 4 1 5 9 2 5 6) 0))
  ) ; end vectors/iteration

  (test-group "vectors/searching"
    (define (cmp a b)
      (cond
         ((< a b) -1)
         ((= a b) 0)
         (else 1)))
    (define v '#(0 2 4 6 8 10 12))
    (test 2 (vector-index even? '#(3 1 4 1 5 9 6)))
    (test 1 (vector-index < '#(3 1 4 1 5 9 2 5 6) '#(2 7 1 8 2)))
    (test #f (vector-index = '#(3 1 4 1 5 9 2 5 6) '#(2 7 1 8 2)))
    (test 5 (vector-index-right odd? '#(3 1 4 1 5 9 6)))
    (test 3 (vector-index-right < '#(3 1 4 1 5) '#(2 7 1 8 2)))
    (test 2 (vector-skip number? '#(1 2 a b 3 4 c d)))
    (test 2 (vector-skip = '#(1 2 3 4 5) '#(1 2 -3 4)))
    (test 7 (vector-skip-right number? '#(1 2 a b 3 4 c d)))
    (test 3 (vector-skip-right = '#(1 2 3 4 5) '#(1 2 -3 -4 5)))
    (test 0 (vector-binary-search v 0 cmp))
    (test 3 (vector-binary-search v 6 cmp))
    (test #f (vector-binary-search v 1 cmp))
    (test-assert (vector-any number? '#(1 2 x y z)))
    (test-assert (vector-any < '#(1 2 3 4 5) '#(2 1 3 4 5)))
    (test #f (vector-any number? '#(a b c d e)))
    (test #f (vector-any > '#(1 2 3 4 5) '#(1 2 3 4 5)))
    (test #f (vector-every number? '#(1 2 x y z)))
    (test-assert (vector-every number? '#(1 2 3 4 5)))
    (test #f (vector-every < '#(1 2 3) '#(2 3 3)))
    (test-assert (vector-every < '#(1 2 3) '#(2 3 4)))
    (test 'yes (vector-any (lambda (x) (if (number? x) 'yes #f)) '#(1 2 x y z)))
    (let-values (((new off) (vector-partition number? '#(1 x 2 y 3 z))))
      (test '#(1 2 3 x y z) (vector-copy new))
      (test 3 (+ off 0)))
  ) ; end vectors-searching

  (test-group "vectors/mutation"
    (define vs (vector 1 2 3))
    (define vf0 (vector 1 2 3))
    (define vf1 (vector 1 2 3))
    (define vf2 (vector 1 2 3))
    (define vr0 (vector 1 2 3))
    (define vr1 (vector 1 2 3))
    (define vr2 (vector 1 2 3))
    (define vc0 (vector 1 2 3 4 5))
    (define vc1 (vector 1 2 3 4 5))
    (define vc2 (vector 1 2 3 4 5))
    (define vrc0 (vector 1 2 3 4 5))
    (define vrc1 (vector 1 2 3 4 5))
    (define vrc2 (vector 1 2 3 4 5))
    (define vu0 (vector 1 2 3 4 5))
    (define vu1 (vector 1 2 3 4 5))
    (define vu2 (vector 1 2 3 4 5))
    (define vur0 (vector 1 2 3 4 5))
    (define vur1 (vector 1 2 3 4 5))
    (define vur2 (vector 1 2 3 4 5))
    (vector-swap! vs 0 1)
    (test '#(2 1 3) (vector-copy vs))
    (vector-fill! vf0 0)
    (test '#(0 0 0) (vector-copy vf0))
    (vector-fill! vf1 0 1)
    (test '#(1 0 0) (vector-copy vf1))
    (vector-fill! vf2 0 0 1)
    (test '#(0 2 3) (vector-copy vf2))
    (vector-reverse! vr0)
    (test '#(3 2 1) (vector-copy vr0))
    (vector-reverse! vr1 1)
    (test '#(1 3 2) (vector-copy vr1))
    (vector-reverse! vr2 0 2)
    (test '#(2 1 3) (vector-copy vr2))
    (vector-copy! vc0 1 '#(10 20 30))
    (test '#(1 10 20 30 5) (vector-copy vc0))
    (vector-copy! vc1 1 '#(0 10 20 30 40) 1)
    (test '#(1 10 20 30 40) (vector-copy vc1))
    (vector-copy! vc2 1 '#(0 10 20 30 40) 1 4)
    (test '#(1 10 20 30 5) (vector-copy vc2))
    (vector-reverse-copy! vrc0 1 '#(10 20 30))
    (test '#(1 30 20 10 5) (vector-copy vrc0))
    (vector-reverse-copy! vrc1 1 '#(0 10 20 30 40) 1)
    (test '#(1 40 30 20 10) (vector-copy vrc1))
    (vector-reverse-copy! vrc2 1 '#(0 10 20 30 40) 1 4)
    (test '#(1 30 20 10 5) (vector-copy vrc2))
    (vector-unfold! (lambda (i) (+ 10 i)) vu0 1 4)
    (test '#(1 11 12 13 5) (vector-copy vu0))
    (vector-unfold! (lambda (i x) (values (+ i x) (+ x 1))) vu1 1 4 0)
    (test '#(1 1 3 5 5) (vector-copy vu1))
    (vector-unfold! (lambda (i x y) (values (+ i x y) (+ x 1) (+ x 1))) vu2 1 4 0 0)
    (test '#(1 1 4 7 5) (vector-copy vu2))
    (vector-unfold-right! (lambda (i) (+ 10 i)) vur0 1 4)
    (test '#(1 11 12 13 5) (vector-copy vur0))
    (vector-unfold-right! (lambda (i x) (values (+ i x) (+ x 1))) vur1 1 4 0)
    (test '#(1 3 3 3 5) (vector-copy vur1))
    (vector-unfold-right! (lambda (i x y) (values (+ i x y) (+ x 1) (+ x 1))) vur2 1 4 0 0)
    (test '#(1 5 4 3 5) (vector-copy vur2))

  ) ; end vectors/mutation

  (test-group "vectors/conversion"
    (test '(1 2 3) (vector->list '#(1 2 3)))
    (test '(2 3) (vector->list '#(1 2 3) 1))
    (test '(1 2) (vector->list '#(1 2 3) 0 2))
    (test '#(1 2 3) (list->vector '(1 2 3)))
    (test '(3 2 1) (reverse-vector->list '#(1 2 3)))
    (test '(3 2) (reverse-vector->list '#(1 2 3) 1))
    (test '(2 1) (reverse-vector->list '#(1 2 3) 0 2))
    (test '#(3 2 1) (reverse-list->vector '(1 2 3)))
    (test "abc" (vector->string '#(#\a #\b #\c)))
    (test "bc" (vector->string '#(#\a #\b #\c) 1))
    (test "ab" (vector->string '#(#\a #\b #\c) 0 2))
    (test '#(#\a #\b #\c) (string->vector "abc"))
    (test '#(#\b #\c) (string->vector "abc" 1))
    (test '#(#\a #\b) (string->vector "abc" 0 2))
  ) ; end vectors/conversion
) ; end vectors
(test-exit)
