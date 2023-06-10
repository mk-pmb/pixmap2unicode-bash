
<!--#echo json="package.json" key="name" underline="=" -->
pixmap2unicode
==============
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Convert black-and-white bitmap pixels to Unicode Block Elements characters.
<!--/#echo -->



Usage
-----

```text
$ ./pixmap2unicode.sh -- test/10x8/arrow_left.png
1       :  ▄██▀    :
2       :▄███▄▄▄▄▄▄:
3       :▀███▀▀▀▀▀▀:
4       :  ▀██▄    :

$ ./pixmap2unicode.sh --bare -- test/10x8/arrow_left.png
  ▄██▀    
▄███▄▄▄▄▄▄
▀███▀▀▀▀▀▀
  ▀██▄    

$ ./pixmap2unicode.sh --rownumfmt='LINES[%04u] = ' --siderails='"' -- test/10x8/arrow_left.png
LINES[0001] = "  ▄██▀    "
LINES[0002] = "▄███▄▄▄▄▄▄"
LINES[0003] = "▀███▀▀▀▀▀▀"
LINES[0004] = "  ▀██▄    "

$ ./pixmap2unicode.sh --style=big -- test/10x8/arrow_left.png
1       :      ██████        :
2       :    ██████          :
3       :  ██████            :
4       :████████████████████:
5       :████████████████████:
6       :  ██████            :
7       :    ██████          :
8       :      ██████        :

$ ./pixmap2unicode.sh --style=big --c:e=_ --c:f=# -- test/10x8/arrow_left.png
1       :______######________:
2       :____######__________:
3       :__######____________:
4       :####################:
5       :####################:
6       :__######____________:
7       :____######__________:
8       :______######________:
```


<!--#toc stop="scan" -->



Known issues
------------

* Needs more/better tests and docs.




&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
ISC
<!--/#echo -->
