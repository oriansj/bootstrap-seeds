#!/bin/sh

# hex0 compiler - https://bootstrapping.miraheze.org/wiki/Stage0
# compile hex0 source in stdin to binary object at stdout
# [external] utilities used: printf
#
# hash or semicolon (#;) start a comment till the end of the line.
# remaining elements are expected to be two consecutive hex digits each,
# separated by space[s] and/or tab[s] and/or newline[s].
#
# backslash does not escape, and does not initiate line-continuation.
#
# exit code is 1 if, after removing comments, an element is not two-hex-digits.
# exit code is 2 if printf failed.
# else exit code is 0
#
# implementation notes:
# - while POSIX, some old shells (pdksh 5.2.14) don't support hex constants in
#   arithmetic expansion (e.g. 0xff). manual conversion can be added if needed.
# - to improve speed if printf is not a shell builtin, 1K buffering is used.

LC_ALL=C
export LC_ALL

buf=
while IFS= read -r line || [ "$line" ]; do
    line=${line%%[#;]*}  # strip (trailing) comments
    for v in $line; do
        case $v in [0-9a-fA-F][0-9a-fA-F])
            buf=$buf\\$((0x$v / 64))$((0x$v % 64 / 8))$((0x$v % 8))
            [ "${#buf}" -lt 1024 ] || { printf "$buf" && buf= || exit 2; }
            continue
        esac
        exit 1
    done
done
printf "$buf" || exit 2
