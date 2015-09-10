#!/usr/bin/env bash
#
# Give me a subject id (PGS_ID)
# and I'll give you rest preprocessed in a folder for that subject
#



set -xe
scriptdir=$(cd $(dirname $0);pwd)

## where to put the preproc data
ppdir=$scriptdir/PGSPreprocess_Anat/Wave6
[ ! -d $subjdir ] && mkdir $ppdir


## where to find the raw data
rawroot="$scriptdir/../UPitt/wave6"

subjdate=$1
[ -z "$subjdate" ] && echo "give me a subj!" && exit 1

## did we already run this?
#  was it a successful run?

finaldir="$ppdir/$subjdate"
finaloutname="$finaldir/mpragei_final.nii.gz"
[ -r $finaloutname ] &&  echo "$subjdate: already successful completed" && exit 0
[ -d $finaldir ] &&  echo -e "$subjdate: have $finaldir but not $finaloutname;\n to try again, remove $finaldir" && exit 1



# do we have mprage dicoms?
subt1dir="$rawroot/$subjdate/Anat/"
[ ! -d $subt1dir ] && echo "no mprage dicom dir ($subt1dir) for $subjdate!" && exit 1

#great then copy dicoms to raj's folder so as not to disrupt original ones
#create preproc directory
[ ! -d $finaldir ] && mkdir $finaldir
cp $subt1dir/MR* $finaldir

#go to that directory to preprocess images
cd $finaldir

#Convert dicoms to nifti using Dimon
Dimon -infile_pattern "MR*" -GERT_Reco -quit -dicom_org -sort_by_acq_time -gert_write_as_nifti -gert_create_dataset -gert_to3d_prefix mprage 

#zip as nifti
gzip -f mprage.nii

#archive dicoms
tar czf mprage_dicom.tar.gz MR*
rm -f MR* 

#now that we have mprage.nii.gz, crop the neck
strucnifti="$finaldir/mprage.nii.gz"

#crop neck 
robustfov -i $strucnifti -r mprage_crop.nii.gz

#now that we have mprage_crop, run preprocess
struccrop="$finaldir/mprage_crop.nii.gz"


### HAVE EVERYTHING we need to preprocess



# run preprocesssMprage for structural scan
preprocessMprage -n $struccrop -r MNI_2mm -b "-R" -o mprage_final.nii.gz \

[ ! -r $finaloutname ] &&  echo "$subjdate: failed to create $finaloutname!" && exit 1
