;;; Copyright 2026 Jessica Tallon
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

(define-module  (goblins sleep-strategies always)
  #:use-module (goblins core-types)
  #:use-module (goblins abstract-types)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:export (sleep:always))

(define (sleep:always)
  (lambda (actormap val->slot-ref)
    (define am-data (actormap-data actormap))
    (hash-fold
     (lambda (refr _ prev)
       (if (val->slot-ref refr)
           (cons refr prev)
           prev))
     '()
     (transactormap-data-messaged-refrs am-data))))


