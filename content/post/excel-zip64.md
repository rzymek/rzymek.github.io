+++
bigimg = ""
date = "2018-11-14"
subtitle = ""
title = "excel zip64"
draft = true
+++

# Problem with huge XLSX files

As you may already know, xlsx files are just zipped xml's. 
```
[Content_Types].xml
docProps/app.xml
docProps/core.xml
_rels/.rels
xl/workbook.xml
xl/_rels/workbook.xml.rels
xl/sharedStrings.xml
xl/styles.xml
xl/worksheets/sheet1.xml
```

Standard ZIP format has 4 bytes reserved for file size. 
The maximum is therefore `0xFFFF FFFF` or `256^4`, `2^32`. 
In other words (numbers) its `4294967296`, that is `4 GB`. 
An unimaginably huge size in 1989 when the first PKZIP spec was published. Not that big now. 
On the other hand current [Excel limits](https://support.office.com/en-us/article/excel-specifications-and-limits-1672b34d-7043-467e-8e27-269d656771c3)
 reach up to 1,048,576 rows by 16,384 columns. The internal `sheet1.xml` file will break the `4GB` limit at about 1 milion rows with 125 columns - with number cell only. Well, I'm workking on a production system where the real data export excedes those standard ZIP limits at about half a milion rows. By the way, Excel handles this amount of data suprisingly well. At least on by 32GB RAM machine.

As you might have guested, the `4GB` limit in ZIP files was overcome years ago. In 2001 actually, in the version 4.5 of the PKZIP specification. With the introduction of ZIP64 extension.


This is sufficient for can handle file sizes 
TTTTTTT
Excel is quite strict when it comes to ZIP64 extension.

Let's first look a at standard zip file structure:
```
 +============+     
 | LFH-1      |   - Local file header for 
 +------------+
 | Compressed |   - Usually using deflate compression
 | file 1     |
 | data       |
 +------------+
 | EXT-1      |   - Data descriptor (optional), contains crc and file size
 +============+     
 | LFH-2      |   
 +------------+
 | Compressed |   
 | file 2     |
 | data       |
 +------------+
 | EXT-2      |   
 +============+     
 | LFH-3      |   
 +------------+
 | ...        |   
 |

              |
 |        ... |
 +------------+
 | EXT-n      |   
 +============+     
 | CEN-1      |   - Central directory entry, one for every file, 
 +------------+     points to each corresponding LFH offset
 | CEN-2      |
 +------------+
 | ...        |
 +------------+
 | CEN-n      |
 +============+     
 | END        |   - End of zip header, points to CEN-1 offset
 +------------+
 ```

I'm going to focus on streaming zip creation. That is compressing data that is
generated on the fly and not known in advance. The output will also be streamed, like over a socket. 
No going back. No seeking to add some info to a LFH.

Zip does fully support this. There are field to store size, crc and compressed size in LFH, but they can be filled with zeros.

Let's look closely at a zip format Excel fully accepts.
First the complete LFH - Local File Header:
```
50 4B 03 04 2D 00 08 00 08 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00 
|----------|-----|-----|-----|-----------|-----------|-----------|-----------|-----|-----|
 'PK\03\04'   |   flags   |   time & date    CRC-32        |     uncompressed   |     | 
 LFH          |           |                           compressed     size       |     | 
 signature    |     compression                         size                filename  |
              |       method                                                 length   |
           version                                                                  extra
           2D = 45                                                               field length
```

Version `0x2D` = `45` is interpreted as 4.5. This is the ZIP specification version where ZIP64 extension was introduced.
Flag value `0x0008` ([little-endian](https://en.wikipedia.org/wiki/Little-endian)) means that the bit at offset 3 is set. 
This bit is a marker that Data Descriptor (EXT) will be written after the file data. 
Compression method `0x0008` means [DEFLATE](https://en.wikipedia.org/wiki/DEFLATE).
