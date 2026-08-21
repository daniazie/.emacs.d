;;; lazemacs-comp.el --- compilation-related libraries -*- lexical-binding: t; no-byte-compile: t; -*-

(use-package no-littering
  :ensure t
  :demand t
  :config
  (setq no-littering-etc-directory
	  (expand-file-name "config/" user-emacs-directory))
  (setq no-littering-var-directory
	  (expand-file-name "data/" user-emacs-directory))
  (let ((dir (no-littering-expand-var-file-name "lock-files/")))
    (make-directory dir t)
    (setq lock-file-name-transforms `((".*" ,dir t)))))

(use-package gcmh
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . gcmh-mode))

(use-package compile-angel
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . (lambda () (compile-angel-on-load-mode 1)))
  :config
  (setq compile-angel-verbose t)
  (push "/init.el" compile-angel-excluded-path-suffixes)
  (push "/early-init.el" compile-angel-excluded-path-suffixes))

(use-package recentf
  :ensure nil
  :defer t
  :after no-littering
  :hook
  (elpaca-after-init . recentf-mode)
  :config
  (add-to-list 'recentf-exclude
               (recentf-expand-file-name no-littering-var-directory))
  (add-to-list 'recentf-exclude
               (recentf-expand-file-name no-littering-etc-directory)))

(provide 'lazemacs-comp)
