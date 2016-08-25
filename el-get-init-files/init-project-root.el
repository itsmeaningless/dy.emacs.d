(require 'project-root)
(setq project-roots
      `(("Generic Perl Project"
         :root-contains-files ("t" "lib")
         :filename-regex ,(regexify-ext-list '(pl pm))
         :on-hit (lambda (p) (message (car p))))
        ("Project"
         ;:root-contains-files (".gitmodules" ".git")
         :root-contains-files (".git")
         :filename-regex ".*\\.\\(java\\|c\\|h\\|cpp\\|lua\\|C\\|lua\\|ec\\|sh\\|py\\|html\\|htm\\|js\\|css\\|json\\|less\\|jade\\|jsx\\|scss\\)\\|.*akefile.*\\|.*note.*" 
         ;:on-hit (lambda (p) (message (car p)))
         :exclude-paths ("media" "contrib" "*/node_modules")
         )
        ("Django project"
         :root-contains-files ("xxxmanage.py")
         :filename-regex ,(regexify-ext-list '(py html css js htm less el jade scss))
         :exclude-paths ("media" "contrib" "*/node_modules"))
        ("Firefox addon project"
         :root-contains-files ("install.rdf")
         :filename-regex ,(regexify-ext-list '(rdf html css js htm))
         :exclude-paths ("media" "contrib"))
        )
      )

;(global-set-key (kbd "C-c p f") 'project-root-find-file)
;(global-set-key (kbd "C-c p g") 'project-root-grep)
;(global-set-key (kbd "C-c p a") 'project-root-ack)
;(global-set-key (kbd "C-c p d") 'project-root-goto-root)
;(global-set-key (kbd "C-c p p") 'project-root-run-default-command)
;(global-set-key (kbd "C-c p l") 'project-root-browse-seen-projects)
;
;(global-set-key (kbd "C-c p M-x")
;                'project-root-execute-extended-command)
;
;(global-set-key
; (kbd "C-c p v")
; (lambda ()
;   (interactive)
;   (with-project-root
;       (shell-command-to-string "pwd"))))
;       ;(let ((root (cdr project-details)))
;       ;  (cond
;       ;    ;((file-exists-p ".svn")
;       ;    ; (svn-status root))
;       ;    ;((file-exists-p ".git")
;       ;    ; (git-status root))
;       ;    ; t)
;       ;    (t
;       ;     (vc-directory root nil)))))))

(define-key evil-motion-state-map (kbd "M-n") 'project-root-find-file)
(define-key evil-insert-state-map (kbd "M-n") 'project-root-find-file)

