#!/usr/bin/perl
#  Copyright 1999-2021 ImageMagick Studio LLC, a non-profit organization
#  dedicated to making software imaging solutions freely available.
#
#  You may not use this file except in compliance with the License.  You may
#  obtain a copy of the License at
#
#    https://imagemagick.org/script/license.php
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
# Test reading blobs supported directly by ImageMagick.
#
BEGIN { $| = 1; $test=1; print "1..2\n"; }
END {print "not ok $test\n" unless $loaded;}
use Image::Magick;
$loaded=1;

require 't/subroutines.pl';

chdir 't' || die 'Cd failed';

my (@blob, $fileName, $format, $height, $image, $size, $status, $width);

$fileName='input_p6.ppm';
print "Ping \"$fileName\" ...\n";
$image=Image::Magick->new;
($width, $height, $size, $format)=$image->Ping("$fileName");
if (($width == 70) && ($height == 46) && ($size == 9673) && ($format eq "PPM"))
  {
    print "ok $test\n";
  }
 else
  {
    print "not ok $test\n";
  }
undef $image;
$test++;

print("Ping blob ...\n");
$image=Image::Magick->new;
$status=$image->Read($fileName);
warn "$status" if "$status";
@blob=$image->ImageToBlob();
undef $image;
$image=Image::Magick->new;
($width, $height, $size, $format)=$image->Ping(blob=>@blob);
undef @blob;
undef $image;
if (($width == 70) && ($height == 46) && ($size == 9673) && ($format eq "PPM"))
  {
    print "ok $test\n";
  }
else
  {
    print "not ok $test\n";
  }

1;
