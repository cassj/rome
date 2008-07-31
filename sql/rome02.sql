      /* select your database */
      
       use rome_test; 

       /*Need to unset the FK checks so we can define
         them at the same time as the table. I can't
         keep track of them when they're all done 
         separately after the tables have been created
       */
       SET FOREIGN_KEY_CHECKS=0;

       /* User details */
        create table person(
 	username CHAR(50) NOT NULL,
 	forename CHAR(30),
 	surname CHAR(30),
 	institution CHAR(50),
 	address CHAR(100),
 	password VARCHAR(50) NOT NULL,
 	email VARCHAR(50) NOT NULL,
  	experiment_name VARCHAR(50),
	experiment_owner CHAR(50),
        datafile_name VARCHAR(50),
 	created DATE,
        active INT,
        data_dir VARCHAR(255),
        upload_dir VARCHAR(255),
	PRIMARY KEY (username),
	FOREIGN KEY (experiment_name, experiment_owner)
            REFERENCES experiment(name, owner)
            ON DELETE SET NULL,
        FOREIGN KEY (datafile_name)
            REFERENCES datafile(name)
            ON DELETE SET NULL
 	) ENGINE=INNODB;

        /* Entries in here are deleted as soon as a user has been approved */ 	
 	create table person_pending(
 	username CHAR(50) NOT NULL,
 	email_id TEXT NOT NULL,
 	user_approved ENUM('0','1'),
 	admin_approved ENUM('0','1'),
        PRIMARY KEY (username),
        FOREIGN KEY (username) 
           REFERENCES person(username)
           ON DELETE CASCADE
 	) ENGINE=INNODB;

  	/*Roles a user can have - Controls access to components*/
 	create table role (
 	name VARCHAR(100) NOT NULL,
 	description TEXT,
	PRIMARY KEY (name)
 	) ENGINE=INNODB; 	

        /* Mapping between person and role */
  	create table person_role (
 	person CHAR(50) NOT NULL,
 	role VARCHAR(100) NOT NULL,
        PRIMARY KEY(person,role),
        FOREIGN KEY (person) REFERENCES person(username) ON DELETE CASCADE,
        FOREIGN KEY (role) REFERENCES role(name) ON DELETE CASCADE
 	) ENGINE=INNODB ;

        /*Workgroups of which user can be a member - Controls access to data*/
        create table workgroup(
        name VARCHAR(100) NOT NULL,
        description TEXT,
        leader CHAR(50) NOT NULL,
        PRIMARY KEY (name),
	FOREIGN KEY (leader) REFERENCES person(username)
        ) ENGINE=INNODB;

        /* Mapping between person and workgroup*/
        create table person_workgroup(
        person CHAR(50) NOT NULL,
        workgroup VARCHAR(100) NOT NULL,
	PRIMARY KEY (person, workgroup),
	FOREIGN KEY (person) REFERENCES person(username) ON DELETE CASCADE,
	FOREIGN KEY (workgroup) REFERENCES workgroup(name) ON DELETE CASCADE
        ) ENGINE=INNODB;

	/* Managing join requests for workgroups */
	create table workgroup_join_request(
        person CHAR(50) NOT NULL,
        workgroup VARCHAR(100) NOT NULL,
	PRIMARY KEY (person, workgroup),
	FOREIGN KEY (person) REFERENCES person(username) ON DELETE CASCADE,
	FOREIGN KEY (workgroup) REFERENCES workgroup(name) ON DELETE CASCADE
	) ENGINE=INNODB;
	
	/* Managing invitations to workgroups */
	create table workgroup_invite(
        person CHAR(50) NOT NULL,
        workgroup VARCHAR(100) NOT NULL,
	PRIMARY KEY (person, workgroup),
	FOREIGN KEY (person) REFERENCES person(username) ON DELETE CASCADE,
	FOREIGN KEY (workgroup) REFERENCES workgroup(name) ON DELETE CASCADE
	) ENGINE=INNODB;
	

        /* Datatypes. Generally R/Bioconductor classes, like expressionSet. 
           This is the information used to determine whether the output of 
           one component can be used as input to another component.*/
 	create table datatype(
 	name VARCHAR(50) NOT NULL,
 	description VARCHAR(100),
        is_image BOOLEAN NOT NULL DEFAULT 0,
        is_export BOOLEAN NOT NULL DEFAULT 0,
        default_blurb TEXT,
	PRIMARY KEY(name)
 	) ENGINE=INNODB;

        /* Define any inheritance relationships between datatypes in here, for
           example AffyBatch is an exprSet, or QCPlot isa ImageFile. */	
 	create table datatype_relationship(
  	child VARCHAR(50) NOT NULL REFERENCES datatype(name),
 	parent VARCHAR(50) NOT NULL REFERENCES datatype(name),
        PRIMARY KEY(child,parent)
 	)engine=innodb;
	
	/* Defines metatdata that instances of a datatype should export to the DB */
	create table datatype_metadata(
	name VARCHAR(50) NOT NULL,
	datatype_name VARCHAR(50) NOT NULL,
	description TEXT,
	optional BOOLEAN,
	PRIMARY KEY (name, datatype_name),
	FOREIGN KEY (datatype_name) REFERENCES datatype(name) ON DELETE CASCADE
	) ENGINE=INNODB;

	/**/
	create table datafile_metadata(
	datafile_name VARCHAR(50) NOT NULL,
	datafile_experiment_name VARCHAR(50) NOT NULL,
	datafile_experiment_owner CHAR(50) NOT NULL,
	datatype_metadata_name VARCHAR(50) NOT NULL,
	datatype_metadata_datatype_name VARCHAR(50) NOT NULL,
	value TEXT,
	PRIMARY KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner, datatype_metadata_name, datatype_metadata_datatype_name),
	FOREIGN KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner) 
          REFERENCES datafile(name, experiment_name, experiment_owner) ON DELETE CASCADE,
	FOREIGN KEY (datatype_metadata_name, datatype_metadata_datatype_name) 
          REFERENCES datatype_metadata(name, datatype_name) ON DELETE CASCADE
	) ENGINE=INNODB;


        /* DEPRECATED 
 	create table export_method(
 	name VARCHAR(50) NOT NULL,
 	description TEXT,
        extension VARCHAR(10),
	PRIMARY KEY (name)
 	) ENGINE=INNODB;
	*/
        /* Export methods for datatypes are actually defined in R, and perl isn't
           aware of them. I decided it was easier to keep a note of them in the 
           database, rather than perl calling R every time it wanted a list of 
           export possibilities.
	   DEPRECATED
 	create table datatype_export_method(
  	datatype VARCHAR(50) NOT NULL,
 	export_method VARCHAR(50) NOT NULL,
        PRIMARY KEY (datatype, export_method) ,
	FOREIGN KEY (datatype) REFERENCES datatype(name) ON DELETE CASCADE,
	FOREIGN KEY (export_method) REFERENCES export_method(name) ON DELETE CASCADE
	) ENGINE=INNODB;
	*/

        /* Processes correspond to individual R templates */
 	create table process(
 	name VARCHAR(50) NOT NULL,
 	component_name VARCHAR(50) NOT NULL,
	component_version VARCHAR (20) NOT NULL,
 	tmpl_file VARCHAR(50),
 	description TEXT,
	processor CHAR(20),
	display_name VARCHAR(50),
	PRIMARY KEY (name, component_name, component_version),
	FOREIGN KEY (component_name, component_version)
	   REFERENCES component(name, version)
	   ON DELETE CASCADE
 	) ENGINE=INNODB;


        /* What datatypes can the process accept? The required field can be 
           defines whether a file of this datatype is required for the process, 
           the required_number defines how may of these files are required for the 
           process. require_number will be ignored if required is false.
           To be honest, this is still pretty unstable. Unless you're feeling brave
           I'd stick to components which only require one datafile of one datatype.

	   Names in accepts and creates refer to the name used in the process template
	   to refer to this file.
        */
 	create table process_accepts(
  	process_name VARCHAR(50) NOT NULL,
	process_component_name VARCHAR(50) NOT NULL,
	process_component_version VARCHAR (20) NOT NULL,
 	datatype_name VARCHAR(50) NOT NULL,
	name VARCHAR(50) NOT NULL,
        PRIMARY KEY (process_name, process_component_name, process_component_version, datatype_name, name),
	FOREIGN KEY (process_name, process_component_name, process_component_version) 
           REFERENCES process(name, component_name, component_version) 
           ON DELETE CASCADE,
	FOREIGN KEY (datatype_name) REFERENCES datatype(name)
 	) ENGINE=INNODB;

        /* The datatype(s) of the datafile this process creates. */
 	create table process_creates(
 	process_name VARCHAR(50) NOT NULL,
	process_component_name VARCHAR(50) NOT NULL,
	process_component_version VARCHAR (20) NOT NULL,
 	datatype_name VARCHAR(50) NOT NULL,
	name VARCHAR(50) NOT NULL,
	suffix VARCHAR(10),
	is_image BOOLEAN DEFAULT 0,
	is_export BOOLEAN DEFAULT 0,
	is_report BOOLEAN DEFAULT 0,
        PRIMARY KEY (process_name, process_component_name, process_component_version, datatype_name, name),
	FOREIGN KEY (process_name, process_component_name, process_component_version) 
           REFERENCES process(name, component_name, component_version) 
           ON DELETE CASCADE,
 	FOREIGN KEY (datatype_name) REFERENCES datatype(name)
 	) ENGINE=INNODB;

        /* Registered components. The idea (though not implemented yet) is
           that you'll be able to run multiple ROME instances with different 
           components, from the same ROME directory. */
 	create table component(
 	name VARCHAR(50) NOT NULL,
	version VARCHAR (20) NOT NULL,
 	always_active BOOLEAN NOT NULL DEFAULT '0',
	description VARCHAR(255),
	installed BOOLEAN NOT NULL DEFAULT '0',
	PRIMARY KEY (name, version )
 	) ENGINE=INNODB;

        /* Link components to processes. Generally a component should only
           need to run a single process, but occasionally you need more than one 

        Nah, just have a link to the component table in process.
 	create table component_process
 	component VARCHAR(50) NOT NULL,
 	process VARCHAR(50) NOT NULL,
        PRIMARY KEY (component,process),
	FOREIGN KEY (component) REFERENCES component(name) ON DELETE CASCADE,
	FOREIGN KEY (process) REFERENCES process(name) ON DELETE CASCADE
	) ENGINE=INNODB; */

        /* Parameters that are used by components. This lets us auto-generate a lot
           of the interface and keep track of exactly what has been done to generate
           a given datafile */
 	create table parameter(
 	name VARCHAR(50) NOT NULL,
	display_name VARCHAR(100) NOT NULL,
	process_name VARCHAR(50) NOT NULL,
	process_component_name VARCHAR(50) NOT NULL,
	process_component_version VARCHAR (20) NOT NULL,
 	description VARCHAR(100),
	optional BOOLEAN NOT NULL DEFAULT 0,
	form_element_type ENUM('text','textarea','checkbox','checkbox_group','select', 'outcome_list') NOT NULL,
	min_value NUMERIC,
	max_value NUMERIC,
	default_value VARCHAR(255),
	is_multiple BOOLEAN NOT NULL DEFAULT 0;
	PRIMARY KEY (name, process_name, process_component_name, process_component_version),
	FOREIGN KEY (process_name, process_component_name, process_component_version) 
           REFERENCES process(name, component_name, component_version) 
	   ON DELETE CASCADE
 	) ENGINE=INNODB;

	/* Allowed values for a parameter. These are just used to generate param forms
	   and are not necessary for every type of parameter. 
	   Constraints on parameter values should go in the controller
	*/
	create table parameter_allowed_value(
 	parameter_name VARCHAR(50) NOT NULL,
	parameter_process_name VARCHAR(50) NOT NULL,
	parameter_process_component_name VARCHAR(50) NOT NULL,
	parameter_process_component_version VARCHAR (20) NOT NULL,
	value VARCHAR(255) NOT NULL,
	PRIMARY KEY (parameter_name, parameter_process_name, parameter_process_component_name, parameter_process_component_version, value),
	FOREIGN KEY (parameter_name, parameter_process_name, parameter_process_component_name, parameter_process_component_version)
	  REFERENCES parameter(name, process_name, process_component_name, process_component_version)
	  ON DELETE CASCADE
	) ENGINE=INNODB;


	/* Arguments are instances of parameters - ie values given to an actual job*/
	create table argument(
	jid INT NOT NULL REFERENCES job(id),
	parameter_name VARCHAR(50) NOT NULL,
	parameter_process_name VARCHAR(50) NOT NULL,
	parameter_process_component_name VARCHAR(50) NOT NULL,
	parameter_process_component_version VARCHAR (20) NOT NULL,
	value VARCHAR(255),
	PRIMARY KEY (jid, parameter_name, parameter_process_name, parameter_process_component_name, parameter_process_component_version, value),
	FOREIGN KEY (parameter_name, parameter_process_name, parameter_process_component_name, parameter_process_component_version)
           REFERENCES parameter(name, process_name, process_component_name, process_component_version)
           ON DELETE CASCADE,
	FOREIGN key (jid)
	   REFERENCES job(id)
	   ON DELETE CASCADE
	) ENGINE=INNODB;


 	/*Stores all the datafiles
        removed and replaced by job_id process VARCHAR(50) REFERENCES process(name)*/

 	create table datafile(
 	name VARCHAR(50),
 	experiment_name VARCHAR(50),
 	experiment_owner CHAR(50),
 	path VARCHAR(100) NOT NULL,
 	datatype varchar(50) NOT NULL,
	status ENUM('private','shared','public'),
	job_id INT,
	is_root BOOLEAN NOT NULL DEFAULT 0,
	PRIMARY KEY (name, experiment_name, experiment_owner),
	FOREIGN KEY (experiment_name, experiment_owner)
	    REFERENCES experiment(name,owner)
	    ON DELETE CASCADE,
	FOREIGN KEY (datatype) 
            REFERENCES datatype(name),
	FOREIGN KEY (job_id)
            REFERENCES job(id)
 	) ENGINE=INNODB;


	/* for currently selected datafiles */
	create table person_datafile(
	person CHAR(50) NOT NULL,
	datafile_name VARCHAR(50) NOT NULL,
	datafile_experiment_name VARCHAR(50),
	datafile_experiment_owner VARCHAR(50),
	PRIMARY KEY (person, datafile_name, datafile_experiment_name, datafile_experiment_owner),
	FOREIGN KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner)
          REFERENCES datafile(name, experiment_name, experiment_owner)
          ON DELETE CASCADE,
	FOREIGN KEY (person)
          REFERENCES person(username)
	  ON DELETE CASCADE
	) ENGINE=INNODB;


        /* for sharing datafiles */
        create table datafile_workgroup(
 	datafile_name VARCHAR(50) NOT NULL,
 	datafile_experiment_name VARCHAR(50)NOT NULL,
 	datafile_experiment_owner CHAR(50) NOT NULL,
        workgroup VARCHAR(100) NOT NULL,
        PRIMARY KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner, workgroup),
	FOREIGN KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner)
	    REFERENCES datafile(name, experiment_name, experiment_owner),
	FOREIGN KEY (workgroup) 
            REFERENCES workgroup(name)
            ON DELETE CASCADE
	) ENGINE=INNODB;

        /* keeps track of the relationships between datafiles.
           this is deleted if you delete the child, but not the parent
           so always delete from the children back up to the root.
         */
 	create table datafile_relationship(
 	parent_datafile_name VARCHAR(50) NOT NULL,
 	parent_datafile_experiment_name VARCHAR(50)NOT NULL,
 	parent_datafile_experiment_owner CHAR(50) NOT NULL,
 	child_datafile_name VARCHAR(50) NOT NULL,
 	child_datafile_experiment_name VARCHAR(50)NOT NULL,
 	child_datafile_experiment_owner CHAR(50) NOT NULL,
        PRIMARY KEY (parent_datafile_name, parent_datafile_experiment_name, parent_datafile_experiment_owner, child_datafile_name, child_datafile_experiment_name, child_datafile_experiment_owner),
	FOREIGN KEY (parent_datafile_name, parent_datafile_experiment_name, parent_datafile_experiment_owner)
           REFERENCES datafile(name, experiment_name, experiment_owner),
	FOREIGN KEY (child_datafile_name, child_datafile_experiment_name, child_datafile_experiment_owner)
           REFERENCES datafile(name, experiment_name, experiment_owner)
           ON DELETE CASCADE
 	) ENGINE=INNODB;


 	/* this is an extension of the datafile table
           allows us to store placeholder datafiles while processes are being run,
           which means we can queue up processes on the placeholder datafile. */
 	create table datafile_pending(
 	datafile_name VARCHAR(50) NOT NULL REFERENCES datafile(name),
 	datafile_experiment_name VARCHAR(50)NOT NULL REFERENCES datafile(experiment_name),
 	datafile_experiment_owner CHAR(50) NOT NULL REFERENCES datafile(experiment_owner),
        PRIMARY KEY(datafile_name, datafile_experiment_name, datafile_experiment_owner),
	FOREIGN KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner)
          REFERENCES datafile(name, experiment_name, experiment_owner)
          ON DELETE CASCADE
 	) ENGINE=INNODB;


	create table job(
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	owner CHAR(50),
	experiment_name VARCHAR(50) NOT NULL,
	experiment_owner CHAR(50) NOT NULL,
	process_name VARCHAR(50) NOT NULL,
	process_component_name VARCHAR(50) NOT NULL,
	process_component_version VARCHAR (20) NOT NULL,
	completed BOOLEAN DEFAULT 0,
	log VARCHAR(255),
	script VARCHAR(255),
	is_root BOOLEAN NOT NULL DEFAULT 0,
	FOREIGN KEY (owner)
           REFERENCES person(username),
	FOREIGN KEY (experiment_name, experiment_owner) 
	   REFERENCES experiment(name,owner)
           ON DELETE CASCADE,
        FOREIGN KEY (process_name, process_component_name, process_component_version) 
	   REFERENCES process(name, component_name, component_version)
	) ENGINE=INNODB;

	create table in_datafile(
	jid INT NOT NULL,
	datafile_name VARCHAR(50),
	datafile_experiment_name VARCHAR(50),
	datafile_experiment_owner CHAR(50),
	PRIMARY KEY (jid, datafile_name, datafile_experiment_name, datafile_experiment_owner),
	FOREIGN KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner)
	   REFERENCES datafile(name, experiment_name, experiment_owner)
	   ON DELETE CASCADE,
	FOREIGN KEY (jid) 
    	   REFERENCES job(id)
	   ON DELETE CASCADE
	) ENGINE=INNODB;


	/* I think this is DEPRECATED
           job just has_many datafiles
	create table out_datafile(
	jid INT NOT NULL REFERENCES job(id),
	datafile_name VARCHAR(50) REFERENCES datafile(name),
	datafile_experiment_name VARCHAR(50) REFERENCES datafile(experiment_name),
	datafile_experiment_owner CHAR(50) REFERENCES datafile(experiment_owner),
	PRIMARY KEY (jid, datafile_name, datafile_experiment_name, datafile_experiment_owner),
	FOREIGN KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner)
	   REFERENCES datafile(name, experiment_name, experiment_owner)
	) ENGINE=INNODB;*/


	create table queue(
	jid INT NOT NULL,
	pid INT,
	status ENUM ('QUEUED','PROCESSING','HALTED'),
	owner char(50),
	start_time DATETIME,
	PRIMARY KEY(jid),
	FOREIGN KEY (jid) 
           REFERENCES job(id)
           ON DELETE CASCADE,
	FOREIGN KEY (owner)
	   REFERENCES person(username)
	   ON DELETE CASCADE
	) ENGINE=INNODB;

 	/* an extension of the datafile table for image files 
	   deleted:src VARCHAR(200),
 	DEPRECATED - this is in the datatype definition
 	create table image_file(
 	datafile_name VARCHAR(50),
 	datafile_experiment_name VARCHAR(50),
 	datafile_experiment_owner CHAR(50),
 	path VARCHAR(100) NOT NULL,
 	height FLOAT,
 	width FLOAT,
        mime_type VARCHAR(100),
	PRIMARY KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner),
	FOREIGN KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner)
	   REFERENCES datafile(name, experiment_name, experiment_owner)
	   ON DELETE CASCADE
 	) ENGINE=INNODB;
        */

 	/* an extension of the datafile table for export files
 	   deleted: href VARCHAR(200)
   	   (DEPECATED : export_method VARCHAR(50) REFERENCES export_type)
          DEPRECATED: is in the datatype definition
 	create table export_file(
	datafile_name VARCHAR(50),
 	datafile_experiment_name VARCHAR(50),
 	datafile_experiment_owner CHAR(50),
	mime_type VARCHAR(100),
	PRIMARY KEY (datafile_name,datafile_experiment_name, datafile_experiment_owner),
	FOREIGN KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner)
           REFERENCES datafile(name, experiment_name, experiment_owner)
	   ON DELETE CASCADE
 	) ENGINE=INNODB;

	*/

 	/* Stores experiments 
 	removed while I have a think:
	root_datafile_name VARCHAR(50) NOT NULL REFERENCES datafile(name),
	*/
 	create table experiment(
 	name VARCHAR(50),
 	owner CHAR(50) NOT NULL,
	date_created DATE NOT NULL,
 	pubmed_id CHAR(30),
  	description TEXT,
	status ENUM('private','shared','public'),
        PRIMARY KEY (name,owner),
	FOREIGN KEY (owner) 
          REFERENCES person(username)
 	) ENGINE=INNODB;
   
        /* for sharing experiments */
        create table experiment_workgroup(
  	experiment_name VARCHAR(50) NOT NULL,
	experiment_owner CHAR(50) NOT NULL,
        workgroup VARCHAR(100) NOT NULL,
        PRIMARY KEY(experiment_name, experiment_owner,workgroup),
	FOREIGN KEY (experiment_name, experiment_owner)
 	   REFERENCES experiment(name, owner)
	   ON DELETE CASCADE,
	FOREIGN KEY (workgroup)
           REFERENCES workgroup(name)
           ON DELETE CASCADE
	) ENGINE=INNODB;


	/*Experimental Outcomes - eg. channels in an array expt, replicates etc*/
	create table outcome(
	name VARCHAR (50) NOT NULL,
	experiment_name VARCHAR(50) NOT NULL ,
	experiment_owner VARCHAR(50) NOT NULL,
	description VARCHAR(255),
	display_name VARCHAR(50),
	PRIMARY KEY (name, experiment_name, experiment_owner),
	FOREIGN KEY (experiment_name, experiment_owner)
	   REFERENCES experiment(name, owner)
           ON DELETE CASCADE
	) ENGINE=INNODB;

	/*Many to Many mapping between datafiles and outcomes*/
	create table outcome_datafile(
	outcome_name VARCHAR (50) NOT NULL,
	outcome_experiment_name VARCHAR(50) NOT NULL,
	outcome_experiment_owner VARCHAR(50) NOT NULL,
	datafile_name VARCHAR(50) NOT NULL,
 	datafile_experiment_name VARCHAR(50) NOT NULL,
 	datafile_experiment_owner CHAR(50) NOT NULL,
	PRIMARY KEY(outcome_name, outcome_experiment_name, outcome_experiment_owner, datafile_name, datafile_experiment_name, datafile_experiment_owner),
	FOREIGN KEY (outcome_name, outcome_experiment_name, outcome_experiment_owner)
	   REFERENCES outcome(name, experiment_name, experiment_owner)
           ON DELETE CASCADE,
	FOREIGN KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner)
           REFERENCES datafile(name, experiment_name, experiment_owner)
	   ON DELETE CASCADE
	) ENGINE=INNODB;


 	/*Discrete Independent Variables*/
 	create table factor(
 	name VARCHAR(50) NOT NULL,
 	owner CHAR(50) NOT NULL,
        description TEXT,
        status ENUM('private','shared','public'),
	tech_rep BOOLEAN DEFAULT 0,
        PRIMARY KEY (name, owner),
	FOREIGN KEY (owner)
    	   REFERENCES person(username)
 	) ENGINE=INNODB;

        /*Levels of Factors*/
 	create table level(
 	factor_name VARCHAR(50) NOT NULL,
        factor_owner CHAR(50) NOT NULL,
 	name VARCHAR(50) NOT NULL,
 	description TEXT,
        PRIMARY KEY (factor_name, factor_owner, name),
	FOREIGN KEY (factor_name, factor_owner)
	   REFERENCES factor(name, owner)
	   ON DELETE CASCADE
 	) ENGINE=INNODB;

	/*many to many mapping between outcome and level*/
	create table outcome_level(
	outcome_name VARCHAR (50) NOT NULL,
	outcome_experiment_name VARCHAR(50) NOT NULL,
	outcome_experiment_owner VARCHAR(50) NOT NULL,
	level_factor_name VARCHAR(50) NOT NULL,
        level_factor_owner CHAR(50) NOT NULL,
 	level_name VARCHAR(50) NOT NULL,
	PRIMARY KEY (outcome_name, outcome_experiment_name, outcome_experiment_owner, level_factor_name, level_factor_owner, level_name),
        FOREIGN KEY (outcome_name, outcome_experiment_name, outcome_experiment_owner)
	   REFERENCES outcome(name, experiment_name, experiment_owner)	
	   ON DELETE CASCADE,
	FOREIGN KEY (level_factor_name, level_factor_owner, level_name)
  	   REFERENCES level(factor_name, factor_owner, name)
	   ON DELETE CASCADE
	) ENGINE=INNODB;

	/*For sharing of factors with workgroups*/
 	create table factor_workgroup(
	factor_name VARCHAR(50) NOT NULL,
	factor_owner CHAR(50) NOT NULL,
	workgroup_name VARCHAR(100) NOT NULL,
	PRIMARY KEY (factor_name, factor_owner, workgroup_name),
	FOREIGN KEY (factor_name,factor_owner)
	   REFERENCES factor(name, owner)
           ON DELETE CASCADE,
	FOREIGN KEY (workgroup_name)
           REFERENCES workgroup(name)
	   ON DELETE CASCADE
	) ENGINE=INNODB;	


	/*Continuous Independent Variables*/
	create table cont_var(
	name VARCHAR(50) NOT NULL,
 	owner CHAR(50) NOT NULL,
        description TEXT,
        status ENUM('private','shared','public'),
        PRIMARY KEY (name, owner),
	FOREIGN KEY (owner)
  	   REFERENCES person(username)
	) ENGINE=INNODB;

	/*Values of continuous variables*/
	create table cont_var_value(
	cont_var_name VARCHAR(50) NOT NULL,
        cont_var_owner CHAR(50) NOT NULL,
	outcome_name VARCHAR (50) NOT NULL,
	outcome_experiment_name VARCHAR(50) NOT NULL,
	outcome_experiment_owner VARCHAR(50) NOT NULL,
	value VARCHAR(255),
	PRIMARY KEY (cont_var_name, cont_var_owner, outcome_name, outcome_experiment_name, outcome_experiment_owner),
	FOREIGN KEY (cont_var_name, cont_var_owner)
 	   REFERENCES cont_var(name, owner),
	FOREIGN KEY (outcome_name, outcome_experiment_name, outcome_experiment_owner)
	   REFERENCES outcome(name, experiment_name, experiment_owner)
	   ON DELETE CASCADE
	) ENGINE=INNODB;

        /*Factors used in an experiment*/
 	create table factor_experiment(
 	factor_name VARCHAR(50) NOT NULL,
 	factor_owner CHAR(50) NOT NULL,
 	experiment_name VARCHAR(50) NOT NULL,
 	experiment_owner CHAR(50) NOT NULL,
        PRIMARY KEY (factor_name, factor_owner, experiment_name, experiment_owner),
	FOREIGN KEY (factor_name, factor_owner)
	   REFERENCES factor(name, owner),
	FOREIGN KEY (experiment_name, experiment_owner)
	   REFERENCES experiment(name, owner)
	   ON DELETE CASCADE
 	) ENGINE=INNODB;

        /*Continuous Variables used in an experiment*/
 	create table cont_var_experiment(
 	cont_var_name VARCHAR(50) NOT NULL,
        cont_var_owner CHAR(50) NOT NULL,
 	experiment_name VARCHAR(50) NOT NULL,
 	experiment_owner CHAR(50) NOT NULL,
        PRIMARY KEY (cont_var_name, cont_var_owner, experiment_name, experiment_owner),
	FOREIGN KEY (cont_var_name, cont_var_owner)
	   REFERENCES cont_var(name, owner),
	FOREIGN KEY (experiment_name, experiment_owner)
	   REFERENCES experiment(name, owner)
	   ON DELETE CASCADE
 	) ENGINE=INNODB;

	
	/*For sharing of continuous variables with workgroups*/
 	create table cont_var_workgroup(
	cont_var_name VARCHAR(50) NOT NULL,
	cont_var_owner CHAR(50) NOT NULL,
	workgroup_name VARCHAR(100) NOT NULL,
	PRIMARY KEY (cont_var_name, cont_var_owner, workgroup_name),
	FOREIGN KEY (cont_var_name, cont_var_owner)
	   REFERENCES cont_var(name, owner),
	FOREIGN KEY (workgroup_name) 
	   REFERENCES workgroup(name)
	   ON DELETE CASCADE  
	) ENGINE=INNODB;	



 	/* Classes of statistics. Not implemented yet. 
           Still pondering how to deal with this
 	create table stat_class(
 	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
 	name CHAR(50) NOT NULL,
 	description VARCHAR(100),
 	multi_level ENUM('0','1'),
 	multi_fac ENUM('0','1')
 	) ENGINE=INNODB;*/










