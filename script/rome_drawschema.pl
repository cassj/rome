use SQL::Translator;

my $trans = new SQL::Translator(
    from => 'MySQL',
    to   => 'GraphViz',
    filename => 'sql/rome02.sql',
    producer_args => {
	out_file => 'schema.ps',
	output_type => 'ps',
	add_color => 0,
	show_constraints => 0,
	height=>20,
	width=>30,
	fontname=>'sans-serif',
	fontsize=>100,
	graphattrs=>{
	    layout=>'dot',
	    directed=>1,
	    concentrate=>1,
	    compress=>1,
	}
    }
    ) or die SQL::Translator->error; 

$trans->translate or die $trans->error;
