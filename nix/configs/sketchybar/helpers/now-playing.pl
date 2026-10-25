#!/usr/bin/perl
# Loads the Now Playing adapter library into perl and prints one JSON line.
# Perl is an Apple platform binary, allowing MediaRemote access on macOS 15.4+.
use strict;
use warnings;
use DynaLoader;

$| = 1;
my ($library, $mode) = @ARGV;
$mode //= "get";
my %entries = map { $_ => "sketchybar_now_playing_$_" } qw(get watch watch_all);
die "now-playing: unknown mode\n" unless exists $entries{$mode};
die "usage: now-playing.pl <adapter library>\n" unless defined $library && -f $library;
my $handle = DynaLoader::dl_load_file($library, 0)
    or die "now-playing: cannot load adapter: " . DynaLoader::dl_error() . "\n";
my $symbol = DynaLoader::dl_find_symbol($handle, $entries{$mode})
    or die "now-playing: adapter entry point missing: " . DynaLoader::dl_error() . "\n";
DynaLoader::dl_install_xsub("main::sketchybar_now_playing_run", $symbol);
sketchybar_now_playing_run();
