#include "master.h"

/* Simple wrappers for ANSI C I/O functions, used for bootstrapping.

Note the ugly loop logic in almost every function; we have to handle EINTR
and restart the operation if the system call was interrupted. Naive
applications don't do this, but then they quickly fail if one enables
itimer()s or other signals.

The Factor library provides platform-specific code for Unix and Windows
with many more capabilities so these words are not usually used in
normal operation. */

void init_c_io(void)
{
	userenv[IN_ENV] = allot_alien(F,(CELL)stdin);
	userenv[OUT_ENV] = allot_alien(F,(CELL)stdout);
}

void io_error(void)
{
	if(errno == EINTR)
		return;

	CELL error = tag_object(from_char_string(strerror(errno)));
	simple_error(ERROR_IO,error,F);
}

void primitive_fopen(void)
{
	char *mode = unbox_char_string();
	REGISTER_C_STRING(mode);
	char *path = unbox_char_string();
	UNREGISTER_C_STRING(mode);

	for(;;)
	{
		FILE *file = fopen(path,mode);
		if(file == NULL)
			io_error();
		else
		{
			box_alien(file);
			break;
		}
	}
}

void primitive_fgetc(void)
{
	FILE* file = unbox_alien();

	for(;;)
	{
		int c = fgetc(file);
		if(c == EOF)
		{
			if(feof(file))
			{
				dpush(F);
				break;
			}
			else
				io_error();
		}
		else
		{
			dpush(tag_fixnum(c));
			break;
		}
	}
}

void primitive_fread(void)
{
	FILE* file = unbox_alien();
	CELL size = unbox_array_size();

	if(size == 0)
	{
		dpush(tag_object(allot_string(0,0)));
		return;
	}

	F_BYTE_ARRAY *buf = allot_byte_array(size);

	for(;;)
	{
		int c = fread(buf + 1,1,size,file);
		if(c <= 0)
		{
			if(feof(file))
			{
				dpush(F);
				break;
			}
			else
				io_error();
		}
		else
		{
			dpush(tag_object(memory_to_char_string(
				(char *)(buf + 1),c)));
			break;
		}
	}
}

void primitive_fwrite(void)
{
	FILE* file = unbox_alien();
	F_STRING* text = untag_string(dpop());
	F_FIXNUM length = untag_fixnum_fast(text->length);
	char* string = to_char_string(text,false);

	if(string_capacity(text) == 0)
		return;

	for(;;)
	{
		size_t written = fwrite(string,1,length,file);
		if(written == length)
			break;
		else
		{
			if(feof(file))
				break;
			else
				io_error();

			/* Still here? EINTR */
			length -= written;
			string += written;
		}
	}
}

void primitive_fflush(void)
{
	FILE *file = unbox_alien();
	for(;;)
	{
		if(fflush(file) == EOF)
			io_error();
		else
			break;
	}
}

void primitive_fclose(void)
{
	FILE *file = unbox_alien();
	for(;;)
	{
		if(fclose(file) == EOF)
			io_error();
		else
			break;
	}
}

/* This function is used by FFI I/O. Accessing the errno global directly is
not portable, since on some libc's errno is not a global but a funky macro that
reads thread-local storage. */
int err_no(void)
{
	return errno;
}

/* Used by library/io/buffer/buffer.factor. Similar to C standard library
function strcspn(const char *s, const char *charset) */
long memcspn(const char *s, const char *end, const char *charset)
{
	const char *scan1, *scan2;

	for(scan1 = s; scan1 < end; scan1++)
	{
		for(scan2 = charset; *scan2; scan2++)
		{
			if(*scan1 == *scan2)
				return scan1 - s;
		}
	}

	return -1;
}
