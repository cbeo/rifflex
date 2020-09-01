
sbcl: rifflex.lisp rifflex.asd package.lisp
	ros run --eval '(ql:quickload :rifflex)' \
		--eval '(rifflex::load-cmu-dict)' \
	        --eval "(sb-ext:save-lisp-and-die #p\"rifflex\" :toplevel #'rifflex::main :executable t)"

install: rifflex
	cp rifflex ~/.local/bin/
