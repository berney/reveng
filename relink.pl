#!/usr/bin/perl -i.bak
# relink.pl
# Greg Cook, 7/Feb/2017

# CRC RevEng: arbitrary-precision CRC calculator and algorithm finder
# Copyright (C) 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017
# Gregory Cook
#
# This file is part of CRC RevEng.
#
# CRC RevEng is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# CRC RevEng is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with CRC RevEng.  If not, see <https://www.gnu.org/licenses/>.

# Renumbers and relinks the elements of b32[], models[] and aliases[]
# and generates initialising code for the large polynomial bitmaps
# in file preset.c of CRC RevEng, to permit adding or deleting presets.
# New elements can be referenced by a new alphanumeric tag wherever the
# index number is to appear.  A string constant in place of an alias
# reference in models[] is converted to a reference to the alias with
# a matching name.

# Usage: perl relink.pl preset.c
# (renames original to preset.c.bak)

use integer;

until(($_ = <>) =~ /(?:aliases\+\s*\w+|\"[A-Z0-9\/-]+\")\s*},\s+\/\*\s*\w+\s*\*\//) {
	if(m|/\*\s*CONSTANT\s+(\w+)\s*=\s*\((\d+)\s*,\s*((?:0x)?[0-9a-fA-F]+)\)\s*\*/|) {push @{$hash{$2}},$1,$3;}
	if(s/(^\s+BMP_C\(0x[0-9A-Fa-f]{8}\) << \(BMP_BIT - 32\),\s+\/\*)\s*(\w+)(.*$)/sprintf("%s%4d%s",$1,$x,$3)/e) {$x{$2} = $x++ || "0";}
	if(m|/\*\s*END AUTO-GENERATED CONSTANTS\s*\*/|) {&bigbmp(\%hash); undef %hash; $blank = 0;}
	unless($blank) {print $_;}
	if(m|/\*\s*BEGIN AUTO-GENERATED CONSTANTS\s*\*/|) {$blank = 1;}
}

do {
	s/b32\+\s*(\w+)/sprintf("b32+%3d",$x{$1})/eg;
	if(s/(aliases\+\s*\w+|\"[A-Z0-9\/-]+\")(\s*},\s+\/\*)\s*(\w+)(\s*\*\/)/sprintf("%s%s%3d%s",$1,$2,$y,$4)/e){$y{$3} = $y++ || "0";}
	push(@models,$_);
} until(($_ = <>) =~ /(^\#\s*define\s+NPRESETS\s+)[1-9][0-9]*/);

do {
	s/(^\#\s*define\s+NPRESETS\s+)[1-9][0-9]*/$1$y/;
	s/models\+\s*(\w+)/sprintf("models+%2d",$y{$1})/e;
	if(s/(,\s+models\+[\d ]\d},\s+\/\*)\s*(\w+)(\s*\*\/)/sprintf("%s%4d%s",$1,$z,$3)/e){$z{$2} = $z++ || "0";}
	if(/(\"[^"]+\")\s*,\s+models\+[\d ]\d},\s+\/\*\s*\w+\s*\*\//){$z{$1} = $z - 1;}
	push(@aliases,$_);
} until(($_ = <>) =~ /(^\#\s*define\s+NALIASES\s+)[1-9][0-9]*/);

while(defined(($model = shift(@models)))) {
	$model =~ s/aliases\+\s*(\w+)/sprintf("aliases+%3d",$z{$1})/e;
	$model =~ s/(,\s+)(\"[^"]+\")\s*/sprintf("%saliases+%3d",$1,$z{$2})/e;
	print $model;
}

print(@aliases);
@aliases = ();

do {
	s/(^\#\s*define\s+NALIASES\s+)[1-9][0-9]*/$1$z/;
	print $_;
} while(defined(($_ = <>)));

sub bigbmp (\%) {
  my ($hr) = @_;
  foreach $width (sort keys %$hr) {
    @vars = @{$$hr{$width}};
    $split = 1;
    $short = $width; $long = undef;
    do {
      if($short > 32) {
        print $split > 1 ? "#    elif " : "#    if ";
        print "BMP_BIT >= ", $short, "\n";
      } elsif($width > 32) {
        print "#    else /* BMP_BIT */\n";
      }
      @vars1 = @vars;
      while(defined($name = shift @vars1)) {
        print "static const bmp_t ",$name, "[] = {\n";
        $poly = shift @vars1;
        if(substr($poly, 0, 2) eq "0x") {
          $poly = unpack("B*",pack("H*",(length($poly)&1?"0":"").substr($poly,2)));
        }
        if(length($poly) < $width) {
          $poly = "0" x ($width - length($poly)) . $poly;
        } elsif(length($poly) > $width) {
          $poly = substr($poly, -$width);
        }
        for($word = 1, $idx = $short; $idx - $short < $width; ++$word, $idx += $short) {
          if($long == $short) {
            printf("\tBMP_C(0x%s),\n", &myhex(substr($poly, $idx - $short, $short) . "0" x ($idx - $width)));
          } elsif($width > $idx) {
            printf("\tBMP_C(0x%s) << (%s - %d) | BMP_C(0x%s) >> (%d - %s),\n",
              &myhex(substr($poly, $idx - $short, $short)), &bit($word), $idx,
              &myhex("0" . substr($poly, $idx, $word * $long - $idx)), $word * $long, &bit($word));
          } else {
            printf("\tBMP_C(0x%s) << (%s - %d),\n",
              &myhex(substr($poly,$idx - $short)), &bit($word), $width);
          }
        }
        print "};\n";
      }
      ++$split;
      $long = $short - 1;
      $short = ($split - 1 + $width) / $split;
      $short = 32 if $short < 32;
    } while($long >= 32);
    print "#    endif /* BMP_BIT */\n" if $width > 32;
    print "\n";
  }
}

sub myhex ($) {
  my ($bin) = @_;
  return(substr(unpack("H*",pack("B*","0"x(-length($bin)&7).$bin)),((length($bin)+3)&4)>>2));
}

sub bit ($) {
  my ($mult) = @_;
  return ($mult == 1 ? "BMP_BIT" : "BMP_BIT * " . $mult);
}
