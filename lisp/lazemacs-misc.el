;;; lazemacs-misc.el --- miscellaneous -*- lexical-binding: t; no-byte-compile: t; -*-

(use-package slack
  :ensure t
  :after alert
  :defer t
  :bind (("C-c S K" . slack-stop)
	 ("C-c S c" . slack-select-rooms)
	 ("C-c S u" . slack-select-unread-rooms)
	 ("C-c S U" . slack-user-select)
	 ("C-c S s" . slack-search-from-messages)
	 ("C-c S J" . slack-jump-to-browser)
	 ("C-c S j" . slack-jump-to-app)
	 ("C-c S e" . slack-insert-emoji)
	 ("C-c S E" . slack-message-edit)
	 ("C-c S r" . slack-message-add-reaction)
	 ("C-c S t" . slack-thread-show-or-create)
	 ("C-c S g" . slack-message-redisplay)
	 ("C-c S G" . slack-conversations-list-update-quick)
	 ("C-c S q" . slack-quote-and-reply)
	 ("C-c S Q" . slack-quote-and-reply-with-link)
	 (:map slack-mode-map
	       (("@" . slack-message-embed-mention)
		("#" . slack-message-embed-channel)))
	 (:map slack-thread-message-buffer-mode-map
	       (("C-c '" . slack-message-write-another-buffer)
		("@" . slack-message-embed-mention)
		("#" . slack-message-embed-channel)))
	 (:map slack-message-buffer-mode-map
	       (("C-c '" . slack-message-write-another-buffer)))
	 (:map slack-message-compose-buffer-mode-map
	       (("C-c '" . slack-message-send-from-buffer)))
	 )
  :hook
  (elpaca-after-init . slack-start)
  :custom
  (slack-extra-subscribed-channels (mapcar 'intern (list "ldi-main" "ldi-graduate" "team-agentic-memory" "ai-server" "help-me" "ml-share" "agentic-memory")))
  (slack-prefer-current-team t)
  :config
  (slack-register-team
   :name "languagedatakhu"
   :token (auth-source-pick-first-password
	   :host "languagedatakhu.slack.com"
	   :user "dania.moriazi01@khu.ac.kr")
   :cookie (auth-source-pick-first-password
	    :host "languagedatakhu.slack.com"
	    :user "dania.moriazi01@khu.ac.kr^cookie")
   :full-and-display-names t
   :default t ))

;; parse message metadata
(defun slack/parse-message-loc (title)
  (concat "#" (string-trim (nth 1 (split-string title "#")))))

(defun slack/parse-sender (message)
  (string-trim (car (split-string message ":"))))

(defun slack/parse-message (info)
  (let* ((title (plist-get info :title))
	 (message (plist-get info :message)))
    (string-trim (nth 1 (split-string message ":")))))

;; configure alert
(defun my/slack-notify (info)
  (let* ((channel (slack/parse-message-loc (plist-get info :title)))
    	 (user (slack/parse-sender (plist-get info :message)))
    	 (message (slack/parse-message info))
    	 (pos (org-find-exact-headline-in-buffer channel)))
    (unless (string-search "주간보고" message)
      (write-region
       (s-concat
  	"** UNREAD "
  	(format "<%s> %s : %s"
    		(format-time-string "%Y-%m-%d %H:%M")
    		channel
    		user)
  	"\n"
  	(format "%s" message)
  	"\n")
       nil
       (concat org-directory "slack.org")
       t))))

(defun my/save-slack ()
  (interactive)
  (save-excursion
    (dolist (buf '("slack.org_archive" "slack.org"))
      (set-buffer buf)
      (if (and (buffer-file-name) (buffer-modified-p))
          (basic-save-buffer)))))

(defun my/org-agenda-todo-archive()
  (interactive)
  (org-agenda-todo 'done)
  (org-agenda-archive)
  (my/save-slack))

(defun my/slack-setup ()
  (alert-define-style
   'my/slack-alert
   :title "org slack alerts"
   :notifier (lambda (info)
               (if (get-buffer "slack.org")
                   (with-current-buffer "slack.org"
                     (save-buffer))
                 (with-current-buffer
                     (get-buffer-create (find-file (concat org-directory "slack.org")))
                   (save-buffer)))
               (my/slack-notify info)))
  
  (add-to-list 'alert-user-configuration
               '(((:category . "slack")) my/slack-alert nil))
  (add-hook 'org-agenda-mode-hook . (lambda ()
				    (keymap-local-set "M" 'my/org-agenda-todo-archive))))

(add-hook 'slack-mode-hook #'my/slack-setup)

;; first we convert org-mode to mrkdwn (markdown flavour used by slack)
(defun my/org-to-slack-md ()
  (interactive)
  (goto-char (point))
  (save-window-excursion
    (get-buffer (org-md-export-as-markdown nil 'subtree))
    (let* ((slack-md (buffer-string))
	   (pyscript (file-truename "~/.emacs.d/utils/convert-org-to-slack.py"))
	   (cmd (format "python %s --md %s"
			(shell-quote-argument pyscript)
			(shell-quote-argument slack-md))))
      (kill-buffer)
      (shell-command-to-string cmd))))

;; then we send the message
 (defun my/slack-send-message ()
  (interactive)
  (let ((slack-msg (my/org-to-slack-md)))
    (save-window-excursion
      (call-interactively #'slack-select-rooms)
      (if (not (string-search "Traceback" slack-msg))
	  (slack-if-let* ((buffer slack-current-buffer))
	      (slack-buffer-send-message buffer slack-msg))
	(print slack-msg)))))

(keymap-global-set "C-c S p" #'my/slack-send-message)
(keymap-global-set "C-c S o" #'my/org-to-slack-md)

(provide 'lazemacs-misc)
