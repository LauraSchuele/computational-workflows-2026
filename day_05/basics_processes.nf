params {
    step: Integer = 0
    zip: String = 'zip' // defines that the default for zip parameter is the string zip
}

// Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be able to print the output to the console)
process SAYHELLO {
    debug true // depug true is needed so the message appears in the output. Directives: Optional settings controlling execution, such as debug, cpus or publishDir.

    // in a general process we would define also inout and output here, but in this task we dont need to

    // define script (Contains the command or shell script that Nextflow executes.)
    script:
    """
    echo "Hello World!"
    """
}

// Task 2 - create a process that says Hello World! using Python
process SAYHELLO_PYTHON {
    debug true

    script:
    """
    python -c "print('Hello World!')"
     
    """
}

// Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
process SAYHELLO_PARAM {
    debug true

    input:
    val greeting // we have val (value) as input (string or number)
    // we take the string from channel and asign it to the variable greeting

    script:
    """
    echo "${greeting}"
    """
}

// Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
process SAYHELLO_FILE {
    //debug true

    input:
    val greeting 

    script:
    """
    echo "${greeting}" > hello.txt  

    """
    // echo "$greeting" > hello.txt 
    // writes it out into separated wd inside the work folder
}

// Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
process UPPERCASE{
    debug true

    input:
    val greeting

    output:
    path 'uppercase.txt'

    script:
    """
    python -c "print('${greeting}'.upper())" > uppercase.txt
    """
}

// Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
process PRINTUPPER{
    debug true

    input:
    path file

    script:
    """
    cat $file
    """
}

// Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
//          Print out the path to the zipped file in the console
process COMPRESS {

    input:
    path input_file

    output:
    path 'uppercase.txt.*'

    script:
    """
    if [ "${params.zip}" = "zip" ]; then
        zip uppercase.txt.zip ${input_file}

    elif [ "${params.zip}" = "gzip" ]; then
        gzip -c ${input_file} > uppercase.txt.gz

    elif [ "${params.zip}" = "bzip2" ]; then
        bzip2 -c ${input_file} > uppercase.txt.bz2

    else
        echo "Unsupported compression format"
        exit 1
    fi
    """
}


// Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console
process COMPRESS_ALL {

    input:
    path input_file

    output:
    path 'uppercase.txt.*'

    script:
    """
    zip uppercase.txt.zip ${input_file}
    gzip -c ${input_file} > uppercase.txt.gz
    bzip2 -c ${input_file} > uppercase.txt.bz2
    """
}


// Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
//          Store the file in the "results" directory under the name "names.tsv"
process WRITETOFILE {

    publishDir 'results', mode: 'copy' //  use the publishDir directive to have output files also in a specific path of your choice. I
    // Note: we should not use this for writing new pipeline!
    // in tutorial they said that this is an old way and in newer versions we would do this on the workflow and output level:
    // https://training.nextflow.io/latest/de/hello_nextflow/01_hello_world/
    // example from tutorial:
    // output{
    //   first_output{
    //        path 'hello_world'
    //        mode 'copy'
    //  }
    //} 

    input:
    val people

    output:
    path 'names.tsv'

    script:
    def rows = people.collect {
        "${it.name}\t${it.title}"
    }.join('\n')

    def content = "name\ttitle\n${rows}"

    """
    printf '%s\\n' '${content}' > names.tsv
    """
}



workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    // here we define the parameter when calling the process! We can define it here or as a default in the params block
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }


    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
        uppercase_ch = UPPERCASE(greeting_ch)
        compressed_ch = COMPRESS(uppercase_ch)
        compressed_ch.view()
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console
    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        uppercase_ch = UPPERCASE(greeting_ch)
        compressed_ch = COMPRESS_ALL(uppercase_ch)
        compressed_ch.view()
    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )

        in_ch
            collected_ch = in_ch.collect()
            out_ch = WRITETOFILE(collected_ch)
            out_ch.view()
    }
}