#lang racket/gui   
; Copyright 2015, Adrian Nackov (BSD, see the LICENCE file.)
; ---
(define error-bad-file "Error - check if this is a valid .rar file")
(define error-bad-path "Error - check if the unrar command is runnable")

(define droppable-canvas%
  (class canvas%
    (define/override (on-drop-file file)
      (if (not (get-unrar-cmd))
          (send this log-error error-bad-path)
          (if (not (run-unrar file))
              (send this log-error error-bad-file)
              #t))
      (super on-drop-file file))
    (define/private (draw self drawing-context)
      (send drawing-context set-pen "Silver" 3 'long-dash)
      (send drawing-context draw-rounded-rectangle 70 50 150 150 -0.1)
      (send drawing-context draw-text "Drop here" 105 230)
      ; draw the arrow lines`
      (send drawing-context draw-line 145 80 145 160)
      (send drawing-context draw-line 135 130 145 160)
      (send drawing-context draw-line 155 130 145 160))
    (define/public (log-error error-type)
      (let ([dc (send this get-dc)])
        (send dc set-text-foreground "red")
        (send dc draw-text error-type 0 0)))    
    (super-new (paint-callback (lambda (canvas dc) 
                                 (draw canvas dc))))))

(define (run-unrar file-path) 
  (define-values (proc out in err)
    (parameterize ([current-directory (get-dirname file-path)])
      (subprocess #f #f #f (get-unrar-cmd) "e" "-y" file-path)))
  (subprocess-wait proc)
  (= 0 (subprocess-status proc)))

(define (get-unrar-cmd)
  (if (file-exists? "/opt/local/bin/unrar")
      "/opt/local/bin/unrar"
      (find-executable-path "unrar")))

(define (get-dirname file-path)
  (path->string (path-only file-path)))

(define (init-gui) 
  (define frame (new frame% 
                     (label "UnRaRcket") 
                     (width 300) 
                     (height 300) 
                     (style '(no-resize-border)))) ; OSX
  (define canvas (new droppable-canvas% 
                     (parent frame)))
  (send canvas accept-drop-files #t)
  (send frame show #t))

(init-gui)
