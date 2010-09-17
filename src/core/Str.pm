augment class Str does Stringy {
    multi method Bool { ?(pir::istrue__IP(self)); }

    method Str() { self }

    my @KNOWN_ENCODINGS = <utf-8 iso-8859-1 ascii>;

    # XXX: We have no $?ENC or $?NF compile-time constants yet.
    multi method encode($encoding is copy = 'utf-8', $nf = '') {
        if $encoding eq 'latin-1' {
            $encoding = 'iso-8859-1';
        }
        die "Unknown encoding $encoding"
            unless $encoding.lc eq any @KNOWN_ENCODINGS;
        $encoding .= lc;
        my @bytes = Q:PIR {
            .local int byte
            .local pmc bytebuffer, it, result
            $P0 = find_lex 'self'
            $S0 = $P0
            $P1 = find_lex '$encoding'
            $S1 = $P1
            if $S1 == 'ascii'       goto transcode_ascii
            if $S1 == 'iso-88591-1' goto transcode_iso_8859_1
            # NOTE: There's an assumption here, that all strings coming in
            #       from the rest of Rakudo are always in UTF-8 form. Don't
            #       know if this assumption always holds; to be on the safe
            #       side, we might transcode even to UTF-8.
            goto finished_transcoding
          transcode_ascii:
            $I0 = find_charset 'ascii'
            $S0 = trans_charset $S0, $I0
            $I0 = find_encoding 'fixed_8'
            $S0 = trans_encoding $S0, $I0
            goto finished_transcoding
          transcode_iso_8859_1:
            $I0 = find_charset 'iso-8859-1'
            $S0 = trans_charset $S0, $I0
            $I0 = find_encoding 'fixed_8'
            $S0 = trans_encoding $S0, $I0
          finished_transcoding:
            bytebuffer = new ['ByteBuffer']
            bytebuffer = $S0

            result = new ['Parcel']
            it = iter bytebuffer
          bytes_loop:
            unless it goto done
            byte = shift it
            push result, byte
            goto bytes_loop
          done:
            %r = result
        };
        return Buf.new(@bytes);
    }

    sub chop-trailing-zeros($i) {
        Q:PIR {
            .local int idx
            $P0 = find_lex '$i'
            $S0 = $P0
            idx = length $S0
        repl_loop:
            if idx == 0 goto done
            dec idx
            $S1 = substr $S0, idx, 1
            if $S1 == '0' goto repl_loop
        done:
            inc idx
            $S0 = substr $S0, 0, idx
            $P0 = $S0
            %r = $P0
        }
    }

    our sub str2num-rat($negate, $int-part, $frac-part is copy) is export {
        $frac-part = chop-trailing-zeros($frac-part);
        my $result = upgrade_to_num_if_needed(str2num-int($int-part))
                     + upgrade_to_num_if_needed(str2num-int($frac-part))
                       / upgrade_to_num_if_needed(str2num-base($frac-part));
        $result = -$result if $negate;
        $result;
    }
}
