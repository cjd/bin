#!/usr/bin/perl

use strict;
use warnings;

while (<>) {
	if (/[\xe2]/) { print; }
}