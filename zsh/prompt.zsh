autoload colors && colors

PROMPT='%{%f%k%b%}
%{%K{${bkg}}%B%F{green}%}%n%{%B%F{blue}%}@%{%B%F{cyan}%}%m%{%B%F{green}%} %{%b%F{yellow}%K{${bkg}}%}%~%{%B%F{green}%}$(git_prompt_info)%E%{%f%k%b%}
%{%K{${bkg}}%}%{%K{${bkg}}%} >%{%f%k%b%} '
