(require 'evil)
(evil-set-toggle-key "<home>")
(evil-mode 1)

(define-key evil-motion-state-map (kbd ";") (lookup-key evil-motion-state-map (kbd ":")))

(define-key evil-insert-state-map (kbd "(") 
  (evil-define-motion evil-insert-parenttheses(cnt) 
    (insert "()")
    (backward-char)))

(define-key evil-insert-state-map (kbd "\"") 
  (evil-define-motion evil-insert-quotes (cnt) 
    (insert "\"\"")
    (backward-char)))

(define-key evil-insert-state-map (kbd "[") 
  (evil-define-motion evil-insert-brackets (cnt) 
    (insert "[]")
    (backward-char)))

(define-key evil-insert-state-map (kbd "{") 
  (evil-define-motion evil-insert-braces (cnt) 
    (insert "{}")
    (backward-char)))

(define-key evil-insert-state-map (kbd "M-j") 
  (evil-define-motion evil-insert-mode-j (cnt) 
    (next-line)))
(define-key evil-insert-state-map (kbd "M-k") 
  (evil-define-motion evil-insert-mode-k (cnt) 
    (previous-line)))
(define-key evil-insert-state-map (kbd "M-h") 
  (evil-define-motion evil-insert-mode-h (cnt) 
    (backward-char)))
(define-key evil-insert-state-map (kbd "M-l") 
  (evil-define-motion evil-insert-mode-l (cnt) 
    (forward-char)))

(require 'cl-lib)
(require 'popup)
(defun get-buffers ()
  (let ((buffs '()))
    (cl-loop for buffer in (buffer-list)
       if (and
           (or 
            (string= "*shell*" (buffer-name buffer))
            (string= "*Messages*" (buffer-name buffer)) 
            (buffer-name buffer)
            ;(buffer-file-name buffer)
            )
           (not
            (or
             (string-prefix-p " *Minibuf" (buffer-name buffer))
             nil
             )
            )
           )
       do (add-to-list 'buffs buffer 'append)
       finally return buffs)))
       ;finally return (sort buffs #'(lambda (buff1 buff2)
       ;(string< (buffer-file-name buff1) (buffer-file-name buff2)))))))

(defun buffer-select (popup)
  (let ((i (read-number "item number:" 0)))
    (popup-select popup i)
    )
)

(defun keep-menu-buffer-kill (popup)
  (let ((item (nth (popup-cursor popup) (popup-list popup))))
    ;(if 
    ;    (buffer-modified-p (get-buffer (popup-item-value item)))
    ;    (progn
    ;      (let (is-write (read-char-choice "the buffer is modified, save it" nil ))))
    ;    )
    
    (kill-buffer (popup-item-value item))
    (if (and (not (get-buffer (popup-item-value item) ) ) (stringp item) )
	(store-substring item 0 "X "))
    (popup-draw popup)
    )
  )

(defun keep-menu-buffer-del (popup)
  (let ((item (nth (popup-cursor popup) (popup-list popup))))
    (del-buffer-from-win (selected-window) (get-buffer (popup-item-value item)))
    (if (and (get-buffer (popup-item-value item)) (stringp item) )
	(store-substring item 0 "D "))
    (popup-draw popup)
    )
  )

(defun keep-menu-buffer-select (popup)
  (let ((item (nth (popup-cursor popup) (popup-list popup))))
    (add-buffer-to-win (selected-window) (get-buffer (popup-item-value item)))
    (if (and (get-buffer (popup-item-value item)) (stringp item) )
	(store-substring item 0 "S "))
    (popup-draw popup)
    )
  )

(defvar buffers-menu-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "TAB") 'popup-next)
    (define-key map "j" 'popup-next)
    (define-key map "k" 'popup-previous)
    (define-key map "q" 'keyboard-quit)
    (define-key map "x" 'keep-menu-buffer-kill)
    (define-key map "d" 'keep-menu-buffer-del)
    (define-key map "s" 'keep-menu-buffer-select)
    (define-key map " " 'popup-select)
    (define-key map "\r" 'popup-select)
    (define-key map (kbd "f") 'buffer-select)
    map)
)

(defun buffer-menu-select ()
  (let ((menu-items
	 (cl-loop for buffer in (win-buffer-list (selected-window))
		  for i from 0
		  collect (popup-make-item (format "  %d %s" i (or (buffer-file-name buffer) (buffer-name buffer))) :value (buffer-name buffer)))))
    (if (< 0 (length menu-items))
	(switch-to-buffer (popup-menu* menu-items :symbol t :keymap buffers-menu-keymap :height 10))))
  (add-curbuff-to-curwin)
  )

(defun buffer-menu-select-all ()
  (let ((menu-items
	 (cl-loop for buffer in (cared-buffer-list)
		  for i from 0
		  collect (popup-make-item (format "  %d %s" i (or (buffer-file-name buffer) (buffer-name buffer))) :value (buffer-name buffer)))))
    (if (< 0 (length menu-items))
	(switch-to-buffer (popup-menu* menu-items :symbol t :keymap buffers-menu-keymap :height 10)))
    )
    (add-curbuff-to-curwin)
  )

(define-key evil-motion-state-map (kbd "f") 
  (evil-define-motion evil-select-buffer (cnt) 
    (forward-char)
    (buffer-menu-select)))

(define-key evil-motion-state-map (kbd "F") 
  (evil-define-motion evil-select-buffer-all (cnt) 
    (forward-char)
    (buffer-menu-select-all)))

(evil-define-motion evil-switch-buffer (cnt) 
  (cl-loop for buffer in (get-switch-nearest-buffer-list (selected-window))
           for i from 0
           if (= i 1)
           do (switch-to-buffer buffer)
           )
  (add-curbuff-to-curwin)
  )

(define-key evil-motion-state-map (kbd "M-f") 'evil-switch-buffer)
(define-key evil-insert-state-map (kbd "M-f") 'evil-switch-buffer)
(define-key evil-motion-state-map (kbd "M-s") 'evil-window-next)
(define-key evil-insert-state-map (kbd "M-s") 'evil-window-next)

;; ------------------------ add begin -------------

(setq win-bufflist-map (make-hash-table :test 'eql))

(defun add-buffer-to-win(window buffer)
  (let* (
         ( bufflist (gethash window win-bufflist-map) ))
    (setq bufflist (remove buffer bufflist))
    (add-to-list 'bufflist buffer)
    (puthash window bufflist win-bufflist-map)
    )
  )

(defun add-curbuff-to-curwin()
  (add-buffer-to-win (selected-window) (current-buffer))
  )

(defun del-buffer-from-win(window buffer)
  (let* (
         ( bufflist (gethash window win-bufflist-map) ))
    (setq bufflist (remove buffer bufflist))
    (puthash window bufflist win-bufflist-map)
    )
  )

(setq cared-buffer-cnt -1)
(defun cared-buffer-list()
  (let ((buffs nil))
   (cl-loop for buffer in (buffer-list)
           if (and
               (or 
                (string= "*shell*" (buffer-name buffer))
                (string= "*Messages*" (buffer-name buffer)) 
                (string= "*scratch*" (buffer-name buffer)) 
                (buffer-name buffer)
                                        ;(buffer-file-name buffer)
                )
               (not
                (or
                 (string-prefix-p " *Minibuf" (buffer-name buffer))
                 (string-prefix-p "*elpy" (buffer-name buffer))
                 (string-prefix-p "*epc" (buffer-name buffer))
                 (string-prefix-p "*code-" (buffer-name buffer))
                 nil
                 )
                )
               )
           do (add-to-list 'buffs buffer 'append)
           finally return buffs)
   )
  )

(setq can-update-cared-buffer-list nil)
(add-hook 'after-init-hook '(lambda () (setq can-update-cared-buffer-list t)))
(add-hook 'buffer-list-update-hook 'update-cared-buffer-list)
(defun update-cared-buffer-list ()
  (if can-update-cared-buffer-list
   (let ((new-cared-buffer-cnt (length (cared-buffer-list))))
    ;(message "1. update-cared-buffer-list ---===--=-=-=-")
    (cond
     (
      (= cared-buffer-cnt new-cared-buffer-cnt)
    ;(message "2. update-cared-buffer-list ---===--=-=-=-")
      t)
     (
      (= -1 cared-buffer-cnt)
      (setq cared-buffer-cnt new-cared-buffer-cnt)

    ;(message "3. update-cared-buffer-list ---===--=-=-=-")
      (let* ((window (selected-window))
             ( bufflist (gethash window win-bufflist-map) ))
           ;(setq bufflist (remove (current-buffer) bufflist))
           (add-to-list 'bufflist (car (buffer-list)) )
           (puthash window bufflist win-bufflist-map)
           )
      )
     (
      (< cared-buffer-cnt new-cared-buffer-cnt)
      (setq cared-buffer-cnt new-cared-buffer-cnt)
    ;(message "4. update-cared-buffer-list ---===--=-=-=-")
    (if (not
         (or
          ;; these buffer I don't care
          (string= "*scratch*" (buffer-name (current-buffer)))
          (string-prefix-p "*epc" (buffer-name (current-buffer)))
          (string-prefix-p "*elpy" (buffer-name (current-buffer)))
          ))
        (let* ((window (selected-window))
               ( bufflist (gethash window win-bufflist-map) ))
          (setq bufflist (remove (current-buffer) bufflist))
          (add-to-list 'bufflist (current-buffer) )
          (puthash window bufflist win-bufflist-map)
          )
      )
    )
     (
      (> cared-buffer-cnt new-cared-buffer-cnt)
      (setq cared-buffer-cnt new-cared-buffer-cnt)
      ; remove from every window's associate-buff-list(if contained), we can do this
      ; but we don't, use the lazy stratege, remove it when called win-buffer-list
      )
     )
    )
   )
  )

(defun win-assoc-bufflist (window)
  (gethash window win-bufflist-map)
  )
;#called by function which binding to f, list the window associate buffers
(defun win-buffer-list (window)
  (cl-loop for buffer in (win-assoc-bufflist window)
           if (not (memq buffer (buffer-list)))
           do (
               let ((bufflist (gethash window win-bufflist-map)))
                (setq bufflist (remove buffer bufflist))
                (puthash window bufflist win-bufflist-map)
                )
           finally return (win-assoc-bufflist window)
           )
  )

;#called by function which binding to F, list the all buffers
;just use cared-buffer-list

;# function bind by M-f
(defun get-switch-nearest-buffer-list (window)
  (let ((win-buffer-list (win-assoc-bufflist window)))
   (if (< (length win-buffer-list) 2)
       (cared-buffer-list)
     win-buffer-list
       )
   )
  )
;; ------------------------ add end   -------------

;; for rscope begin
(load-file "~/.emacs.d/manual-package/rscope/rscope.el")
(add-hook 'c-mode-common-hook (function rscope:hook))

(evil-define-state rscope
  "Rscope state."
  :tag " <CS> "
  :suppress-keymap t)

(define-key evil-rscope-state-map "j" 
  (evil-define-motion evil-rscope-mode-j (cnt) 
    (rscope-next-symbol)))
(define-key evil-rscope-state-map "k" 
  (evil-define-motion evil-rscope-mode-k (cnt) 
    (rscope-prev-symbol)))
(define-key evil-rscope-state-map " " 
  (evil-define-motion evil-rscope-mode-space (cnt) 
    (rscope-select-entry-current-window)))
(define-key evil-rscope-state-map "o" 
  (evil-define-motion evil-rscope-mode-o (cnt) 
    (rscope-select-entry-other-window)))
(define-key evil-rscope-state-map "q" 
  (evil-define-motion evil-rscope-mode-q (cnt) 
    (rscope-close-results)))
(define-key evil-rscope-state-map (kbd "RET")
  (evil-define-motion evil-rscope-mode-ret (cnt) 
    (rscope-preview-entry-other-window)))
(when (featurep 'outline)
  (message "have outline---------->")
  (define-key evil-rscope-state-map "0" 
    (evil-define-motion evil-rscope-mode-0 (cnt) 
      (interactive)
      (show-all)))
  (define-key evil-rscope-state-map "1" 
    (evil-define-motion evil-rscope-mode-1 (cnt) 
      (interactive)
      (hide-sublevels 1)))
  (define-key evil-rscope-state-map "2" 
    (evil-define-motion evil-rscope-mode-2 (cnt) 
      (interactive)
      (hide-sublevels 2)))
  (define-key evil-rscope-state-map "3" 
    (evil-define-motion evil-rscope-mode-3 (cnt) 
      (interactive)
      (hide-sublevels 3)))
  (define-key evil-rscope-state-map "4" 
    (evil-define-motion evil-rscope-mode-4 (cnt) 
      (interactive)
      (hide-sublevels 4)))
  (define-key evil-rscope-state-map "+" 
    (evil-define-motion evil-rscope-mode-+ (cnt) 
      (hide-subtree)))
  (define-key evil-rscope-state-map "-" 
    (evil-define-motion evil-rscope-mode-- (cnt) 
      (hide-subtree)))
  )

(add-hook 'rscope-list-entry-hook 'evil-rscope-state)
;;(define-key rscope-list-entry-keymap "n" 'rscope-next-symbol)
;;(define-key rscope-list-entry-keymap "p" 'rscope-prev-symbol)
;;(define-key rscope-list-entry-keymap "q" 'rscope-close-results)
;;(define-key rscope-list-entry-keymap " " 'rscope-preview-entry-other-window)
;;(define-key rscope-list-entry-keymap (kbd "RET") 'rscope-select-entry-other-window)
;;(define-key rscope-list-entry-keymap (kbd "S-<return>") 'rscope-select-entry-current-window)
;;(when (featurep 'outline)
;;  (define-key rscope-list-entry-keymap "0" (lambda() (interactive) (show-all)))
;;  (define-key rscope-list-entry-keymap "1" (lambda() (interactive) (hide-sublevels 1)))
;;  (define-key rscope-list-entry-keymap "2" (lambda() (interactive) (hide-sublevels 2)))
;;  (define-key rscope-list-entry-keymap "3" (lambda() (interactive) (hide-sublevels 3)))
;;  (define-key rscope-list-entry-keymap "4" (lambda() (interactive) (hide-sublevels 4)))
;;  (define-key rscope-list-entry-keymap "-" (function hide-subtree))
;;  (define-key rscope-list-entry-keymap "+" (function show-subtree)))

;; for rscope end -------------------

;; for shell-current-directory begin -------------------->
(load-file "~/.emacs.d/el-get/shell-current-directory/shell-current-directory.el")
(define-key evil-motion-state-map (kbd "gs")
  (evil-define-motion evil-motion-gs (cnt)
      (shell-current-directory)
      ))
(define-key evil-motion-state-map (kbd "go")
  (evil-define-motion evil-motion-go (cnt)
      (shell-current-directory-other-window)
      ))
;; for shell-current-directory end   -------------------->

(provide 'init-evil)
