/* Define the necessary fieldsets. Set all the advanced ones to be toggled off initially */

INSERT INTO fieldset (name, process_name, process_component_name, process_component_version, position, legend, toggle) VALUES(
'primer3_params',
'single_primer_pair',
'primerdesign',
'0.0.1',
1,
'Parameters for Primer3',
1
);

INSERT INTO fieldset (name, process_name, process_component_name, process_component_version, position, legend, toggle) VALUES(
'primer3_params',
'tiling_primers',
'primerdesign',
'0.0.1',
1,
'Parameters for Primer3',
1
);

INSERT INTO fieldset (name, process_name, process_component_name, process_component_version, position, legend, toggle) VALUES(
'primer3_advanced_params',
'single_primer_pair',
'primerdesign',
'0.0.1',
2,
'Advanced Parameters for Primer3',
0
);

INSERT INTO fieldset (name, process_name, process_component_name, process_component_version, position, legend, toggle) VALUES(
'primer3_advanced_params',
'tiling_primers',
'primerdesign',
'0.0.1',
2,
'Advanced Parameters for Primer3',
0
);


INSERT INTO fieldset (name, process_name, process_component_name, process_component_version, position, legend, toggle) VALUES(
'unafold_params',
'single_primer_pair',
'primerdesign',
'0.0.1',
3,
'Parameters for UNAFold',
1
);

INSERT INTO fieldset (name, process_name, process_component_name, process_component_version, position, legend, toggle) VALUES(
'unafold_params',
'tiling_primers',
'primerdesign',
'0.0.1',
3,
'Parameters for UNAFold',
1
);

INSERT INTO fieldset (name, process_name, process_component_name, process_component_version, position, legend, toggle) VALUES(
'unafold_advanced_params',
'single_primer_pair',
'primerdesign',
'0.0.1',
4,
'Advanced Parameters for UNAFold',
0
);

INSERT INTO fieldset (name, process_name, process_component_name, process_component_version, position, legend, toggle) VALUES(
'unafold_advanced_params',
'tiling_primers',
'primerdesign',
'0.0.1',
4,
'Advanced Parameters for UNAFold',
0
);


INSERT INTO fieldset (name, process_name, process_component_name, process_component_version, position, legend, toggle) VALUES(
'blastn_params',
'single_primer_pair',
'primerdesign',
'0.0.1',
5,
'Parameters for Blastn',
1
);

INSERT INTO fieldset (name, process_name, process_component_name, process_component_version, position, legend, toggle) VALUES(
'blastn_params',
'tiling_primers',
'primerdesign',
'0.0.1',
5,
'Parameters for Blastn',
1
);


INSERT INTO fieldset (name, process_name, process_component_name, process_component_version, position, legend, toggle) VALUES(
'blastn_advanced_params',
'single_primer_pair',
'primerdesign',
'0.0.1',
6,
'Advanced Parameters for Blastn',
0
);

INSERT INTO fieldset (name, process_name, process_component_name, process_component_version, position, legend, toggle) VALUES(
'blastn_advanced_params',
'tiling_primers',
'primerdesign',
'0.0.1',
6,
'Advanced Parameters for Blastn',
0
);




/******************

 Parameters for Primer3

*******************/

/* 1. Included Region */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'included_region', 
  'Included Region', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Optional. Design primers in this subsequence (as start,length)',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  1,
  'primer3_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'included_region', 
  'Included Region', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Optional. Design primers in this subsequence (as start,length)',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  1,
  'primer3_params'
);





/* 2. Target Regions */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'target', 
  'Target', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Optional. Target region which must be covered by an amplicon (as start,length)',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  1,
  2,
  'primer3_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'target', 
  'Target', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Optional. Target region which must be covered by an amplicon (as start,length)',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  1,
  2,
  'primer3_params'
);





/*
  3: Excluded Regions
*/


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'exluded_region', 
  'Excluded Region', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Optional. Region which must not be overlapped by an amplicon (as start,length)',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  1,
  3,
  'primer3_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'exluded_region', 
  'Excluded Region', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Optional. Region which must not be overlapped by an amplicon (as start,length)',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  1,
  3,
  'primer3_params'
);




/* 4. Known left sequence (single only) */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'left_input', 
  'Known Left Primer', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Optional. Known sequence for the left primer',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  4,
  'primer3_params'
);

/* 5. Known right sequence (single only) */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'right_input', 
  'Known Right Primer', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Optional. Known sequence for the right primer',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  5,
  'primer3_params'
);



/* 6: Amplicon max tm */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'product_max_tm', 
  'Amplicon Maximum Tm', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Maximum melting temp for the amplicon',
  1, 
  'text',
  NULL,
  NULL,
  '1000000.0',
  0,
  6,
  'primer3_params'
);



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'product_max_tm', 
  'Amplicon Maximum Tm', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Maximum melting temp for an amplicon',
  1, 
  'text',
  NULL,
  NULL,
  '1000000.0',
  0,
  6,
  'primer3_params'
);


/* 7: Amplicon Min Tm*/



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'product_min_tm', 
  'Amplicon Minimum Tm', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Minimum melting temperature of the amplicon',
  1, 
  'text',
  NULL,
  NULL,
  '-1000000.0',
  0,
  7,
  'primer3_params'
);




INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'product_min_tm', 
  'Amplicon Minimum Tm', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Minimum melting temperature of the amplicon',
  1, 
  'text',
  NULL,
  NULL,
  '1000000.0',
  0,
  7,
  'primer3_params'
);


/* 8: optimal size */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'opt_size', 
  'Optimal Primer Size', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '20',
  0,
  8,
  'primer3_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'opt_size', 
  'Optimal Primer Size', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '20',
  0,
  8,
  'primer3_params'
);


/* 9: Min Primer Size */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'min_size', 
  'Minimum Primer Size', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '18',
  0,
  9,
  'primer3_params'
);



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'min_size', 
  'Minimum Primer Size', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '18',
  0,
  9,
  'primer3_params'
);

/* 10: Max Primer Size */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_size', 
  'Maximum Primer Size', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '27',
  0,
  10,
  'primer3_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_size', 
  'Maximum Primer Size', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '27',
  0,
  10,
  'primer3_params'
);







/* 11: optimum TM */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'opt_tm', 
  'Optimum Primer Tm', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'in degrees C',
  1, 
  'text',
  NULL,
  NULL,
  '60.0',
  0,
  11,
  'primer3_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'opt_tm', 
  'Optimum Primer Tm', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'in degrees C',
  1, 
  'text',
  NULL,
  NULL,
  '60.0',
  0,
  11,
  'primer3_params'
);


/* 12: Min Tm */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'min_tm', 
  'Minimum Primer Tm', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'in degrees C',
  1, 
  'text',
  NULL,
  NULL,
  '57.0',
  0,
  12,
  'primer3_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'min_tm', 
  'Minimum Primer Tm', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'in degrees C',
  1, 
  'text',
  NULL,
  NULL,
  '57.0',
  0,
  12,
  'primer3_params'
);


/* 13: Max Tm */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_tm', 
  'Maximum Primer Tm', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'in degrees C',
  1, 
  'text',
  NULL,
  NULL,
  '63.0',
  0,
  13,
  'primer3_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_tm', 
  'Maximum Primer Tm', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'in degrees C',
  1, 
  'text',
  NULL,
  NULL,
  '63.0',
  0,
  13,
  'primer3_params'
);


/* 14 max_diff_tm */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_diff_tm', 
  'Maximum Tm Difference', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'in degrees C. Maximum difference in Tm between primers',
  1, 
  'text',
  NULL,
  NULL,
  '100.0',
  0,
  14,
  'primer3_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_diff_tm', 
  'Maximum Tm Difference', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'in degrees C. Maximum difference in Tm between primers',
  1, 
  'text',
  NULL,
  NULL,
  '100.0',
  0,
  14,
  'primer3_params'
);



/* 15: product opt size */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'product_opt_size', 
  'Optimum Amplicon Size', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  15,
  'primer3_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'product_opt_size', 
  'Optimum Amplicon Size', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  15,
  'primer3_params'
);

/* 16: product min size */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'product_min_size', 
  'Minimum Amplicon Size', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  16,
  'primer3_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'product_min_size', 
  'Minimum Amplicon Size', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  16,
  'primer3_params'
);



/* 17: product max size */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'product_max_size', 
  'Maximum Amplicon Size', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  17,
  'primer3_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'product_max_size', 
  'Maximum Amplicon Size', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  17,
  'primer3_params'
);




/*
'PRIMER_PRODUCT_SIZE_RANGE'=>'(size range list, default 100-300) space separated list of product sizes eg <a>-<b> <x>-<y>',
Think i'll leave this out for now and used the product_size stuff. Less computationally efficient for P3, but it'll do

'PRIMER_DEFAULT_PRODUCT' => '(size range list, default 100-300)',
not sure what this is for.

'PRIMER_PICK_INTERNAL_OLIGO'=>'(boolean, default 0) if set, a hybridization probe will be selected',
No - this is a different task altogether and shouild be in a sep process if needed ,

  'PRIMER_SEQUENCE_QUALITY'=>'(quality list, default empty) A list of space separated integers with one per base. Could adapt a Phred object to this.',

Leaving this one out for the moment, although it is probably possible to retrieve this type of info
from the ensembl data.

'PRIMER_MISPRIMING_LIBRARY'=>'(string, optional) A file containing sequences to avoid amplifying. Should be fasta format, but see primer3 docs for constraints.',
'PRIMER_MAX_MISPRIMING'=>'(decimal,9999.99, default 12.00) Weighting for PRIMER_MISPRIMING_LIBRARY',
'PRIMER_PAIR_MAX_MISPRIMING'=>'(decimal,9999.99, default 24.00 Weighting for PRIMER_MISPRIMING_LIBRARY',

Leave this out and have a repmask component which adds masked regions as seqfeatures. These can then be avoided by
primer3 using the exclude_regions parameter
*/






/* Primer3 Advanced Params */


/* 1: GC Clamp */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'gc_clamp', 
  'GC Clamp', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Number of Gs and Cs at the 3 prime end',
  1, 
  'text',
  NULL,
  NULL,
  '0',
  0,
  1,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'gc_clamp', 
  'GC Clamp', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Number of Gs and Cs at the 3 prime end',
  1, 
  'text',
  NULL,
  NULL,
  '0',
  0,
  1,
  'primer3_advanced_params'
);



/* 2: min GC */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'min_gc', 
  'Minimum Percentage of GCs', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '20.0',
  0,	
  2,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'min_gc', 
  'Minimum Percentage of GCs', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '20.0',
  0,	
  2,
  'primer3_advanced_params'
);


/* 3: optimal GC */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'opt_gc', 
  'Optimum Percentage of GCs', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '50.0',
  0,	
  3,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'opt_gc', 
  'Optimum Percentage of GCs', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '50.0',
  0,	
  3,
  'primer3_advanced_params'
);

/* 4: Maximum GC*/


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_gc', 
  'Maximum Percentage of GCs', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '80.0',
  0,	
  4,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_gc', 
  'Maximum Percentage of GCs', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '80.0',
  0,	
  4,
  'primer3_advanced_params'
);




/* 5 Salt conc */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'salt_conc', 
  'mM Salt Concentration', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'For Tm Calculations',
  1, 
  'text',
  NULL,
  NULL,
  '50.0',
  0,	
  5,
  'primer3_advanced_params'
);



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'salt_conc', 
  'mM Salt Concentration', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'For Tm Calculations',
  1, 
  'text',
  NULL,
  NULL,
  '50.0',
  0,	
  5,
  'primer3_advanced_params'
);



/* 6: DNA Conc*/


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'dna_conc', 
  'mM DNA Concentration', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'For Tm Calculations',
  1, 
  'text',
  NULL,
  NULL,
  '50.0',
  0,	
  6,
  'primer3_advanced_params'
);



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'dna_conc', 
  'mM DNA Concentration', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'For Tm Calculations',
  1, 
  'text',
  NULL,
  NULL,
  '50.0',
  0,	
  6,
  'primer3_advanced_params'
);



/*7: Ns*/



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'num_ns_accepted', 
  'Maximum Number of Ns', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Maximum number of unknown bases (N) in a primer',
  1, 
  'text',
  NULL,
  NULL,
  '0',
  0,	
  7,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'num_ns_accepted', 
  'Maximum Number of Ns', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Maximum number of unknown bases (N) in a primer',
  1, 
  'text',
  NULL,
  NULL,
  '0',
  0,	
  7,
  'primer3_advanced_params'
);



/* 8: self_any */



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'self_any', 
  'Maximum Self Alignment', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Maximum alignment score for within and between primers when checking for hairpin loops',
  1, 
  'text',
  NULL,
  NULL,
  '8.00',
  0,	
  8,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'self_any', 
  'Maximum Self Alignment', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Maximum alignment score for within and between primers when checking for hairpin loops',
  1, 
  'text',
  NULL,
  NULL,
  '8.00',
  0,	
  8,
  'primer3_advanced_params'
);



/* 9: self-end*/



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'self_end', 
  'Maximum Self End', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Maximum alignment score for within and between primers when checking for primer dimers',
  1, 
  'text',
  NULL,
  NULL,
  '3.00',
  0,	
  9,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'self_end', 
  'Maximum Self End', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Maximum alignment score for within and between primers when checking for primer dimers',
  1, 
  'text',
  NULL,
  NULL,
  '3.00',
  0,	
  9,
  'primer3_advanced_params'
);


/* 10: max poly x*/

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_poly_x', 
  'Maximum Poly-X', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Maximum length of a mononucleotide repeat',
  1, 
  'text',
  NULL,
  NULL,
  '5',
  0,	
  10,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_poly_x', 
  'Maximum Poly-X', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Maximum length of a mononucleotide repeat',
  1, 
  'text',
  NULL,
  NULL,
  '5',
  0,	
  10,
  'primer3_advanced_params'
);



/* 11: liberal base? */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'liberal_base', 
  'Liberal Base?', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Allow use of IUPAC codes (just changes them to N)',
  1, 
  'checkbox',
  NULL,
  NULL,
  '0',
  0,	
  11,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'liberal_base', 
  'Liberal Base?', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Allow use of IUPAC codes (just changes them to N)',
  1, 
  'checkbox',
  NULL,
  NULL,
  '0',
  0,	
  11,
  'primer3_advanced_params'
);


/*12 num return*/

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'num_return', 
  'Return Number', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Number of primers to return',
  1, 
  'checkbox',
  NULL,
  NULL,
  '0',
  0,	
  12,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'num_return', 
  'Return Number', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Number of primers to return for each window',
  1, 
  'checkbox',
  NULL,
  NULL,
  '0',
  0,	
  12,
  'primer3_advanced_params'
);



/* 13 max end stability */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_end_stability', 
  'Maximum End Stabilty', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'For the 5 3 prime bases of a primer (larger value means more stable end)',
  1, 
  'text',
  NULL,
  NULL,
  '100.00',
  0,	
  13,
  'primer3_advanced_params'
);



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_end_stability', 
  'Maximum End Stabilty', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'For the 5 3 prime bases of a primer (larger value means more stable end)',
  1, 
  'text',
  NULL,
  NULL,
  '100.00',
  0,	
  13,
  'primer3_advanced_params'
);



/* 14: product opt tm */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'product_opt_tm', 
  'Optimum Amplicon Tm', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  14,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'product_opt_tm', 
  'Optimum Amplicon Tm', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  14,
  'primer3_advanced_params'
);


/* 15: wt tm gt */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_tm_gt', 
  'Weight Tm high', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for primers with Tm over Optimal Tm',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  15,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_tm_gt', 
  'Weight Tm high', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for primers with Tm over Optimal Tm',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  15,
  'primer3_advanced_params'
);



/* 16: wt tm lt */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_tm_lt', 
  'Weight Tm low', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for primers with Tm under Optimal Tm',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  16,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_tm_lt', 
  'Weight Tm low', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for primers with Tm under Optimal Tm',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  16,
  'primer3_advanced_params'
);


/* 17: wt size gt */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_size_gt', 
  'Weight Size high', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for primers longer than the optimal size',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  17,
  'primer3_advanced_params'
);



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_size_gt', 
  'Weight Size high', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for primers longer than the optimal size',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  17,
  'primer3_advanced_params'
);



/* 18: wt size lt */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_size_lt', 
  'Weight Size high', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for primers shorter than the optimal size',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  18,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_size_lt', 
  'Weight Size high', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for primers shorter than the optimal size',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  18,
  'primer3_advanced_params'
);



/* 19: wt gc perc gt */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_gc_percent_gt', 
  'Weight GC Percent High', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for primers with higher than optimal GC content',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  19,
  'primer3_advanced_params'
);




INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_gc_percent_gt', 
  'Weight GC Percent High', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for primers with higher than optimal GC content',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  19,
  'primer3_advanced_params'
);



/* 20: wt gc perc lt */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_gc_percent_lt', 
  'Weight GC Percent Low', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for primers with lower than optimal GC content',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  20,
  'primer3_advanced_params'
);



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_gc_percent_lt', 
  'Weight GC Percent Low', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for primers with lower than optimal GC content',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  20,
  'primer3_advanced_params'
);



/* 21: wt_compl_any */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_compl_any', 
  'Weight Any Complimentary', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for sequences with any complimentarity',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  21,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_compl_any', 
  'Weight Any Complimentary', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for sequences with any complimentarity',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  21,
  'primer3_advanced_params'
);



/* 22: wt_compl_end */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_compl_end', 
  'Weight End Complimentary', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for sequences with end complimentarity',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  22,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_compl_end', 
  'Weight End Complimentary', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for sequences with end complimentarity',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  22,
  'primer3_advanced_params'
);



/* 23: wt_num_ns */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_num_ns', 
  'Weight Num Ns', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for sequences with unknown bases',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  23,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_num_ns', 
  'Weight Num Ns', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Penalty weight for sequences with unknown bases',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  23,
  'primer3_advanced_params'
);


/* 24: wt_rep_sim */
INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_rep_sim', 
  'Weight Rep Sim', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  24,
  'primer3_advanced_params'
);
INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_rep_sim', 
  'Weight Rep Sim', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  24,
  'primer3_advanced_params'
);


/* 25: wt seq qual */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_seq_qual', 
  'Weight Sequence Quality', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  25,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_seq_qual', 
  'Weight Sequence Quality', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  25,
  'primer3_advanced_params'
);


/* 26: wt end qual */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_end_qual', 
  'Weight End Quality', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  26,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_end_qual', 
  'Weight End Quality', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  26,
  'primer3_advanced_params'
);


/* 27: wt pos penalty */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_pos_penalty', 
  'Weight Pos Penalty', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  27,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_pos_penalty', 
  'Weight Pos Penalty', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  27,
  'primer3_advanced_params'
);


/* 28: wt end stability */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_end_stability', 
  'Weight End Stability', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  28,
  'primer3_advanced_params'
);
INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_end_stability', 
  'Weight End Stability', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  28,
  'primer3_advanced_params'
);



/* 29: pair wt pr penalty */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_pr_penalty', 
  'Pair Weight Pr Penalty', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '1.0',
  0,
  29,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_pr_penalty', 
  'Pair Weight Pr Penalty', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '1.0',
  0,
  29,
  'primer3_advanced_params'
);


/* 30: pair_wt_io_penalty*/

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_io_penalty', 
  'Pair Weight IO Penalty', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  30,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_io_penalty', 
  'Pair Weight IO Penalty', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  30,
  'primer3_advanced_params'
);


/* 31: pair wt diff tm */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_diff_tm', 
  'Pair Weight Diff in Tm', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  31,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_diff_tm', 
  'Pair Weight Diff in Tm', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  31,
  'primer3_advanced_params'
);


/* 32: pair wt compl any */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_compl_any', 
  'Pair Weight Any Complimentary', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  32,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_compl_any', 
  'Pair Weight Any Complimentary', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  32,
  'primer3_advanced_params'
);



/* 33 pair_wt_compl_end */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_compl_end', 
  'Pair Weight End Complimentary', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  33,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_compl_end', 
  'Pair Weight End Complimentary', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  33,
  'primer3_advanced_params'
);



/* 34: pair wt product tm lt */ 


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_product_tm_lt', 
  'Pair Weight Product Tm Low', 
  'single_primer_oair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  34,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_product_tm_lt', 
  'Pair Weight Product Tm Low', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  34,
  'primer3_advanced_params'
);


/* 35: pair wt product tm gt */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_product_tm_gt', 
  'Pair Weight Product Tm High', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  35,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_product_tm_gt', 
  'Pair Weight Product Tm High', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  35,
  'primer3_advanced_params'
);


/* 36: pair wt product size gt */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_product_weight_gt', 
  'Pair Weight Product Size High', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  36,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_product_weight_gt', 
  'Pair Weight Product Size High', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  36,
  'primer3_advanced_params'
);


/* 37: pair wt product size lt */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_product_weight_lt', 
  'Pair Weight Product Size Low', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  37,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_product_weight_lt', 
  'Pair Weight Product Size Low', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  37,
  'primer3_advanced_params'
);


/* 38: pair_wt_rep_sim */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_rep_sim', 
  'Pair Weight Rep Sim', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  38,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_rep_sim', 
  'Pair Weight Rep Sim', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  38,
  'primer3_advanced_params'
);


/* 39 inside_penalty */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'inside_penalty', 
  'Inside Penalty', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '-1.0',
  0,
  39,
  'primer3_advanced_params'
);



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'inside_penalty', 
  'Inside Penalty', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '-1.0',
  0,
  39,
  'primer3_advanced_params'
);




/* 40 outside penalty */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'outside_penalty', 
  'Outside Penalty', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  40,
  'primer3_advanced_params'
);



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'outside_penalty', 
  'Outside Penalty', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0.0',
  0,
  40,
  'primer3_advanced_params'
);


/* 41 lib ambiguity codes consensus */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'lib_ambiguity_codes_consensus', 
  'Lib Ambiguity Codes Consensus', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  41,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'lib_ambiguity_codes_consensus', 
  'Lib Ambiguity Codes Consensus', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  41,
  'primer3_advanced_params'
);


/* 42 max_template_mispriming */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_template_mispriming', 
  'Maximum Template Mispriming', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '-1.00',
  0,
  42,
  'primer3_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'max_template_mispriming', 
  'Maximum Template Mispriming', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '-1.00',
  0,
  42,
  'primer3_advanced_params'
);


/* 43 pair_max_template_misprimint */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_max_template_mispriming', 
  'Pair Maximum Template Mispriming', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '-1.00',
  0,
  43,
  'primer3_advanced_params'
);



INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_max_template_mispriming', 
  'Pair Maximum Template Mispriming', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '-1.00',
  0,
  43,
  'primer3_advanced_params'
);



/* 44: pair_wt_template_mispriming */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_template_mispriming', 
  'Pair Weight Template Mispriming', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0',
  0,
  43,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'pair_wt_template_mispriming', 
  'Pair Weight Template Mispriming', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0',
  0,
  43,
  'primer3_advanced_params'
);

/* 44 : wt_template_mispriming */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_template_mispriming', 
  'Weight Template Mispriming', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0',
  0,
  44,
  'primer3_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wt_template_mispriming', 
  'Weight Template Mispriming', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0',
  0,
  44,
  'primer3_advanced_params'
);







/*
  'PRIMER_FIRST_BASE_INDEX'=>'(int, default 0) Index of the first base. Do not change this or allow it to be changed, as we will have to mess with subseqs and whatnot.',

  Not using this
*/



/*
  'PRIMER_TASK'=>'(string, default pick_pcr_primers) Choose from pick_pcr_primers, pick_pcr_primers_and_hyb_probe, pick_left_only, pick_right_only, pick_hyb_probe_only',

  don't need this - just 'pick_pcr_primers'
*/



/*
  'PRIMER_INTERNAL_OLIGO_MAX_TEMPLATE_MISHYB' => '(decimal 9999.99, default 12.00)',
  ignoring internal oligo settings

*/


/*
  'PRIMER_MIN_QUALITY'=>'(int, default 0) Minimum sequence quality calculated from PRIMER_SEQUENCE_QUALITY',
  'PRIMER_MIN_END_QUALITY'=>'(int, default 0) Minimum sequence quality calculated from PRIMER_SEQUENCE_QUALITY at 5 prime 5 bases',
  'PRIMER_QUALITY_RANGE_MIN'=>'(int, default 0) Minimum sequence quality calculated from PRIMER_SEQUENCE_QUALITY',
  'PRIMER_QUALITY_RANGE_MAX'=>'(int, default 100) Maximum sequence quality calculated from PRIMER_SEQUENCE_QUALITY',
  not using any of these yet either

*/


/*
  'PRIMER_INTERNAL_OLIGO_EXCLUDED_REGION'=>'(interval list, default empty) Internal oligos must ignore these regions',
  'PRIMER_INTERNAL_OLIGO_INPUT'=>'(nucleotide sequence, default empty) Known sequence of an internal oligo',
  'PRIMER_INTERNAL_OLIGO_OPT_SIZE'=>'(int, default 20)',
  'PRIMER_INTERNAL_OLIGO_MIN_SIZE'=>'(int, default 18)',
  'PRIMER_INTERNAL_OLIGO_MAX_SIZE'=>'(int, default 27)',
  'PRIMER_INTERNAL_OLIGO_OPT_TM'=>'(float, default 60.0 degrees C)',
  'PRIMER_INTERNAL_OLIGO_OPT_GC_PERCENT'=>'(float, default 50.0%)',
  'PRIMER_INTERNAL_OLIGO_MIN_TM'=>'(float, default 57.0 degrees C)',
  'PRIMER_INTERNAL_OLIGO_MAX_TM'=>'(float, default 63.0 degrees C)',
  'PRIMER_INTERNAL_OLIGO_MIN_GC'=>'(float, default 20.0%)',
  'PRIMER_INTERNAL_OLIGO_MAX_GC'=>'(float, default 80.0%)',
  'PRIMER_INTERNAL_OLIGO_SALT_CONC'=>'(float, default 50.0 mM)',
  'PRIMER_INTERNAL_OLIGO_DNA_CONC'=>'(float, default 50.0 nM)',
  'PRIMER_INTERNAL_OLIGO_SELF_ANY'=>'(decimal 9999.99, default 12.00)',
  'PRIMER_INTERNAL_OLIGO_MAX_POLY_X'=>'(int, default 5)',
  'PRIMER_INTERNAL_OLIGO_SELF_END'=>'(decimal 9999.99, default 12.00)',
  'PRIMER_INTERNAL_OLIGO_MISHYB_LIBRARY'=>'(string, optional)',
  'PRIMER_INTERNAL_OLIGO_MAX_MISHYB'=>'(decimal,9999.99, default 12.00)',
  'PRIMER_INTERNAL_OLIGO_MIN_QUALITY'=>'(int, default 0)',
  'PRIMER_IO_WT_TM_GT'=>'(float, default 1.0)',
  'PRIMER_IO_WT_TM_LT'=>'(float, default 1.0)',
  'PRIMER_IO_WT_GC_PERCENT_GT'=>'(float, default 1.0)',
  'PRIMER_IO_WT_GC_PERCENT_LT'=>'(float, default 1.0)',
  'PRIMER_IO_WT_SIZE_LT'=>'(float, default 1.0)',
  'PRIMER_IO_WT_SIZE_GT'=>'(float, default 1.0)',
  'PRIMER_IO_WT_COMPL_ANY'=>'(float, default 0.0)',
  'PRIMER_IO_WT_COMPL_END'=>'(float, default 0.0)',
  'PRIMER_IO_WT_NUM_NS'=>'(float, default 0.0)',
  'PRIMER_IO_WT_REP_SIM'=>'(float, default 0.0)',
  'PRIMER_IO_WT_SEQ_QUAL'=>'(float, default 0.0)',
  'PRIMER_IO_WT_END_QUAL'=>'(float, default 0.0)',
Ignore internal oligo things as we're not using them for these processes

*/





/**************

UNAFold Params

***************/
%mfe_params = (
		  NA        => 'DNA',
		  tmin      => 60,
		  tmax      => 60,
		  sodium    => 0.05,
		  magnesium => 0.003,

/* 1: NA */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'NA', 
  'Nucleic Acid', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0',
  0,
  1,
  'unafold_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'NA', 
  'Nucleic Acid', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '0',
  0,
  1,
  'unafold_params'
);

/* 2: tmin */
INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'tmin', 
  'tmin', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Lowest temperature to use',
  1, 
  'text',
  NULL,
  NULL,
  '60',
  0,
  2,
  'unafold_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'tmin', 
  'tmin', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Lowest temperature to use',
  1, 
  'text',
  NULL,
  NULL,
  '60',
  0,
  2,
  'unafold_params'
);

/* 3: tmax */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'tmax', 
  'tmax', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Highest temperature to use',
  1, 
  'text',
  NULL,
  NULL,
  '60',
  0,
  3,
  'unafold_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'tmax', 
  'tmax', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Highest temperature to use',
  1, 
  'text',
  NULL,
  NULL,
  '60',
  0,
  3,
  'unafold_params'
);

/* 4: sodium */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'sodium', 
  'sodium', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Molar Sodium Concentration',
  1, 
  'text',
  NULL,
  NULL,
  '0.05',
  0,
  4,
  'unafold_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'sodium', 
  'sodium', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Molar Sodium Concentration',
  1, 
  'text',
  NULL,
  NULL,
  '0.05',
  0,
  4,
  'unafold_params'
);



/* 5: magnesium */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'magnesium', 
  'magnesium', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Molar Magnesium Concentration',
  1, 
  'text',
  NULL,
  NULL,
  '0.003',
  0,
  5,
  'unafold_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'magnesium', 
  'magnesium', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Molar Magnesium Concentration',
  1, 
  'text',
  NULL,
  NULL,
  '0.003',
  0,
  5,
  'unafold_params'
);

/**************

UNAFold Advanced Params

**************/

/* 1: tinc */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'tinc', 
  'Temperature Increment', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  1,
  'unafold_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'tinc', 
  'Temperature Increment', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  '1',
  0,
  1,
  'unafold_advanced_params'
);

/* 2: Polymer */ 


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'polymer', 
  'Polymer', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Use salt corrections for polymers instead of oligomers',
  1, 
  'text',
  NULL,
  NULL,
  '0',
  0,
  2,
  'unafold_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'polymer', 
  'Polymer', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Use salt corrections for polymers instead of oligomers',
  1, 
  'text',
  NULL,
  NULL,
  '0',
  0,
  2,
  'unafold_advanced_params'
);


/* 3: suffix */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'suffix', 
  'Suffix', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Use energy rules with this suffix. Overrides tmin, tinc, tmax, sodium, magneium, polymer',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  3,
  'unafold_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'suffix', 
  'Suffix', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Use energy rules with this suffix. Overrides tmin, tinc, tmax, sodium, magneium, polymer',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  3,
  'unafold_advanced_params'
);


/* 4: Prohibit */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'prohibit', 
  'Prohibit', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'as i,j,[k]. Prohibit all base pairs in the helix from i to i+k-1 j-k+1. See UNAfold Documentation',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  4,
  'unafold_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'prohibit', 
  'Prohibit', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'as i,j,[k]. Prohibit all base pairs in the helix from i to i+k-1 j-k+1. See UNAfold Documentation',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  4,
  'unafold_advanced_params'
);


/* 5: force */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'force', 
  'force', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'as i,j,[k]. Force all base pairs in the helix from i to i+k-1 j-k+1 to be double stranded. See UNAfold Documentation',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  5,
  'unafold_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'force', 
  'force', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'as i,j,[k]. Force all base pairs in the helix from i to i+k-1 j-k+1 to be double stranded. See UNAfold Documentation',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  5,
  'unafold_advanced_params'
);


/* 6: energyOnly */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'energyOnly', 
  'Energy Only', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Skips computation of structure (see UNAFold docs)',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  6,
  'unafold_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'energyOnly', 
  'Energy Only', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Skips computation of structure (see UNAFold docs)',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  6,
  'unafold_advanced_params'
);


/* 7 noisolate */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'noisolate', 
  'No Isolate', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Prohibits isolated base pairs',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  7,
  'unafold_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'noisolate', 
  'No Isolate', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Prohibits isolated base pairs',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  7,
  'unafold_advanced_params'
);

/*8: mfold */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'mfold', 
  'As MFold', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Multiple suboptimal tracebacks in the style of Mfold. As P,W,MAX (see UnaFold docs)',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  8,
  'unafold_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'mfold', 
  'As MFold', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Multiple suboptimal tracebacks in the style of Mfold. As P,W,MAX (see UnaFold docs)',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  8,
  'unafold_advanced_params'
);

/* 9: maxbp */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'maxbp', 
  'Maximum base Pair', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Bases further apart than this cannot pair',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  9,
  'unafold_advanced_params'
);

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'maxbp', 
  'Maximum base Pair', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Bases further apart than this cannot pair',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  9,
  'unafold_advanced_params'
);

/* 10: maxloop */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'maxloop', 
  'Maximum Loop', 
  'single_primer_pair',
  'primerdesign', 
  '0.0.1', 
  'Maximum size of bulge/interior loops',
  1, 
  'text',
  NULL,
  NULL,
  '30',
  0,
  10,
  'unafold_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'maxloop', 
  'Maximum Loop', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Maximum size of bulge/interior loops',
  1, 
  'text',
  NULL,
  NULL,
  '30',
  0,
  10,
  'unafold_advanced_params'
);

/* 11: nodangle */


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'nodangle', 
  'No Dangle', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Remove single-base stacking from consideration',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  11,
  'unafold_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'nodangle', 
  'No Dangle', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Remove single-base stacking from consideration',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  11,
  'unafold_advanced_params'
);

/* 12: simple */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'simple', 
  'Simple', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'Use constant multi-branch penalty rather than the affine default',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  12,
  'unafold_advanced_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'simple', 
  'Simple', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'Use constant multi-branch penalty rather than the affine default',
  1, 
  'text',
  NULL,
  NULL,
  NULL,
  0,
  12,
  'unafold_advanced_params'
);


/**************

 Blastn Params

***************/

/* 1: Expect */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'expect', 
  'Expect', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  100,
  0,
  1,
  'blastn_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'expect', 
  'Expect', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  100,
  0,
  1,
  'blastn_params'
);


/* 2: wordsize */

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wordsize', 
  'Wordsize', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  11,
  0,
  2,
  'blastn_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'wordsize', 
  'Wordsize', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  '',
  1, 
  'text',
  NULL,
  NULL,
  11,
  0,
  1,
  'blastn_params'
);


/* 3: database*/

INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'database', 
  'Database', 
  'single_primer_pair', 
  'primerdesign', 
  '0.0.1', 
  'to blast against.',
  1, 
  'checkbox_group',
  NULL,
  NULL,
  NULL,
  1,
  3,
  'blastn_params'
);


INSERT INTO parameter (name, display_name, process_name, process_component_name, process_component_version,description, optional, form_element_type, min_value, max_value, default_value, is_multiple, position, fieldset)
VALUES (
  'database', 
  'Database', 
  'tiling_primers', 
  'primerdesign', 
  '0.0.1', 
  'to blast against.',
  1, 
  'checkbox_group',
  NULL,
  NULL,
  NULL,
  1,
  3,
  'blastn_params'
);






INSERT INTO parameter_allowed_value (parameter_name, parameter_process_name, parameter_process_component_name, parameter_process_component_version, value) VALUES (
  'database',
  'single_primer_pair',
  'primerdesign',
  '0.0.1',
  'nr'
);

INSERT INTO parameter_allowed_value (parameter_name, parameter_process_name, parameter_process_component_name, parameter_process_component_version, value) VALUES (
  'database',
  'tiling_primers',
  'primerdesign',
  '0.0.1',
  'nr'
);


INSERT INTO parameter_allowed_value (parameter_name, parameter_process_name, parameter_process_component_name, parameter_process_component_version, value) VALUES (
  'database',
  'single_primer_pair',
  'primerdesign',
  '0.0.1',
  'refseq_genomic'
);

INSERT INTO parameter_allowed_value (parameter_name, parameter_process_name, parameter_process_component_name, parameter_process_component_version, value) VALUES (
  'database',
  'tiling_primers',
  'primerdesign',
  '0.0.1',
  'refseq_genomic'
);


INSERT INTO parameter_allowed_value (parameter_name, parameter_process_name, parameter_process_component_name, parameter_process_component_version, value) VALUES (
  'database',
  'single_primer_pair',
  'primerdesign',
  '0.0.1',
  'refseq_transcript'
);

INSERT INTO parameter_allowed_value (parameter_name, parameter_process_name, parameter_process_component_name, parameter_process_component_version, value) VALUES (
  'database',
  'tiling_primers',
  'primerdesign',
  '0.0.1',
  'refseq_transcript'
);
