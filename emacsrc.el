;; TODO: Tab should OBEY. If the line is already indented, assume I want to insert a tab.

;; TODO: Make canceling telling global path just disable it

;; TODO: vc-annotate on CVS should use current working version when on a branch

;; TODO: If you undo, the mark should be reset.

;; Ideal tab behavior:
;; Indent line if not indented
;; If indented already, and are at beginning of line, insert a tab
;; If not indented already, and not at beginning of line, do code completion

;; Module: use indentation already used in file!
;; Nice to have: Next/prev buffer that is a file in same folder or subfolder, has the effect
;; of letting me browse project files. Nice for having dual emacs groups for different projects...

(toggle-debug-on-error)

;; When remotely logging in, need to remap alt for emacs keybindings to work
(when (getenv "DISPLAY")
  (when (not (string= (nth 0 (split-string (nth 1 (split-string (getenv "DISPLAY") ":")) "\\.")) "0"))
	(setq x-alt-keysym 'meta)))

(setq backup-directory-alist
	  `((".*" . ,"~/backup")))
(setq auto-save-file-name-transforms
	  `((".*" ,"~/backup" t)))
(setq tramp-backup-directory-alist backup-directory-alist)

(setq load-path (cons "~/etc/color-theme-6.6.0" load-path))
(if (file-exists-p "/home/udesktop178/joeg/global-install/share/gtags/gtags.el")
	(load-file "/home/udesktop178/joeg/global-install/share/gtags/gtags.el"))

(load-file "~/etc/color-theme-6.6.0/color-theme.el")
(load-file "~/etc/breadcrumb.el")

(add-to-list 'load-path "~/etc/drag-stuff")
(require 'drag-stuff)
(drag-stuff-global-mode t)

(add-to-list 'load-path "~/etc/wrap-region")
(require 'wrap-region)
(wrap-region-global-mode t)
(setq wrap-region-insert-twice t)
(add-hook 'wrap-region-after-insert-twice-hook
          (lambda ()
            (let ((modes '(c-mode c-mode-common-hook c++-mode java-mode javascript-mode css-mode)))
              (if (and (string= (char-to-string (char-before)) "{") (member major-mode modes))
                  (let ((origin (line-beginning-position)))
                    (newline 2)
                    (indent-region origin (line-end-position))
                    (forward-line -1)
                    (indent-according-to-mode))))))
(setq wrap-region-except-modes '(calc-mode))

(defadvice wrap-region (around wrap-region-around (left right beg end) activate)
  "..."
  (let ((modes '(c-mode c++-mode java-mode)))
    (cond ((member major-mode modes)
           (let ((region (buffer-substring-no-properties beg end))
                 (origin (line-beginning-position)))
             (delete-region beg end)
             (insert left)
             (newline 2)
             (insert "}")
             (indent-region origin (line-end-position))
             (forward-line -1)
             (insert region)
             (indent-region beg end)))
          (t ad-do-it))))

;; So annoying this is not default
(defadvice yank (after c-yank-indent)
  "Indents after yanking"
  (when (member major-mode '(c-mode c++-mode javascript-mode java-mode css-mode))
	(indent-region)))

(load-file "~/etc/undo-tree.el")
(require 'undo-tree)
(global-undo-tree-mode)
(define-key undo-tree-map (kbd "C-/") nil)

;; android-mode
(if (file-exists-p "~/opt/android-mode")
	(progn
	  (add-to-list 'load-path "~/opt/android-mode")
	  (require 'android-mode)
	  (setq android-mode-sdk-dir (getenv "ANDROID_PATH"))))

(defun android-debug ()
  (progn
	(setq gud-jdb-use-classpath t)
	(setq gud-jdb-classpath (format "%s/src:%s/bin/classes" (android-root) (android-root)))
	(setq gud-jdb-sourcepath (format "%s/src" (android-root)))
	)
  (jdb "jdb -attach localhost:8700")
  )

(defun android-log ()
  (terminal-emulator "android_log" "adb" '("logcat")))

(android-log)

(setq tramp-default-method "ssh")
(setq tramp-default-user "joeg")
(require 'tramp)

(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t)
;; Without these two lines when I try to reopen a file in a new frame it jumps to the old one >_<
(setq ido-default-file-method 'selected-window)
(setq ido-default-buffer-method 'selected-window)
(setq completion-ignored-extensions (append completion-ignored-extensions '(".fpo" ".ii")))

(require 'breadcrumb)
(setq bc-bookmark-limit 10000)
(global-set-key (kbd "C-S-SPC")         'bc-set) ;; Shift-SPACE for set bookmark
(global-set-key [(control meta j)]      'bc-previous) ;; M-j for jump to previous
(global-set-key [(control meta k)]      'bc-next) ;; Shift-M-j for jump to next
(global-set-key [(control meta l)]      'bc-goto-current) ;; C-c j for jump to current bookmark
(global-set-key [(control x)(control j)]        'bc-list) ;; C-x M-j for the bookmark menu list

(add-to-list 'default-frame-alist '(font . "Consolas-12"))

;; Color theme
(require 'color-theme)
(setq color-theme-is-global t)
(color-theme-initialize)
(color-theme-euphoria)

;; Turn off GUI parts
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(setq visible-bell t)
(fset 'yes-or-no-p 'y-or-n-p) ;; Make all "yes or no" prompts be "y or n" instead

;; Show me the region until I do something on it
(setq transient-mark-mode t)

;; Make killing the line also delete it
(setq kill-whole-line t)

;; Stop this crazy blinking cursor
(blink-cursor-mode 0)

;; when on a TAB, the cursor has the TAB length
(setq-default x-stretch-cursor t)

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
;;(mouse-avoidance-mode 'jump)

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
	  (when (not (string= topdir ""))
		  (progn
			(cd topdir)
			(start-process-shell-command "gtags create"
										 "gtags_buffer"
										 "gtags -q && echo 'created tagfile'")
			(cd olddir)))) ; restore
    ;;  tagfile already exists; update it
    (start-process-shell-command "gtags update"
								 "gtags_buffer"
								 "global -u 2> /dev/null && echo 'updated tagfile'")))

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

;; (add-hook 'c-mode-common-hook
;;   (lambda ()
;; 	(local-set-key (kbd "{") )))

(defun djcb-hasktags-create-or-update ()
  "create or update the TAGS file with hasktags"
  (interactive)
  (if (not (file-exists-p (concat default-directory "TAGS")))
    (let ((olddir default-directory)
          (topdir (read-directory-name
                    "hasktags: top of source tree:" default-directory)))
      (cd topdir)
      (shell-command "hasktags -e `find -name \\*.hs` && echo 'created tagfile'")
      (cd olddir)) ; restore
    ;;  tagfile already exists; update it
    (shell-command "hasktags -a `find -name \\*.hs` && echo 'updated tagfile'")))

(add-hook 'haskell-mode-hook
  (lambda ()
    (djcb-hasktags-create-or-update)))

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

(setq auto-mode-alist (cons '("\\.incl$" . c++-mode) auto-mode-alist))

;;-------------
;; Switch between source and header
;;------------
;; Association list of extension -> inverse extension
(setq exts '(("c"   . ("h" "H"))
			 ("cpp" . ("hpp" "h" "H"))
             ("hpp" . ("cpp" "c" "C"))
             ("h"   . ("cpp" "c" "C"))
			 ("H"   . ("cpp" "c" "C"))
			 ("C"   . ("hpp" "h" "H"))))

;; Process the association list of extensions and find the last file
;; that exists
(defun find-other-file (fname fext)
  (dolist (value (cdr (assoc fext exts)) result)
	(let ((path (file-name-directory fname))
		  (name (file-name-nondirectory fname)))
	  (if (file-exists-p (concat path name "." value))
		  (setq result (concat path name "." value))
		(if (file-exists-p (concat path "private/" name "." value))
			(setq result (concat path "private/" name "." value))
		  (if (file-exists-p (concat path "../" name "." value))
			  (setq result (concat path "../" name "." value))))))))
  
;; Toggle function that uses the current buffer name to open/find the
;; other file
(defun toggle-header-buffer()
  (interactive)
  (let ((ext (file-name-extension buffer-file-name))
        (fname (file-name-sans-extension buffer-file-name)))
    (find-file (find-other-file fname ext))))

;; Bind the toggle function to a global key
(global-set-key "\M-t" 'toggle-header-buffer) ;; TODO: Think of better key

;; So I can delete it
(setq show-trailing-whitespace t)

;; Delete trailing whitespace automagically
;; TODO: Debug, doesn't seem to be working
(add-hook 'write-file-hook
  (lambda ()
    (nuke-trailing-whitespace)))

;; Most useful binding ever
(global-set-key (kbd "C-/") 'comment-or-uncomment-region) ;; C-S-_ does undo already

;; By default compilation frame is half the window. Yuck.
(setq compilation-window-height 8)

 ;; keep the window focused on the messages during compilation
(setq compilation-scroll-output t)

 ;; Keep the highlight on the compilation error
(setq next-error-highlight t)

;; When compiling, make the compile window go away when finished if there are no errors
(setq compilation-finish-function
      (lambda (buf str)

        (if (string-match "exited abnormally" str)

            ;;there were errors
            (message "compilation errors, press C-x ` to visit")

          ;;no errors, make the compilation window go away in 0.5 seconds
          (run-at-time 0.5 nil 'delete-windows-on buf)
          (message "NO COMPILATION ERRORS!"))))

;; Don't indent whole files because they're in a namespace block
(add-hook 'c++-mode-hook (lambda () (c-set-offset 'innamespace 0)))

(global-set-key "\M-j" 'previous-buffer)
(global-set-key "\M-k" 'next-buffer)

(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "C-m") 'newline-and-indent)

;; If I'm searching and I hit backspace, I mean backspace dammit.
(define-key isearch-mode-map '[backspace] 'isearch-delete-char)

;; AWESOMENESS
(require 'cc-mode)
(global-set-key (kbd "C-d") 'c-hungry-delete-forward)
(global-set-key (kbd "DEL") 'c-hungry-delete-forward)
(global-set-key (kbd "<backspace>") 'c-hungry-delete-backwards)

(add-hook 'c-mode-common-hook
		  (lambda () (setq c-hungry-delete-key t)))

(add-hook 'c-mode-common-hook
		  (lambda () (c-subword-mode 1)))

(defun close-frame-or-exit ()
  "Tries to close the current frame, if it's the only one left just exits."
  (interactive)
  (if (= (length (frame-list)) 1)
	  (save-buffers-kill-emacs)
	(delete-frame)))

(global-set-key "\C-x\C-c" 'close-frame-or-exit)

;; TODO: Make this automatic for new .h files
(defun ff/headerize ()
  "Adds the #define HEADER_H, etc."
  (interactive)
  (let ((flag-name (replace-regexp-in-string
                    "[\. \(\)]" "_"
                    (upcase (file-name-nondirectory (buffer-name))))))
    (goto-char (point-max))
    (insert "\n#endif\n")
    (goto-char (point-min))
    (insert (concat "#ifndef " flag-name "\n"))
    (insert (concat "#define " flag-name "\n"))
    )
  )

;; Run makefile, or if there isn't one 
(defun smart-compile()
  (if (or (file-exists-p "makefile")
		  (file-exists-p "Makefile")
		  (file-exists-p "../Makefile"))
	  (compile "make -k -j2")
	(if (file-expand-wildcards "*.tc")
		(compile "tlmake")
	  (compile (concat
				"make -k -j2 "
				(file-name-sans-extension
				 (file-name-nondirectory buffer-file-name)))))))
  

(defun ff/fast-compile ()
  "Compiles without asking anything."
  (interactive)
  (let ((compilation-read-command nil))
    (smart-compile)))

(defun tlmake-install ()
  (interactive)
  (compile "tlmake install"))

(define-key global-map [f9] 'ff/fast-compile)
(define-key global-map [f10] 'tlmake-install)

(defun list-all-subfolders (folder)
  (let ((folder-list (list folder)))
	(dolist (subfolder (directory-files folder))
	  (let ((name (concat folder "/" subfolder)))
		(when (and (file-directory-p name)
				   (not (equal subfolder ".."))
				   (not (equal subfolder ".")))
		  (set 'folder-list (append folder-list (list name))))))
  folder-list))

;; Use full file names for buffers, otherwise can get lost
(setq-default mode-line-buffer-identification
			  '("%S:"(buffer-file-name "%f")))


(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)
(setq uniquify-separator "/")
(setq uniquify-after-kill-buffer-p t) ; rename after killing uniquified
(setq uniquify-ignore-buffers-re "^\\*") ; don't muck with special buffers

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
