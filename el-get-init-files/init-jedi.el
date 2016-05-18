(require 'jedi)
(setq jedi:complete-on-dot t)
(setq jedi:setup-keys t)
(add-hook 'python-mode-hook 'jedi:setup)
