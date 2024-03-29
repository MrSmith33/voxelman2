module deps.vma;

extern(C):

void vmaAllocateMemory();
void vmaAllocateMemoryForBuffer();
void vmaAllocateMemoryForImage();
void vmaAllocateMemoryPages();
void vmaBeginDefragmentation();
void vmaBeginDefragmentationPass();
void vmaBindBufferMemory();
void vmaBindBufferMemory2();
void vmaBindImageMemory();
void vmaBindImageMemory2();
void vmaCalculatePoolStatistics();
void vmaCalculateStatistics();
void vmaCalculateVirtualBlockStatistics();
void vmaCheckCorruption();
void vmaCheckPoolCorruption();
void vmaClearVirtualBlock();
void vmaCreateAliasingBuffer();
void vmaCreateAliasingImage();
void vmaCreateAllocator();
void vmaCreateBuffer();
void vmaCreateBufferWithAlignment();
void vmaCreateImage();
void vmaCreatePool();
void vmaCreateVirtualBlock();
void vmaDestroyAllocator();
void vmaDestroyBuffer();
void vmaDestroyImage();
void vmaDestroyPool();
void vmaDestroyVirtualBlock();
void vmaEndDefragmentation();
void vmaEndDefragmentationPass();
void vmaFindMemoryTypeIndex();
void vmaFindMemoryTypeIndexForBufferInfo();
void vmaFindMemoryTypeIndexForImageInfo();
void vmaFlushAllocation();
void vmaFlushAllocations();
void vmaFreeMemory();
void vmaFreeMemoryPages();
void vmaGetAllocationInfo();
void vmaGetAllocationMemoryProperties();
void vmaGetAllocatorInfo();
void vmaGetHeapBudgets();
void vmaGetMemoryProperties();
void vmaGetMemoryTypeProperties();
void vmaGetPhysicalDeviceProperties();
void vmaGetPoolName();
void vmaGetPoolStatistics();
void vmaGetVirtualAllocationInfo();
void vmaGetVirtualBlockStatistics();
void vmaInvalidateAllocation();
void vmaInvalidateAllocations();
void vmaIsVirtualBlockEmpty();
void vmaMapMemory();
void vmaSetAllocationName();
void vmaSetAllocationUserData();
void vmaSetCurrentFrameIndex();
void vmaSetPoolName();
void vmaSetVirtualAllocationUserData();
void vmaUnmapMemory();
void vmaVirtualAllocate();
void vmaVirtualFree();
