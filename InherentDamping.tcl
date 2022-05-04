# ######################################
# ---- Inherent Damping
# ######################################
if {$Damping == "Rayleigh" } {
	# Computing Eigenvectors (modes)
	set lambda [eigen -fullGenLapack $numeigs]
	#
	#puts "The natural frequencies are $lambda"
	set pi 3.1416
	foreach lam $lambda {
	lappend freq 	[expr sqrt($lam)]
	lappend period	[expr 2*$pi/sqrt($lam)]
	
}

	set wi [lindex $freq [expr $Ti-1]]
	set wj [lindex $freq [expr $Tj-1]]

	set alphaM [expr 2*$zi*$wi*$wj/($wi+$wj)]
	set betaK  [expr 2*$zi/($wi+$wj)]

	
# # Applying rayleigh damping
# rayleigh $alphaM $betaK $betaKinit $betaKcomm
	if {$RayleighStiffness == "Initial"} { 
		rayleigh $alphaM 0 $betaK 0
		unset freq period
	} elseif {$RayleighStiffness == "Current"} { 
		rayleigh $alphaM $betaK 0 0
		unset freq period
	}
} elseif {$Damping == "Modal"} {

	# Modal Damping 
	eigen $numeigs
	modalDamping $zi
}

