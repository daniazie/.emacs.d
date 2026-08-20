(use-package plstore
  :ensure nil
  :config
  (add-to-list 'plstore-encrypt-to "dania.moriazi01@khu.ac.kr")
  :custom
  (epg-pinentry-mode 'loopback))

(provide 'lazemacs-secrets)
