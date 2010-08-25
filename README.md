Ristretto
=========

Ristretto is a Ruby on Rails based project management and time-tracking app.

Installation
============

Requirements
------------

    gem install rails -v 2.3.8

    gem install authlogic -v 2.1.6
    gem install vestal_versions -v 1.0.2
    gem install bluecloth -v 2.0.7
    gem install will_paginate -v 2.3.14
    gem install cancan -v 1.3.3
    gem install paperclip -v 2.3.3
    gem install exception_notification -v 2.3.3.0
    gem install icalendar -v 1.1.5

or

    rake gems:install

Setup
-----

    git clone git://github.com/egressive/ristretto.git
    cd ristretto
    cp config/database.example.yml config/database.yml
    cp config/settings.example.yml config/settings.yml

Copy the output of `rake secret` into `:secret` in `environment.rb` below `config.action_controller.session`

    rake db:create
    rake db:schema:load
    rake user:new NAME=yourname FIRST_NAME=your LAST_NAME=name EMAIL=example@example.com PASSWORD=yourpassword
    rake user:is_staff NAME=yourname
    ./script/server

Licence
=======

Ristretto - Project Management and Time-tracking
Copyright (C) 2010 Kale Worsley <kale@egressive.com>

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

