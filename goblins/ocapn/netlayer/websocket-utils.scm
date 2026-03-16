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

;; This hopefully should be removed in the future. It's fixing a bug which
;; appeared in Guile 3.0.11 and has since been fixed.
;; https://codeberg.org/guile/guile/issues/120
(define-module (goblins ocapn netlayer websocket-utils)
  #:use-module (goblins contrib syrup)
  #:export (<init:peer-auth>
            init:peer-auth
            init:peer-auth?
            init:peer-auth-payload
            marshall::init:peer-auth
            unmarshall::init:peer-auth))

(define-syrup-record-type <init:peer-auth>
  (init:peer-auth payload)
  init:peer-auth?
  init:peer-auth
  marshall::init:peer-auth unmarshall::init:peer-auth
  (payload init:peer-auth-payload))
