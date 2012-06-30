use strict;
use warnings;
use Test::More;
use FindBin;

use Text::MicroTemplate::Extended;

my $mt = Text::MicroTemplate::Extended->new(
    template_args => {
        foo => 'bar',
    },
    include_path => ["$FindBin::Bin/templates"],
);

my $out;
{
    # base template error at compile time
    eval {
        $out = $mt->render('error/child');
    };
    ok $@, 'error ok';
    ok !$out, 'no output ok';

    like $@, qr/at line 7/, 'line 7 ok';
    like $@, qr/7: <\?= \$r \?>/, 'line number ok';
}

{
    # base template error at runtime
    eval {
        $out = $mt->render('error/child2');
    };
    ok $@, 'error ok';
    ok !$out, 'no output ok';

    like $@, qr/&main::undefined_func called at line 7/, 'error ok';
    like $@, qr/7: <\?= undefined_func\(\) \?>/, 'line number ok';
}

{
    # child template error at compile time
    eval {
        $out = $mt->render('error/child-err-compiletime');
    };
    ok $@, 'error ok';
    ok !$out, 'no output ok';

    like $@, qr/at line 5/, 'error ok';
    like $@, qr/5: <\?= \$r \?>/, 'line number ok';
}

{
    # child template error at compile time
    eval {
        $out = $mt->render('error/child-err-runtime');
    };
    ok $@, 'error ok';
    ok !$out, 'no output ok';

    like $@, qr/at line 5/, 'error ok';
    like $@, qr/5: <\?= undefined_func\(\) \?>/, 'line number ok';
}

done_testing;
