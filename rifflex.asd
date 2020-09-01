;;;; rifflex.asd

(asdf:defsystem #:rifflex
  :description "Describe rifflex here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"

  :defsystem-depends-on (:deploy)
  :build-operation "deploy-op"
  :build-pathname "rifflex"
  :entry-point "rifflex::main"


  :depends-on (#:split-sequence #:alexandria)
  :serial t
  :components ((:file "package")
               (:file "rifflex")))
