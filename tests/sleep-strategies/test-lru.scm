;;; Copyright (C) 2026 David Thompson
;;;
;;; Licensed under the Apache License, Version 2.0 (the "License");
;;; you may not use this file except in compliance with the License.
;;; You may obtain a copy of the License at
;;;
;;;    http://www.apache.org/licenses/LICENSE-2.0
;;;
;;; Unless required by applicable law or agreed to in writing, software
;;; distributed under the License is distributed on an "AS IS" BASIS,
;;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;;; See the License for the specific language governing permissions and
;;; limitations under the License.

(define-module (tests sleep-strategies lru)
  #:use-module (goblins core-types)
  #:use-module (goblins sleep-strategies lru)
  #:use-module (srfi srfi-64))

(test-begin "test-sleep-strategies-lru")

;; We don't actually care about what's in the transactormap very much.
;; All that matters are the hash table keys.
(define (fake-transaction . objs)
  (let ((delta (make-hash-table)))
    (for-each (lambda (obj) (hashq-set! delta obj #t)) objs)
    (_make-actormap 'fake
                    (make-transactormap-data #f
                                             delta
                                             (make-hash-table)
                                             #f)
                    #f #f)))

;; We also don't care about the persistence layer so we just pretend
;; everything in the cache is persistable.
(define (val->slot-ref x) #t)

(define (symbol<? a b)
  (string<? (symbol->string a) (symbol->string b)))

(test-equal "nothing is evicted if cache isn't over capacity"
  '()
  ;; Fills the cache but doesn't overflow.
  ((sleep:lru #:max-objects 3) (fake-transaction 'a 'b 'c) val->slot-ref))

(test-equal "least recently used objects are evicted when cache is full"
  '(a c)
  (let ((lru (sleep:lru #:max-objects 3)))
    (sort (append
           ;; Fill cache.
           (lru (fake-transaction 'a 'b 'c) val->slot-ref)
           ;; Add two items and freshen an old one.
           (lru (fake-transaction 'd 'e 'b) val->slot-ref))
          symbol<?)))

(test-end "test-sleep-strategies-lru")
