#!/usr/bin/make
# contrib/Makefile
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
# along with CRC RevEng.  If not, see <http://www.gnu.org/licenses/>.

# C compiler and flags.  Adjust to taste.
CC = gcc
CFLAGS = -O3 -Wall -ansi -fomit-frame-pointer
# Shell commands
RM = rm

# Target objects
TARGETS = getopt.o
# Header files
HEADERS = getopt.h

.PHONY: clean all

all: $(TARGETS)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $<

clean:
	-$(RM) $(TARGETS)
