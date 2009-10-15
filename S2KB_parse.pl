#!/usr/bin/perl -w

@keywords = (FILENAME,OBJECT,RA,DEC,EPOCH,UT,ST,"DATE-OBS",
             AIRMASS,EXPTIME,FILTER1,FILTER2,FOCUS,CCDSUM,DEWTEMP,CAMTEMP);

$file = pop(@ARGV);
open (IN,$file);

$lines = 0;
$bytes = 0;
do {
#  print "-> start do-loop\n";
  $count = read (IN,$buf,80) || die("Cannot read 80 bytes from $file.\n");
#  print "-> $buf, $count\n";
  $bytes = $bytes + $count;
  ($name,$eq,$value) = unpack ("A8 A2 A20",$buf);
  $name =~ s/\s//g;
  $value =~ s/\'//g;
  $header{$name} = $value;
#  print "$name   $value  $header{$name}\n";

  $lines += 1;
#  print "-> $lines\n";
} until $name eq "END" || $lines > 72;

# crop RA, DEC

$header{RA} = sprintf ("%1.11s",$header{RA});
$header{DEC} = sprintf ("%1.11s",$header{DEC});

# adjust precision in UT to seconds

$header{UT} = sprintf ("%1.8s",$header{UT});

# same for LST

$header{LST} = sprintf ("%1.8s",$header{LST});

# get rid of decimal in exptime if it is at end of string

$header{EXPTIME} = sprintf ("%6.1f",$header{EXPTIME});
$header{EXPTIME} =~ s/\.$//;

# adjust precision in epoch to tenths

$header{EPOCH} = sprintf ("%6.1f",$header{EPOCH});

# get image counter out of IRAF file name

#$file =~ s/(\D+)//;
$file =~ s/(\d{1,4})\.fits//;
$header{FILENAME} = sprintf ("%4i",int($&));

# format CCDSUM

$header{CCDSUM} =~ /(\d\s\d)/;
$header{CCDSUM} = $1;
$header{CCDSUM} =~ s/\s/x/;

# format UT date

$header{"DATE-OBS"} =~ /\-/;
$header{"DATE-OBS"} = $';         

# format AIRMASS

$header{AIRMASS} = sprintf ("%5.3f",$header{AIRMASS});

# keep precision in TELFOCUS for now

#$header{FOCUS} = sprintf ("%5.0f",$header{FOCUS});

# get rid of whitespace in everything but title

foreach $keyword (@keywords) {
  unless ($keyword eq "OBJECT") {
    $header{$keyword} =~ s/\s//g;
  }
}

foreach $keyword (@keywords) {
  unless (defined($header{$keyword})) {
    $header{$keyword}="??"
  }
  print "$header{$keyword} \n";
}
