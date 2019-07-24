#! /bin/bash

echo "The following are the hardlinks to /bin on a mounted file system"
sudo find /bin -xdev -type f -links +1 -ls | sort -n




