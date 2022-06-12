my $template = q:to/END/;
<!DOCTYPE html>
<html>
<head>
  <title>automata</title>
</head>
<body>
  <pre>%s</pre>
  <style type="text/css">
   body {
      background-color: #282c34;
   }
   .code {
      font-family: monospace;
      font-size: 1.2em;
   }
   .comment {
      color: #abb2bf;
   }
   .variable {
      color: #61afef;
   }
   .op {
       color: #005757;
   }
   .number {
       color: #e06c75;
   }
  </style>
</body>
</html>
END

sub w(Str $class, Str $content) of Str {
  "<span class=\"code {$class}\">{$content}</span>"
}

sub collect($/, $elements) {
  $elements.map: {
    given $/{$_} {
      when List { .map: *.made }
      default { .?made // '' }
    }
  }
}

grammar G {
  rule TOP        { <line> [ \n <line> ]*
                  { make sprintf $template, join "\n", collect $/, <line> } }

  rule line       { <assignment>? <comment>?
                  { make join ' ', collect $/, <assignment comment> } }

  rule comment    { '//' <text> 
                  { make do w("comment") <==
                    [~] '//', $<text>.made } }

  rule assignment { <ident> <assign> <expression>
                  { make join ' ', collect $/, <ident assign expression> } }

  rule expression { <sign>? <value> [ <op> <value> ]*
                  { make [~]
                       $<sign>.?made // '', $<value>[0].made,
                       [~] do for $<op> Z $<value>[1..*] -> [$op, $value]
                       { [~] ' ', $op.made, ' ', $value.made } } }

  rule value { | [ <number>
                 { make [~] collect $/, <number> } ]
               | [ <ident>
                 { make [~] collect $/, <ident> } ]
               | [ <oparen> <expression> <cparen>
                 { make [~] collect $/, <oparen expression cparen> } ] }

  token number { \d+ [ \. \d+ [ 'E' <[ \+ \- ]>? \d+ ]? ]?
               { make w("number", $/.Str) } }

  token ident { <alpha> <alnum>*
              { make w("variable", $/.Str) } }

  token assign { \=                { make w("op", $/.Str) } }
  token oparen { \(                { make w("op", $/.Str) } }
  token cparen { \)                { make w("op", $/.Str) } }
  token op     { <[ \+ \- \* \/ ]> { make w("op", $/.Str) } }
  token sign   { <[ \- \+ ]>?      { make w("op", $/.Str) } }

  token text { <-[\n]>*
             { make $/.Str } }

  token ws { \h* }
}

spurt "output.html", do given G.parse: "input.txt".IO.slurp { .made };

