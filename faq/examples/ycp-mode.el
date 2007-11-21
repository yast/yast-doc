;;; ycp-mode.el --- major mode for editing YCP code

;; Copyright (C) 1999 SuSE GmbH

;; Author: Andreas Schwab <schwab@suse.de>
;; Keywords: ycp languages

;; This package is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This package is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This packages provides a GNU Emacs major mode for editing YCP code.

;;; Code:

(require 'cc-vars)
(require 'cc-langs)
(require 'cc-styles)
(eval-when-compile (require 'cc-defs))

(defvar ycp-mode-syntax-table nil
  "Syntax table in use in YCP-mode buffers.")

(unless ycp-mode-syntax-table
  (let ((syntax-table (make-syntax-table)))
    (c-populate-syntax-table syntax-table)
    (modify-syntax-entry ?$ "'" syntax-table)
    ;; Kluge: make ` a word character
    (modify-syntax-entry ?` "w" syntax-table)
    (setq ycp-mode-syntax-table syntax-table)))

(defvar ycp-mode-abbrev-table nil
  "Abbrev table in use in YCP-mode buffers.")
(define-abbrev-table 'ycp-mode-abbrev-table ())

(defvar ycp-font-lock-keywords
 (let ((ycp-keywords
	(eval-when-compile
	 (regexp-opt '("if" "else" "while" "do" "repeat" "until"
		       "continue" "return" "define" "break"
		       "empty" "textdomain"))))
       (ycp-builtin-types
	(eval-when-compile
	 (regexp-opt '("any" "void" "integer" "boolean" "float"
		       "string" "byteblock" "path"
		       "locale" "symbol" "declaration" "term"
		       "list" "map" "block" "global"))))
       (ycp-builtin-funcs
	(eval-when-compile
	 (regexp-opt '("is" "select" "lookup" "contains" "setcontains"
		       "size" "haskey" "add" "prepend" "union" "foreach" "filter"
		       "find" "maplist" "flatten" "sort" "time" "toset" "listmap" "mapmap"
		       "tointeger" "tofloat" "tostring" "topath"
		       "crypt" "substring" "findfirstnotof" "tolower"
		       "toascii" "filterchars" "eval" "symbolof"
		       "sleep" "sformat" "y2log" "mergestring" "splitstring"
		       "findfirstof" "issubstring"
		       "fileexist" "checkIP" "isnil" "include" "module" "import"
		       "y2debug" "y2milestone" "y2warning" "y2error" "y2security" "y2internal"
		       ))))
       (ycp-ui-widgets
	(eval-when-compile
	 (regexp-opt '(
		       "`Bottom"
		       "`CheckBox"
		       "`ComboBox"
		       "`DownloadProgress"
		       "`Empty"
		       "`Frame"
		       "`HBox"
		       "`HCenter"
		       "`HSpacing"
		       "`HSquash"
		       "`HStretch"
		       "`HVCenter"
		       "`HVSquash"
		       "`HVStretch"
		       "`HWeight"
		       "`Heading"
		       "`Image"
		       "`IntField"
		       "`Label"
		       "`Left"
		       "`LogView"
		       "`MenuButton"
		       "`MultiLineEdit"
		       "`MultiSelectionBox"
		       "`Password"
		       "`ProgressBar"
		       "`PushButton"
		       "`RadioButton"
		       "`RadioButtonGroup"
		       "`ReplacePoint"
		       "`RichText"
		       "`Right"
		       "`SelectionBox"
		       "`Table"
		       "`TextEntry"
		       "`Top"
		       "`Tree"
		       "`VBox"
		       "`VCenter"
		       "`VSpacing"
		       "`VSquash"
		       "`VStretch"
		       "`VWeight"
		       "`DummySpecialWidget"
		       "`BarGraph"
		       "`Slider"
		       "`PartitionSplitter"
		       ))))

       (ycp-ui-widget-options
	(eval-when-compile
	 (regexp-opt '(
		       "`id"
		       "`item"
		       "`menu"
		       "`opt"

		       "`autoShortcut"
		       "`debugLayout"
		       "`decorated"
		       "`default"
		       "`defaultsize"
		       "`disabled"
		       "`editable"
		       "`hstretch"
		       "`hvstretch"
		       "`immediate"
		       "`notify"
		       "`outputField"
		       "`plainText"
		       "`shrinkable"
		       "`vstretch"
		       "`warncolor"
		       "`zeroWidth"
		       "`zeroHeight"
		       ))))

       (ycp-ui-widget-properties
	(eval-when-compile
	 (regexp-opt '(
		       "`CurrentButton"
		       "`CurrentItem"
		       "`Enabled"
		       "`ExpectedSize"
		       "`Filename"
		       "`Item"
		       "`Items"
		       "`Label"
		       "`Labels"
		       "`LastLine"
		       "`Notify"
		       "`SelectedItems"
		       "`Value"
		       "`Values"
		       "`ValidChars"
		       ))))

       (ycp-ui-glyphs
	(eval-when-compile
	 (regexp-opt '(
		       "`ArrowLeft"
		       "`ArrowRight"
		       "`ArrowUp"
		       "`ArrowDown"
		       "`CheckMark"
		       "`BulletArrowRight"
		       "`BulletCircle"
		       "`BulletSquare"
		       ))))

       (ycp-ui-functions
	(eval-when-compile
	  ;; For UI functions, presence of the leading backquote depends on UI
	  ;; or WFM context, thus it is optional - see regexp below (the
	  ;; '(cons (concat ...))' line)
	 (regexp-opt '(
		       "BusyCursor"
		       "ChangeWidget"
		       "CloseDialog"
		       "DumpWidgetTree"
		       "FakeUserInput"
		       "GetDisplayInfo"
		       "GetLanguage"
		       "GetModulename"
		       "Glyph"
		       "HasSpecialWidget"
		       "MakeScreenShot"
		       "NormalCursor"
		       "OpenDialog"
		       "PlayMacro"
		       "PollInput"
		       "QueryWidget"
		       "RecalcLayout"
		       "RecordMacro"
		       "ReplaceWidget"
		       "SetConsoleFont"
		       "SetFocus"
		       "SetLanguage"
		       "SetModulename"
		       "UserInput"
		       "WidgetExists"
		       ))))
       )
  (list
   (cons (concat "\\<\\(" ycp-keywords "\\)\\>")		'font-lock-keyword-face)
   (cons (concat "\\<\\(" ycp-builtin-types "\\)\\>")		'font-lock-type-face)
   (cons (concat "\\<\\(" ycp-builtin-funcs "\\)\\>")		'font-lock-function-name-face)
   (cons (concat "\\<`?\\(" ycp-ui-functions "\\)\\>")		'font-lock-function-name-face)
   (cons (concat "\\<\\(" ycp-ui-widgets "\\)\\>")		'font-lock-reference-face)
   (cons (concat "\\<\\(" ycp-ui-widget-options "\\)\\>")	'font-lock-constant-face)
   (cons (concat "\\<\\(" ycp-ui-widget-properties"\\)\\>")	'font-lock-type-face)
   (cons (concat "\\<\\(" ycp-ui-glyphs"\\)\\>")		'font-lock-type-face)
   (cons "\\<\\(true\\|false\\)\\>"
    ;; Losing XEmacs has no font-lock-constant-face
    (if (facep 'font-lock-constant-face)
     'font-lock-constant-face
     'font-lock-keyword-face))))
     "Default expressions to highlight in YCP mode.")

(defvar ycp-offsets-alist
  '((c-basic-offset . 4)
    (c-offsets-alist
     ;; Half indentation for toplevel statements
     (defun-block-intro     . *)
     ;; ???
     (arglist-intro         . c-lineup-arglist-intro-after-paren)
     ;; ???
     (arglist-close         . c-lineup-arglist)
     ;; Open "substatement" indicates the line after an `if', `else', `while', `do' statement.
     (substatement-open     . 0)))

  "Association list of syntactic element symbols and indentation offsets.

See `c-offsets-alist' for details")

(unless (assoc "ycp" c-style-alist)
  (c-add-style "ycp" ycp-offsets-alist))

;;;###autoload
(defun ycp-mode ()
  "Major mode for editing YCP code.
This is much like C mode.  It uses the same keymap as C mode and has the
same variables for customizing indentation.  It has its own abbrev table
and its own syntax table.

Turning on YCP mode calls the value of the variable `ycp-mode-hook'
with no args, if that value is non-nil."
  (interactive)
  (kill-all-local-variables)
  (require 'cc-mode)
  (c-initialize-cc-mode)
  (use-local-map c++-mode-map)
  (setq major-mode 'ycp-mode)
  (setq mode-name "YCP")
  (setq local-abbrev-table ycp-mode-abbrev-table)
  (c-common-init)
  (setq comment-start "// "
	comment-end   ""
	c-conditional-key "\\b\\(for\\|if\\|do\\|else\\|while\\)\\b[^_]"
 	c-class-key c-C-class-key	; WRONG
	c-baseclass-key nil
	c-comment-start-regexp c-C++-comment-start-regexp
	imenu-create-index-function 'cc-imenu-c-generic-expression ; XXX
	imenu-case-fold-search nil)
  (set-syntax-table ycp-mode-syntax-table)
  (set (make-local-variable 'font-lock-defaults)
       '(ycp-font-lock-keywords nil nil ((?_ . "w"))))
  (run-hooks 'c-mode-common-hook)
  (run-hooks 'ycp-mode-hook)
  (c-update-modeline)
  )
(provide 'ycp-mode)

;;; ycp-mode.el ends here
