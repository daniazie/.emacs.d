;;; early-init.el --- early initialisation -*- lexical-binding: t; no-byte-compile: t; -*-

(setq package-enable-at-startup nil)
(setq load-prefer-newer t)

(setq inhibit-default-init t)
(setq use-package-enable-imenu-support t)

;; make native compilation silent
(when (native-comp-available-p)
  (setq native-comp-async-report-warnings-errors 'silent))
(setq native-comp-always-compile t)
(setq bytecomp--inhibit-lexical-cookie-warning t)
(setq inhibit-compacting-font-caches t)

;; personally, I prefer not to have the menu-, tool- and scroll-bars.
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(setq inhibit-startup-message t) ;; I don't need this

(setq ring-bell-function 'ignore) ;; the ring bell always annoyed me tbh
(setq use-file-dialog nil) ;; I want to keep everything in emacs pls
(setq use-dialog-box nil)

(set-language-environment "Korean")
(prefer-coding-system 'utf-8-emacs)
(setq default-korean-keyboard "")

(setopt use-short-answers t) ;; I cannot be bothered to type yes/no in full every time

;; (setq no-byte-compile t)

;; have emacs open in fullscreen by default
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-hook 'after-init-hook (lambda () (set-frame-name "home")))
