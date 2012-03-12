Ristretto
=========

Ristretto is a Ruby on Rails based project management and time-tracking app.

Installation
============

Requirements
------------

    gem install bundler

Setup
-----

    git clone git://github.com/egressive/ristretto.git
    cd ristretto
    bundle install
    rake ristretto:setup
    rake db:create db:schema:load
    rake user:new NAME="Your Name" EMAIL=example@example.com PASSWORD=yourpassword
    ./script/server

Other steps
-----------

You should probably replace the `secret` key in settings.yml by copying the output of `rake secret`.

License
=======

Ristretto - Project Management and Time-tracking
Copyright (C) 2010-2012 Kale Worsley <kale@egressive.com>, Josh Campbell <josh@egressive.com>, Malc Locke <malc@egressive.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

