;; TODO: It'd be cool to hit a key combo to cycle through yanking things
;; in the kill ring.. think there's already a customization for this.

;; Let us connect with emacs-client
(server-start)

(set-frame-font "Consolas-9")

;; Color theme
(require 'color-theme)
(setq color-theme-is-global t)
(color-theme-euphoria)

;; Turn off GUI parts
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-message t)
(setq visible-bell t)

;; Don't litter everywhere with file~ backups
(setq
 backup-by-copying t      ; don't clobber symlinks
 backup-directory-alist
 '(("." . "~/backup/emacs-backups"))    ; don't litter my fs tree
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)       ; use versioned backups

;; Make emacs use the normal clipboard
(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

;; Show column number in the mode line
(column-number-mode 1)

;; Show current buffer name in titlebar (instead of emacs@whatever)
(setq frame-title-format "%b")

;; Scroll 1 line at a time
(setq scroll-step 1)

;; God, the emacs people do think of everything
(mouse-avoidance-mode 'jump)

(defun move-line-up (n)
  "Moves current line N (1) lines up leaving point in place."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Moves current line N (1) lines down leaving point in place."
  (interactive "p")
  (move-line (if (null n) 1 n)))

(global-set-key [(meta up)] 'move-line-up)
(global-set-key [(meta down)] 'move-line-down)

;; A more useful C-a
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
	((save-excursion (skip-chars-backward " \t") (bolp)) ; At indentation.
	 (forward-line 0))
	(t (back-to-indentation))))
(global-set-key [(control a)] 'beginning-or-indentation)

;; Make C-w consistent with shell usage
;; Rebinds cut to C-x C-k though
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)

;; Don't use alt-x, use C-x C-m, alt is a pain
(global-set-key "\C-x\C-m" 'execute-extended-command)

;; Prefer to code in Python 3.0, the future :D
(setq-default py-python-command "python3")

;; Emacs won't load shell-script-mode for zsh automatically
(setq auto-mode-alist
      (append
       ;; File name (within directory) starts with a dot.
       '(("zshrc" . shell-script-mode))
       auto-mode-alist))

;; Function to generate tags with GNU Global
;; from here: http://emacs-fu.blogspot.com/2009/01/navigating-through-source-code-using.html
(defun djcb-gtags-create-or-update ()
  "create or update the gnu global tag file"
  (interactive)
  (if (not (= 0 (call-process "global" nil nil nil " -p"))) ; tagfile doesn't exist?
    (let ((olddir default-directory)
          (topdir (read-directory-name
                    "gtags: top of source tree:" default-directory)))
      (cd topdir)
      (shell-command "gtags && echo 'created tagfile'")
      (cd olddir)) ; restore
    ;;  tagfile already exists; update it
    (shell-command "global -u && echo 'updated tagfile'")))

;; Rebind the normal find tag functions to use the GNU global versions
(add-hook 'gtags-mode-hook
  (lambda()
    (local-set-key (kbd "M-.") 'gtags-find-tag)   ; find a tag, also M-.
    (local-set-key (kbd "M-,") 'gtags-find-rtag)))  ; reverse tag

;; Generate tags whenever we open a C/C++ source file
(add-hook 'c-mode-common-hook
  (lambda ()
    (require 'gtags)
    (gtags-mode t)
    (djcb-gtags-create-or-update)))

;; Append a new line to files so GCC shuts up
(add-hook 'c-mode-common-hook
  (lambda ()
    (setq require-final-newline t)))

;; Prefer 4-space tabs
(setq c-default-style "bsd")
(setq-default c-basic-offset 4)
(setq-default indent-tabs-mode t)
(setq default-tab-width 4)
(setq tab-width 4)
(c-set-offset 'case-label '+)     ;; 'case' indented once after 'switch'

;; For most modes I'm coding, I don't want line wrap
(setq-default truncate-lines t)

;; Show matching parentheses
(show-paren-mode 1)

;;-------------
;; Switch between source and header
;;------------
;; Association list of extension -> inverse extension
(setq exts '(("c"   . ("h"))
			 ("cpp" . ("hpp" "h"))
             ("hpp" . ("cpp" "c"))
             ("h"   . ("cpp" "c"))))

;; Process the association list of extensions and find the last file
;; that exists
(defun find-other-file (fname fext)
  (dolist (value (cdr (assoc fext exts)) result)
    (if (file-exists-p (concat fname "." value))
        (setq result (concat fname "." value)))))

;; Toggle function that uses the current buffer name to open/find the
;; other file
(defun toggle-header-buffer()
  (interactive)
  (let ((ext (file-name-extension buffer-file-name))
        (fname (file-name-sans-extension buffer-file-name)))
    (find-file (find-other-file fname ext))))

;; Bind the toggle function to a global key
;;(global-set-key "\M-t" 'toggle-header-buffer) ;; TODO: Think of better key

;; So I can delete it
(setq show-trailing-whitespace t)

;; Delete trailing whitespace automagically
(add-hook 'write-file-hook
  (lambda ()
    (nuke-trailing-whitespace)))

;; Most useful binding ever
(global-set-key (kbd "C-/") 'comment-or-uncomment-region) ;; C-S-_ does undo already

;; Add code to let me move lines up or down
(defun move-line (&optional n)
  "Move current line N (1) lines up/down leaving point in place."
  (interactive "p")
  (when (null n)
    (setq n 1))
  (let ((col (current-column)))
    (beginning-of-line)
    (next-line 1)
    (transpose-lines n)
    (previous-line 1)
    (forward-char col)))