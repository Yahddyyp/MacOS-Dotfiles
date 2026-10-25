#!/usr/bin/perl
use strict;
use warnings;
use JSON::PP;
use File::Basename;

$| = 1;

# Ensure single instance via PID file
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

my $child_pid;

sub cleanup {
    if (defined $child_pid && kill(0, $child_pid)) {
        kill 'TERM', $child_pid;
    }
    unlink $pidfile if -f $pidfile;
    exit 0;
}

$SIG{INT} = $SIG{TERM} = \&cleanup;
END {
    if (defined $child_pid && kill(0, $child_pid)) {
        kill 'TERM', $child_pid;
    }
    unlink $pidfile if -f $pidfile;
}

# Paths
my $dir = dirname(__FILE__);
my $config_dir = $ENV{CONFIG_DIR} || "$ENV{HOME}/.config/sketchybar";
my $pl_script = "$config_dir/helpers/now-playing.pl";
my $adapter = "$config_dir/helpers/libnowplaying.dylib";

if (! -f $pl_script || ! -f $adapter) {
    $pl_script = "$dir/now-playing.pl";
    $adapter = "$dir/libnowplaying.dylib";
}

die "Adapter not found: $adapter\n" unless -f $adapter;
die "Script not found: $pl_script\n" unless -f $pl_script;

my $user = (getpwuid($<))[0];
my $sketchybar = "/etc/profiles/per-user/$user/bin/sketchybar";
$sketchybar = "sketchybar" unless -x $sketchybar;

# Launch now-playing in watch mode
$child_pid = open(my $pipe, "-|", "/usr/bin/perl", $pl_script, $adapter, "watch_all")
    or die "Cannot start watch: $!\n";

my $last_label = "";
my $last_drawing = "";

# Wait for sketchybar to finish begin_config() and register media.cover
for (1 .. 30) {
    my $check = qx($sketchybar --query media.cover 2>&1);
    last if $check && $check =~ /"name":\s*"media\.cover"/;
    select(undef, undef, undef, 0.1);
}

while (my $line = <$pipe>) {
    chomp $line;
    next unless length $line;

    my $data = eval { decode_json($line) };
    next unless $data;

    my $title = $data->{kMRMediaRemoteNowPlayingInfoTitle} // "";
    my $artist = $data->{kMRMediaRemoteNowPlayingInfoArtist} // "";
    my $display_id = $data->{displayID} // "";
    my $pid = $data->{pid} // "";

    $title =~ s/[\r\n]//g;
    $artist =~ s/[\r\n]//g;
    $title =~ s/^\s+|\s+$//g;
    $artist =~ s/^\s+|\s+$//g;

    my $drawing = ($title ne "") ? "on" : "off";
    my $label = "";

    if ($drawing eq "on") {
        if ($display_id ne "") {
            if (open my $afh, ">", "/tmp/sketchybar_media_app") {
                print $afh "$display_id\n";
                close $afh;
            }
        }
        if ($pid ne "") {
            if (open my $pfh, ">", "/tmp/sketchybar_media_pid") {
                print $pfh "$pid\n";
                close $pfh;
            }
        }

        if ($artist ne "") {
            $label = "$artist - $title";
        } else {
            $label = $title;
        }

        if (length($label) > 50) {
            $label = substr($label, 0, 47) . "...";
        }
    } else {
        unlink "/tmp/sketchybar_media_app" if -f "/tmp/sketchybar_media_app";
        unlink "/tmp/sketchybar_media_pid" if -f "/tmp/sketchybar_media_pid";
    }

    # Only update sketchybar if the displayed state changed
    if ($drawing ne $last_drawing || $label ne $last_label) {
        $last_drawing = $drawing;
        $last_label = $label;

        if ($drawing eq "on") {
            system($sketchybar, "--set", "media.cover", "drawing=on", "label=$label");
        } else {
            system($sketchybar, "--set", "media.cover", "drawing=off");
        }
    }
}

close $pipe;
unlink $pidfile if -f $pidfile;
