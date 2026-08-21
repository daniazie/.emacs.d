;;; lazemacs-help.el --- help and documentation -*- lexical-binding: t; no-byte-compile: t; -*-

(use-package helpful
  :ensure t    
  :defer t
  :bind
  ("C-h f" . helpful-callable)
  ("C-h v" . helpful-variable)
  ("C-h k" . helpful-key)
  ("C-h x" . helpful-command)

  ("C-c C-d" . helpful-at-point)
  ("C-h F" . helpful-function))

(provide 'lazemacs-help)
