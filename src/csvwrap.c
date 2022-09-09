#include <csv.h>
#include <stdio.h>

struct csv_parser* csv_create_parser_x(int options) {
  struct csv_parser *p = (struct csv_parser*)malloc(sizeof(struct csv_parser));
  csv_init(p, options);
  return p;
}

int preserve_whitespace(unsigned char f) { return 0; }

void csv_set_delim_x(struct csv_parser *p, char delim) {
  csv_set_delim(p, delim);
}

void csv_set_quote_x(struct csv_parser *p, char quote) {
  csv_set_quote(p, quote);
}

void csv_preserve_whitespace(struct csv_parser *p) {
  csv_set_space_func(p, preserve_whitespace);
}

int csv_stream_file_x (
  struct csv_parser *p,
  char* fpath, 
  void (*data_handler)(void* s, size_t len, void *data),
  void (*record_handler)(int c, void *data)  
) {
  FILE *in = fopen(fpath, "rb");
  char buf[1024];
  size_t i;

  if(in == NULL){
    return -1;
  }

  while((i=fread(buf, 1, 1024, in)) > 0){
    if(csv_parse(p, buf, i, data_handler, record_handler, NULL) != i){
      fprintf(stderr, "Error parsing file: %s\n", csv_strerror(csv_error(p)));
      fclose(in);
      return -2;
    }
  }

  csv_fini(p, data_handler, record_handler, NULL);
  csv_free(p);

  if(ferror(in)){
    fprintf(stderr, "Error reading from input file %s\n", fpath);
    fclose(in);
    return -3;
  }

  fclose(in);
  return 0;
}

char* csv_write_2(char* data, int data_len, char quote) {
  char *buf = calloc((data_len * 2) + 1, sizeof(char));
  csv_write2(buf, data_len*2+2, data, data_len, quote);
  return buf;
}

int csv_read_file(
  char* fpath,
  int options,
  char quote,
  char delim,
  void (*data_handler)(void* s, size_t len, void *data),
  void (*record_handler)(int c, void *data)  
){
  char buf[1024];
  FILE *in;
  struct csv_parser p;
  size_t i;


  csv_init(&p, options);
  in = fopen(fpath, "rb");
  if(in == NULL){
    return -1;
  }

  csv_set_delim(&p, delim);
  csv_set_quote(&p, quote);

  while((i=fread(buf, 1, 1024, in)) > 0){
    if(csv_parse(&p, buf, i, data_handler, record_handler, NULL) != i){
      fprintf(stderr, "Error parsing file: %s\n", csv_strerror(csv_error(&p)));
      fclose(in);
      return -2;
    }
  }

  csv_fini(&p, data_handler, record_handler, NULL);
  csv_free(&p);

  if(ferror(in)){
    //fprintf(stderr, "Error reading from input file %s\n", fpath);
    fclose(in);
    return -3;
  }

  fclose(in);
  return 0;
}
