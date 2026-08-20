(use-package posframe
  :ensure t
  :demand t)

(use-package which-key
  :ensure t t
  :defer t
  :hook
  (elpaca-after-init . which-key-mode)
  :custom
  (which-key-popup-type 'side-window)
  :config
  (which-key-setup-side-window-right-bottom))

(provide 'lazemacs-completion)
