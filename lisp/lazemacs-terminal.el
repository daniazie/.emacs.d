(use-package clipetty
  :ensure t    
  :defer t
  :if
  (not (display-graphic-p))
  :hook
  (elpaca-after-init . global-clipetty-mode))

(use-package kkp
  :ensure t
  :defer t
  :if
  (not (display-graphic-p))
  :hook
  (tty-setup . global-kkp-mode))

(use-package term
  :ensure nil
  :demand t)

(use-package popterm
  :defer t
  :ensure t    
  :if (display-graphic-p) ;; I only want to use popterm if I'm using the GUI version.
  :bind (("C-`"   . popterm-toggle)
         ("C-~"   . popterm-toggle-cd)
         ([f9]    . popterm-window-toggle))
  :custom
  (popterm-backend 'ghostel)     ; or 'ghostel, 'eat, 'shell, 'eshell
  (popterm-display-method 'posframe)  ; or 'window, 'fullscreen
  (popterm-scope 'project)   ; or 'frame, 'dedicated, nil
  (popterm-auto-cd t))

(provide 'lazemacs-terminal)
