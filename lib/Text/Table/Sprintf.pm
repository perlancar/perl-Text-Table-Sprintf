# we strive for minimality
## no strict: TestingAndDebugging::RequireUseStrict
package Text::Table::Sprintf;

#IFUNBUILT
use strict 'subs', 'vars';
use warnings;
#END IFUNBUILT

# AUTHORITY
# DATE
# DIST
# VERSION

our %FEATURES = (
    set_v => {
        TextTable => 1,
    },

    features => {
        TextTable => {
            can_align_cell_containing_wide_character => 0,
            can_align_cell_containing_color_code     => 0,
            can_align_cell_containing_newline        => 0,
            can_use_box_character                    => 0,
            can_customize_border                     => 0,
            can_halign                               => 0,
            can_halign_individual_row                => 0,
            can_halign_individual_column             => 0,
            can_halign_individual_cell               => 0,
            can_valign                               => 0,
            can_valign_individual_row                => 0,
            can_valign_individual_column             => 0,
            can_valign_individual_cell               => 0,
            can_rowspan                              => 0,
            can_colspan                              => 0,
            can_color                                => 0,
            can_color_theme                          => 0,
            can_set_cell_height                      => 0,
            can_set_cell_height_of_individual_row    => 0,
            can_set_cell_width                       => 0,
            can_set_cell_width_of_individual_column  => 0,
            speed                                    => 'fast',
            can_hpad                                 => 0,
            can_hpad_individual_row                  => 0,
            can_hpad_individual_column               => 0,
            can_hpad_individual_cell                 => 0,
            can_vpad                                 => 0,
            can_vpad_individual_row                  => 0,
            can_vpad_individual_column               => 0,
            can_vpad_individual_cell                 => 0,
        },
    },
);

sub table {
    my %params = @_;
    my $rows = $params{rows} or die "Must provide rows!";
    # XXX check that all rows contain the same number of columns

    return "" unless @$rows;

    # determine the width of each column
    my @widths;
    for my $row (@$rows) {
        for (0..$#{$row}) {
            my $len = length $row->[$_];
            $widths[$_] = $len if !defined $widths[$_] || $widths[$_] < $len;
        }
    }

    # determine the sprintf format for a single row
    my $rowfmt = join(
        "",
        (map { ($_ ? "" : "|") . " %-$widths[$_]s |" } 0..$#widths),
        "\n");
    my $line = join(
        "",
        (map { ($_ ? "" : "+") . ("-" x ($widths[$_]+2)) . "+" } 0..$#widths),
        "\n");

    # determine the sprintf format for the whole table
    my $tblfmt;
    if ($params{header_row}) {
        $tblfmt = join(
            "",
            $line,
            $rowfmt,
            $line,
            (map { $rowfmt } 1..@$rows-1),
            $line,
        );
    } else {
        $tblfmt = join(
            "",
            $line,
            (map { $rowfmt } 1..@$rows),
            $line,
        );
    }

    # generate table
    sprintf $tblfmt, map { @$_ } @$rows;
}

*generate_table = \&table;

1;
#ABSTRACT: Generate simple text tables from 2D arrays using sprintf()

=for Pod::Coverage ^(max)$

=head1 SYNOPSIS

 use Text::Table::Sprintf;

 my $rows = [
     # header row
     ['Name', 'Rank', 'Serial'],
     # rows
     ['alice', 'pvt', '123456'],
     ['bob',   'cpl', '98765321'],
     ['carol', 'brig gen', '8745'],
 ];
 print Text::Table::Sprintf::table(rows => $rows, header_row => 1);


=head1 DESCRIPTION

This module provides a single function, C<table>, which formats a
two-dimensional array of data as a simple text table.

The example shown in the SYNOPSIS generates the following table:

 +-------+----------+----------+
 | Name  | Rank     | Serial   |
 +-------+----------+----------+
 | alice | pvt      | 123456   |
 | bob   | cpl      | 98765321 |
 | carol | brig gen | 8745     |
 +-------+----------+----------+

This module models its interface on L<Text::Table::Tiny> 0.03, employs the same
technique of using C<sprintf()>, but takes the technique further by using a
single large format and C<sprintf> the whole table. This results in even more
performance gain (see benchmark result or benchmark using
L<Acme::CPANModules::TextTable>).

Caveats: make sure each row contains the same number of elements. Otherwise, the
table will not be correctly formatted (cells might move to another row/column).


=head1 FUNCTIONS

=head2 table

Usage:

 my $table_str = Text::Table::Sprintf::table(%params);

The C<table> function understands these arguments, which are passed as a hash.

=over

=item * rows (aoaos)

Takes an array reference which should contain one or more rows of data, where
each row is an array reference.

=item * header_row (bool)

If given a true value, the first row in the data will be interpreted as a header
row, and separated from the rest of the table with a ruled line.

=back

=head2 generate_table

Alias for L</table>, for compatibility with L<Text::Table::Tiny>.


=head1 SEE ALSO

L<Text::Table::Tiny>

Other text table modules listed in L<Acme::CPANModules::TextTable>. The selling
point of Text::Table::Sprintf is performance and light footprint (just about a
page of code that does not use I<any> module, core or otherwise).
