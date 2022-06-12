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
   .COMMENT {
      color: #abb2bf;
   }
   .VARIABLE {
      color: #61afef;
   }
   .OP {
       color: #005757;
   }
   .INTEGER {
       color: #e06c75;
   }
   .FLOAT {
       color: #e06c75;
   }
  </style>
</body>
</html>
END

grammar G {
  rule TOP { <line> [ \n <line> ]* { make '(:' } }
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

  token text { <-[\n]>* }
  token ident { <ident-start> <ident-rest>* }

  token ident-start { <alpha> }
  token ident-rest { <alnum> }
  token ws { \h* }
}

say do given G.parse: "input.txt".IO.slurp { .made };

