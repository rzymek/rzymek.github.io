+++
bigimg = ""
date = "2018-11-14T21:31:32+01:00"
subtitle = ""
title = "excel zip64"

+++

# Problem with huge XLSX files

As you may already know, xlsx files are just zipped xml's. 
```
xl/workbook/sheet1.xml
```

Standard ZIP format has 4 bytes reserved for file size. 
The maximum is therefore `0xFFFF FFFF` or `256^4`, `2^32`. 
In other words (numbers) its `4294967296`, that is `4 GB`. 
An unimaginably huge size in 1989 when the first PKZIP spec was published. Not that big now. 
On the other hand current [Excel limits](https://support.office.com/en-us/article/excel-specifications-and-limits-1672b34d-7043-467e-8e27-269d656771c3)
 reach up to 1,048,576 rows by 16,384 columns. The internal `sheet1.xml` file will break the `4GB` limit at about 1 milion rows with 125 columns - with number cell only. Well, I'm workking on a production system where the real data export excedes those standard ZIP limits at about half a milion rows. By the way, Excel handles this amount of data suprisingly well. At least on by 32GB RAM machine.

As you might have guested, the `4GB` limit in ZIP files was overcome years ago. In 2001 actually, in the version 4.5 of the PKZIP specification. With the introduction of ZIP64 extension.


This is sufficient for   can handle file sizes 
Excel is quite strict when it comes to ZIP64 extension.