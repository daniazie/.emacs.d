;;; lazemacs-org.el --- org-mode -*- lexical-binding: t; no-byte-compile: t; -*-

(use-package org
  :ensure (:wait t)
  :defer nil
  :custom
  (org-directory (file-truename "~/org/"))
  (org-startup-folded t) ;; a more compact display
  (org-agenda-start-on-weekday 0)
  (org-startup-indented t)
  (org-M-RET-may-split-line '((item . nil)))
  (org-support-shift-select t)
  (org-return-follows-link t)
  (org-refile-allow-creating-parent-nodes 'confirm)
  (org-refile-targets '((org-agenda-files :maxlevel . 3)))
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (emacs-lisp . t)
     (org . t)
     (latex . t)))
  
  (keymap-global-set "C-c c" #'org-capture)
  (keymap-global-set "C-c l" #'org-link-store-props)
  (keymap-global-set "C-c a" #'org-agenda)

  (defun my/org-mode-level-font-size ()
    (set-face-attribute 'org-level-4 nil :inherit 'outline-4 :height 1.0)      
    (set-face-attribute 'org-level-3 nil :inherit 'outline-3 :height 1.1)      
    (set-face-attribute 'org-level-2 nil :inherit 'outline-2 :height 1.2)      
    (set-face-attribute 'org-level-1 nil :inherit 'outline-1 :height 1.3)      
    (set-face-attribute 'org-document-title nil :inherit 'outline-1 :height 1.4 :underline nil))

  (my/org-mode-level-font-size)
  
  (unless (display-graphic-p)
    (keymap-unset org-mode-map "C-c ,")
    (keymap-set org-mode-map "C-c , p" #'org-priority)
    (keymap-set org-mode-map "C-c , i" #'org-insert-structure-template))

  (org-link-set-parameters "gh"
    			   :follow #'my/gh-open
    			   :export #'my/gh-export
    			   :store-link #'my/gh-store-link
    			   :insert-description #'my/gh-link-description)

  (org-link-set-parameters "hf"
    			   :follow #'hf-open
    			   :export #'hf-export
    			   :insert-description #'hf-description
    			   :store-link #'hf-store-link)


  (org-link-set-parameters "repo"
    			   :follow #'my/repo-open
    			   :export #'my/repo-export
    			   :store-link #'my/repo-store-link
    			   :insert-description #'my/repo-link-description)


  (org-link-set-parameters "ref"
   			   :follow #'my/ref-link--open-link
   			   :export #'my/ref-link--export-link
   			   :store-link #'my/ref-link--store-link
   			   :insert-description #'my/ref-link--insert-description))

;; org-ibullets for nice-looking bullets
(use-package org-ibullets
  :defer t
  :ensure (org-ibullets :host github :repo "jamescherti/org-ibullets.el" :build (:after org))
  :hook
  (org-mode . org-ibullets-mode))

;; org-modern-indent because org-modern doesn't work with org-indent-mode
(use-package org-modern-indent    
  :defer t
  :ensure (org-modern-indent :host github :repo "jdtsmith/org-modern-indent" :build (:after org))
  :hook
  (org-mode . org-modern-indent-mode))

;; org-modern
(use-package org-modern
  :ensure t
  :after org
  :defer t
  :hook
  (org-mode . global-org-modern-mode)
  :custom    
  (org-modern-hide-stars nil)
  (org-modern-star 'replace)
  (org-modern-block-fringe 2)
  (org-modern-todo nil)
  (org-modern-tag nil)
  (org-modern-block-name t)
  (org-modern-timestamp nil)
  (org-modern-progress nil)

  (org-auto-align-tags nil)
  (org-tags-column 0)
  (org-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)

  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-pretty-entities-include-sub-superscripts nil)
  (org-agenda-tags-column 0)
  (org-ellipsis "...")

  :config
  (modify-all-frames-parameters '((right-divider-width . 40)
                                  (internal-border-width . 30)))

  (dolist (face '(window-divider
                  window-divider-first-pixel
                  window-divider-last-pixel))
    (face-spec-reset-face face)
    (set-face-foreground face (face-attribute 'default :background)))
  (set-face-background 'fringe (face-attribute 'default :background)))

;; and then we use org-appear to unhide the emphasis markers when hovered over
(use-package org-appear
  :ensure t
  :hook
  (org-mode . org-appear-mode))

(defun my/gh-open (link _)
  (browse-url (my/gh-expand-link link)))

(defun my/gh-expand-link (link)
  (if (string-search "#" link)
      (progn (if (string-search ":#" link)
		 (apply #'format "https://github.com/%s/pull/%s"
			(my/gh-parse-link link))
	       (apply #'format "https://github.com/%s/issues/%s"
		      (my/gh-parse-link link))))
    (if (string-search ":" (string-remove-prefix "gh:" link))
	(apply #'format "https://github.com/%s/tree/%s" (my/gh-parse-link link))
      (format "https://github.com/%s" link))))

(defun my/gh-export (link description backend info)
  (if-let ((transcode-link (alist-get
			    'link (org-export-backend-transcoders
				   (org-export-get-backend backend)))))
      (let ((link (org-element-create
		   'link (list :type "https"
			       :path (my/gh-expand-link link)))))
	(funcall transcode-link link desc info))
    (concat "gh:" link)))

(defun my/get-sep (link)
  (if (string-search "#" link)
      (if (string-search ":#" link)
	  ":#" "#")
    ":"))

(defun my/gh-get-entry-type (link)
  (if (string= (my/get-sep link) ":#")
      "pr"
    "issue"))

(defun my/gh-parse-link (link) 
  (let ((parts
	 (string-split (string-remove-prefix "gh:" link)
		       (my/get-sep link) t)))
    parts))

(defun my/gh-link-description (link description)
  (or description
      (if (string-search "#" link)
	  (progn (let* ((repo (nth 0 (my/gh-parse-link link)))
			(id (nth 1 (my/gh-parse-link link)))
			(entry (my/gh-get-entry-type link)))
		   (format "%s: %s"
			   (string-replace ":#" "#"
					   (string-remove-prefix "gh:" link))
			   (my/gh-get-entry-title repo entry id))))
	(if (string-search ":" (string-remove-prefix "gh:" link))
	    (string-remove-prefix "gh:" link)
	  link))))

(defun my/gh-get-entry-title (repo entry id)
  (let ((cmd (format "gh %s view %s --repo %s --json title"
		     (shell-quote-argument entry)
		     (shell-quote-argument id)
		     (shell-quote-argument repo))))
    (alist-get 'title
	       (json-parse-string
		(shell-command-to-string cmd) :object-type 'alist))))

(defun my/gh-store-link (link &optional description)
  (org-link-store-props
   :type "gh"
   :link (my/gh-expand-link link)
   :description (my/gh-link-description link description)))

(defun hf-open (repo &optional repo-type)
  (interactive
   (list (completing-read "Choose repo type: " '("model" "dataset"))))
  (browse-url (hf-expand-link repo repo-type)))

(defun hf-expand-link (repo &optional repo-type)
  (if (string= repo-type "dataset")
      (format "https://huggingface.co/datasets/%s" repo)
    (format "https://huggingface/co/%s" repo)))

(defun hf-export (repo description backend info &optional repo-type)
  (if-let ((transcode-link (alist-get
			    'link (org-export-backend-transcoders
				   (org-export-get-backend backend)))))
      (let ((link (org-element-create
		   'link (list :type "https"
			       :path (hf-expand-link repo repo-type)))))
	(funcall transcode-link link desc info))
    (concat "hf:" link)))

(defun hf-description (repo &optional description)
  (or description repo))

(defun hf-store-link (repo &optional description repo-type)
  (org-link-store-props
   :type "hf"
   :link (hf-expand-link repo repo-type)
   :description description))

(defun my/repo-open (link _)
  (browse-url (my/repo-expand-link link)))

(setq repo-list '("codeberg.org"))

(defun my/repo-domain ()
  (interactive
   (let ((repo-type (completing-read "Repo domain: " repo-list)))
     (when (not (member repo-type repo-list))
       (add-to-list 'repo-list (list repo-type)))
     repo-type)))

(defun my/repo-expand-link (link)
  (interactive "r")
  (let ((domain (my/repo-domain)))
    (if (string-search ":" (string-remove-prefix "repo:" link))
	(apply #'format
	       (concat "https://" domain "/%s/tree/%s") (my/repo-parse-link link))
      (format "https://%s/%s" domain link))))
  
(defun my/repo-export (link description backend info)
  (if-let ((transcode-link (alist-get
			    'link (org-export-backend-transcoders
				   (org-export-get-backend backend)))))
      (let ((link (org-element-create
		   'link (list :type "https"
			       :path (my/repo-expand-link link)))))
	(funcall transcode-link link desc info))
    (concat "repo:" link)))

(defun my/get-sep (link)
  (if (string-search "#" link)
      (if (string-search ":#" link)
	  ":#" "#")
    ":"))

(defun my/get-entry-type (link)
  (if (string= (my/get-sep link) ":#")
      "pr"
    "issue"))

(defun my/repo-parse-link (link) 
  (let ((parts (string-split (string-remove-prefix "repo:" link) (my/get-sep link) t)))
    parts))

(defun my/repo-link-description (link description)
  (or description
      (if (string-search ":" (string-remove-prefix "repo:" link))
	  (string-remove-prefix "repo:" link)
	link)))

(defun my/repo-store-link (link &optional description)
  (org-link-store-props
   :type "repo"
   :link (my/repo-expand-link link)
   :description (my/repo-link-description link description)))

(defun my/ref-link--open-link (link _)
  (org-link-open-from-string link))

(defun my/ref-link--parse-id (link)
  (let* ((id (string-remove-suffix "/" link))
	 (id (car (last (split-string id "/"))))
	 (id (string-remove-suffix ".pdf" id)))
    id))

(defun my/ref-link--export-link (link description backend info)
  (if-let ((transcode-link (alist-get
			    'link (org-export-backend-transcoders
				   (org-export-get-backend backend)))))
      (let ((link (org-element-create
		   'link (list :type "https"
			       :path link))))
	(funcall transcode-link link desc info))
    (concat "ref:" (my/ref-link--parse-id link))))

(defun my/ref-link--insert-description (link description)
  (or description
      (let ((id (my/ref-link--parse-id link)))
	(format "ref:%s" id))))

(defun my/ref-link--store-link (link &optional description)
  (org-link-store-props
   :type "ref"
   :link link
   :description (my/ref-link--insert-description link description)))

(setq org-gcal-client-id
      (auth-source-pick-first-password :host "org-gcal"
                                       :user "dania.moriazi01@khu.ac.kr^id"))
(setq org-gcal-client-secret
      (auth-source-pick-first-password :host "org-gcal"
                                       :user "dania.moriazi01@khu.ac.kr^secret"))

(use-package org-gcal
  :ensure t
  :defer t
  :after org
  :commands org-gcal-sync
  :config
  (setq org-gcal-fetch-file-alist '(("dania.moriazi01@khu.ac.kr" . "/home/dania/org/calendar.org"))))

(defun do-org-confirm-babel-evaluations (lang body)
  (not (or (string= lang "python")
           (string= lang "calc"))))

(setq-local org-confirm-babel-evaluate 'do-org-confirm-babel-evaluations)

(use-package org-project-capture
  :ensure t
  :defer t
  :bind
  (("C-c n p" . org-project-capture-project-todo-completing-read)
   ("C-c n t" . org-project-capture-capture-for-current-project)
   ("C-c n a" . org-project-capture-agenda-for-current-project))
  :config
  (progn
    (setq org-project-capture-backend
          (make-instance 'org-project-capture-projectile-backend))
    (setq org-project-capture-projects-file (expand-file-name "projects.org" org-directory))
    (org-project-capture-single-file)))

(use-package org-projectile
  :defer t
  :ensure t
  :after projectile)

(provide 'lazemacs-org)
