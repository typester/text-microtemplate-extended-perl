sub auto_set_repository { }

use inc::Module::Install;
name 'Text-MicroTemplate-Extended';
all_from 'lib/Text/MicroTemplate/Extended.pm';

requires 'Text::MicroTemplate' => '0.13';

test_requires 'Test::More' => '0.94';
test_requires 'Test::Base';

auto_set_repository;

WriteAll;
