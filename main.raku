grammar G {
  rule TOP { <line> [ \n <line> ]* }
  rule line { <assignment>? <comment>? }

  rule comment { '//' <text> }

  rule assignment { <ident> '=' <expression> }
  rule expression { <sign>? <value> [ <op> <value> ]* }
  rule value { | <number>
               | <ident>
               | [ '(' <expression> ')' ] }
  token number { \d+ [ \. \d+ [ 'E' <sign>? \d+ ]? ]? }
  token sign { <[ \- \+ ]>? }
  token op { <[ \+ \- \* \/ ]> }
  token ident { <ident-start> <ident-rest>* }


  token text { <-[\n]>* { make "//{$/.Str}"; } }
  token ident-start { <alpha> }
  token ident-rest { <alnum> }
  token ws { \h* }
}

class actions {
  method TOP ($/) { say "Finished parsing input..."; }
  method comment ($/) {
    my $text = $/.made;
    say "Comment: '{$text}'";
  }
  method assignment ($/) {
    say "Assigning: '{$/.Str}'";
  }
}

my $input = "input.txt".IO.slurp;
my $m = G.parse($input);
say $m;

