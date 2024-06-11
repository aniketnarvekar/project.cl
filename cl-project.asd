(defsystem "cl-project"
  :version "0.1.0"
  :author ""
  :license ""
  :description ""
  :depends-on ()
  :components ((:module "src"
                :components
                ((:file "main"))))
  :in-order-to ((test-op (test-op #:cl-project/tests)))
  :perform (compile-op :after (o c)
		       (load (asdf:system-relative-pathname :cl-project "scripts/automate.lisp"))))


(asdf:defsystem #:cl-project/tests
  :depends-on (#:cl-project #:fiveam)
  :serial t
  :components ((:module "test"
		:components ((:file "package")
			     (:file "test"))))
  :perform (test-op (op s)
		    (symbol-call :fiveam '#:run! :cl-project)))
