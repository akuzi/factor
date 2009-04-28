#include <assert.h>

#define FRAME_RETURN_ADDRESS(frame) *(XT *)(frame_successor(frame) + 1)

INLINE void flush_icache(CELL start, CELL len) {}

F_FASTCALL void c_to_factor(CELL quot);
F_FASTCALL void throw_impl(CELL quot, F_STACK_FRAME *rewind_to);
F_FASTCALL void lazy_jit_compile(CELL quot);

void set_callstack(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy);

INLINE void set_call_site(CELL return_address, CELL target)
{
	/* An x86 CALL instruction looks like so:
	   |e8|..|..|..|..|
	   where the ... are a PC-relative jump address.
	   The return_address points to right after the
	   instruction. */
#ifdef FACTOR_DEBUG
	assert(*(unsigned char *)(return_address - 5) == 0xe8);
#endif
	*(F_FIXNUM *)(return_address - 4) = (target - (return_address - 4));
}
