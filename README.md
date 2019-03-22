# Text::CSV::LibCSV

Uses a wrapper that can stream data/records from a csv file using libcsv.

# Options

## Delimiter (`.new(:delimiter<>)`)

LibCSV allows a char to be specified for the delimiter, if you provide a multicharacter string only the first ordinal will be used.

## Quote (`.new(:quote<>)`)

LibCSV allows a char to be specified for the quoting char, if you provide a multicharacter string only the first ordinal will be used.

## Preserve Whitespace (`.new(:preserve-ws)`)

You can choose to not auto-trim tabs and spaces from data by passing this option along

## Parser Options (`.new(:parser-options(int32))`)

See your local libcsv documentation for what is acceptable here, out of the box is provided the structure:

```
CSV-STRICT        => 1
CSV-REPALL-NL     => 2
CSV-STRICT-FINI   => 4
CSV-APPEND-NULL   => 8
CSV-EMPTY-IS-NULL => 16
```

You can build your own options with the enum (example: `CSV-STRICT +| CSV-EMPTY-IS-NULL`) or the convenience method: `Text::CSV::LibCSV.build-options(:CSV-STRICT, :CSV-EMPTY-IS-NULL)`

## Has Headers (`.new(:has-headers) | .read-file(:has-headers)`)

When provided to `.new` this option will set the default parsing mode to assuming there are headers in the CSV file.  This option can be overridden by passing this option to `.read-file`.  This option will also cause a hash containing `header => <value>` pairs rather than array to be returned from parsing

## Auto Decode (`.new(:auto-decode)`)

This will auto-decode the data records that are emitted from libcsv.  If this option is left empty then the user will receive `Buf` types back

# Usage


## OO interface

```perl6
use Text::CSV::LibCSV;

my $parser-options = CSV-STRICT +| CSV-EMPTY-IS-NULL;
my Text::CSV::LibCSV $parser .=new(:$parser-options, :auto-decode('utf8'), :has-headers);

my @lines = $parser.read-file('path-to-file');

# @lines = [ { ... }, { ... }, ... ];
```

## Procedural

```perl6
use Text::CSV::LibCSV :csv-read-file;

my @lines = csv-read-file('path-to-file', :$parser-options, :auto-decode('utf8'), :has-headers);

# @lines = [ { ... }, { ... }, ... ];

```

# Streaming

Sometimes your CSV files are large or simply want to act as the record/data is available.  This is possible with the following pattern:

```perl6
use Text::CSV::LibCSV;

my Supplier $on-data   .=new;
my Supplier $on-record .=new;

$on-data.Supply.tap( -> $data {
  # depending on your options $data contains a Buf or Buf.decode()
});

$on-record.Supply.tap( -> $record {
  # depending on your options $record contains a hash or array
});

my $parser-options = CSV-STRICT +| CSV-EMPTY-IS-NULL;
my Text::CSV::LibCSV $parser .=new(:$parser-options, :auto-decode('utf8'), :has-headers);

$parser.read-file('path-to-file', :$on-data, :$on-record, :!return-all);
```
