module deps.mimalloc;
extern(C):
// Standard malloc interface
void* mi_malloc(size_t size);
void* mi_calloc(size_t count, size_t size);
void* mi_realloc(void* p, size_t newsize);
void* mi_expand(void* p, size_t newsize);
void mi_free(void* p);
// Extended functionality
void* mi_malloc_small(size_t size);
void* mi_zalloc_small(size_t size);
void* mi_zalloc(size_t size);
void* mi_mallocn(size_t count, size_t size);
void* mi_reallocn(void* p, size_t count, size_t size);
void* mi_reallocf(void* p, size_t newsize);
size_t mi_usable_size(void* p);
size_t mi_good_size(size_t size);
