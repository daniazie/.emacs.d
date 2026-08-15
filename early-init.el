;;; -*- lexical-binding: t; no-byte-compile: t -*-
(setopt user-init-file (expand-file-name "init.el" user-emacs-directory))

(setq package-enable-at-startup nil)
(add-hook 'after-init-hook (lambda () (set-frame-name "home")))
