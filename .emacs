
;;; -*- lexical-binding: t -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files
   '("~/org/todo.org" "/home/dania/org/slack.org"
     "/home/dania/org/agentic-memory.org"
     "/home/dania/org/meeting.org" "/home/dania/org/inbox.org"))
 '(org-export-backends '(ascii html icalendar latex md odt org))
 '(package-selected-packages
   '(arxiv-mode base16-theme company conda elfeed-score engine-mode exwm
		helm-bibtex json-mode kaolin-themes lush-theme magit
		mbo70s-theme nov org-appear org-bullets org-mode
		org-noter org-project-capture org-projectile org-ref
		org-remark ox-gist quelpa slack
		solarized-gruvbox-theme solarized-theme toc-org
		vertico winum)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(require 'package)
(require 'use-package)
(require 'which-key)
(require 'json)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(load-theme 'solarized-gruvbox-dark t)

(use-package org
  :ensure t)

(setq org-directory (file-truename "~/org/"))
;; (set-frame-font "Jetbrains Mono" nil t)

(defun my/load-config ()
  (interactive)
  (let ((config-file (expand-file-name "config.org" user-emacs-directory)))
    (when (file-readable-p config-file)
      (org-babel-load-file config-file))))
(my/load-config)
(server-start)
