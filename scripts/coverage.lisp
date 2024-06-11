;;; Load SB-COVER
(require :sb-cover)

;;; Turn on generation of code coverage instrumentation in the compiler
(declaim (optimize (sb-cover:store-coverage-data 3)))

;;; Load some code, ensuring that it's recompiled with the new optimization
;;; policy.
(asdf:oos 'asdf:load-op :cl-project :force t)

;;; Run the test suite.
(fiveam:run! :cl-project)

;;; Produce a coverage report
(let ((pathname (asdf:system-relative-pathname :cl-project "coverage/")))
  (sb-cover:report pathname))

;;; Turn off instrumentation
(declaim (optimize (sb-cover:store-coverage-data 0)))
