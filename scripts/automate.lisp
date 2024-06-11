;;;; automate.lisp

;;; The automation script to test and create a coverage report.

;;; The script uses ASDF to test the package and SBCL' package
;;; SB-COVER to create test report.

;;; The requirements: ASDF and SBCL compiler.

;;; Loading HUNCHENTOOT for code coverage server.
#+sbcl
(ql:quickload :hunchentoot :silent t)

(in-package #:cl-user)

;;; Configuration

#+sbcl
(defvar *cl-project-code-coverage-server-port* 4243
  "An interger value which indicates the code coverage server port.")

#+sbcl
(defvar *cl-project-code-coverage-document-directory*
  (asdf:system-relative-pathname :cl-project "coverage/"))

#+sbcl
(defvar *cl-project-code-coverage-script-pathname*
  (asdf:system-relative-pathname :cl-project "scripts/coverage.lisp")
  "The pathname to the code coverage script.")

;;; Test

(defun cl-project-test ()
  "Test the CL-PROJECT package."
  (asdf:test-system :cl-project))

;;; Coverage

;;; Server

#+sbcl
(let ((acceptor nil))
  (defvar *cl-project-code-coverage-server-fn*
    (lambda ()
      (setq acceptor
	    (or acceptor
		(make-instance 'tbnl:easy-acceptor
			       :port *cl-project-code-coverage-server-port*
			       :document-root *cl-project-code-coverage-document-directory*
			       :access-log-destination nil))))
    "A function object with no parameters and return server OBJECT.

The function is responsible to create a server instance and returning
server instance if it's already created.

The function uses `*cl-project-code-coverage-server-port*' and
`*cl-project-code-coverage-document-directory*' variables while creating
a new object."))

#+sbcl
(defun cl-project-code-coverage-start-server ()
  "Starts the CL-PROJECT code coverage server. The function returns no value.

The function uses `*cl-project-code-coverage-server-fn*' to access the
server object."
  (let* ((object (funcall *cl-project-code-coverage-server-fn*))
	 (port (tbnl:acceptor-port object)))
    (unless (tbnl:started-p object)
      (prog2
	  (format t ";; Starting server...~%")
	  (tbnl:start object)
	(format t ";; Started server listening to port ~a.~%" port)))
    (values)))

#+sbcl
(defun cl-project-code-coverage-stop-server ()
  "The function returns T if server is listening before stoping or nil if
server is already shutdown before stoping.

The function uses `*cl-project-code-coverage-server-fn*' variable to access
the server object."
  (let* ((object (funcall *cl-project-code-coverage-server-fn*))
	 (started-p (tbnl:started-p object))
	 (port (tbnl:acceptor-port object))
	 (format-string (if started-p
			    ";; Stopping server listening to port ~a.~%"
			    ";; Already stoped server listening to port ~a.~%")))
    (format t format-string port)
    (prog1 started-p
      (tbnl:stop object))))

#+sbcl
(defun cl-project-code-coverage ()
  "The function create code coverage report, start the server and returns
code cover index package URL.

The function uses `*cl-project-code-coverage-server-fn*' to start the
server.

The function uses `load' fuction to load the
`*cl-project-code-coverage-script-pathname*'. See `load' function
documentation for more information."
  (load *cl-project-code-coverage-script-pathname*)
  (cl-project-code-coverage-start-server)
  (let* ((object (funcall *cl-project-code-coverage-server-fn*))
	 (port (tbnl:acceptor-port object)))
    (format nil "http://localhost:~a/cover-index.html" port)))

;;; Runner

(defun cl-project-runner ()
  "The function tests and create code coverage report for CL-ALOG
package.

The function returns code coverage report URL."
  (cl-project-test)
  #+sbcl
  (cl-project-code-coverage))
