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

.sub '&str2num-base'
    .param string src_s
    .local int pos, eos
    .local num result
    pos = 0
    eos = length src_s
    result = 1
  str_loop:
    unless pos < eos goto str_done
    .local string char
    char = substr src_s, pos, 1
    if char == '_' goto str_next
    result *= 10
  str_next:
    inc pos
    goto str_loop
  err_base:
    die 'invalid radix conversion'
  str_done:
    $P0 = box result
    .return ($P0)
.end

.sub 'str2num-num'
    .param int negate
    .param string int_part
    .param string frac_part
    .param int exp_part_negate
    .param string exp_part

    .local num ex, result
    ex = '&str2num-int'(exp_part)
    unless exp_part_negate goto ex_negate_done
    ex = -ex
  ex_negate_done:
    result  = '&str2num-int'(frac_part)
    $I0     = '&str2num-base'(frac_part)
    result /= $I0
    $I0     = '&str2num-int'(int_part)
    result += $I0
    $N0     = pow 10.0, ex
    result *= $N0
    unless negate goto res_neg_done
    result  = -result
  res_neg_done:
    $P0 = box result
    .return ($P0)
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

