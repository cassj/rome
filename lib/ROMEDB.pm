package ROMEDB;
    
=head1 NAME 
    
 ROMEDB - DBIC Schema Class
  
=cut
    

# Note to self: draw me with something like: 
# dbicdeploy -Ilib ROMEDB ~/graphs GraphViz
# then mv ~/graphs/*.sql to *.png.

 # Our schema needs to inherit from 'DBIx::Class::Schema'
 use base qw/DBIx::Class::Schema/;
 
__PACKAGE__->load_classes({
     ROMEDB => [qw/
               Person
               PersonPending
               PersonDatafile

               Role
               PersonRole

               Workgroup
               PersonWorkgroup
               WorkgroupJoinRequest
               WorkgroupInvite

               Experiment
               ExperimentWorkgroup

               Factor
               FactorExperiment
               FactorWorkgroup
               Level  

               ContVar
               ContVarExperiment
               ContVarValue
               ContVarWorkgroup

               Datafile
               DatafilePending
               DatafileWorkgroup

               Outcome
               OutcomeLevel
               OutcomeContVarValue
               OutcomeDatafile

               Datatype
               DatatypeMetadata
               DatafileMetadata

	       Component
               Process
               ProcessAccepts
               ProcessCreates

               Job
               InDatafile
             
               Fieldset
               Parameter
               ParameterAllowedValue
               Argument

               Queue
               
      /]
});


  
1;
