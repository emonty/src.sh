# Copyright (c) 2017 Red Hat, Inc
#
# This file is part of src.sh
#
# ttrun is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ttrun is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with src.sh.  If not, see <http://www.gnu.org/licenses/>.

unset -f src
function src {
    GOPATH=${GOPATH:-~}
    SRCSRCDIR=${SRCSRCDIR:-$GOPATH/src}
    SRCSRCPREFIXES=${SRCSRCPREFIXES:-github.com}
    SRCSRCUSEPUSHD=${SRCSRCUSEPUSHD:-0}

    function try_get {
        if type go >/dev/null 2>&1 ; then
            # If it's there, just use go get
            go get -v -d $1 >/dev/null 2>&1
        else
            # Simulate go get. Slightly less efficient since it will attempt
            # to contact remote locations even if the request doesn't have
            # a hostname component. Also, results in more file io since it
            # will clone to a temp dir then move it. Just having go get
            # is recommended ... but it's not THAT much extra work to support
            # its non-existence.
            loc=$(mktemp -d)
            pushd $loc >/dev/null
            git clone https://$1 >/dev/null 2>&1
            if [[ -d $(basename $1) ]] ; then
               mkdir -p $SRCSRCDIR/$1
               mv $(basename $1) $SRCSRCDIR/$1
            fi
            popd
            rm -rf $loc
        fi
        try_cd $2/$1 && return 0
        return 1
    }
        
    function try_cd {
        if [[ -d $1 ]] ; then
            if [[ $SRCSRCUSEPUSHD -eq 1 ]] ; then
                pushd $1
            else
                echo $1
                cd $1
            fi
            return 0
        fi
        return 1
    }
    if [[ ! -d $SRCSRCDIR ]] ; then
        echo "No usable SRCSRCDIR found - either set GOPATH or SRCSRCDIR"
        return 1
    fi

    # Did we give a fully qualified name and it already exists?
    try_cd $SRCSRCDIR/$1 && return 0

    # Look for non-qualified names that already exist
    for prefix in $SRCSRCPREFIXES ; do
        try_cd $SRCSRCDIR/$prefix/$1 && return 0
    done

    # Did we provide fully qualified name?
    try_get $1 $SRCSRCDIR && return 0

    # Try name with prefixes
    for prefix in $SRCSRCPREFIXES ; do
        try_get $prefix/$1 $SRCSRCDIR && return 0
    done

    echo "Could not find or clone $1 - try fully qualifying it"
    return 1
}
