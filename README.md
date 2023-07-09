# gslaplay - Apple IIgs GSLA Player

Program that plays GS LZB Animation files.

-----
New Apple IIgs Animation file format ... GS LZ Byte Compressed Animation
> Why?  When there are so many image formats would we need another one?
> It's because $C2/Paintworks animation format is just terribly inefficient.

- Inspired by Deluxe Animation Run/Skip/Dump, and FLI/FLC with similar properties.
- I replace the "Run" with a dictionary/frame buffer copy from the existing buffer to the existing buffer.   This is able to runlength not just a single byte, but a repeating pattern of arbitrary length.
- Care is taken in the encoder to make sure the 65816 does not have to cross bank boundaries during any copy.  This is so we can use the MVN instruction and also reduce the number of bank checks in the code.
  - (We have an opcode to indicate "source data bank has changed".)
- Goals include a good balance between file size, and playback performance (since one often makes a trade off with the other).

-----


## Format
The file has an initial header followed by multiple data chunks.

### Header

Header of the File is 20 bytes as follows:

File Offset | Data                   |  Comment
------------|:----------------------:|------------------------------------
|           | _File ID_              | 
0           | `0x47`                 |  'G'  Graphics
1           | `0x53`                 |  'S' 
2           | `0x4C`                 |  'L'  LZB
3           | `0x41`                 |  'A'  Animation
4           | {FileLength}           | (32-bit long) File length in bytes
8           | {VL}                   | Version Low - File format Minor version, `0` for now
9           | {VH}                   | Version High - Bits:  ```%RVVV_VVVV_VVVV_VVVV```
|           |                        |  `V` is Major version #, `0` for now
|           |                        |  `R` is the MSB,  `R = 0` no ring frame
|           |                        |  `R = 1`, there is a ring frame
|           |                        | _Ring Frame_ is a frame that will delta from the last frame of the animation back to the first for smoother looping.  If a ring frame exists, it's also in the frame count.
0xA         | {Width}  `0x00A0`      | (16-bit word) Width in bytes, typically 320/2 == 160 == 0x00A0
0xC         | {Height} `0x00C8`      | (16-bit word) Height in bytes, typically 200 == 0x00C8
0xE         | {FrameLength} `0x8000` | (16-bit word) Frame size in bytes, since a "Frame" may contain more than just the width * height, worth of pixels. For now this is `$8000`, or 32768
0x10        | {FrameCount}           | (32-bit long) Frame Count (total, including ring frame)
|           | _HEADER END HERE_      | 
0x14        | _First data chunk...._ | .... 
...         | _Next data chunk...._  | .... until end of file


After the header comes AIFF style chunks of data starting at file offset `0x14`, basically a 4-byte chunk name, followed by a 4-byte length (inclusive of the chunk header). The idea is that you can skip chunks you don't understand.


### Data Chunk Definitions
##### INIT
Initial Frame Chunk, this is the data used to first initialize the playback buffer

File Offset | Data                   |  Comment
------------|:----------------------:|------------------------------------
0           | `0x49`                 |  'I'
1           | `0x4E`                 |  'N'
2           | `0x49`                 |  'I'
3           | `0x54`                 |  'T'
4           | {ChunkLength}          | (32-bit long) Chunk length in bytes, including this 8-byte header
8           | {FrameData}            | A single frame of data which will be decoded/decompressed into a frame-sized buffer (right now `0x8000`). This data stream includes, an end of animation opcode, so that the normal animation decompressor can be called on this data and it will emit the initial frame onto the screen.

##### ANIM
Animation Frame Chunk, contains the encoded delta frame data for all of the frames

Chunk Offset| Data                   |  Comment
------------|:----------------------:|------------------------------------
0           | `0x41`                 |  'A'
1           | `0x4E`                 |  'N'
2           | `0x49`                 |  'I'
3           | `0x4D`                 |  'M'
4           | {ChunkLength}          | (32-bit long) Chunk length in bytes, including this 8-byte header
8           | {FrameData}            | Frames data stream, intended to be decompressed at 60FPS, which is why no play speed is included. If you need a play-rate slower than this, blank frames should be inserted into the animation data

> Every attempt is made to delta encode the image,  meaning we just encode information about what changed each frame.  We attempt to make the size efficient by supporting dictionary copies (where the dictionary is made up of existing pixels in the frame buffer).

### Decoding Chunk Data

Command Word, encoded low-high, what the bits mean:

`xxx_xxxx_xxxx_xxx` is the number of bytes 1-16384 to follow (0 == 1 byte)

#### Copy Commands

`%0xxx_xxxx_xxxx_xxx1` - Copy Bytes - straight copy bytes

`%1xxx_xxxx_xxxx_xxx1` - Skip Bytes - skip bytes / move the cursor

`%1xxx_xxxx_xxxx_xxx0` - Dictionary Copy bytes from frame buffer to frame buffer

#### Control Commands

`%0000_0000_0000_0000` - Source Skip -> Source pointer skips to next bank of data

`%0000_0000_0000_0010` - End of Frame - end of frame

`%0000_0000_0000_0110` - End of Animation / End of File / No more frames

- other remaining codes, are reserved for future expansion
