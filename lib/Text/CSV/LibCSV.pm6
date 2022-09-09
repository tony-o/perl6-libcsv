use Text::CSV::LibCSV::Native;
use NativeCall;
unit class Text::CSV::LibCSV;

has Pointer $!parser;
has Str $!delimiter;
has Str $!quote;
has Bool $!preserve-ws;
has int32 $!parser-options;
has Str $!auto-decode;
has Bool $!has-headers;

submethod BUILD (Str :$!delimiter? = ',', Str :$!quote? = '"', Bool :$!preserve-ws? = False, int32 :$!parser-options? = 0, Bool :$!has-headers? = False, Str :$!auto-decode) {
  $!parser = csv_create_parser_x($!parser-options);
  csv_set_delim_x($!parser, $!delimiter.ord) if $!delimiter ne ',';
  csv_set_quote_x($!parser, $!quote.ord) if $!quote ne '"';
  csv_preserve_whitespace($!parser, 1) if $!preserve-ws;
}

method build-options(:$CSV-STRICT = 0, :$CSV-REPALL-NL = 0, :$CSV-STRICT-FINI = 0, :$CSV-APPEND-NULL = 0, :$CSV-EMPTY-IS-NULL = 0) returns int32 {
  0 +|
  ($CSV-STRICT ?? 1 !! 0) +|
  ($CSV-REPALL-NL ?? 2 !! 0) +|
  ($CSV-STRICT-FINI ?? 4 !! 0) +|
  ($CSV-APPEND-NULL ?? 8 !! 0) +|
  ($CSV-EMPTY-IS-NULL ?? 16 !! 0);
}

method csv-write-field(Str $data) {
  csv_write_2($data, $data.chars, $!quote.ord);
}

method csv-write(@data) {
  my Str $x = '';
  for @data -> @ds {
    my $len = @ds.elems - 1;
    my $i = 0;
    for @ds -> $d {
      $x ~= csv_write_2($d.Str, $d.Str.chars, $!quote.ord);
      if $i++ < $len {
        $x ~= $!delimiter;
      }
    }
    $x ~= "\n";
  }
  $x;
}

method read-file(Str $file-path, Supplier :$on-data?, Supplier :$on-record?, :$return-all? is copy, :$has-headers? = $!has-headers) {
  $return-all = $return-all.so || (!$on-data.defined && !$on-record.defined);
  my @data;
  my @c-row;
  my @headers;
  my $row = 0;
  my sub data (Pointer[uint8] $bytes, Int $len, OpaquePointer $null) {
    my Buf $data .=new;
    for 0..^$len {
      $data.push($bytes[$_]);
    }
    $on-data.emit($!auto-decode ?? $data.decode($!auto-decode) !! $data)
      if $on-data.defined;
    @c-row.push($!auto-decode ?? $data.decode($!auto-decode) !! $data);
  }
  my sub record (Int $len, OpaquePointer $null) {
    if $has-headers && $row == 0 {
      @headers = @c-row.clone;
    } else {
      if $has-headers {
        my %row;
        for 0..^@c-row.elems -> $i {
          %row{@headers[$i]} = @c-row[$i];
        }
        @data.push(%row) if $return-all;
        $on-record.emit(%row.clone) if $on-record.defined;
      } else {
        $on-record.emit(@c-row.clone) if $on-record.defined;
        @data.push(@c-row.clone) if $return-all;
      }
    }
    $row++;
    @c-row = ();
  }
  my $rval = csv_stream_file_x(
    $!parser,
    $file-path.IO.absolute,
    &data,
    &record,
  );
  die 'Could not parse input file.' if $rval == -2;
  die 'Error reading input file.' if $rval == -3;
  die 'Unable to open file ' ~ $file-path.IO.absolute if $rval == -1;
  @data;
}




### Procedural stuff follows:
enum CSV-PARSER-OPTIONS is export (
  'CSV-STRICT' => 1,
  'CSV-REPALL-NL' => 2,
  'CSV-STRICT-FINI' => 4,
  'CSV-APPEND-NULL' => 8,
  'CSV-EMPTY-IS-NULL' => 16,
);

sub on-data (Pointer[uint8] $bytes, Int $len, OpaquePointer $null) {
  my Buf $data .=new;
  for 0..^$len {
    $data.push($bytes[$_]);
  }
  @*ROW.push($data);
}

sub on-record (Int $len, OpaquePointer $data) {
  say $len;
  @*DATA.push(@*ROW.clone);
  @*ROW = ();
}

sub csv-write-field(Str $data, Str :$quote where *.ords.elems == 1 = '"') is export {
  csv_write_2($data, $data.chars, $quote.ord);
}

sub csv-write(@data, Str :$quote where *.ords.elems == 1 = '"', Str :$delimiter = ',') is export {
  my Str $x = '';
  for @data -> @ds {
    my $len = @ds.elems - 1;
    my $i = 0;
    for @ds -> $d {
      $x ~= csv_write_2($d.Str, $d.Str.chars, $quote.ord);
      if $i++ < $len {
        $x ~= $delimiter;
      }
    }
    $x ~= "\n";
  }
  $x;
}

multi sub csv-read-file (IO $file, uint8 :$parser-options = 0, uint16 :$quote = '"'.ord, uint16 :$delim = ',', :$data = &on-data, :$record = &on-record) is export(:csv-read-file) {
  my $path = $file.absolute;
  my @*DATA;
  my @*ROW;
  csv_read_file($path, $parser-options, $quote, $delim, $data, $record);
}

multi sub csv-read-file (Str $file) is export(:csv-read-file) {
  csv-read-file($file.IO);
}
