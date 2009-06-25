use inc::Module::Install;
name 'Text-MicroTemplate-Extended';
all_from 'lib/Text/MicroTemplate/Extended.pm';

test_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
