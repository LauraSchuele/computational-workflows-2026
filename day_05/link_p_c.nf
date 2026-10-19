#!/usr/bin/env nextflow

process SPLITLETTERS {
    input:
    tuple val(meta), val(input_str), val(out_name) // nextflow matches them by position

    output:
    tuple val(meta), path("${out_name}_*") // warum hier *?

    script:
    """
    printf '%s' "${input_str}" | split -b ${meta.block_size} - ${out_name}_
    """
} 

process CONVERTTOUPPER {

    input:
    path chunk_file

    output:
    stdout

    script:
    """
    tr '[:lower:]' '[:upper:]' < ${chunk_file}
    """
}



workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet}
    in_ch = channel.fromPath('samplesheet_2.csv') // create a channel
        .splitCsv(header: true) // channel reads in the data, header: tru so we get column names for each row
        .map {v ->  // make block_size the meta-map, similar to advanced_cannel_operations step 2
                [
                [block_size: v.block_size],
                            v.input_str,
                            v.out_name
                ]
                
            }
     // in_ch.view()

    // split the input string into chunks
    split_ch = SPLITLETTERS(in_ch)

    // lets remove the metamap to make it easier for us, as we won't need it anymore
    files_ch = split_ch
        .map { meta, files -> files }
        .flatten() // warum hier flatten? flatten the list to multiple items 
    files_ch.view() // view the files
    // convert the chunks to uppercase and save the files to the results directory
    upper_ch = CONVERTTOUPPER(files_ch)

    upper_ch.view()


}