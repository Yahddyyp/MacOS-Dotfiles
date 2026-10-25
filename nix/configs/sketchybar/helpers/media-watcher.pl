#!/usr/bin/perl
use strict;
use warnings;
use DynaLoader;
use File::Basename;

$| = 1;

# Single instance via PID file
my $pidfile = "/tmp/sketchybar_media_watcher.pid";
if (open my $fh, "<", $pidfile) {
    my $old_pid = <$fh>;
    chomp $old_pid if $old_pid;
    if ($old_pid && $old_pid != $$ && kill(0, $old_pid)) {
        kill 'TERM', $old_pid;
        select(undef, undef, undef, 0.1);
        kill 'KILL', $old_pid if kill(0, $old_pid);
    }
    close $fh;
}

if (open my $fh, ">", $pidfile) {
    print $fh "$$\n";
    close $fh;
}

# Cleanup on exit
$SIG{INT} = $SIG{TERM} = sub {
    unlink $pidfile if -f $pidfile;
    exit 0;
};
END { unlink $pidfile if -f $pidfile; }

# Paths
my $dir = dirname(__FILE__);
my $config_dir = $ENV{CONFIG_DIR} || "$ENV{HOME}/.config/sketchybar";
my $adapter = "$config_dir/helpers/libnowplaying.dylib";
$adapter = "$dir/libnowplaying.dylib" unless -f $adapter;

die "Adapter not found: $adapter\n" unless -f $adapter;

my $user = (getpwuid($<))[0];
my $sketchybar = "/etc/profiles/per-user/$user/bin/sketchybar";
$sketchybar = "sketchybar" unless -x $sketchybar;

# Wait for sketchybar to finish begin_config() and register media.cover
for (1 .. 30) {
    my $check = qx($sketchybar --query media.cover 2>&1);
    last if $check && $check =~ /"name":\s*"media\.cover"/;
    select(undef, undef, undef, 0.1);
}

# Load adapter and run watch loop directly in this single process
my $handle = DynaLoader::dl_load_file($adapter, 0)
    or die "media-watcher: cannot load adapter: " . DynaLoader::dl_error() . "\n";
my $symbol = DynaLoader::dl_find_symbol($handle, "sketchybar_now_playing_watch_all")
    or die "media-watcher: entry point missing: " . DynaLoader::dl_error() . "\n";

DynaLoader::dl_install_xsub("main::watch", $symbol);
watch();
