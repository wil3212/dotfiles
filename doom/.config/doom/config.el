;; Set your Roam directory
(setq org-roam-directory (file-truename "~/org-roam"))
(setq org-journal-dir "~/org-roam/journal")

(map! :leader
    (:prefix-map ("w" . "wiki")
    :desc "Open Index" "w" (lambda () (interactive) (find-file (expand-file-name "20260513000206-main_thing.org" org-roam-directory)))))

(setq display-line-numbers-type 'relative)




(setq imenu-list-focus-after-activation t)
(map! :leader
      (:prefix ("t" . "Toggle")
       :desc "Toggle imenu shown in a sidebar" "i" #'imenu-list-smart-toggle))



(defun my/org-checkbox-timestamp (&rest _)
  "Append a precise timestamp when a checkbox is checked."
(save-excursion
(beginning-of-line)
;; Verifica se a linha tem um checkbox marcado [X] e se já não possui o texto "(Concluído:"
(when (and (looking-at "^[ \t]*\\(?:[-+*]\\|[0-9]+[.)]\\)[ \t]+\\[X\\]")
            (not (string-match-p "(Concluído:" (thing-at-point 'line t))))
    (end-of-line)
    ;; Insere a data e a hora exata (HH:MM:SS)
    (insert (format-time-string " (Concluído: %Y-%m-%d %H:%M:%S)")))))

;; Conecta a função para rodar sempre DEPOIS que você usar o atalho de marcar o checkbox
(advice-add 'org-toggle-checkbox :after #'my/org-checkbox-timestamp)
(setq doom-theme 'doom-acario-dark)

;; This elisp code uses use-package, a macro to simplify configuration. It will
;; install it if it's not available, so please edit the following code as
;; appropriate before running it.

;; Note that this file does not define any auto-expanding YaSnippets.

;; Install use-package
(package-install 'use-package)

;; AucTeX settings - almost no changes
(use-package latex
  :ensure auctex
  :hook ((LaTeX-mode . prettify-symbols-mode))
  :bind (:map LaTeX-mode-map
         ("C-S-e" . latex-math-from-calc))
  :config
  ;; Format math as a Latex string with Calc
  (defun latex-math-from-calc ()
    "Evaluate `calc' on the contents of line at point."
    (interactive)
    (cond ((region-active-p)
           (let* ((beg (region-beginning))
                  (end (region-end))
                  (string (buffer-substring-no-properties beg end)))
             (kill-region beg end)
             (insert (calc-eval `(,string calc-language latex
                                          calc-prefer-frac t
                                          calc-angle-mode rad)))))
          (t (let ((l (thing-at-point 'line)))
               (end-of-line 1) (kill-line 0)
               (insert (calc-eval `(,l
                                    calc-language latex
                                    calc-prefer-frac t
                                    calc-angle-mode rad))))))))

(use-package preview
  :after latex
  :hook ((LaTeX-mode . preview-larger-previews))
  :config
  (defun preview-larger-previews ()
    (setq preview-scale-function
          (lambda () (* 1.25
                   (funcall (preview-scale-from-face)))))))

;; CDLatex settings
(use-package cdlatex
  :ensure t
  :hook (LaTeX-mode . turn-on-cdlatex)
  :bind (:map cdlatex-mode-map
              ("<tab>" . cdlatex-tab)))

;; Yasnippet settings
(use-package yasnippet
  :ensure t
  :hook ((LaTeX-mode . yas-minor-mode)
         (post-self-insert . my/yas-try-expanding-auto-snippets))
  :config
  (use-package warnings
    :config
    (cl-pushnew '(yasnippet backquote-change)
                warning-suppress-types
                :test 'equal))

  (setq yas-triggers-in-field t)

  ;; Function that tries to autoexpand YaSnippets
  ;; The double quoting is NOT a typo!
  (defun my/yas-try-expanding-auto-snippets ()
    (when (and (boundp 'yas-minor-mode) yas-minor-mode)
      (let ((yas-buffer-local-condition ''(require-snippet-condition . auto)))
        (yas-expand)))))

;; CDLatex integration with YaSnippet: Allow cdlatex tab to work inside Yas
;; fields
(use-package cdlatex
  :hook ((cdlatex-tab . yas-expand)
         (cdlatex-tab . cdlatex-in-yas-field))
  :config
  (use-package yasnippet
    :bind (:map yas-keymap
           ("<tab>" . yas-next-field-or-cdlatex)
           ("TAB" . yas-next-field-or-cdlatex))
    :config
    (defun cdlatex-in-yas-field ()
      ;; Check if we're at the end of the Yas field
      (when-let* ((_ (overlayp yas--active-field-overlay))
                  (end (overlay-end yas--active-field-overlay)))
        (if (>= (point) end)
            ;; Call yas-next-field if cdlatex can't expand here
            (let ((s (thing-at-point 'sexp)))
              (unless (and s (assoc (substring-no-properties s)
                                    cdlatex-command-alist-comb))
                (yas-next-field-or-maybe-expand)
                t))
          ;; otherwise expand and jump to the correct location
          (let (cdlatex-tab-hook minp)
            (setq minp
                  (min (save-excursion (cdlatex-tab)
                                       (point))
                       (overlay-end yas--active-field-overlay)))
            (goto-char minp) t))))

    (defun yas-next-field-or-cdlatex nil
      (interactive)
      "Jump to the next Yas field correctly with cdlatex active."
      (if
          (or (bound-and-true-p cdlatex-mode)
              (bound-and-true-p org-cdlatex-mode))
          (cdlatex-tab)
        (yas-next-field-or-maybe-expand)))))

;; Array/tabular input with org-tables and cdlatex
(use-package org-table
  :after cdlatex
  :bind (:map orgtbl-mode-map
              ("<tab>" . lazytab-org-table-next-field-maybe)
              ("TAB" . lazytab-org-table-next-field-maybe))
  :init
  (add-hook 'cdlatex-tab-hook 'lazytab-cdlatex-or-orgtbl-next-field 90)
  ;; Tabular environments using cdlatex
  (add-to-list 'cdlatex-command-alist '("smat" "Insert smallmatrix env"
                                       "\\left( \\begin{smallmatrix} ? \\end{smallmatrix} \\right)"
                                       lazytab-position-cursor-and-edit
                                       nil nil t))
  (add-to-list 'cdlatex-command-alist '("bmat" "Insert bmatrix env"
                                       "\\begin{bmatrix} ? \\end{bmatrix}"
                                       lazytab-position-cursor-and-edit
                                       nil nil t))
  (add-to-list 'cdlatex-command-alist '("pmat" "Insert pmatrix env"
                                       "\\begin{pmatrix} ? \\end{pmatrix}"
                                       lazytab-position-cursor-and-edit
                                       nil nil t))
  (add-to-list 'cdlatex-command-alist '("tbl" "Insert table"
                                        "\\begin{table}\n\\centering ? \\caption{}\n\\end{table}\n"
                                       lazytab-position-cursor-and-edit
                                       nil t nil))
  :config
  ;; Tab handling in org tables
  (defun lazytab-position-cursor-and-edit ()
    ;; (if (search-backward "\?" (- (point) 100) t)
    ;;     (delete-char 1))
    (cdlatex-position-cursor)
    (lazytab-orgtbl-edit))

  (defun lazytab-orgtbl-edit ()
    (advice-add 'orgtbl-ctrl-c-ctrl-c :after #'lazytab-orgtbl-replace)
    (orgtbl-mode 1)
    (open-line 1)
    (insert "\n|"))

  (defun lazytab-orgtbl-replace (_)
    (interactive "P")
    (unless (org-at-table-p) (user-error "Not at a table"))
    (let* ((table (org-table-to-lisp))
           params
           (replacement-table
            (if (texmathp)
                (lazytab-orgtbl-to-amsmath table params)
              (orgtbl-to-latex table params))))
      (kill-region (org-table-begin) (org-table-end))
      (open-line 1)
      (push-mark)
      (insert replacement-table)
      (align-regexp (region-beginning) (region-end) "\\([:space:]*\\)& ")
      (orgtbl-mode -1)
      (advice-remove 'orgtbl-ctrl-c-ctrl-c #'lazytab-orgtbl-replace)))

  (defun lazytab-orgtbl-to-amsmath (table params)
    (orgtbl-to-generic
     table
     (org-combine-plists
      '(:splice t
                :lstart ""
                :lend " \\\\"
                :sep " & "
                :hline nil
                :llend "")
      params)))

  (defun lazytab-cdlatex-or-orgtbl-next-field ()
    (when (and (bound-and-true-p orgtbl-mode)
               (org-table-p)
               (looking-at "[[:space:]]*\\(?:|\\|$\\)")
               (let ((s (thing-at-point 'sexp)))
                 (not (and s (assoc s cdlatex-command-alist-comb)))))
      (call-interactively #'org-table-next-field)
      t))

  (defun lazytab-org-table-next-field-maybe ()
    (interactive)
    (if (bound-and-true-p cdlatex-mode)
        (cdlatex-tab)
      (org-table-next-field))))

;;  (setq scroll-margin 99999
;;      scroll-conservatively 0
;;      maximum-scroll-margin 0.5
;;      scroll-preserve-screen-position t)

;; Enable centered-cursor-mode
(use-package! centered-cursor-mode
  :commands (centered-cursor-mode global-centered-cursor-mode)
  :config
  ;; Keep cursor exactly in the middle vertically
  ;(setq ccm-recenter-at-top-bottom t)
  (setq scroll-conservatively 101)  ; Prevents jumpy automatic scrolling
  (setq scroll-margin 0)
  (setq scroll-step 1)              ; Forces line-by-line rendering
  ;(setq redisplay-dont-pause t)     ; Forces Emacs to update the screen immediately

  ;; Bind to a toggle key (e.g., <leader> t c)
  ;:bind (:map evil-normal-state-map
  ;("<leader>tc" . 'centered-cursor-mode)
  ;)
)

(after! org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((C . t)))) ; This enables both C and C++

(after! org
  (setq org-capture-templates (assoc-delete-all "t" org-capture-templates))
  ;; 1. Use setq-default to enforce global timestamp formats against overwrites
  (setq-default org-time-stamp-formats '("<%Y-%m-%d %a>" . "<%Y-%m-%d %a %H:%M:%S>"))
  (setq org-clock-out-remove-zero-time-clocks nil)

  ;; 2. Function to dynamically read previous activities from time.org
;;(defun my/get-time-activities ()
;;  "Parse time.org for existing Level 4 activities to use in autocompletion."
;;  (let ((acts nil)
;;        (time-file (expand-file-name "~/org-roam/time.org")))
;;    (when (file-exists-p time-file)
;;      (with-temp-buffer
;;        (insert-file-contents time-file)
;;        (goto-char (point-min))
;;        ;; Regex to find all level 4 headings and capture the text after it
;;        (while (re-search-forward "^\\*\\{4\\} \\(.*\\)" nil t)
;;          (add-to-list 'acts (match-string-no-properties 1)))))
;;    acts))
  (defun my/get-time-activities ()
  "Use Org's native parser to extract Level 4 headings from Time.org."
  (let ((acts nil)
        (time-file (expand-file-name "~/org-roam/Time.org")))
    (when (file-exists-p time-file)
      ;; find-file-noselect reads the active buffer, including unsaved changes
      (with-current-buffer (find-file-noselect time-file)
        ;; natively parse the tree structure for level 4 items
        (org-map-entries
         (lambda ()
           ;; org-heading-components returns a list where the 5th item (index 4) is the clean text
           (push (nth 4 (org-heading-components)) acts))
         "LEVEL=4")))
    (if acts
        (delete-dups acts)
      '("Programming" "Study" "Personal" "Work"))))
  ;; 3. Wipe default templates
  (setq org-capture-templates (assq-delete-all "t" org-capture-templates))

  ;; 4. Inject the dynamic function into the template
  (setq org-capture-templates
        (append org-capture-templates
                '(
                  ("t" "Start Time Tracker" entry
                   (file+datetree "~/org-roam/Time.org")
                   ;; %(...) executes Lisp. completing-read gives you the UI menu.
                   "* %(completing-read \"Activity: \" (my/get-time-activities))\n%?"
                   :clock-in t :clock-keep t)

                  ("m" "Log Transaction" table-line
                   (file+headline "~/org-roam/money.org" "Transactions")
                   "| %<%Y-%m-%d %H:%M:%S> | %^{Type|Expense|Income} | %^{Category|RU|Transport|Hardware|Bills} | %^{Amount} |"
                   :kill-buffer t)))))

;; Ativa o highlight de parênteses correspondentes globalmente
(show-smartparens-global-mode +1)
;; Faz j e k navegarem puramente por linhas visuais
;;  (map! :n "j" #'evil-next-visual-line
;;      :n "k" #'evil-previous-visual-line
;;      :v "j" #'evil-next-visual-line
;;      :v "k" #'evil-previous-visual-line)
