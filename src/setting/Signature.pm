class Signature is also {
    method perl() {
        return [~] gather {
            take ':(';
            my $sep = '';
            my $last_was_multi_inv = True;
            for $.params -> $param {
                # First, separator, if any.
                if $last_was_multi_inv && !$param.multi_invocant { $sep = ';; ' }
                take ~$sep;
                $sep = ', ';

                # First the type.
                my $name = $param.name;
                if !$param.slurpy {
                    my $sigil = substr($name, 0, 1);
                    my $perl = $param.type.perl;
                    if $sigil eq '$' {
                        take $perl ~ ' ';
                    }
                    elsif $sigil eq '@' {
                        if $perl ne 'Positional' {
                            take substr($perl, 11, $perl.chars - 12) ~ ' ';
                        }
                    }
                    elsif $sigil eq '%' {
                        if $perl ne 'Associative' {
                            take substr($perl, 12, $perl.chars - 13) ~ ' ';
                        }
                    }
                    elsif substr($perl, 0, 8) eq 'Callable' {
                        $name = '&' ~ $name;
                        if $perl ne 'Callable' {
                            take substr($perl, 9, $perl.chars - 10) ~ ' ';
                        }
                    }
                    else {
                        take $perl ~ ' ';
                    }
                }

                # Slurpiness, namedness, then the name.
                if $param.slurpy { take '*' }
                for @($param.named_names) -> $name {
                    take ':' ~ $name ~ '(';
                }
                take $name;
                take ')' x +$param.named_names;

                # Optionality.
                if $param.optional && !$param.named && !$param.default   { take '?' }
                elsif !$param.optional && $param.named && !$param.slurpy { take '!' }
                
                # Any constraints?
                if $param.constraints {
                    take ' where ' ~ $param.constraints.perl;
                }

                # Default.
                if $param.default {
                    take ' = ' ~ $param.default.perl;
                }

                # Invocant/multi invocant marking.
                if $param.invocant { $sep = ': '; }
                $last_was_multi_inv = $param.multi_invocant;
            }
            take ')';
        }
    }
}