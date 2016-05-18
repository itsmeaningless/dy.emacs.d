(require 'yasnippet) ;; not yasnippet-bundle
;(yas-global-mode 1)

(yas-reload-all)
(add-hook 'prog-mode-hook
          '(lambda ()
             (yas-minor-mode)))
