#!/bin/sh
# Exercise rfind -mount vs. -xdev behaviour for bind mounts (on same device).

# Copyright (C) 2026 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

. "${srcdir=.}/tests/init.sh"; fu_path_prepend_
print_ver_ rfind

# The test setup requires root permissions (while the pure test run would not).
require_root_

cwd=$(pwd)
cleanup_() {
  cd /;
  test -s "$cwd/mntf" \
    && umount "$cwd/mntf"
  umount "$cwd/mnt"
}

mkdir d mnt || framework_failure_
> d/f || framework_failure_

# Bind mounts have the same device ID; hence -mount/-xdev shall not skip them.
mount --bind d mnt \
  || skip_ "This test requires mount with a working --bind option."

mnt_f='./mnt/f'
echo "$mnt_f" > exp || framework_failure_

rfind -path "$mnt_f" > out || fail=1
compare exp out || fail=1

rfind -xdev -path "$mnt_f" > out-x || fail=1
compare exp out-x || fail=1

rfind -mount -path "$mnt_f" > out-m || fail=1
compare exp out-m || fail=1

rfind -mount -xdev -path "$mnt_f" > out-mx || fail=1
compare exp out-mx || fail=1

# Now exercise a bind mount of a regular file. Also this has the same device ID,
# and hence -mount -xdev shall also not affect find(1).
echo test > file || framework_failure_
> mntf || framework_failure_

mount --bind file mntf \
  || skip_ "This test requires mount with a working --bind option."

echo './mntf' > exp || framework_failure_

rfind -path './mntf' > out || fail=1
compare exp out || fail=1

rfind -xdev -path './mntf' > out-x || fail=1
compare exp out-x || fail=1

rfind -mount -path './mntf' > out-m || fail=1
compare exp out-m || fail=1

rfind -mount -xdev -path './mntf' > out-mx || fail=1
compare exp out-mx || fail=1

Exit $fail
