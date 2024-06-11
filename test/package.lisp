;;;; package.lisp
;;;; Define packages here to remove circular dependencies.

(defpackage #:cl-project-test
  (:documentation "A package to group cl-project tests.")
  (:use #:cl #:fiveam))
