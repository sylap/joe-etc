;; TODO: 'n' and 'p' should go up and down without ctrl
;; when in a read only buffer. will make navigating ack
;; output easier.

;; TODO: No global prompt for /tmp

;; for emacsclient
(server-start)

;; When running a local install of emacs, still pull in officially
;; installed packages.
(when (and (file-directory-p "/usr/share/emacs/site-lisp")
           (not (memq "/usr/share/emacs/site-lisp" load-path)))
  (add-to-list 'load-path "/usr/share/emacs/site-lisp"))

;; Color theme
(add-to-list 'load-path "~/etc/emacs/color-theme-6.6.0")
(require 'color-theme)
(setq color-theme-is-global t)
(color-theme-initialize)
(color-theme-euphoria)

;; Enable debugging
(setq-default debug-on-error t)

(when (getenv "DISPLAY")
  ;; Make emacs use the normal clipboard
  (setq x-select-enable-clipboard t)
  (setq interprogram-paste-function 'x-cut-buffer-or-selection-value)
  ;; When remotely logging in, need to remap alt for emacs keybindings to work
  (when (not (string= (nth 0 (split-string (nth 1 (split-string (getenv "DISPLAY") ":")) "\\.")) "0"))
    (setq x-alt-keysym 'meta)))

(setq make-backup-files nil)

(add-to-list 'load-path "~/etc/drag-stuff")
(add-to-list 'load-path "~/etc/emacs")

(require 'winpoint)
(window-point-remember-mode 1)

(require 'drag-stuff)
(drag-stuff-global-mode t)

(defun yank-and-indent ()
  "Yank and then indent the newly formed region according to mode."
  (interactive)
  (yank)
  (call-interactively 'indent-region))

(require 'undo-tree)
(global-undo-tree-mode)
(define-key undo-tree-map (kbd "C-/") nil)
(setq-default undo-limit 1000000)
(setq-default undo-strong-limit 1000000)

(setq tramp-default-method "ssh")
(setq tramp-default-user "joeg")
(require 'tramp)

(require 'ido)
;; Without this, when running emacs as sudo .ido.last will become
;; root owned. Super annoying.
(setq ido-save-directory-list-file (concat "~/.ido." (getenv "LOGNAME") ".last"))
(ido-mode t)
(setq ido-enable-flex-matching t)
;; Without these two lines when I try to reopen a file in a new frame it jumps to the old one >_<
(setq ido-default-file-method 'selected-window)
(setq ido-default-buffer-method 'selected-window)
(setq completion-ignored-extensions
      (append completion-ignored-extensions '(".fpo" ".ii" ".d" ".o")))
(setq ido-ignore-files
      (append ido-ignore-files '(".*-g" ".*-O2")))

(load-file "~/etc/breadcrumb.el")
(require 'breadcrumb)
(setq bc-bookmark-limit 10000)
(global-set-key (kbd "C-S-SPC")         'bc-set) ;; Shift-SPACE for set bookmark
(global-set-key [(control meta j)]      'bc-previous) ;; M-j for jump to previous
(global-set-key [(control meta k)]      'bc-next) ;; Shift-M-j for jump to next
(global-set-key [(control meta l)]      'bc-goto-current) ;; C-c j for jump to current bookmark
(global-set-key [(control x)(control j)]        'bc-list) ;; C-x M-j for the bookmark menu list

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:height 105 :family "Consolas" :embolden f)))))

;; Turn off GUI parts
(when (functionp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (functionp 'menu-bar-mode)
  (menu-bar-mode -1))
(when (functionp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(setq visible-bell t)
(fset 'yes-or-no-p 'y-or-n-p) ;; Make all "yes or no" prompts be "y or n" instead

;; Get rid of the visual bell for some common 'errors'
(setq ring-bell-function
      (lambda ()
        (unless (memq this-command
                      '(isearch-abort abort-recursive-edit exit-minibuffer keyboard-quit))
          (ding))))

;; Show me the region until I do something on it
(setq transient-mark-mode t)

;; Make killing the line also delete it
(setq kill-whole-line t)

;; Stop this crazy blinking cursor
(blink-cursor-mode 0)

;; when on a TAB, the cursor has the TAB length
(setq-default x-stretch-cursor t)

;; Show column number in the mode line
(column-number-mode 1)

;; Show current buffer name in titlebar (instead of emacs@whatever)
(setq frame-title-format "%b")

;; Scroll 1 line at a time
(setq scroll-step 1)

(defun beginning-or-indentation (&optional n)
  "Move cursor to beginning of this line or to its indentation.
  If at indentation position of this line, move to beginning of line.
  If at beginning of line, move to beginning of previous line.
  Else, move to indentation position of this line.
  With arg N, move backward to the beginning of the Nth previous line.
  Interactively, N is the prefix arg."
  (interactive "P")
  (cond ((or (bolp) n)
         (forward-line (- (prefix-numeric-value n))))
        ((save-excursion (skip-chars-backward "[:space:]") (bolp)) ; At indentation.
         (forward-line 0))
        (t (back-to-indentation))))

(defun end-or-trailing (&optional n)
  "Move cursor to end of this line or to its indentation.
  If in middle of of this line, move to last nonwhitespace character on line.
  If at last nonwhitespace character of this line, move to end of line.
  With arg N, move backward to the end of the Nth next line.
  Interactively, N is the prefix arg."
  (interactive "P")
  (cond
   ((or (eolp) n)
    (message "cond1")
    (forward-line (prefix-numeric-value (or n 1)))
    (end-of-line)
    (skip-chars-backward "[:space:]"))
   ((save-excursion
      (skip-chars-forward "[:space:]")
      (eolp)) ; At start of trailing whitespace
    (message "cond2")
    (end-of-line))
   (t
    (message "cond3")
    (end-of-line)
    (skip-chars-backward "[:space:]"))))

(global-set-key "\C-a" 'beginning-or-indentation)
(global-set-key "\C-e" 'end-or-trailing)

;; Make C-w consistent with shell usage
;; Rebinds cut to C-x C-k though
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)

;; Don't use alt-x, use C-x C-m, alt is a pain
(global-set-key "\C-x\C-m" 'execute-extended-command)

;; Emacs won't load shell-script-mode for zsh automatically
(setq auto-mode-alist
      (append
       ;; File name (within directory) starts with a dot.
       '(("zshrc" . shell-script-mode)
         ("\\.do\\'" . shell-script-mode))
       auto-mode-alist))

;; Emacs won't load emacs-lisp-mode for ido-prompt automatically
(setq auto-mode-alist
      (append
       ;; File name (within directory) starts with a dot.
       '(("ido-prompt" . emacs-lisp-mode))
       auto-mode-alist))

;; Emacs won't load emacs-lisp-mode for ido-prompt automatically
(setq auto-mode-alist
      (append
       ;; File name (within directory) starts with a dot.
       '(("\\.json\\'" . js2-mode))
       auto-mode-alist))

(setq auto-mode-alist
      (append
       ;; File name (within directory) starts with a dot.
       '(("\\.cpp.cog\\'" . c++-mode)
         ("\\.hpp.cog\\'" . c++-mode)
         ("\\.incl$'" . c++-mode))
       auto-mode-alist))

;; For most modes I'm coding, I don't want line wrap
(setq-default truncate-lines t)

;; Show matching parentheses
(show-paren-mode 1)

;; So I can delete it
(setq show-trailing-whitespace t)

;; Delete trailing whitespace automagically
;; (add-hook 'write-file-hooks
;;           (lambda ()
;;             (delete-trailing-whitespace)))

(add-hook 'sh-mode-hook
	  (lambda () (setq indent-tabs-mode nil)))

;; TODO: Filter untabify for makefiles

(setq indent-tabs-mode nil)

;; Most useful binding ever
(global-set-key (kbd "C-/") 'comment-or-uncomment-region) ;; C-S-_ does undo already

;; By default compilation frame is half the window. Yuck.
(setq compilation-window-height 8)

;; keep the window focused on the messages during compilation
(setq compilation-scroll-output t)

;; Keep the highlight on the compilation error
(setq next-error-highlight t)

(defun buffer-mode (buffer-or-string)
  "Returns the major mode associated with a buffer."
  (save-excursion
    (set-buffer buffer-or-string)
    major-mode))

;; When compiling, make the compile window go away when finished if there are no errors
(setq compilation-finish-function
      (lambda (buf str)
        (if (string-match "ack:.*" (buffer-name buf))
            (let ((cur-window (selected-window)))
              (select-window (get-buffer-window buf))
              (goto-char 0)
              (select-window cur-window))
          (if (string-match "exited abnormally" str)
              ;;there were errors
              (message "compilation errors, press C-x ` to visit")
            ;;no errors, make the compilation window go away in 0.5 seconds
            (run-at-time 0.5 nil 'delete-windows-on buf)
            (message "NO COMPILATION ERRORS!")))))

(global-set-key "\M-j" 'previous-buffer)
(global-set-key "\M-k" 'next-buffer)

;; TODO: disable for assembly
(defun indent-newline-indent ()
  (interactive)
  (progn
    (indent-according-to-mode)
    (newline-and-indent)))

(defun open-line-and-indent ()
  (interactive)
  (progn
    (open-line 1)
    (indent-according-to-mode)))

(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "C-m") 'newline-and-indent)
(global-set-key (kbd "C-o") 'open-line-and-indent)

(setq auto-mode-alist
	  (cons '("\\.make\\'" . makefile-gmake-mode) auto-mode-alist))

(add-hook 'asm-mode-hook
	  (lambda ()
	    (local-set-key (kbd "RET") 'newline)))

;; If I'm searching and I hit backspace, I mean backspace dammit.
(define-key isearch-mode-map '[backspace] 'isearch-delete-char)

(defun close-frame-or-exit ()
  "Tries to close the current frame, if it's the only one left just exits."
  (interactive)
  (if (= (length (frame-list)) 1)
      (save-buffers-kill-emacs)
    (delete-frame)))

;; Close windows, not emacs.
(global-set-key "\C-x\C-c" 'close-frame-or-exit)

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)
(setq uniquify-separator "|")
(setq uniquify-after-kill-buffer-p t) ; rename after killing uniquified
(setq uniquify-ignore-buffers-re "^\\*") ; don't muck with special buffers
(setq uniquify-buffer-name-style 'post-forward)

(global-set-key (kbd "C-x K") 'kill-other-buffers-of-this-file-name)

(defun kill-other-buffers-of-this-file-name (&optional buffer)
  "Kill all other buffers visiting files of the same base name."
  (interactive "bBuffer to make unique: ")
  (setq buffer (get-buffer buffer))
  (cond ((buffer-file-name buffer)
         (let ((name (file-name-nondirectory (buffer-file-name buffer))))
           (loop for ob in (buffer-list)
                 do (if (and (not (eq ob buffer))
                             (buffer-file-name ob)
                             (let ((ob-file-name (file-name-nondirectory (buffer-file-name ob))))
                               (or (equal ob-file-name name)
                                   (string-match (concat name "\\.~.*~$") ob-file-name))) )
                        (kill-buffer ob)))))
        (default (message "This buffer has no file name."))))

(defun unindent-region-with-tab ()
  (interactive)
  (save-excursion
    (if (< (point) (mark)) (exchange-point-and-mark))
    (let ((save-mark (mark)))
      (if (= (point) (line-beginning-position)) (previous-line 1))
      (goto-char (line-beginning-position))
      (while (>= (point) save-mark)
        (goto-char (line-beginning-position))
        (if (= (string-to-char "\t") (char-after (point))) (delete-char 1))
        (previous-line 1)))))

(defun unindent-block()
  (interactive)
  (shift-region (- tab-width))
  (setq deactivate-mark nil))

(defun shift-region(numcols)
  (if (< (point)(mark))
      (if (not(bolp))    (progn (beginning-of-line)(exchange-point-and-mark) (end-of-line)))
    (progn (end-of-line)(exchange-point-and-mark)(beginning-of-line)))
  (setq region-start (region-beginning))
  (setq region-finish (region-end))
  (save-excursion
    (if (< (point) (mark)) (exchange-point-and-mark))
    (let ((save-mark (mark)))
      (indent-rigidly region-start region-finish numcols))))

(global-set-key "\C-s" 'isearch-forward-regexp)
(global-set-key "\C-r" 'isearch-backward-regexp)
(global-set-key "\M-%" 'query-replace-regexp)

(require 'ack)
(autoload 'ack-same "full-ack" nil t)
(autoload 'ack "full-ack" nil t)
(autoload 'ack-find-same-file "full-ack" nil t)
(autoload 'ack-find-file "full-ack" nil t)
(global-set-key "\M-k" 'ack)
(setq-default ack-guess-type nil)
(setq-default ack-command (concat (expand-file-name "etc/bin/ack" (getenv "HOME")) " --nocolor --nogroup "))

;; Threshold after which we consider the file to be large
;; and don't want to do anything too expensive.
(setq uncomfortable-buffer-size (* 10 1024 1024))

;; Make more notepad like out of the box
(setq default-major-mode 'text-mode)
(setq text-mode-hook        ; Enable auto-fill-mode
      '(lambda ()
         (let ((ext (file-name-extension (buffer-file-name))))
           (when (and (not (or (string-equal ext "tc")
                               (string-equal ext "in")
                               (string-equal ext "tmp")
                               (string-equal ext "log")))
                      (< (buffer-size) uncomfortable-buffer-size))
             (visual-line-mode 1)))))

;; Taken from Trey Jackson's answer on superuser.com
;; http://superuser.com/questions/205420/how-can-i-interrupt-emacs-opening-a-large-file
(defun my-find-file-check-make-large-file-read-only-hook ()
  "If a file is over a given size, make the buffer read only."
  (when (> (buffer-size) uncomfortable-buffer-size)
    (setq buffer-read-only t)
    (setq auto-save-default nil)
    (buffer-disable-undo)
    (fundamental-mode)
    (message "Large buffer: Undo disabled, made read only, autosave disabled.")))
(add-hook 'find-file-hooks 'my-find-file-check-make-large-file-read-only-hook)

(defun my-delete-leading-whitespace (start end)
  "Delete whitespace at the beginning of each line in region."
  (interactive "*r")
  (save-excursion
    (if (not (bolp)) (forward-line 1))
    (delete-whitespace-rectangle (point) end nil)))
(global-set-key "\C-x\C-h" 'my-delete-leading-whitespace)

(add-hook 'c-mode-common-hook
          (lambda ()
            (load "~/etc/emacs/c-common.el")))

(add-hook 'java-mode-hook
          (lambda ()
            (load "~/etc/emacs/java.el")))

(modify-frame-parameters nil '((wait-for-wm . nil)))

(autoload 'markdown-mode "markdown-mode.el"
  "Major mode for editing Markdown files" t)
(setq auto-mode-alist
      (cons '("\\.md" . markdown-mode) auto-mode-alist))

;; lets you delete camelcase words one at a time
(if (functionp 'c-subword-mode)
    (progn
      (require 'cc-mode)
      (c-subword-mode 1))
  (subword-mode t))

;; use setq-default to set it for /all/ modes
(setq-default mode-line-format
              (list
               ;; the buffer name; the file name as a tool tip
               '(:eval (propertize "%b " 'face 'font-lock-warning-face
                                   'help-echo (buffer-file-name)))

               ;; line and column
               "(" ;; '%02' to set to 2 chars at least; prevents flickering
               (propertize "%02l" 'face 'font-lock-type-face) ","
               (propertize "%02c" 'face 'font-lock-type-face)
               ") "

               ;; relative position, size of file
               "["
               (propertize "%p" 'face 'font-lock-comment-face) ;; % above top
               "/"
               (propertize "%I" 'face 'font-lock-comment-face) ;; size
               "] "

               ;; the current major mode for the buffer.
               "["

               '(:eval (propertize "%m" 'face 'font-lock-string-face
                                   'help-echo buffer-file-coding-system))
               "] "


               "[" ;; insert vs overwrite mode, input-method in a tooltip
               '(:eval (propertize (if overwrite-mode "Ovr" "Ins")
                                   'face 'font-lock-variable-name-face
                                   'help-echo (concat "Buffer is in "
                                                      (if overwrite-mode "overwrite" "insert") " mode")))

               ;; is this buffer read-only?
               '(:eval (when buffer-read-only
                         (concat ","  (propertize "RO"
                                                  'face 'font-lock-type-face
                                                  'help-echo "Buffer is read-only"))))
               "] "

               ;; add the time, with the date and the emacs uptime in the tooltip
               '(:eval (propertize (format-time-string "%H:%M")
                                   'help-echo
                                   (concat (format-time-string "%c; ")
                                           (emacs-uptime "Uptime:%hh"))))
               ;; was this buffer modified since the last save?
               '(:eval (when (buffer-modified-p)
                         (concat " "  (propertize "Mod"
                                                  'face 'font-lock-warning-face
                                                  'help-echo "Buffer has been modified"))))

               " --"
               ;; i don't want to see minor-modes; but if you want, uncomment this:
               ;; minor-mode-alist  ;; list of minor modes
               "%-" ;; fill with '-'
               ))

;; Kill whole words at once, even in mid word
(global-set-key (kbd "M-d")
                (lambda ()
                  (interactive)
                  (if (char-after)
                      (progn
                        (backward-word)
                        (kill-word 1)))))

(require 'project-root)

(setq project-roots
      `(("Autotools project"
         :root-contains-files ("configure.ac")
         :on-hit (lambda (p) (message (car p))))
        ("TL project"
         :filename-regex ,(regexify-ext-list '(tc H C))
         :on-hit (lambda (p) (message (car p))))
        ("bld project"
         :root-contains-files ("bld-list")
         :on-hit (lambda (p) (message (car p))))
        ("CMake project"
         :root-contains-files ("CMakeLists.txt")
         :on-hit (lambda (p) (message (car p))))
        ("Personal config files"
         :path-matches ,(format "\\(%s\\)*" (expand-file-name "etc" (getenv "HOME")))
         :on-hit (lambda (p) (message (car p))))
        ("Fallback to current folder"
         :root-contains-files (".")
         :on-hit (lambda (p) (message (car p))))))

(global-set-key (kbd "C-c f") 'project-root-find-file)
(global-set-key (kbd "C-c a") 'project-root-ack)
(global-set-key (kbd "C-c d") 'project-root-goto-root)
(global-set-key (kbd "C-c p") 'project-root-run-default-command)
(global-set-key (kbd "C-c l") 'project-root-browse-seen-projects)

(defun compilation-buffer-name-jg (unused-mode-name)
  (concat unused-mode-name ": " (with-project-root default-directory)))
(setq-default compilation-buffer-name-function 'compilation-buffer-name-jg)
(global-set-key [f9] 'compile)

;; Ostensibly this is for letting you insert the results of minibuffer
;; commands into other minibuffer commands, but I like it because it
;; just lets me use the damn thing without getting the error about
;; "Command attempted to use minibuffer while in minibuffer"
(setq enable-recursive-minibuffers t)

;; Highlight current line subtly, makes it easier to find cursor
(global-hl-line-mode)
(set-face-background hl-line-face "grey13")

;; We always want a gigantic mark ring
(setq-default mark-ring-max 65535)

;; Needed for ido-mode to work in large source trees
(setq ido-max-directory-size 3000000)

(put 'upcase-region 'disabled nil)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(TeX-view-program-selection (quote (((output-dvi style-pstricks) "Evince") (output-dvi "Evince") (output-pdf "Evince") (output-html "Evince"))))
 '(ediff-split-window-function (quote split-window-horizontally)))


; Code to get the current class name, will try this if I can't get
; autocomplete working
;; (replace-regexp-in-string "INLINES$" ""
;;  (file-name-sans-extension
;;   (file-name-nondirectory (buffer-file-name))))
