(defvar emacs-repeater-version "0.1"
  "Current version of emacs repeater")

(require 'url)

(defgroup emacs-repeater nil
  "emacs repeater"
  :prefix "repeater-"
  :group 'applications)

(defvar emacs-repeater-output-buffer-name "*repeater-out*")
(defvar emacs-repeater-input-buffer-name "*repeater-in*")
(defvar emacs-repeater-default-payload "GET / HTTP/1.1
Host: %s

")

(defvar emacs-repeater-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") 'emacs-repeater-send-payload)
    map)
  "The key map for emacs repeater.")

(defun emacs-repeater-target-prompt ()
  (list
   (read-from-minibuffer "Host: ")
   (read-from-minibuffer "Port: ")))

(defun emacs-repeater (target-host target-port)
  (interactive (emacs-repeater-target-prompt))
  (let ((buffer (generate-new-buffer emacs-repeater-input-buffer-name))
	(host target-host)
	(port target-port))
    (with-current-buffer buffer
      (generate-new-buffer emacs-repeater-output-buffer-name)
      (insert (format emacs-repeater-default-payload host))
      (use-local-map emacs-repeater-mode-map)
      (setq target-host host)
      (setq target-port port)
      (make-local-variable 'target-host)
      (make-local-variable 'target-port))
    (switch-to-buffer buffer)))

(defun emacs-repeater-send-payload ()
  (interactive)
  (let ((network-process (open-network-stream
			  "repeater-stream"
			  emacs-repeater-output-buffer-name
			  target-host
			  target-port)))
    (progn
      (process-send-string network-process
			   (with-current-buffer
			       emacs-repeater-input-buffer-name
			     (buffer-string)))
      (with-current-buffer emacs-repeater-output-buffer-name
	(delete-region (point-min) (point-max))))))

(provide 'elisp-repeater)
