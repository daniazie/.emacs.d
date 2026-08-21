;;; lazemacs-keybinds.el --- keybindings -*- lexical-binding: t; no-byte-compile: t; -*-

(defun my/open-config-file ()
  (interactive)
  (get-buffer-create (find-file (expand-file-name "config.org" "~/.emacs.d/"))))

(keymap-global-set "C-c f p" #'my/open-config-file)

(defun my/split-window-left ()
  (interactive)
  (select-window (split-window-right)))

(defun my/split-window-below ()
  (interactive)
  (select-window (split-window-below)))

(keymap-global-set "C-x 2" #'my/split-window-below)
(keymap-global-set "C-x 3" #'my/split-window-left)

(use-package vertigo
  :ensure t
  :defer t
  :custom
  (vertigo-max-digits 3)
  (vertigo-cut-off 9) 
  :config
  (keymap-global-set "M-n" #'vertigo-jump-down) ;; based on C-n to go to the next line
  (keymap-global-set "M-p" #'vertigo-jump-up)) ;; based on C-p to go to the previous line

(defun my/meow-deactivate-input-method ()
  (interactive)
  (when meow-current-input-method
    (deactivate-input-method)))
  
(defun my/meow-reactivate-input-method ()
  (interactive)
  (when meow-current-input-method
    (activate-input-method meow-current-input-method)))

(use-package meow
  :ensure t
  :demand t
  :init
  (defvar meow-input-method nil)
  :hook
  (meow-insert-exit . my/meow-deactivate-input-method)
  (meow-insert-enter . my/meow-reactivate-input-method)
  :custom
  (meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  :config
  (defun my/meow-qwerty-setup ()
    (meow-motion-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; Use SPC (0-9) for digit arguments.
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet)
     '("." . embark-act)
     '("a" . beginning-of-line)
     '("e" . end-of-line)
     '("j" . vertigo-jump-down)
     '("k" . vertigo-jump-up)
     '("l" . recenter-top-bottom))
    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . delete-char)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)
     '("<escape>" . ignore)))
  (my/meow-qwerty-setup)
  (meow-global-mode 1))

(provide 'lazemacs-keybinds)
