###############################################################################
#
# readAT2file
#
# written by Andrew Hardyniec
#
# Adapted from:
#
# Written: MHS
# Date: July 2000
# A procedure which parses a ground motion record from the PEER strong motion database by finding dt in the record header, then
# echoing data values to the output file. Formal arguments
#
#   inFilename -- file which contains PEER strong motion record
#   outFilename -- file to be written in format G3 can read
#   dt -- time step determined from file header
#
# Assumptions
#
#   The header in the PEER record is, e.g., formatted as follows:
#     PACIFIC ENGINEERING AND ANALYSIS STRONG-MOTION DATA
#   IMPERIAL VALLEY 10/15/79 2319, EL CENTRO ARRAY 6, 230
#   ACCELERATION TIME HISTORY IN UNITS OF G
#   3930    .0050    NPTS, DT
#
#
#  Code presented on page 415 of the OpenSees Manual
#
###############################################################################

proc readAT2file {inFilename outFilename dt npts} {

	# Pass dt by reference
	upvar $npts NPTS
	upvar $dt DT

	# Open the input file and catch the error if it can't be read
	if [catch {open $inFilename r+} inFileID] {

		puts stderr "Cannot open $inFilename for reading"

	} else {

		# Open output file for writing
		set outFileID [open $outFilename w]

		# Flag indicating dt is found and that ground motion
		# values should be read -- ASSUMES dt is on last line
		# of header!!!
		set flag 0

		# Look at each line in the file
		foreach line [split [read $inFileID] \n] {

			if {[llength $line] == 0} {

				# Blank line --> do nothing
				continue

			} elseif {$flag == 1} {

				# Echo ground motion values to output file
				puts $outFileID $line

			} else {

				# Search header lines for dt
				foreach word $line {

					# Find the desired token and set the flag
					if {[string match $word NPTS,]} {

						set NPTS [lindex $line 0]  ;  # Assumes NPTS is the first value in the line
						set DT [lindex $line 1]  ;  # Assumes DT is the second value in the line
						set flag 1

					}

				}

			}

		}

	# Close the output file
	close $outFileID

	# Close the input file
	close $inFileID

	}
}  ;  # end proc readAT2file