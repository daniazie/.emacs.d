;;; lazemacs-bib.el --- bibliography management -*- lexical-binding: t; no-byte-compile: t; -*-

(use-package citar
  :ensure t
  :defer t
  :custom
  (citar-bibliography '("~/bib/references.bib"))
  :hook
  (LaTeX-mode . citar-capf-setup)
  (org-mode . citar-capf-setup))

(use-package citar-embark
  :ensure t :after (citar embark)
  :defer t
  :hook
  (citar-capf-setup . citar-embark-mode))

(use-package arxiv-mode
  :ensure t
  :defer t
  :hook
  (elfeed-search-mode . arxiv-mode))

(use-package elfeed
  :ensure t
  :defer t
  :hook
  (elfeed-search-mode . elfeed-update)
  :init
  (setq elfeed-search-filter "@2-month-ago +unread")
  (setq elfeed-feeds '("http://export.arxiv.org/api/query?search_query=cat:cs.CL&start=0&max_results=500&sortBy=submittedDate&sortOrder=descending" "http://export.arxiv.org/api/query?search_query=cat:cs.AI&start=0&max_results=500&sortBy=submittedDate&sortOrder=descending"))
  (setq arxiv_bib "~/org/references.bib")
  (setq arxiv_pdf_loc "~/Documents/papers/arxiv/")
  (setq org-ref-pdf-directory arxiv_pdf_loc)
  
  (setq bibtex-completion-library-path "~/Documents/papers/arxiv/")
  (setq bibtex-completion-bibliography (list arxiv_bib))
  (setq bibtex-completion-pdf-field "file")
  :custom
  (elfeed-search-date-format '("%y-%m-%d" 10 :left))
  (elfeed-search-title-max-width 110)
  :config
  (defun concatenate-authors (authors-list)
    "Given AUTHORS-LIST, list of plists; return string of all authors concatenated."
    (if (> (length authors-list) 1)
	(format "%s et al." (plist-get (nth 0 authors-list) :name))
      (plist-get (nth 0 authors-list) :name)))
  
  (defun my-search-print-fn (entry)
    "Print ENTRY to the buffer."
    (let* ((date (elfeed-search-format-date (elfeed-entry-date entry)))
	   (title (or (elfeed-meta entry :title)
		      (elfeed-entry-title entry) ""))
	   (title-faces (elfeed-search--faces (elfeed-entry-tags entry)))
	   (entry-authors (concatenate-authors
			   (elfeed-meta entry :authors)))
	   (title-width (- (window-width) 10
			   elfeed-search-trailing-width))
	   (title-column (elfeed-format-column
			  title 100
			  :left))
	   (entry-score
	    (elfeed-format-column
	     (number-to-string (elfeed-score-scoring-get-score-from-entry entry)) 10 :left))
	   (authors-column (elfeed-format-column entry-authors 40 :left)))
      (insert (propertize date 'face 'elfeed-search-date-face) " ")
      (insert (propertize title-column
			  'face title-faces 'kbd-help title) " ")
      (insert (propertize authors-column
			  'kbd-help entry-authors) " ")
      (insert entry-score " ")))

  (setq elfeed-search-print-entry-function #'my-search-print-fn)

  (defun my/elfeed-entry-to-arxiv ()
    (interactive)
    (let* ((link (elfeed-entry-link elfeed-show-entry))
	   (match-idx (string-match "arxiv.org/abs/\\([0-9.]*\\)" link))
	   (matched-arxiv-number (match-string 1 link))
	   (last-arxiv-key "")
	   (last-arxiv-title ""))
      (when matched-arxiv-number
	(message "Going to arXiv: %s" matched-arxiv-number)
	(arxiv-get-pdf-add-bibtex-entry matched-arxiv-number arxiv_bib arxiv_pdf_loc)
	;; Now, we are updating the most recent bib file with the pdf location
	(message "Update bibtex with pdf file location")
	
	(save-excursion
	  ;; Get the bib file
	  (find-file arxiv_bib)
	  ;; get to last line
	  (goto-char (point-max))
	  ;; get to the first line of bibtex
	  (bibtex-beginning-of-entry)
	  (let* ((entry (bibtex-parse-entry))
		 (key (cdr (assoc "=key=" entry)))
		 (title (bibtex-completion-apa-get-value "title" entry))
		 (pdf (org-ref-get-pdf-filename key)))
	    (message (concat "checking for key: " key))
	    (message (concat "value of pdf: " pdf))
	    (when (file-exists-p pdf)
	      (bibtex-set-field "file" pdf)
	      (setq last-arxiv-key key)
	      (setq last-arxiv-title title)
	      (save-buffer)
	      )))
	
	(save-excursion
	  (find-file (concat org-directory "papers.org"))
	  (goto-char (point-max))
	  (insert (format "** TODO Read paper (cite:%s) %s" last-arxiv-key last-arxiv-title))
	  (save-buffer))
	)))

  (keymap-global-unset "C-c e")
  (keymap-global-set "C-c e a" #'my/elfeed-entry-to-arxiv)
  (keymap-global-set "C-c e s" #'elfeed))

(use-package elfeed-score   
  :ensure t :after elfeed
  :defer t
  :hook
  (elfeed-search-mode . elfeed-score-enable)
  :config
  (elfeed-score-load-score-file "~/.emacs.d/elfeed.score")
  (define-key elfeed-search-mode-map "=" elfeed-score-map))

(use-package zotra
  :ensure t
  :defer t
  :config
  (setq zotra-backend 'zotra-server)
  (setq zotra-local-server-directory (file-truename "~/zotra-server"))
  (with-eval-after-load "bibtex-completion"
    (zotra-bibtex-completion))
  (setq zotra-download-attachment-default-directory bibtex-completion-library-path)
  (setq zotra-default-bibliography bibtex-completion-bibliography)
  (add-hook 'zotra-after-get-bibtex-entry-hook 'org-ref-clean-bibtex-entry)
  
  (defun zotra-add-entry-and-download-attachment (&optional url)
    (interactive)
    (let ((zotra-after-get-bibtex-entry-hook
	   (append zotra-after-get-bibtex-entry-hook
		   '(zotra-download-attachment-for-current-entry))))
      (zotra-add-entry url))))

(provide 'lazemacs-bib)
