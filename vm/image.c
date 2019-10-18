#include "master.h"

/* Certain special objects in the image are known to the runtime */
void init_objects(F_HEADER *h)
{
	int i;
	for(i = 0; i < USER_ENV; i++)
		userenv[i] = F;
	userenv[GLOBAL_ENV] = h->global;
	userenv[BOOT_ENV] = h->boot;
	T = h->t;
	bignum_zero = h->bignum_zero;
	bignum_pos_one = h->bignum_pos_one;
	bignum_neg_one = h->bignum_neg_one;
}

INLINE void load_data_heap(FILE *file, F_HEADER *h, F_PARAMETERS *p)
{
	CELL good_size = h->data_size + (1 << 20);

	if(good_size > p->aging_size)
		p->aging_size = good_size;

	init_data_heap(p->gen_count,p->young_size,p->aging_size,p->secure_gc);

	F_ZONE *tenured = &data_heap->generations[TENURED];

	if(fread((void*)tenured->start,h->data_size,1,file) != 1)
		fatal_error("load_data_heap failed",0);

	tenured->here = tenured->start + h->data_size;
	data_relocation_base = h->data_relocation_base;
}

INLINE void load_code_heap(FILE *file, F_HEADER *h, F_PARAMETERS *p)
{
	CELL good_size = h->code_size + (1 << 19);

	if(good_size > p->code_size)
		p->code_size = good_size;

	init_code_heap(p->code_size);

	if(h->code_size != 0
		&& fread(first_block(&code_heap),h->code_size,1,file) != 1)
		fatal_error("load_code_heap failed",0);

	code_relocation_base = h->code_relocation_base;
	build_free_list(&code_heap,h->code_size);
}

/* Read an image file from disk, only done once during startup */
/* This function also initializes the data and code heaps */
void load_image(F_PARAMETERS *p)
{
	FILE *file = OPEN_READ(p->image);
	if(file == NULL)
	{
		FPRINTF(stderr,"Cannot open image file: %s\n",p->image);
		fprintf(stderr,"%s\n",strerror(errno));
		exit(1);
	}

	F_HEADER h;
	fread(&h,sizeof(F_HEADER),1,file);

	if(h.magic != IMAGE_MAGIC)
		fatal_error("Bad image: magic number check failed",h.magic);

	if(h.version != IMAGE_VERSION)
		fatal_error("Bad image: version number check failed",h.version);
	
	load_data_heap(file,&h,p);
	load_code_heap(file,&h,p);

	fclose(file);

	init_objects(&h);

	relocate_data();
	relocate_code();

	/* Store image path name */
	userenv[IMAGE_ENV] = tag_object(from_native_string(p->image));
}

/* Compute total sum of sizes of free blocks */
void save_code_heap(FILE *file)
{
	F_BLOCK *scan = first_block(&code_heap);

	while(scan)
	{
		if(scan->status == B_ALLOCATED)
			fwrite(scan,scan->size,1,file);
		scan = next_block(&code_heap,scan);
	}
}

/* Save the current image to disk */
bool save_image(const F_CHAR *filename)
{
	FILE* file;
	F_HEADER h;

	FPRINTF(stderr,"*** Saving %s...\n",filename);

	file = OPEN_WRITE(filename);
	if(file == NULL)
		fatal_error("Cannot open image for writing",errno);

	F_ZONE *tenured = &data_heap->generations[TENURED];

	h.magic = IMAGE_MAGIC;
	h.version = IMAGE_VERSION;
	h.data_relocation_base = tenured->start;
	h.boot = userenv[BOOT_ENV];
	h.data_size = tenured->here - tenured->start;
	h.global = userenv[GLOBAL_ENV];
	h.t = T;
	h.bignum_zero = bignum_zero;
	h.bignum_pos_one = bignum_pos_one;
	h.bignum_neg_one = bignum_neg_one;
	
	h.code_size = heap_size(&code_heap);
	h.code_relocation_base = code_heap.segment->start;
	fwrite(&h,sizeof(F_HEADER),1,file);

	fwrite((void*)tenured->start,h.data_size,1,file);
	/* save_code_heap(file); */
	fwrite(first_block(&code_heap),h.code_size,1,file);

	fclose(file);

	return true;
}

void primitive_save_image(void)
{
	/* do a full GC to push everything into tenured space */
	primitive_code_gc();

	save_image(unbox_native_string());
}

void primitive_save_image_and_exit(void)
{
	/* do a full GC + code heap compaction */
	compact_code_heap();

	save_image(unbox_native_string());

	/* now exit; we cannot continue executing like this */
	exit(0);
}

/* Initialize an object in a newly-loaded image */
void relocate_object(CELL relocating)
{
	do_slots(relocating,data_fixup);

	switch(untag_header(get(relocating)))
	{
	case WORD_TYPE:
		fixup_word((F_WORD*)relocating);
		break;
	case DLL_TYPE:
		ffi_dlopen((F_DLL*)relocating,false);
		break;
	case ALIEN_TYPE:
		fixup_alien((F_ALIEN*)relocating);
		break;
	}
}

/* Since the image might have been saved with a different base address than
where it is loaded, we need to fix up pointers in the image. */
void relocate_data()
{
	CELL relocating;

	data_fixup(&userenv[BOOT_ENV]);
	data_fixup(&userenv[GLOBAL_ENV]);
	data_fixup(&T);
	data_fixup(&bignum_zero);
	data_fixup(&bignum_pos_one);
	data_fixup(&bignum_neg_one);

	F_ZONE *tenured = &data_heap->generations[TENURED];

	for(relocating = tenured->start;
		relocating < tenured->here;
		relocating += untagged_object_size(relocating))
	{
		allot_barrier(relocating);
		relocate_object(relocating);
	}
}

void fixup_code_block(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL words_start, CELL words_end)
{
	/* relocate literal table data */
	CELL scan;
	CELL literal_end = literal_start + relocating->literal_length;

	for(scan = literal_start; scan < literal_end; scan += CELLS)
		data_fixup((CELL*)scan);

	for(scan = words_start; scan < words_end; scan += CELLS)
	{
		if(relocating->finalized)
			code_fixup((XT*)scan);
		else
			data_fixup((CELL*)scan);
	}

	relocate_code_block(relocating,code_start,reloc_start,
		literal_start,words_start,words_end);
}

void relocate_code()
{
	iterate_code_heap(fixup_code_block);
}
