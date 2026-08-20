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

(provide 'lazemacs-misc)
