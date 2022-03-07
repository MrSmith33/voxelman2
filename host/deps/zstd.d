module deps.zstd;

extern(C):

void ZSTD_compress();
void ZSTD_decompress();
void ZSTD_getFrameContentSize();
void ZSTD_getDecompressedSize();
void ZSTD_findFrameCompressedSize();
void ZSTD_compressBound();
void ZSTD_isError();
void ZSTD_getErrorName();
void ZSTD_minCLevel();
void ZSTD_maxCLevel();
void ZSTD_defaultCLevel();
