       /* User details . Why 'active'?*/
        create table person(
 	username CHAR(50) NOT NULL PRIMARY KEY,
 	forename CHAR(30),
 	surname CHAR(30),
 	institution CHAR(50),
 	address CHAR(100),
 	password VARCHAR(50) NOT NULL,
 	email VARCHAR(50) NOT NULL,
  	experiment_name VARCHAR(50) REFERENCES experiment(name),
	experiment_owner CHAR(50)  REFERENCES experiment(owner),
        datafile_name VARCHAR(50)  REFERENCES datafile(name),
 	created DATE,
        active INT,
        data_dir VARCHAR(255),
        upload_dir VARCHAR(255),
        static_dir VARCHAR(255)
 	);

        /* Entries in here are deleted as soon as a user has been approved */ 	
 	create table person_pending(
 	username CHAR(50) NOT NULL PRIMARY KEY REFERENCES person(usename),
 	email_id TEXT NOT NULL,
 	user_approved ENUM('0','1'),
 	admin_approved ENUM('0','1')
 	);

  	/*Roles a user can have - Controls access to components*/
 	create table role (
 	name VARCHAR(100) NOT NULL PRIMARY KEY,
 	description TEXT
 	); 	

        /* Mapping between person and role */
  	create table person_role (
 	person CHAR(50) NOT NULL  REFERENCES person(username),
 	role VARCHAR(100) NOT NULL  REFERENCES role(id),
        PRIMARY KEY(person,role)
 	);

        /*Workgroups of which user can be a member - Controls access to data*/
        create table workgroup(
        name VARCHAR(100) NOT NULL PRIMARY KEY,
        description TEXT,
        leader CHAR(50) NOT NULL REFERENCES person(username)
        );

        /* Mapping between person and workgroup*/
        create table person_workgroup(
        person CHAR(50) NOT NULL REFERENCES person(username),
        workgroup VARCHAR(100) NOT NULL REFERENCES workgroup(name),
	PRIMARY KEY (person, workgroup)
        );
      
       /* Stores join requests for workgroups
          Contents moved to person_workgroup on admin approval
        */
	create table workgroup_join_request(
        person CHAR(50) NOT NULL REFERENCES person(username),
        workgroup VARCHAR(100) NOT NULL REFERENCES workgroup(name),
	PRIMARY KEY (person, workgroup)
	);
	
	/* Stores invites for workgroups
	   Contents moved to person_workgroup on user approval
	*/
	create table workgroup_invite(
        person CHAR(50) NOT NULL REFERENCES person(username),
        workgroup VARCHAR(100) NOT NULL REFERENCES workgroup(name),
	PRIMARY KEY (person, workgroup)
	);

        /* Datatypes. Generally R/Bioconductor classes, like expressionSet. 
           This is the information used to determine whether the output of 
           one component can be used as input to another component.*/
 	create table datatype(
 	name VARCHAR(50) NOT NULL PRIMARY KEY,
 	description VARCHAR(100),
        default_blurb TEXT
 	);

        /* Define any inheritance relationships between datatypes in here, for
           example AffyBatch is an exprSet, or QCPlot isa ImageFile. */	
 	create table datatype_relationship(
  	child VARCHAR(50) NOT NULL REFERENCES datatype(name),
 	parent VARCHAR(50) NOT NULL REFERENCES datatype(name),
        PRIMARY KEY(child,parent)
 	);

        /*A comprehensive list of export types, eg PDF, TDT, EXCEL etc.*/
 	create table export_method(
 	name VARCHAR(50) NOT NULL PRIMARY KEY,
 	description TEXT,
        extension VARCHAR(10)
 	);

        /* Export methods for datatypes are actually defined in R, and perl isn't
           aware of them. I decided it was easier to keep a note of them in the 
           database, rather than perl calling R every time it wanted a list of 
           export possibilities. */
 	create table datatype_export_method(
  	datatype VARCHAR(50) NOT NULL REFERENCES datatype(name),
 	export_method VARCHAR(50) NOT NULL REFERENCES export_method(name),
        PRIMARY KEY (datatype, export_method) 
	);

        /* Processes correspond to individual R templates */
 	create table process(
 	name VARCHAR(50) NOT NULL PRIMARY KEY,
 	tmpl_file VARCHAR(50),
 	description TEXT,
 	);

        /* What datatypes can the process accept? The required field can be 
           defines whether a file of this datatype is required for the process, 
           the required_number defines how may of these files are required for the 
           process. require_number will be ignored if required is false.
           To be honest, this is still pretty unstable. Unless you're feeling brave
           I'd stick to components which only require one datafile of one datatype.
        */
 	create table process_accepts(
  	process VARCHAR(50) NOT NULL REFERENCES process(name),
 	accepts VARCHAR(50) NOT NULL REFERENCES datatype(name),
        PRIMARY KEY (process, accepts)
 	);

        /* The datatype(s) of the datafile this process creates. */
 	create table process_creates(
 	process VARCHAR(50) NOT NULL REFERENCES process(name),
 	creates VARCHAR(50) NOT NULL REFERENCES datatype(name),
        num INT DEFAULT 1,
        PRIMARY KEY (process, creates)
 	);

        /* Registered components. The idea (though not implemented yet) is
           that you'll be able to run multiple ROME instances with different 
           components, from the same ROME directory. */
 	create table component(
 	name VARCHAR(50) NOT NULL PRIMARY KEY,
 	href VARCHAR(50) NOT NULL,
 	always_active BOOLEAN NOT NULL DEFAULT '0'
 	);

        /* Link components to processes. Generally a component should only
           need to run a single process, but occasionally you need more than one */
 	create table component_process(
 	component VARCHAR(50) NOT NULL REFERENCES component(name),
 	process VARCHAR(50) NOT NULL REFERENCES process(name),
        PRIMARY KEY (component,process)
	);

        /* Parameters that are used by components. This lets us auto-generate a lot
           of the interface and keep track of exactly what has been done to generate
           a given datafile */
 	create table parameter(
 	name VARCHAR(50) NOT NULL,
	process VARCHAR(50) NOT NULL REFERENCES process(name),
 	description VARCHAR(100),
	PRIMARY KEY (name, process)
 	);


 	/*Stores all the datafiles*/
 	create table datafile(
 	name VARCHAR(50),
 	experiment_name VARCHAR(50) REFERENCES experiment(name),
 	experiment_owner CHAR(50) REFERENCES experiment(owner),
 	description TEXT,
 	process VARCHAR(50) REFERENCES process(name),
 	path VARCHAR(100) NOT NULL,
 	datatype varchar(50) NOT NULL REFERENCES datatype(name),
	status ENUM('private','shared','public'),
	PRIMARY KEY (name, experiment_name, experiment_owner)
 	);

        /* for sharing datafiles */
        create table datafile_workgroup(
 	datafile_name VARCHAR(50) NOT NULL REFERENCES datafile(name),
 	datafile_experiment_name VARCHAR(50)NOT NULL REFERENCES datafile(experiment_name),
 	datafile_experiment_owner CHAR(50) NOT NULL REFERENCES datafile(experiment_owner),
        workgroup VARCHAR(100) NOT NULL REFERENCES workgroup(name),
        PRIMARY KEY (datafile_name, datafile_experiment_name, datafile_experiment_owner, workgroup)
	);

        /* keeps track of the relationships between datafiles. 
           In principle, a datafile could have many parents and many children
           but I'm avoiding the many parents wherever possible.*/
 	create table datafile_relationship(
 	parent_datafile_name VARCHAR(50) NOT NULL REFERENCES datafile(name),
 	parent_datafile_experiment_name VARCHAR(50)NOT NULL REFERENCES datafile(experiment_name),
 	parent_datafile_experiment_owner CHAR(50) NOT NULL REFERENCES datafile(experiment_owner),
 	child_datafile_name VARCHAR(50) NOT NULL REFERENCES datafile(name),
 	child_datafile_experiment_name VARCHAR(50)NOT NULL REFERENCES datafile(experiment_name),
 	child_datafile_experiment_owner CHAR(50) NOT NULL REFERENCES datafile(experiment_owner),
        PRIMARY KEY (parent_datafile_name, parent_datafile_experiment_name, parent_datafile_experiment_owner, child_datafile_name, child_datafile_experiment_name, child_datafile_experiment_owner)
 	);

 	/* Stores the values of parameters used in the process which 
           generated the datafile. */ 	
 	create table datafile_parameter(
 	datafile_name VARCHAR(50) NOT NULL REFERENCES datafile(name),
 	datafile_experiment_name VARCHAR(50)NOT NULL REFERENCES datafile(experiment_name),
 	datafile_experiment_owner CHAR(50) NOT NULL REFERENCES datafile(experiment_owner),
 	value VARCHAR(100) NOT NULL,
	parameter VARCHAR(50) NOT NULL REFERENCES parameter(name),
        PRIMARY KEY (datafile_name,datafile_experiment_name, datafile_experiment_owner, parameter)
 	);


 	/* this is an extension of the datafile table
           allows us to store placeholder datafiles while processes are being run,
           which means we can queue up processes on the placeholder datafile. */
 	create table datafile_pending(
 	datafile_name VARCHAR(50) NOT NULL REFERENCES datafile(name),
 	datafile_experiment_name VARCHAR(50)NOT NULL REFERENCES datafile(experiment_name),
 	datafile_experiment_owner CHAR(50) NOT NULL REFERENCES datafile(experiment_owner),
        PRIMARY KEY(datafile_name, datafile_experiment_name, datafile_experiment_owner)
 	);


 	/* This is the process queue. */
 	create table process_pending(
 	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
 	processor VARCHAR(100),
 	script VARCHAR(100),
 	status ENUM ('QUEUED','PROCESSING','HALTED','COMPLETE'),
 	error TEXT,
 	start_time DATETIME,
 	pid INT,
 	datafile INT REFERENCES datafile(id),
 	person CHAR(50) REFERENCES person(username),
 	process VARCHAR(50) REFERENCES process(name),
 	experiment INT REFERENCES experiment(id)
 	);

 	/* an extension of the datafile table for image files */
 	create table image_file(
 	id INT NOT NULL PRIMARY KEY,
 	src VARCHAR(200),
 	height FLOAT,
 	width FLOAT
 	);


 	/* an extension of the datafile table for export files */
 	create table export_file(
 	id INT NOT NULL PRIMARY KEY,
 	href VARCHAR(200),
 	export_method VARCHAR(50) REFERENCES export_type
 	);

 	/* Stores experiments */
 	create table experiment(
 	name VARCHAR(50),
 	owner CHAR(50) NOT NULL REFERENCES person(username),
	date_created DATE NOT NULL,
 	pubmed_id CHAR(30),
  	description TEXT,
 	root_datafile_name VARCHAR(50) NOT NULL REFERENCES datafile(name),
	status ENUM('private','shared','public'),
        PRIMARY KEY (name,owner)
 	);
   
        /* for sharing experiments */
        create table experiment_workgroup(
  	experiment_name VARCHAR(50) NOT NULL REFERENCES experiment(name),
	experiment_owner CHAR(50) NOT NULL REFERENCES experiment(owner),
        workgroup VARCHAR(100) NOT NULL REFERENCES workgroup(name),
        PRIMARY KEY(experiment_name, experiment_owner,workgroup)
	);


 	/*Experimental Factors*/
 	create table factor(
 	name VARCHAR(50) NOT NULL,
 	owner CHAR(50) NOT NULL REFERENCES person(username),
        description TEXT,
        continuous BOOLEAN DEFAULT 0,
        status ENUM('private','shared','public'),
        PRIMARY KEY (name, owner)
 	);

        /*Levels of Experimental Factors*/
 	create table level(
 	factor_name VARCHAR(50) NOT NULL REFERENCES factor(name),
        factor_owner CHAR(50) NOT NULL REFERENCES factor(owner),
 	name VARCHAR(50) NOT NULL,
 	description TEXT,
        PRIMARY KEY (factor_name, factor_owner, name)
 	);

        /*Experimental Treatments */
 	create table treatment(
 	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
 	name VARCHAR(100),
 	description VARCHAR(100)
 	);

        /*The levels of factors used in treatments*/
 	create table treatment_level(
 	treatment INT NOT NULL REFERENCES treatment(id),
 	level INT NOT NULL REFERENCES level(id),
        PRIMARY KEY (treatment,level)
 	);

        /*Factors used in an experiment*/
 	create table factor_experiment(
 	factor_name VARCHAR(50) NOT NULL REFERENCES factor(name),
 	factor_owner CHAR(50) NOT NULL REFERENCES factor(owner),
 	experiment_name VARCHAR(50) NOT NULL REFERENCES experiment(name),
 	experiment_owner CHAR(50) NOT NULL REFERENCES experiment(owner),
        PRIMARY KEY (factor_name, factor_owner, experiment_name, experiment_owner)
 	);

 	/* Classes of statistics. Not implemented yet. 
           Still pondering how to deal with this*/
 	create table stat_class(
 	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
 	name CHAR(50) NOT NULL,
 	description VARCHAR(100),
 	multi_level ENUM('0','1'),
 	multi_fac ENUM('0','1')
 	);










