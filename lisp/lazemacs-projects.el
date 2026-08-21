;;; lazemacs-projects.el --- project management -*- lexical-binding: t; no-byte-compile: t; -*-

(use-package projectile
  :ensure t
  :defer t
  :init
  (setq projectile-project-search-path '((file-truename "~/Documents/research/") (file-truename ("~/Documents/toy-projects/"))))
  :hook
  (treemacs-mode . projectile-mode)
  :config
  (setq projectile-completion-system 'default)
  (setq projectile-sort-order 'recentf)
  (setq projectile-indexing-method 'alien)
  (setq projectile-enable-caching t)

  (setq projectile-frecency-file (expand-file-name "projectile-frecency.eld" (file-truename "~/.emacs.d/")))
  
  (defun my/projectile-project-find-fn (dir)
    (when-let ((root (projectile-project-root dir)))
      (cons 'transient root)))
  (add-to-list 'project-find-functions #'my/projectile-project-find-fn)
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(provide 'lazemacs-projects)
