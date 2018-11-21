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


This is sufficient to handle file sizes .....


Excel is quite strict when it comes to ZIP64 extension.

Let's first look a at standard zip file structure:
```
 +============+     
 | LFH-1      |   - Local file header for file 1
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
 50 4B 03 04 2D 00 08 00 08 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ...
|-----------|-----|-----|-----|-----------|-----------|-----------|-----------|
 'PK\03\04'   |   flags   |   time & date    CRC-32        |     uncompressed  
 LFH          |           |                           compressed     size      
 signature    |     compression                         size                
              |       method                                                
           version                                                          
           2D = 45                                                          
```
```           
... 18 00 00 00 78 6C 2F 77 6F 72 6B 73 68 65 65 74 73 2F 73 68 65 65 74 31 2E 78 6D 6C 
   |-----|-----|-----------------------------------------------------------------------|
      |     |      filename ('xl/worksheets/sheet1.xml')
 filename   |      24 bytes (0x18) in this case
 length     |
          extra field length
```

Version `0x2D` = `45` is interpreted as 4.5. This is the ZIP specification version where ZIP64 extension was introduced.
Flag value `0x0008` ([little-endian](https://en.wikipedia.org/wiki/Little-endian)) means that the bit at offset 3 is set. 
This bit is a marker that Data Descriptor (EXT) will be written after the file data. 
Compression method `0x0008` means [DEFLATE](https://en.wikipedia.org/wiki/DEFLATE).

After the header comes actual compressed file data. When reimplementing the zip format (to match Excel expectations) 
I just used [java.util.zip.DeflaterOutputStream](https://docs.oracle.com/javase/8/docs/api/java/util/zip/DeflaterOutputStream.html). Actually I did extended it to add functionality to record CRC and to wrap it in `BufferedOutputStream`. Turns out if you don't feed `DeflaterOutputStream` in chunks of about `4096` bytes it becomes really slow. Like *three times slower*. I did stumble upon this observation while browsing through 
[`commons-compress` sources](https://github.com/apache/commons-compress/blob/c03704d773dfa0dfc5b2e53b4c198a95d0213ca0/src/main/java/org/apache/commons/compress/archivers/zip/StreamCompressor.java#L42):

    /*
     * Apparently Deflater.setInput gets slowed down a lot on Sun JVMs
     * when it gets handed a really big buffer.  See
     * https://issues.apache.org/bugzilla/show_bug.cgi?id=45396
     *
     * Using a buffer size of 8 kB proved to be a good compromise
     */

Getting back to ZIP structure. After compressed file data comes the optional *Data Descriptor* (EXT) header. It contains CRC, size and compressed size. Initially 4 bytes were reserved for each of these values. ZIP specification 4.5 is used, the compressed and uncompressed sizes are 8 bytes each.
```
 50 4B 07 08 73 B9 D9 10 06 66 30 21 00 00 00 00 9A 90 DC 15 01 00 00 00
|-----------|-----------|-----------------------|-----------------------|
 'PK\07\08'    CRC-32    compressed size          uncompressed size
                          0x21 30 66 06 =          0x01 15 DC 90 9A =
                          556819974 bytes (532mb)  4661743770 bytes (4,4GiB)
```

This is repeated for every file.


After all the files comes the *Central Directory*. Here for every file comes a structure very similar to local file header. 

```
 50 4B 01 02 2D 00 2D 00 00 00 08 00 00 00 00 00 73 B9 D9 10 06 66 30 21 FF FF FF FF ...
|-----------|-----|-----|-----|-----|-----------|-----------|-----------|-----------| 

```
```
... 18 00 0C 00 00 00 00 00 00 00 00 00 00 00 C4 08 00 00 ...
   |-----|-----|-----|-----|-----|-----------|-----------| 
```
```
... 78 6C 2F 77 6F 72 6B 73 68 65 65 74 73 2F 73 68 65 65 74 31 2E 78 6D 6C ...
   |-----------------------------------------------------------------------|
     filename ('xl/worksheets/sheet1.xml')
     24 bytes (0x18) in this case
```
```

... 01 00 08 00 9A 90 DC 15 01 00 00 00 
   |-----|-----|-----------------------|
    sig    size     compressed size
```


```
 50 4B 05 06 00 00 00 00 08 00 08 00 09 02 00 00 18 6F 30 21 00 00
|-----------|-----|-----|-----|-----|-----------|-----------|-----|
  END sig     
```

TL;DR:
Excel seem to require zip spec. version 4.5 in Local File Header if ZIP64 is used anywhere
with this zip entry (Central directory file header or Data descriptor).
When the zip (xlsx) is created on a OutputStream, files size and crc is not know at the time 
of writing Local file header. 
