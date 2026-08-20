(use-package ibuffer
  :ensure nil
  :defer t
  :bind
  ("C-x C-b" . ibuffer))

(use-package elscreen
  :ensure t    
  :defer t
  :hook
  (elpaca-after-init . elscreen-start))

(use-package buffer-guardian
  :ensure t
  :defer t
  :custom
  ;; When non-nil, include remote files in the auto-save process
  (buffer-guardian-inhibit-saving-remote-files t)
  
  ;; When non-nil, buffers visiting nonexistent files are not saved
  (buffer-guardian-inhibit-saving-nonexistent-files t)
  
  ;; Save the buffer even if the window change results in the same buffer
  (buffer-guardian-save-on-same-buffer-window-change t)
  
  ;; Non-nil to enable verbose mode to log when a buffer is automatically saved
  (buffer-guardian-verbose nil)
  
  ;; Pre-save all package-managed buffers before native save commands run
  ;; Advise `save-some-buffers' to use `buffer-guardian' logic.
  ;; When non-nil and `buffer-guardian-mode' is active, this intercepts
  ;; `save-some-buffers' to silently pre-save package-managed buffers before
  ;; allowing the native command to run normally.
  (buffer-guardian-override-save-some-buffers nil)
  
  ;; Save all buffers after N seconds of user idle time. (Disabled by default)
  ;; (buffer-guardian-save-all-buffers-idle 30)
  
  ;; Save all buffers every N seconds. (Disabled by default)
  ;; (buffer-guardian-save-all-buffers-interval (* 60 30))
  
  :hook
  (elpaca-after-init . buffer-guardian-mode))

(use-package bufferfile
  :ensure t
  :defer t
  :commands
  (bufferfile-copy
   bufferfile-rename
   bufferfile-delete)
  :custom
  (bufferfile-verbose nil)
  (bufferfile-delete-switch-to 'parent-directory))

(use-package golden-ratio
  :ensure t    
  :defer t
  :custom
  (golden-ratio-auto-scale t)
  :config
  (add-to-list 'golden-ratio-exclude-modes 'undo-tree-visualizer-mode)
  (add-to-list 'golden-ratio-exclude-modes 'helpful-mode)
  (add-to-list 'golden-ratio-exclude-modes 'prog-mode)
  (add-to-list 'golden-ratio-exclude-modes 'lsp-mode)
  (add-to-list 'golden-ratio-exclude-modes 'python-mode)
  :hook
  (elpaca-after-init . golden-ratio-mode))

(provide 'lazemacs-buffers)
