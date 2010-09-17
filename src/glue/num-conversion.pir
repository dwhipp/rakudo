.namespace ["Str" ]

.sub '&str2num-int'
    .param string src_s
    .local int pos, eos
    .local num result
    pos = 0
    eos = length src_s
    result = 0
    str_loop:
    unless pos < eos goto str_done
    .local string char
    char = substr src_s, pos, 1
    if char == '_' goto str_next
    .local int digitval
    digitval = index "0123456789", char
    if digitval < 0 goto err_base
    if digitval >= 10 goto err_base
    result *= 10
    result += digitval
    str_next:
    inc pos
    goto str_loop
    err_base:
    die 'Invalid radix conversion'
    str_done:
    $P0 = box result
    .return($P0)
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

