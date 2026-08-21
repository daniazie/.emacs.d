;;; init.el --- initialise emacs and packages -*- lexical-binding: t; no-byte-compile: t; -*-

(custom-set-variables
 '(org-agenda-files
   '("/home/dania/org/agentic-memory.org" "/home/dania/org/calendar.org"
     "/home/dania/org/daily.org" "/home/dania/org/meeting.org"
     "/home/dania/org/todo.org" "/home/dania/org/slack.org")))

(let (;; temporarily increase `gc-cons-threshold' when loading to speed up startup.
    (gc-cons-threshold most-positive-fixnum)
    ;; Empty to avoid analyzing files when loading remote files.
    (file-name-handler-alist nil))
  )

(setq custom-file (make-temp-file "emacs-custom-"))
(profiler-start 'cpu+mem)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'lazemacs-core)
(require 'lazemacs-comp)
(require 'lazemacs-style)
(require 'lazemacs-buffers)
(require 'lazemacs-completion)
(require 'lazemacs-terminal)
(require 'lazemacs-keybinds)
(require 'lazemacs-help)
(require 'lazemacs-windows)
(require 'lazemacs-secrets)
(require 'lazemacs-projects)
(require 'lazemacs-ide)
(require 'lazemacs-org)
(require 'lazemacs-bib)
(require 'lazemacs-misc)
(require 'lazemacs-theme)
