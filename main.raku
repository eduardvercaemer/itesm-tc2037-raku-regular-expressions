grammar G {
  rule TOP { <line> [ \n <line> ]* }
  rule line {
    | <empty>
    | <comment>
    | <other>
  }
  token empty {''}
  token comment { '//' <text> { make $<text>.made; } }
  token other { <text> { make $<text>.made; } }
  token text { <-[\n]>* { make "//{$/.Str}"; } }
  token ws { \h* }
}

class actions {
  method TOP ($/) { say "Finished parsing input..."; }
  method comment ($/) {
    my $text = $/.made;
    say "Comment: '{$text}'";
  }
}

my $input = "input.txt".IO.slurp;
my $m = G.parse($input, actions => actions.new);

