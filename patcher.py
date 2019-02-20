#!/usr/bin/env python3
import re

infile = 'rrlogd'
outfile = 'rrlogd_patch'

with open(infile, "rb") as f:
   data = f.read()

data = bytearray(data);

patterns = [b"\xF2\x04\x03\xFF\xF7\x4B\xFF", b"\xF2\x04\x03\xFF\xF7\x45\xFF", b"\x33\x46\x4B\xA8\x10\x22"]
replaces = [b"\xF2\x04\x03\xE3\x20\x4B\xFF", b"\xF2\x04\x03\xE3\x20\x45\xFF", b"\x33\x46\x47\xA8\x10\x22"]

matches = [0,0,0];
for i in range(len(patterns)):
   pattern = patterns[i]
   replace = bytearray(replaces[i])
   regex = re.compile(pattern)
   for match_obj in regex.finditer(data):
       matches[i] = matches[i]+1;
       offset = match_obj.start()
       print ("Original %08X: "%offset, ', '.join("%02X"%(ch) for ch in data[offset:offset+len(pattern)]))
       print ("Patched  %08X: "%offset, ', '.join("%02X"%(ch) for ch in replace))
       data[offset:offset+len(pattern)] = replace

if( ((matches[0] == 1 and matches[1] == 0) or (matches[0] == 0 and matches[1] == 1)) and matches[2] == 1):
   print("Patch appears to be successful. Writing to outfile")
   with open(outfile, "wb") as f:
      f.write(data)
   print("The patched rrlogd has been written to %s" % outfile)
else:
  print("Patch has failed")
