use v6;

use Test;
plan *;

use Yapsi;

my $out;
my $clear = method ($out:) { $out = '' }
my $io-collector = class { method say($i) {$out ~= $i ~ "\n"} };

my Yapsi::Compiler $compiler .= new;
my Yapsi::Runtime $runtime .= new( :io($io-collector) );

my @tests =
    'say 42',                          "42\n",      'printing',
    'my $a = 42; say $a',              "42\n",      'variables',
    'my $a = 5; my $b = $a; say $b',   "5\n",       'assignment',
    'my $b := my $a; $a = 7; say $b',  "7\n",       'binding',
    'say my $a',                       "Any()\n",   'uninitialized',
    'say say 42',                      "42\n1\n",   'return value of say',
    'my $a = 42; my $a; say $a',       "42\n",      'same scope, same var',
    'my $a = 42; say ++$a',            "43\n",      'prefix increment',
    'my $a; say ++$a',                 "1\n",       'increment undefined',
    'my $a = 42; { say $a }',          "42\n",      'variable in a block',
    'my $a = 42; { say my $a }',       "Any()\n",   'new variable in a block',
    'my $a; { $a = 42 }; say $a',      "42\n",      'value survives block',
    'my $a = 42; {my $a = 7}; say $a', "42\n",      'initialised value survives block',
    '{}; my $a = 42; { say $a }',      "42\n",      'same-level blocks',
    'if 42 { say 5 }',                 "5\n",       'executing if block',
    'if 0 { say 5 }',                  "",          'non-executing if block',
    'if 0 {} else { say 42 }',         "42\n",      'executing else block',
    'if 5 {} else { say 42 }',         "",          'non-executing else block',
;

for @tests -> $program, $expected, $message {
    $out.$clear;
    $runtime.run( $compiler.compile($program) );

    is $out, $expected, $message;
}

done_testing;
