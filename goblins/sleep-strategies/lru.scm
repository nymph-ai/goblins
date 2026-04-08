;;; Copyright (C) 2026 David Thompson <dave@spritely.institute>
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

;;; Commentary:
;;
;; Least recently used (LRU) cache eviction algorithm for use with
;; sleepy actors.
;;
;;; Code:

(define-module (goblins sleep-strategies lru)
  #:use-module (goblins core-types)
  #:use-module (srfi srfi-9)
  #:use-module (ice-9 match)
  #:export (sleep:lru))

(define-record-type <link>
  (make-link value next prev)
  link?
  (value link-ref link-set!)
  (next link-next set-link-next!)
  (prev link-prev set-link-prev!))

(define* (sleep:lru #:key (max-objects 100))
  (unless (and (exact-integer? max-objects) (>= max-objects 1))
    (error "expected a positive exact integer" max-objects))
  ;; Standard LRU data structures.  A hash table for constant time
  ;; lookup and a doubly linked list for ordering items by recency.
  ;; Doubly linked so we can add to the head and remove from the tail
  ;; in constant time.
  (define objects (make-hash-table))
  (define head #f)
  (define tail #f)
  (define size 0)
  (define (freshen refr)
    (match (hashq-ref objects refr)
      ;; Newly spawned or awoken.
      (#f
       (cond
        ;; Initialize list with one link.
        ((zero? size)
         (let ((link (make-link refr #f #f)))
           (hashq-set! objects refr link)
           (set! head link)
           (set! tail link)))
        ;; Prepend refr to chain.
        (else
         (let ((link (make-link refr head #f)))
           (set-link-prev! head link)
           (hashq-set! objects refr link)
           (set! head link))))
       (set! size (1+ size)))
      ;; Already in cache; move to head of the chain.
      ((and link ($ <link> _ next prev))
       (unless (eq? link head)
         ;; Remove link from chain.
         (set-link-next! prev next)
         (when next (set-link-prev! next prev))
         ;; Add link to the head of the chain.
         (set-link-prev! head link)
         (set-link-next! link head)
         (set-link-prev! link #f)
         ;; Update head/tail pointers.
         (set! head link)
         (when (eq? link tail)
           (set! tail prev))))))
  (define (freshen-keys table)
    (hash-for-each (lambda (k v) (freshen k)) table))
  (lambda (actormap val->slot-ref)
    (define (evict)
      (if (> size max-objects)
          ;; Evict the least recently used object.
          (match tail
            (($ <link> refr _ prev)
             (hashq-remove! objects refr)
             ;; Unlink the tail and make the previous link the new
             ;; tail.  Note that we don't have to consider the head
             ;; because this code cannot be reached unless size is > 2
             ;; (minimum cache size is 1) which means the head is not
             ;; eq? to the tail.
             (set-link-next! prev #f)
             (set! tail prev)
             (set! size (1- size))
             ;; Return only obects that are not promises and are
             ;; persistable.
             ;;
             ;; XXX: This feels like an abstraction leak we could
             ;; avoid.  We have to be careful to only return objects
             ;; that are not promises and are persistable (which we
             ;; test with val->slot-ref).  It would be better if our
             ;; sleep strategies didn't need to worry about the
             ;; persistence layer at all.
             (if (and (not (local-promise-refr? refr))
                      (val->slot-ref refr))
                 (cons refr (evict))
                 (evict))))
          '()))
    (match (actormap-data actormap)
      (($ <transactormap-data> _ deltas messaged)
       (freshen-keys deltas)
       (freshen-keys messaged)
       (evict)))))
