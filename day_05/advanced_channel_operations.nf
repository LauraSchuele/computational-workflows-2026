params {
    step: Integer = 0
}


workflow{

    // Task 1 - Read in the samplesheet.

    if (params.step == 1) {
        channel.fromPath('samplesheet.csv') // create a channel
            .splitCsv(header: true) // channel reads in the data, header: tru so we get column names for each row
            .view()
    }

    // Task 2 - Read in the samplesheet and create a meta-map with all metadata and another list with the filenames ([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
    //          Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

    if (params.step == 2) {
        in_ch = channel.fromPath('samplesheet.csv')  // again create channel, but here output to new channel later
            .splitCsv(header: true) 
            .map { v ->[ // v is one row
                [sample: v.sample, strandedness: v.strandedness], // list with metadata
                [v.fastq_1, v.fastq_2] // list with file names
            ]
        }
        in_ch.view() // output to new channel
    }

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently. 
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

if (params.step == 3) {

    in_ch = channel.fromPath('samplesheet.csv')
        .splitCsv(header: true)
        .map { v ->
            [
                [sample: v.sample, strandedness: v.strandedness],
                [v.fastq_1, v.fastq_2]
            ]
        }

    split_ch = in_ch.branch { meta, reads ->  // we have the two lists as input
        auto:    meta.strandedness == 'auto'  // split into three channels
        forward: meta.strandedness == 'forward'
        reverse: meta.strandedness == 'reverse'
    }

    split_ch.auto.view { "AUTO: $it" } // $it = item of the channel
    split_ch.forward.view { "FORWARD: $it" }
    split_ch.reverse.view { "REVERSE: $it" }
}

    // Task 4 - Group together all files with the same sample-id and strandedness value.

    if (params.step == 4) {
            in_ch = channel.fromPath('samplesheet.csv')
        .splitCsv(header: true)
        .map { v ->
            [
                [sample: v.sample, strandedness: v.strandedness],
                [v.fastq_1, v.fastq_2]
            ]
        }

    in_ch
        .groupTuple()
        .view()
    }



}