#!/usr/bin/perl
use strict;
use warnings;
use DynaLoader;
use File::Basename;

$| = 1;

my $pidfile = "/tmp/sketchybar_media_watcher.pid";

sub cleanup_pidfile {
    return unless -f $pidfile;
    if (open my $fh, "<", $pidfile) {
        my $recorded = <$fh>;
        close $fh;
        chomp $recorded if defined $recorded;
        unlink $pidfile if defined $recorded && $recorded eq $$;
    }
}

# Single instance via PID file (verified against process name)
if (open my $fh, "<", $pidfile) {
    my $old_pid = <$fh>;
    close $fh;
    chomp $old_pid if defined $old_pid;
    if ($old_pid && $old_pid =~ /^\d+$/ && $old_pid != $$ && kill(0, $old_pid)) {
        if (open my $ps, "-|", "/bin/ps", "-p", $old_pid, "-o", "comm=") {
            my $comm = <$ps> // "";
            close $ps;
            if ($comm =~ /perl/) {
                kill 'TERM', $old_pid;
                for (1 .. 10) {
                    last unless kill(0, $old_pid);
                    select(undef, undef, undef, 0.05); }
                kill 'KILL', $old_pid if kill(0, $old_pid);
            }
        }
    }
}

if (open my $fh, ">", $pidfile) {
    print $fh "$$\n";
    close $fh;
}

$SIG{INT} = $SIG{TERM} = sub {
    cleanup_pidfile();
    exit 0;
};
END { cleanup_pidfile(); }

# Paths
my $dir = dirname(__FILE__);
my $config_dir = $ENV{CONFIG_DIR} || "$ENV{HOME}/.config/sketchybar";
my $adapter = "$config_dir/helpers/libnowplaying.dylib";
$adapter = "$dir/libnowplaying.dylib" unless -f $adapter;

die "Adapter not found: $adapter\n" unless -f $adapter;

my $user = (getpwuid($<))[0];
my ($sketchybar) = grep { -x $_ } (
    "/etc/profiles/per-user/$user/bin/sketchybar",
    "/run/current-system/sw/bin/sketchybar",
);
$sketchybar //= "sketchybar";

# Wait for sketchybar to finish begin_config() and register media.cover
for (1 .. 30) {
    if (open my $q, "-|", $sketchybar, "--query", "media.cover") {
        local $/;
        my $check = <$q> // "";
        close $q;
        last if $check =~ /"name":\s*"media\.cover"/;
    }
    select(undef, undef, undef, 0.1);
}

# Load adapter and run watch loop directly in this single process
my $handle = DynaLoader::dl_load_file($adapter, 0)
    or die "media-watcher: cannot load adapter: " . DynaLoader::dl_error() . "\n";
my $symbol = DynaLoader::dl_find_symbol($handle, "sketchybar_now_playing_watch_all")
    or die "media-watcher: entry point missing: " . DynaLoader::dl_error() . "\n";

DynaLoader::dl_install_xsub("main::watch", $symbol);
watch();
