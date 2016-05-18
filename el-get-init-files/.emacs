(menu-bar-mode -1)
(setq-default indent-tabs-mode nil)
(setq default-tab-width 4)
(setq tab-width 4)
(setq tab-stop-list (number-sequence 4 120 4))
;(global-linum-mode t)

;; smooth scroll
(setq scroll-margin 3 scroll-conservatively 10000)
(setq search-highlight t)

(add-to-list 'load-path "~/.emacs.d/el-get")

;; for evil, must befor el-get
(setq evil-want-C-i-jump t)
(setq evil-want-C-u-scroll t)

(setq el-get-user-package-directory  "~/.emacs.d/el-get-init-files/")
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
    (url-retrieve-synchronously
      "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")
(el-get 'sync)

(setq c-default-style "linux"
      c-basic-offset 4)

;(add-to-list 'load-path "~/.emacs.d/manual-package/elscreen")
;(require 'elscreen)
;(elscreen-start)
;(define-key evil-normal-state-map (kbd "C-w t") 'elscreen-create) ;creat tab
;(define-key evil-normal-state-map (kbd "C-w x") 'elscreen-kill) ;kill tab
;(define-key evil-normal-state-map "gT" 'elscreen-previous) ;previous tab
;(define-key evil-normal-state-map "gt" 'elscreen-next) ;next tab

;; for load Semantic begin
(setq semantic-default-submodes '(global-semantic-idle-scheduler-mode
                                  global-semanticdb-minor-mode
                                  global-semantic-idle-summary-mode
                                  global-semantic-mru-bookmark-mode))
(semantic-mode 1)

(global-set-key (kbd "RET") 'newline-and-indent)
;; CC-mode
(add-hook 'c-mode-common-hook '(lambda ()
        (add-to-list 'ac-sources 'ac-source-semantic)
        (local-set-key (kbd "RET") 'newline-and-indent)
        (semantic-mode t)))
;; for load Semantic end

;; for semantic  Autocomplete  begin
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories (expand-file-name
             "~/.emacs.d/elpa/auto-complete-1.4.20110207/dict"))
(setq ac-comphist-file (expand-file-name
             "~/.emacs.d/ac-comphist.dat"))
(ac-config-default)

(global-semantic-highlight-edits-mode (if window-system 1 -1))
(global-semantic-show-unmatched-syntax-mode 1)
(global-semantic-show-parser-state-mode 1)

(defconst user-include-dirs
  (list "/home/dengyu/include/" "/home/dengyu/include/chnlincl/"))
(defconst system-include-dirs
  (list 
   "/usr/include/"
   "/usr/local/include/"
   ))
(let ((include-dirs user-include-dirs))
  (setq include-dirs (append include-dirs system-include-dirs))
  (mapc (lambda (dir)
          (semantic-add-system-include dir 'c++-mode)
          (semantic-add-system-include dir 'c-mode)
          (semantic-add-system-include dir 'cc-mode))
        include-dirs))

(setq ac-auto-show-menu t)
;; for semantic  Autocomplete end

(add-to-list 'auto-mode-alist '("\\.ec$" . c-mode))

;; highlight matching parentheses
(show-paren-mode t)
;; ------------------- for mod hook begin ----------------------------------
(add-hook 'python-mode-hook
          #'(lambda ()
              (modify-syntax-entry ?_ "w")
              ))

(add-hook 'c-mode-common-hook
          #'(lambda ()
              (modify-syntax-entry ?_ "w")
              ))

(add-hook 'emacs-lisp-mode-hook
          #'(lambda ()
              (modify-syntax-entry ?- "w")
              ))

;; ------------------- for mod hook end   ----------------------------------

(desktop-save-mode 1)

;; ------------------------add manually above this line---------------------
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(yas-snippet-dirs (quote ("/home/dengyu/.emacs.d/el-get/yasnippet/snippets" "/home/dengyu/.emacs.d/el-get/elpy/snippets/")) nil (yasnippet)))
