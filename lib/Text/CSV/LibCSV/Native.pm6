use NativeCall;
use LibraryMake;
unit module Text::CSV::LibCSV::Native;

sub libcsvwrap is export {
  state $ = do {
    my $so = get-vars('')<SO>;
    ~(%?RESOURCES{"lib/libcsvwrap$so"}).absolute;
  }
}

sub csv_write_2(
  Str $data,
  int8 $data_len,
  uint16 $quote,
) returns Str is native(&libcsvwrap) is export { * };

sub csv_read_file(
  Str $filepath,
  uint8 $options,
  uint16 $quote,
  uint16 $delim,
  &data_handler (Pointer[uint8], Int, OpaquePointer),
  &record_handler (Int, OpaquePointer),
) is native(&libcsvwrap) is export { * };

sub csv_stream_file_x(
  OpaquePointer,
  Str $filepath,
  &data_handler (Pointer[uint8], Int, OpaquePointer),
  &record_handler (Int, OpaquePointer),
) returns int8 is native(&libcsvwrap) is export { * };

sub csv_create_parser_x(uint8 $opt) returns Pointer is native(&libcsvwrap) is export { * }
sub csv_set_delim_x(OpaquePointer, uint16 $delim) is native(&libcsvwrap) is export { * }
sub csv_set_quote_x(OpaquePointer, uint16 $quote) is native(&libcsvwrap) is export { * }
sub csv_preserve_whitespace(OpaquePointer, uint16) is native(&libcsvwrap) is export { * }
