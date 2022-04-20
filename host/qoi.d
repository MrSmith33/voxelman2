/// QOI - The "Quite OK Image" format for fast, lossless image compression
/// Dominic Szablewski - https://phoboslab.org
/// -- LICENSE: The MIT License(MIT)
/// Copyright(c) 2021 Dominic Szablewski - https://phoboslab.org
/// Copyright(c) 2022 Andrey Penechko - D port
module qoi;

enum QOI_COLORSPACE : ubyte {
	SRGB = 0,
	LINEAR = 1,
}

struct qoi_desc {
	uint width;
	uint height;
	ubyte channels;
	QOI_COLORSPACE colorspace;
}

alias QOI_MALLOC = extern(C) @nogc nothrow void* function(size_t size);

private:
enum QOI_OP_INDEX = 0x00; // 00xxxxxx
enum QOI_OP_DIFF  = 0x40; // 01xxxxxx
enum QOI_OP_LUMA  = 0x80; // 10xxxxxx
enum QOI_OP_RUN   = 0xc0; // 11xxxxxx
enum QOI_OP_RGB   = 0xfe; // 11111110
enum QOI_OP_RGBA  = 0xff; // 11111111

enum QOI_MASK_2   = 0xc0; // 11000000

uint QOI_COLOR_HASH(qoi_rgba_t c) @nogc nothrow { return c.r*3 + c.g*5 + c.b*7 + c.a*11; };
enum QOI_MAGIC = (uint('q') << 24) | (uint('o') << 16) | (uint('i') << 8) | uint('f');
enum QOI_HEADER_SIZE = 14;

/* 2GB is the max file size that this implementation can safely handle. We guard
against anything larger than that, assuming the worst case with 5 bytes per
pixel, rounded down to a nice clean value. 400 million pixels ought to be
enough for anybody. */
enum uint QOI_PIXELS_MAX = 400000000;

union qoi_rgba_t {
	struct { ubyte r, g, b, a; };
	uint v;
}

immutable ubyte[8] qoi_padding = [0,0,0,0,0,0,0,1];

void qoi_write_32(ubyte* bytes, int* pos, uint v) @nogc nothrow {
	bytes[(*pos)++] = (0xff000000 & v) >> 24;
	bytes[(*pos)++] = (0x00ff0000 & v) >> 16;
	bytes[(*pos)++] = (0x0000ff00 & v) >> 8;
	bytes[(*pos)++] = (0x000000ff & v);
}

uint qoi_read_32(const(ubyte)* bytes, int* pos) @nogc nothrow {
	uint a = bytes[(*pos)++];
	uint b = bytes[(*pos)++];
	uint c = bytes[(*pos)++];
	uint d = bytes[(*pos)++];
	return (a << 24) | (b << 16) | (c << 8) | d;
}


/// Encode raw RGB or RGBA pixels into a QOI image in memory.
/// The function either returns null on failure (invalid parameters or malloc
/// failed) or a pointer to the encoded data on success. On success the out_len
/// is set to the size in bytes of the encoded data.
/// The returned qoi data should be free()d after use.
extern(C) export void* qoi_encode(const(void)* data, const(qoi_desc)* desc, int* out_len, QOI_MALLOC malloc) @nogc nothrow {
	if (data == null) return null;
	if (out_len == null) return null;
	if (desc == null) return null;
	if (desc.width == 0) return null;
	if (desc.height == 0) return null;
	if (desc.channels < 3) return null;
	if (desc.channels > 4) return null;
	if (desc.colorspace > 1) return null;
	if (desc.height >= QOI_PIXELS_MAX / desc.width) return null;

	const int max_size =
		desc.width * desc.height * (desc.channels + 1) +
		QOI_HEADER_SIZE + cast(int)qoi_padding.sizeof;

	int p = 0;
	ubyte* bytes = cast(ubyte*)malloc(max_size);
	if (!bytes) return null;

	qoi_write_32(bytes, &p, QOI_MAGIC);
	qoi_write_32(bytes, &p, desc.width);
	qoi_write_32(bytes, &p, desc.height);
	bytes[p++] = desc.channels;
	bytes[p++] = desc.colorspace;

	const(ubyte)* pixels = cast(const(ubyte)*)data;

	int run = 0;
	qoi_rgba_t px_prev;
	px_prev.r = 0;
	px_prev.g = 0;
	px_prev.b = 0;
	px_prev.a = 255;
	qoi_rgba_t px = px_prev;

	int px_len = desc.width * desc.height * desc.channels;
	int px_end = px_len - desc.channels;
	int channels = desc.channels;
	qoi_rgba_t[64] index;

	for (int px_pos = 0; px_pos < px_len; px_pos += channels) {
		px.r = pixels[px_pos + 0];
		px.g = pixels[px_pos + 1];
		px.b = pixels[px_pos + 2];

		if (channels == 4) {
			px.a = pixels[px_pos + 3];
		}

		if (px.v == px_prev.v) {
			run++;
			if (run == 62 || px_pos == px_end) {
				bytes[p++] = cast(ubyte)(QOI_OP_RUN | (run - 1));
				run = 0;
			}
		}
		else {
			int index_pos;

			if (run > 0) {
				bytes[p++] = cast(ubyte)(QOI_OP_RUN | (run - 1));
				run = 0;
			}

			index_pos = QOI_COLOR_HASH(px) % 64;

			if (index[index_pos].v == px.v) {
				bytes[p++] = cast(ubyte)(QOI_OP_INDEX | index_pos);
			}
			else {
				index[index_pos] = px;

				if (px.a == px_prev.a) {
					byte vr = cast(byte)(px.r - px_prev.r);
					byte vg = cast(byte)(px.g - px_prev.g);
					byte vb = cast(byte)(px.b - px_prev.b);

					byte vg_r = cast(byte)(vr - vg);
					byte vg_b = cast(byte)(vb - vg);

					if (
						vr > -3 && vr < 2 &&
						vg > -3 && vg < 2 &&
						vb > -3 && vb < 2
					) {
						bytes[p++] = cast(ubyte)(QOI_OP_DIFF | (vr + 2) << 4 | (vg + 2) << 2 | (vb + 2));
					}
					else if (
						vg_r >  -9 && vg_r <  8 &&
						vg   > -33 && vg   < 32 &&
						vg_b >  -9 && vg_b <  8
					) {
						bytes[p++] = cast(ubyte)(QOI_OP_LUMA     | (vg   + 32));
						bytes[p++] = cast(ubyte)((vg_r + 8) << 4 | (vg_b +  8));
					}
					else {
						bytes[p++] = QOI_OP_RGB;
						bytes[p++] = px.r;
						bytes[p++] = px.g;
						bytes[p++] = px.b;
					}
				}
				else {
					bytes[p++] = QOI_OP_RGBA;
					bytes[p++] = px.r;
					bytes[p++] = px.g;
					bytes[p++] = px.b;
					bytes[p++] = px.a;
				}
			}
		}
		px_prev = px;
	}

	for (size_t i = 0; i < qoi_padding.sizeof; i++) {
		bytes[p++] = qoi_padding[i];
	}

	*out_len = p;
	return bytes;
}

/// Decode a QOI image from memory.
/// The function either returns null on failure (invalid parameters or malloc
/// failed) or a pointer to the decoded pixels. On success, the qoi_desc struct
/// is filled with the description from the file header.
/// The returned pixel data should be free()d after use.
extern(C) export void* qoi_decode(const void* data, int size, qoi_desc* desc, int channels, QOI_MALLOC malloc) @nogc nothrow {
	if (data == null) return null;
	if (desc == null) return null;
	if (channels != 0 && channels != 3 && channels != 4) return null;
	if (size < QOI_HEADER_SIZE + cast(int)qoi_padding.sizeof) return null;
	if (malloc == null) return null;

	const(ubyte)* bytes = cast(const(ubyte)*)data;
	int p = 0;

	uint header_magic = qoi_read_32(bytes, &p);
	desc.width = qoi_read_32(bytes, &p);
	desc.height = qoi_read_32(bytes, &p);
	desc.channels = bytes[p++];
	desc.colorspace = cast(QOI_COLORSPACE)bytes[p++];

	if (desc.width == 0) return null;
	if (desc.height == 0) return null;
	if (desc.channels < 3) return null;
	if (desc.channels > 4) return null;
	if (desc.colorspace > 1) return null;
	if (header_magic != QOI_MAGIC) return null;
	if (desc.height >= QOI_PIXELS_MAX / desc.width) return null;

	if (channels == 0) channels = desc.channels;

	int px_len = desc.width * desc.height * channels;
	ubyte* pixels = cast(ubyte*)malloc(px_len);

	if (!pixels) return null;

	qoi_rgba_t[64] index;
	qoi_rgba_t px;
	px.r = 0;
	px.g = 0;
	px.b = 0;
	px.a = 255;

	int run = 0;

	int chunks_len = size - cast(int)qoi_padding.sizeof;
	for (int px_pos = 0; px_pos < px_len; px_pos += channels) {
		if (run > 0) {
			run--;
		}
		else if (p < chunks_len) {
			int b1 = bytes[p++];

			if (b1 == QOI_OP_RGB) {
				px.r = bytes[p++];
				px.g = bytes[p++];
				px.b = bytes[p++];
			}
			else if (b1 == QOI_OP_RGBA) {
				px.r = bytes[p++];
				px.g = bytes[p++];
				px.b = bytes[p++];
				px.a = bytes[p++];
			}
			else if ((b1 & QOI_MASK_2) == QOI_OP_INDEX) {
				px = index[b1];
			}
			else if ((b1 & QOI_MASK_2) == QOI_OP_DIFF) {
				px.r += ((b1 >> 4) & 0x03) - 2;
				px.g += ((b1 >> 2) & 0x03) - 2;
				px.b += ( b1       & 0x03) - 2;
			}
			else if ((b1 & QOI_MASK_2) == QOI_OP_LUMA) {
				int b2 = bytes[p++];
				int vg = (b1 & 0x3f) - 32;
				px.r += vg - 8 + ((b2 >> 4) & 0x0f);
				px.g += vg;
				px.b += vg - 8 +  (b2       & 0x0f);
			}
			else if ((b1 & QOI_MASK_2) == QOI_OP_RUN) {
				run = (b1 & 0x3f);
			}

			index[QOI_COLOR_HASH(px) % 64] = px;
		}

		pixels[px_pos + 0] = px.r;
		pixels[px_pos + 1] = px.g;
		pixels[px_pos + 2] = px.b;

		if (channels == 4) {
			pixels[px_pos + 3] = px.a;
		}
	}

	return pixels;
}
