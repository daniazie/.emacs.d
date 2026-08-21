;;; lazemacs-theme.el --- theme and dashboard -*- lexical-binding: t; no-byte-compile: t; -*-

(defun my/convert-time (&optional DATE TIME ZONE)
  (encode-time
   (parse-time-string
    (format "%sT%s%s" (format-time-string "%Y-%m-%d" DATE) TIME ZONE))))

(defun my/check-time-is-new-day ()
  (let ((is_night (time-less-p nil (my/convert-time nil "10:00:00" "+09"))))
    (if (not (member (format-time-string "%A") '("Saturday" "Sunday")))
	(and (not is_night) (time-less-p nil (my/convert-time nil "15:00:00" "+09")))
      (not is_night))))

(defun my/goto-or-create-timestamp-header ()
  (interactive)
  (with-current-buffer
      (set-buffer (current-buffer))
    (when (my/check-time-is-new-day)
      (let* ((timestamp (format-time-string "[%Y-%m-%d %a]"))
	     (pos (org-find-exact-headline-in-buffer timestamp)))
	(if (not pos)
	    (progn (goto-char (buffer-size))
		   (org-insert-heading nil nil t)
		   (insert timestamp)
		   (goto-char (buffer-size))
		   (org-capture 0 "d"))
	  (goto-char pos))
	(save-buffer)))))

(defun my/open-org-daily ()
  (interactive)
  (set-buffer
   (get-buffer (find-file (concat org-directory "daily.org"))))
  (when (my/check-time-is-new-day)
    (let* ((timestamp (format-time-string "[%Y-%m-%d %a]"))
	   (pos (org-find-exact-headline-in-buffer timestamp)))
      (unless pos (progn
		    (goto-char (buffer-size))
		    (org-insert-heading nil nil t)
		    (insert timestamp)
		    (goto-char (buffer-size))
		    (org-capture 0 "d")))))
  (goto-char (buffer-size))
  (current-buffer))

(keymap-global-set "C-c f d" #'my/open-org-daily)

(defun my/open-org-agenda ()
  (interactive)
  (split-window-right)
  (org-agenda nil "n")
  (current-buffer))

(defun my/kill-agenda-window ()
  (let ((agenda-win (get-buffer-window org-agenda-buffer-name)))
    (when agenda-win
      (delete-window agenda-win))))

(defun my/window-setup ()
  (interactive)
  (if (and (fboundp 'server-running-p) 
           (not (server-running-p)))
      (server-start))
  (my/open-org-agenda)
  (dired-sidebar-toggle-sidebar org-directory)
  (select-window (get-buffer-window dashboard-buffer-name))
  (add-hook 'demap-minimap-set-window-hook #'my/kill-agenda-window)
  (current-buffer))

(use-package dashboard 
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . dashboard-setup-startup-hook)
  :config
  (add-hook 'dashboard-after-initialize-hook #'my/window-setup)
  :custom
  (dashboard-banner-logo-title "the dashboard")
  (dashboard-startup-banner (expand-file-name "banner.txt" user-emacs-directory))
  (dashboard-center-content t)
  (dashbaord-vertically-center-content t)
  (dashboard-items '((recents . 5)
                     (bookmarks . 5)
                     (projects . 5)))
  (dashboard-navigation-cycle t)
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t))

(provide 'lazemacs-theme)
