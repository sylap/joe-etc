;; (add-to-list 'load-path "/home/udesktop/share/gtags/")

(defun extract-version-number (x)
  (mapcar 'string-to-int
		  (split-string (car (cdr (split-string x "-"))) "\\.")))

(defun pick-greater-version-helper (x y)
  (cond ((= (car x) (car y))
		 (if (> (length (cdr x)) 0)
			 (pick-greater-version-helper (cdr x) (cdr y))
		   (error x y (length (cdr x)))))
		((> (car x) (car y)) 0)
		((< (car x) (car y)) 1)))

(defun pick-greater-version (x y)
  (if (= (pick-greater-version-helper
		  (extract-version-number x)
		  (extract-version-number y)) 0)
	  x
	y))

;; ;; Defer to locally installed global if it exists
;; ;; And use the highest version number installed
;; (let ((global-install
;; 	   (reduce 'pick-greater-version
;; 			   (filter! 'file-directory-p
;; 						(mapcar (lambda (x) (concat "~/opt/" x))
;; 								(directory-files "~/opt" nil "global-?.?"))))))
;;   (add-to-list 'load-path (concat global-install "/share/gtags")))

(if (file-directory-p "~/opt/share/gtags")
    (add-to-list 'load-path "~/opt/share/gtags"))

;; Function to generate tags with GNU Global
;; from here: http://emacs-fu.blogspot.com/2009/01/navigating-through-source-code-using.html
(require 'gtags)

;; (defun djcb-gtags-create-or-update ()
;;   "create or update the gnu global tag file"
;;   (interactive)
;;   (if (not (= 0 (call-process "global" nil nil nil " -p"))) ; tagfile doesn't exist?
;; 	  (let ((olddir default-directory)
;; 			(topdir (read-directory-name
;; 					 "gtags: top of source tree:" default-directory)))
;; 		(when (not (string= topdir ""))
;; 		  (progn
;; 			(cd topdir)
;; 			(start-process-shell-command "gtags create"
;; 										 "gtags_buffer"
;; 										 "gtags -q && echo 'created tagfile'")
;; 			(cd olddir)))) ; restore
;;     ;;  tagfile already exists; update it
;;     (start-process-shell-command "gtags update"
;; 								 "gtags_buffer"
;; 								 "global -u 2> /dev/null && echo 'updated tagfile'")))

(defun gtags-select-tag-and-kill-buffer ()
  (interactive)
  (let ((buf (current-buffer)))
    (gtags-select-tag)
    (kill-buffer buf)))

;; Rebind the normal find tag functions to use the GNU global versions
(add-hook 'gtags-select-mode-hook
 		  (lambda()
				(define-key gtags-select-mode-map (kbd "<return>") 'gtags-select-tag-and-kill-buffer)))

;; Rebind the normal find tag functions to use the GNU global versions
(local-set-key (kbd "M-.") 'gtags-find-tag)   ; find a tag, also M-.
(local-set-key (kbd "M-,") 'gtags-find-rtag)  ; reverse tag

;; In later gtags versions these aren't set by default.
(define-key gtags-select-mode-map "\e*" 'gtags-pop-stack)
(define-key gtags-select-mode-map "\^?" 'scroll-down)
(define-key gtags-select-mode-map " " 'scroll-up)
(define-key gtags-select-mode-map "\C-b" 'scroll-down)
(define-key gtags-select-mode-map "\C-f" 'scroll-up)
(define-key gtags-select-mode-map "k" 'previous-line)
(define-key gtags-select-mode-map "j" 'next-line)
(define-key gtags-select-mode-map "p" 'previous-line)
(define-key gtags-select-mode-map "n" 'next-line)
(define-key gtags-select-mode-map "q" 'gtags-pop-stack)
(define-key gtags-select-mode-map "u" 'gtags-pop-stack)
(define-key gtags-select-mode-map "\C-t" 'gtags-pop-stack)
(define-key gtags-select-mode-map "\C-m" 'gtags-select-tag)
(define-key gtags-select-mode-map "\C-o" 'gtags-select-tag-other-window)

;; (if (string-match (concat "^/home/"
;; 						  (getenv "LOGNAME") ".*")
;; 				  default-directory)
;; 	(djcb-gtags-create-or-update))

(gtags-mode t)

(add-to-list 'load-path "~/etc/emacs/autopair-read-only")
(require 'autopair)
(autopair-mode)
(local-set-key (kbd "C-y") 'yank-and-indent)

(setq require-final-newline t)

(setq c-hungry-delete-key t)
(local-set-key (kbd "C-d") 'c-hungry-delete-forward)
(local-set-key (kbd "DEL") 'c-hungry-delete-forward)
(local-set-key (kbd "<backspace>") 'c-hungry-delete-backwards)

;; TODO: Ask on SO why innamespace offset isn't applying to
;; to comments.

(if (string-match ".*jgl.*" (system-name))
    (progn
      (setq my-indent-size 2)
      (c-set-offset 'innamespace 2))
  (progn
    (setq my-indent-size 4)
    (c-set-offset 'innamespace 0)))

;; Prefer 4-space tabs
(setq c-default-style "bsd")
(setq c-basic-offset my-indent-size)
(setq indent-tabs-mode nil)
(setq default-tab-width my-indent-size)
(setq tab-width my-indent-size)
(c-set-offset 'case-label '+)     ;; 'case' indented once after 'switch'

;; Make tab stop list match the 4 space indent
;;(setq tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60))

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
  (compile "bld"))

(defun ff/fast-compile ()
  "Compiles without asking anything."
  (interactive)
  (let ((compilation-read-command nil))
    (smart-compile)))

(define-key global-map [f9] 'ff/fast-compile)
(defun list-all-subfolders (folder)
  (let ((folder-list (list folder)))
	(dolist (subfolder (directory-files folder))
	  (let ((name (concat folder "/" subfolder)))
		(when (and (file-directory-p name)
				   (not (equal subfolder ".."))
				   (not (equal subfolder ".")))
		  (set 'folder-list (append folder-list (list name))))))
	folder-list))

;;-------------
;; Switch between source and header
;;------------
;; Association list of extension -> inverse extension
(setq exts '(("c"   . ("hpp" "h" "H"))
						 ("cc"  . ("hpp" "h" "H"))
						 ("cpp" . ("hpp" "h" "H"))
             ("hpp" . ("cpp" "c" "C" "cc" "CC"))
             ("h"   . ("cpp" "c" "C" "cc" "CC"))
						 ("H"   . ("cpp" "c" "C" "cc" "CC"))
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
			  (setq result (concat path "../" name "." value))
			(if (file-exists-p (concat path name "INLINES." value))
				(setq result (concat path name "INLINES." value))
			  (if (file-exists-p (concat path (replace-in-string name "INLINES" "") "." value))
				  (setq result (concat path (replace-in-string name "INLINES" "") "." value))))))))))

;; Toggle function that uses the current buffer name to open/find the
;; other file
(defun toggle-header-buffer()
  (interactive)
  (let ((ext (file-name-extension buffer-file-name))
        (fname (file-name-sans-extension buffer-file-name)))
    (find-file (find-other-file fname ext))))

;; Bind the toggle function to a global key
(global-set-key "\M-t" 'toggle-header-buffer)

(require 'whitespace)
(setq whitespace-style '(face lines))
(whitespace-mode t)

;; extra syntax highlighting
(defface font-lock-bracket-face
  '((t (:foreground "white")))
  "Font lock mode face for brackets, e.g. '(', ']', etc."
  :group 'font-lock-faces)
(defvar font-lock-bracket-face 'font-lock-bracket-face
  "Font lock mode face for backets.  Changing this directly
  affects only new buffers.")

(defvar operators-regexp
  (regexp-opt '("+" "-" "*" "/" "%" "!"
                "&" "^" "~" "|"
                "=" "<" ">"
                "." "," ";" ":" "?"))
  "Regexp matching symbols that are operators in most programming
  languages.")

(setq operators-font-lock-spec
      (cons operators-regexp
            (list
             0 ;; use whole match
             'font-lock-builtin-face
             'keep ;; OVERRIDE
             )))

(defvar brackets-regexp
  (regexp-opt '("(" ")" "[" "]" "{" "}"))
  "Regexp matching symbols that are grouping operators in most
  programming languages.")

(setq brackets-font-lock-spec
      (cons brackets-regexp
            (list
             0 ;; use whole match
             'font-lock-bracket-face
             'keep ;; OVERRIDE
             )))

(setq c-types-regexp
      (concat
       "\\<[_a-zA-Z][_a-zA-Z0-9]*_t\\>" "\\|"
       (regexp-opt '("short" "long" "unsigned" "signed" "int" "char" "float" "void") 'words)))

;; (setq c-keywords-regexp
;;       (concat
;;        "\\<[_a-zA-Z][_a-zA-Z0-9]*_t\\>" "\\|"
;;        (regexp-opt '(
;; 					 "and"
;; 					 "and_eq"
;; 					 "alignas"
;; 					 "alignof"
;; 					 "asm"
;; 					 "auto"
;; 					 "bitand"
;; 					 "bitor"
;; 					 "bool"
;; 					 "break"
;; 					 "case"
;; 					 "catch"
;; 					 "class"
;; 					 "compl"
;; 					 "const"
;; 					 "constexpr"
;; 					 "const_cast"
;; 					 "continue"
;; 					 "decltype"
;; 					 "default"
;; 					 "delete"
;; 					 "double"
;; 					 "dynamic_cast"
;; 					 "else"
;; 					 "enum"
;; 					 "explicit"
;; 					 "export"
;; 					 "extern"
;; 					 "false"
;; 					 "float"
;; 					 "for"
;; 					 "friend"
;; 					 "goto"
;; 					 "if"
;; 					 "inline"
;; 					 "mutable"
;; 					 "namespace"
;; 					 "new"
;; 					 "noexcept"
;; 					 "not"
;; 					 "not_eq"
;; 					 "nullptr"
;; 					 "operator"
;; 					 "or"
;; 					 "or_eq"
;; 					 "private"
;; 					 "protected"
;; 					 "public"
;; 					 "register"
;; 					 "reinterpret_cast"
;; 					 "return"
;; 					 "signed"
;; 					 "sizeof"
;; 					 "static"
;; 					 "static_assert"
;; 					 "static_cast"
;; 					 "struct"
;; 					 "switch"
;; 					 "template"
;; 					 "this"
;; 					 "thread_local"
;; 					 "throw"
;; 					 "true"
;; 					 "try"
;; 					 "typedef"
;; 					 "typeid"
;; 					 "typename"
;; 					 "union"
;; 					 "unsigned"
;; 					 "using"
;; 					 "virtual"
;; 					 "volatile"
;; 					 "while"
;; 					 "xor"
;; 					 "xor_eq"
;; 					 ) 'words))

(font-lock-add-keywords
 'c-mode
 (list
  operators-font-lock-spec
  brackets-font-lock-spec
  (cons c-types-regexp 'font-lock-type-face)))
  ;;(cons c-keywords-regexp 'font-lock-keyword-face)))

(font-lock-add-keywords
 'c++-mode
 (list
  operators-font-lock-spec
  brackets-font-lock-spec
  (cons c-types-regexp 'font-lock-type-face)))
  ;;(cons c-keywords-regexp 'font-lock-keyword-face)))

;; Starting in emacs 23 there's some stupid default abbreviation
;; for trying to correct mispellings of 'else', problem is it doesn't
;; understand context, so a legit variable named elSE will always get
;; changed to Else.
(abbrev-mode 0)
