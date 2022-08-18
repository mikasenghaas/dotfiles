# fzf.rc.fish
#  configs for fish-fzf
# by: mika senghaas

set fzf_preview_dir_cmd exa --all --color=always
fzf_configure_bindings --history=\cr --directory=\cf --variables=\cv --git_log=\cl
