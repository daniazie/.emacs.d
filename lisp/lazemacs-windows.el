;;; lazemacs-windows.el --- window management -*- lexical-binding: t; no-byte-compile: t; -*-

(use-package ace-window
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . ace-window-display-mode)
  :bind
  ("M-o" . ace-window)
  :commands ace-window
  :custom
  (aw-background nil)
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (defvar aw-dispatch-alist
    '((?x aw-delete-window "Delete Window")
      (?m aw-swap-window "Swap Windows")
      (?M aw-move-window "Move Window")
      (?c aw-copy-window "Copy Window")
      (?j aw-switch-buffer-in-window "Select Buffer")
      (?n aw-flip-window)
      (?u aw-switch-buffer-other-window "Switch Buffer Other Window")
      (?c aw-split-window-fair "Split Fair Window")
      (?v aw-split-window-vert "Split Vert Window")
      (?b aw-split-window-horz "Split Horz Window")
      (?o delete-other-windows "Delete Other Windows")
      (?? aw-show-dispatch-help))
    "List of actions for `aw-dispatch-default'."))

(use-package switchy-window
  :ensure t
  :defer t
  :custom
  (switchy-window-delay 1.5)
  :hook
  (elpaca-after-init . switchy-window-minor-mode)
  :bind
  (:map switchy-window-minor-mode-map
        ("<remap> <other-window>" . switchy-window)))

(provide 'lazemacs-windows)
