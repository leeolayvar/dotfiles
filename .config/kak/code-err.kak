declare-option line-specs code_errors
declare-option bool code_err
declare-option str code_err_file
declare-option int code_err_line
declare-option str code_err_desc

define-command -params 1 set-code-err-line %{
  %sh{
    file=$(basename $(echo ${1} | cut -d ':' -f 1))
    line=$(echo ${1} | cut -d ':' -f 2)
    col=$(echo ${1} | cut -d ':' -f 3)
    desc="${file}:${line}:${col}:"$(echo ${1} | cut -d ':' -f 4-)

    if [ ${kak_opt_code_err} == "false" ]; then
      printf %s\\n "add-highlighter window/ flag_lines default code_errors"
      printf %s\\n "set-option buffer code_err true"
      # get the timestamp for the set-option usage.
      # No idea why it wants a timestamp.
      timestamp=$(date +%s)

      printf %s\\n "set-option global code_errors ${timestamp}:${line}|{red,default}x"

      # report the new error.
      printf %s\\n "set-option buffer code_err_line ${line}"
      printf %s\\n "set-option buffer code_err_desc \"${desc}\""
      printf %s\\n "echo -markup {red,default} ${desc}"
    else

      # add this error to previous errors
      printf %s\\n "set-option global code_errors ${kak_opt_code_errors}:${line}|{red,default}x"
    fi
  }
}

define-command unset-code-err-line %{
  set-option buffer code_err false
  remove-highlighter window/hlflags_code_errors
}

define-command jump-code-err %{
  evaluate-commands %sh{
    if [ ${kak_opt_code_err} == "true" ]; then
      # TODO(leeola): is there a better way to move the cursor?
      printf %s\\n "edit ${kak_opt_code_err_file} ${kak_opt_code_err_line}"

      # report the most recent error.
      printf %s\\n "echo -markup {red,default} ${kak_opt_code_err_desc}"
    else
      printf %s\\n "echo no reported errors"
    fi
  }
}
